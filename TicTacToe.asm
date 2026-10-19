# BITMAP DISPLAY SETUP
#   Unit Width/Height: 4 pixels
#   Display Width/Height: 256
#   Base Address: 0x10010000 Then Connect to MIPS

.data 0x10010000
screen:         .space 16384
board:          .word 0,0,0,0,0,0,0,0,0
input_buffer:   .space 64

winning_lines:  .byte 0,1,2, 3,4,5, 6,7,8
                .byte 0,3,6, 1,4,7, 2,5,8
                .byte 0,4,8, 2,4,6

digit_font:     .byte 2,6,2,2,7
                .byte 7,1,7,4,7
                .byte 7,1,7,1,7
                .byte 5,5,7,1,1
                .byte 7,4,7,1,7
                .byte 7,4,7,5,7
                .byte 7,1,1,2,2
                .byte 7,5,7,5,7
                .byte 7,5,7,1,7

instructions:   .asciiz "\n=== TIC-TAC-TOE ===\nTwo players: X (blue) and O (orange). X goes first.\nEnter the number of an empty square, then press Enter.\n\n 1 | 2 | 3\n---+---+---\n 4 | 5 | 6\n---+---+---\n 7 | 8 | 9\n\nGet three in a row, column, or diagonal to win.\nEnter 0 during a turn to quit.\n"
prompt_x:       .asciiz "\nPlayer X - choose 1-9 (0 quits): "
prompt_o:       .asciiz "\nPlayer O - choose 1-9 (0 quits): "
invalid_move:   .asciiz "Invalid input. Enter one digit from 1 to 9, or 0 to quit.\n"
occupied:       .asciiz "That square is occupied. Choose an empty square.\n"
x_wins:         .asciiz "\nPlayer X wins! The green border marks the finished game.\n"
o_wins:         .asciiz "\nPlayer O wins! The green border marks the finished game.\n"
tie_message:    .asciiz "\nIt is a tie! The yellow border marks the finished game.\n"
replay_prompt:  .asciiz "Play again? Enter 1 for yes or 0 to quit: "
invalid_replay: .asciiz "Invalid input. Enter 1 or 0.\n"
goodbye:        .asciiz "\nThanks for playing!\n"

.text
.globl main
main:
    li    $v0, 4
    la    $a0, instructions
    syscall

new_game:
    jal   init_game
    nop
    li    $s0, 1
    li    $s1, 0
    jal   draw_board
    nop

turn_loop:
    move  $a0, $s0
    jal   print_turn
    nop
    jal   read_digit
    nop
    beqz  $v0, quit_game
    nop
    blt   $v0, 1, bad_move
    nop
    bgt   $v0, 9, bad_move
    nop

    addiu $t0, $v0, -1
    sll   $t0, $t0, 2
    la    $t1, board
    addu  $t1, $t1, $t0
    lw    $t2, 0($t1)
    bnez  $t2, occupied_move
    nop
    sw    $s0, 0($t1)
    addiu $s1, $s1, 1
    jal   draw_board
    nop
    jal   check_winner
    nop
    bnez  $v0, player_won
    nop
    beq   $s1, 9, game_tied
    nop

    xori  $s0, $s0, 3
    j     turn_loop
    nop

bad_move:
    li    $v0, 4
    la    $a0, invalid_move
    syscall
    j     turn_loop
    nop

occupied_move:
    li    $v0, 4
    la    $a0, occupied
    syscall
    j     turn_loop
    nop

player_won:
    li    $a0, 0x0022c55e
    jal   draw_border
    nop
    la    $a0, x_wins
    beq   $s0, 1, print_result
    nop
    la    $a0, o_wins
    j     print_result
    nop

game_tied:
    li    $a0, 0x00facc15
    jal   draw_border
    nop
    la    $a0, tie_message

print_result:
    li    $v0, 4
    syscall

replay_loop:
    li    $v0, 4
    la    $a0, replay_prompt
    syscall
    jal   read_digit
    nop
    beqz  $v0, quit_game
    nop
    beq   $v0, 1, new_game
    nop
    li    $v0, 4
    la    $a0, invalid_replay
    syscall
    j     replay_loop
    nop

quit_game:
    li    $v0, 4
    la    $a0, goodbye
    syscall
    li    $v0, 10
    syscall

init_game:
    la    $t0, board
    li    $t1, 9
init_loop:
    sw    $zero, 0($t0)
    addiu $t0, $t0, 4
    addiu $t1, $t1, -1
    bnez  $t1, init_loop
    nop
    jr    $ra
    nop

print_turn:
    beq   $a0, 1, print_x_turn
    nop
    la    $a0, prompt_o
    j     print_turn_message
    nop
print_x_turn:
    la    $a0, prompt_x
print_turn_message:
    li    $v0, 4
    syscall
    jr    $ra
    nop

read_digit:
    la    $a0, input_buffer
    sb    $zero, 62($a0)
    li    $a1, 64
    li    $v0, 8
    syscall
    la    $t0, input_buffer
    lbu   $t1, 62($t0)
    bnez  $t1, read_invalid
    nop
read_leading_space:
    lbu   $t1, 0($t0)
    beq   $t1, 32, read_skip_space
    nop
    beq   $t1, 9, read_skip_space
    nop
    blt   $t1, 48, read_invalid
    nop
    bgt   $t1, 57, read_invalid
    nop
    addiu $t3, $t1, -48
    addiu $t0, $t0, 1
    j     read_trailing_space
    nop
read_skip_space:
    addiu $t0, $t0, 1
    j     read_leading_space
    nop
read_trailing_space:
    lbu   $t1, 0($t0)
    beqz  $t1, read_valid
    nop
    beq   $t1, 32, read_next_space
    nop
    beq   $t1, 9, read_next_space
    nop
    beq   $t1, 10, read_next_space
    nop
    beq   $t1, 13, read_next_space
    nop
    j     read_invalid
    nop
read_next_space:
    addiu $t0, $t0, 1
    j     read_trailing_space
    nop
read_valid:
    move  $v0, $t3
    jr    $ra
    nop
read_invalid:
    li    $v0, -1
    jr    $ra
    nop

check_winner:
    la    $t0, winning_lines
    li    $t1, 8
    la    $t2, board
winner_loop:
    lbu   $t3, 0($t0)
    sll   $t3, $t3, 2
    addu  $t3, $t3, $t2
    lw    $t3, 0($t3)
    beqz  $t3, winner_next
    nop
    lbu   $t4, 1($t0)
    sll   $t4, $t4, 2
    addu  $t4, $t4, $t2
    lw    $t4, 0($t4)
    bne   $t3, $t4, winner_next
    nop
    lbu   $t5, 2($t0)
    sll   $t5, $t5, 2
    addu  $t5, $t5, $t2
    lw    $t5, 0($t5)
    bne   $t3, $t5, winner_next
    nop
    move  $v0, $t3
    jr    $ra
    nop
winner_next:
    addiu $t0, $t0, 3
    addiu $t1, $t1, -1
    bnez  $t1, winner_loop
    nop
    li    $v0, 0
    jr    $ra
    nop

draw_board:
    addiu $sp, $sp, -40
    sw    $ra, 36($sp)
    sw    $s0, 32($sp)
    sw    $s1, 28($sp)
    sw    $s2, 24($sp)
    sw    $s3, 20($sp)
    jal   clear_and_grid
    nop
    li    $s0, 0
    la    $s1, board
draw_cell_loop:
    li    $t0, 3
    div   $s0, $t0
    mflo  $t1
    mfhi  $t2
    mul   $s2, $t2, 21
    mul   $s3, $t1, 21
    lw    $a2, 0($s1)
    bnez  $a2, draw_filled_cell
    nop
    addiu $a0, $s2, 9
    addiu $a1, $s3, 8
    addiu $a2, $s0, 1
    jal   draw_digit
    nop
    j     draw_next_cell
    nop
draw_filled_cell:
    addiu $a0, $s2, 3
    addiu $a1, $s3, 3
    jal   draw_symbol
    nop
draw_next_cell:
    addiu $s0, $s0, 1
    addiu $s1, $s1, 4
    blt   $s0, 9, draw_cell_loop
    nop
    lw    $s3, 20($sp)
    lw    $s2, 24($sp)
    lw    $s1, 28($sp)
    lw    $s0, 32($sp)
    lw    $ra, 36($sp)
    addiu $sp, $sp, 40
    jr    $ra
    nop

clear_and_grid:
    li    $t0, 0
    la    $t2, screen
grid_row_loop:
    li    $t1, 0
grid_pixel_loop:
    li    $t3, 0x000f172a        
    beq   $t0, 0, grid_color
    nop
    beq   $t0, 63, grid_color
    nop
    beq   $t1, 0, grid_color
    nop
    beq   $t1, 63, grid_color
    nop
    beq   $t0, 21, grid_color
    nop
    beq   $t0, 42, grid_color
    nop
    beq   $t1, 21, grid_color
    nop
    beq   $t1, 42, grid_color
    nop
    j     grid_store
    nop
grid_color:
    li    $t3, 0x0064748b
grid_store:
    sw    $t3, 0($t2)
    addiu $t2, $t2, 4
    addiu $t1, $t1, 1
    blt   $t1, 64, grid_pixel_loop
    nop
    addiu $t0, $t0, 1
    blt   $t0, 64, grid_row_loop
    nop
    jr    $ra
    nop

draw_digit:
    addiu $t0, $a2, -1
    mul   $t0, $t0, 5
    la    $t8, digit_font
    addu  $t0, $t0, $t8
    la    $t8, screen
    li    $t9, 0x0094a3b8
    li    $t1, 0
digit_row_loop:
    lbu   $t3, 0($t0)
    li    $t2, 0
digit_col_loop:
    li    $t4, 4
    srlv  $t4, $t4, $t2
    and   $t5, $t3, $t4
    beqz  $t5, digit_next_col
    nop
    addu  $t6, $a1, $t1
    sll   $t6, $t6, 6
    addu  $t6, $t6, $a0
    addu  $t6, $t6, $t2
    sll   $t6, $t6, 2
    addu  $t6, $t6, $t8
    sw    $t9, 0($t6)
digit_next_col:
    addiu $t2, $t2, 1
    blt   $t2, 3, digit_col_loop
    nop
    addiu $t0, $t0, 1
    addiu $t1, $t1, 1
    blt   $t1, 5, digit_row_loop
    nop
    jr    $ra
    nop


draw_symbol:
    la    $t8, screen
    li    $t9, 0x0038bdf8
    beq   $a2, 1, symbol_start
    nop
    li    $t9, 0x00fb923c
symbol_start:
    li    $t0, 0
symbol_row_loop:
    li    $t1, 0
symbol_col_loop:
    beq   $a2, 1, symbol_x_test
    nop
    addiu $t2, $t1, -7
    addiu $t3, $t0, -7
    mul   $t4, $t2, $t2
    mul   $t5, $t3, $t3
    addu  $t4, $t4, $t5
    blt   $t4, 30, symbol_next_col
    nop
    bgt   $t4, 58, symbol_next_col
    nop
    j     symbol_store
    nop
symbol_x_test:
    subu  $t4, $t1, $t0
    blt   $t4, -1, symbol_other_diagonal
    nop
    ble   $t4, 1, symbol_store
    nop
symbol_other_diagonal:
    addu  $t4, $t1, $t0
    addiu $t4, $t4, -14
    blt   $t4, -1, symbol_next_col
    nop
    bgt   $t4, 1, symbol_next_col
    nop
symbol_store:
    addu  $t6, $a1, $t0
    sll   $t6, $t6, 6
    addu  $t6, $t6, $a0
    addu  $t6, $t6, $t1
    sll   $t6, $t6, 2
    addu  $t6, $t6, $t8
    sw    $t9, 0($t6)
symbol_next_col:
    addiu $t1, $t1, 1
    blt   $t1, 15, symbol_col_loop
    nop
    addiu $t0, $t0, 1
    blt   $t0, 15, symbol_row_loop
    nop
    jr    $ra
    nop

draw_border:
    la    $t0, screen
    li    $t1, 0
border_loop:
    sll   $t2, $t1, 2
    addu  $t3, $t0, $t2
    sw    $a0, 0($t3)
    sw    $a0, 16128($t3)
    sll   $t2, $t1, 8
    addu  $t3, $t0, $t2
    sw    $a0, 0($t3)
    sw    $a0, 252($t3)
    addiu $t1, $t1, 1
    blt   $t1, 64, border_loop
    nop
    jr    $ra
    nop
