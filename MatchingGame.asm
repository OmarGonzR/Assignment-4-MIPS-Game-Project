# BITMAP DISPLAY SETUP
#   Unit Width/Height: 4 pixels
#   Display Width/Height: 256
#   Base Address: 0x10010000 Then Connect to MIPS

.data 0x10010000
screen:         .space 16384
cards:          .space 64
matched:        .space 64
first_index:    .word -1
second_index:   .word -1
attempts:       .word 0
pairs_found:    .word 0
phase:          .word 0
input_buffer:   .space 64
number_buffer:  .space 12
pair_colors:    .word 0x00dc2626,0x002563eb,0x0016a34a,0x009333ea
                .word 0x00ea580c,0x000891b2,0x00db2777,0x00713f12
title_try:      .asciiz "TRY"
footer_first:   .asciiz "FIRST CARD"
footer_second:  .asciiz "SECOND CARD"
footer_review:  .asciiz "ENTER TO HIDE"
footer_win:     .asciiz "ALL MATCHED"

instructions:   .asciiz "\n=== MEMORY MATCHING ===\nFind the eight matching pairs hidden in a 4x4 grid.\nCards show letters A-H when revealed; each letter appears twice.\nChoose two different face-down cards, numbered 1-16.\nA match stays face up with a green border.\nAfter a mismatch, press Enter to hide the two cards again.\nEnter 0 at any prompt to quit.\n\nCard positions, from left to right:\n  1   2   3   4\n  5   6   7   8\n  9  10  11  12\n 13  14  15  16\n\nThe header shows TRY (attempts) and matched pairs out of 8.\nAn attempt counts only after two valid choices.\n"
new_message:    .asciiz "\nNew board! Find all eight pairs.\n"
first_prompt:   .asciiz "\nFirst card (1-16, or 0 to quit): "
second_prompt:  .asciiz "Second card (1-16, or 0 to quit): "
invalid_number: .asciiz "Invalid input. Enter a whole number from 1 to 16, or 0 to quit.\n"
already_matched:.asciiz "That card is already matched. Choose a face-down card.\n"
same_card:      .asciiz "Choose a different card; your first card is already face up.\n"
card_message:   .asciiz "Card "
colon_space:    .asciiz ": "
newline:        .asciiz "\n"
match_message:  .asciiz "Match! Those two cards will stay face up.\n"
no_match:       .asciiz "No match. Look at both letters before hiding them.\n"
review_prompt:  .asciiz "Press Enter to hide both cards, or enter 0 to quit: "
invalid_review: .asciiz "Invalid input. Press Enter to continue, or enter 0 to quit.\n"
progress_try:   .asciiz "Attempts: "
progress_pairs: .asciiz "  Pairs found: "
out_of_eight:   .asciiz "/8\n"
win_message:    .asciiz "\nYou found all eight pairs in "
win_end:        .asciiz " attempts! You win!\n"
replay_prompt:  .asciiz "\nPlay again? 1 = Yes, 0 = Quit: "
invalid_replay: .asciiz "Invalid input. Enter 1 or 0.\n"
goodbye:        .asciiz "\nThanks for playing Memory Matching!\n"

font_data:
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 1,1,2,4,4
    .byte 7,5,5,5,7
    .byte 2,6,2,2,7
    .byte 7,1,7,4,7
    .byte 7,1,7,1,7
    .byte 5,5,7,1,1
    .byte 7,4,7,1,7
    .byte 7,4,7,5,7
    .byte 7,1,1,2,2
    .byte 7,5,7,5,7
    .byte 7,5,7,1,7
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0 
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 0,0,0,0,0
    .byte 2,5,7,5,5
    .byte 6,5,6,5,6
    .byte 7,4,4,4,7
    .byte 6,5,5,5,6
    .byte 7,4,6,4,7
    .byte 7,4,6,4,4
    .byte 7,4,5,5,7
    .byte 5,5,7,5,5
    .byte 7,2,2,2,7
    .byte 1,1,1,5,7
    .byte 5,5,6,5,5
    .byte 4,4,4,4,7
    .byte 5,7,7,5,5
    .byte 5,7,7,7,5
    .byte 7,5,5,5,7
    .byte 6,5,6,4,4
    .byte 7,5,5,7,1
    .byte 6,5,6,5,5
    .byte 7,4,7,1,7
    .byte 7,2,2,2,2
    .byte 5,5,5,5,7
    .byte 5,5,5,5,2
    .byte 5,5,7,7,5
    .byte 5,5,2,5,5
    .byte 5,5,2,2,2
    .byte 7,1,2,4,7


.text
.globl main
main:
    li    $v0, 4
    la    $a0, instructions
    syscall
    li    $v0, 30
    syscall
    move  $a1, $a0
    li    $a0, 0
    li    $v0, 40
    syscall

new_game:
    jal   init_game
    nop
    jal   shuffle_cards
    nop
    jal   draw_board
    nop
    li    $v0, 4
    la    $a0, new_message
    syscall
    jal   print_progress
    nop

choice_loop:
    la    $a0, first_prompt
    lw    $t0, phase
    beqz  $t0, print_choice_prompt
    nop
    la    $a0, second_prompt
print_choice_prompt:
    li    $v0, 4
    syscall
    jal   read_number
    nop
    beqz  $v0, quit_game
    nop
    blt   $v0, 1, invalid_choice
    nop
    bgt   $v0, 16, invalid_choice
    nop
    addiu $s0, $v0, -1
    move  $a0, $s0
    jal   validate_choice
    nop
    beq   $v0, 1, matched_choice
    nop
    beq   $v0, 2, repeated_choice
    nop
    lw    $t0, phase
    bnez  $t0, choose_second
    nop

choose_first:
    sw    $s0, first_index
    li    $t0, 1
    sw    $t0, phase
    jal   draw_board
    nop
    move  $a0, $s0
    jal   print_reveal
    nop
    j     choice_loop
    nop

choose_second:
    sw    $s0, second_index
    li    $t0, 2
    sw    $t0, phase
    lw    $t0, attempts
    addiu $t0, $t0, 1
    sw    $t0, attempts
    jal   draw_board
    nop
    move  $a0, $s0
    jal   print_reveal
    nop

    # Compare the values of the two selected cards
    lw    $t0, first_index
    lw    $t1, second_index
    sll   $t2, $t0, 2
    sll   $t3, $t1, 2
    la    $t4, cards
    addu  $t5, $t4, $t2
    addu  $t6, $t4, $t3
    lw    $t5, 0($t5)
    lw    $t6, 0($t6)
    beq   $t5, $t6, found_match
    nop

    li    $v0, 4
    la    $a0, no_match
    syscall
    jal   print_progress
    nop
review_loop:
    li    $v0, 4
    la    $a0, review_prompt
    syscall
    jal   read_number
    nop
    beqz  $v0, quit_game
    nop
    beq   $v0, -2, hide_cards
    nop
    li    $v0, 4
    la    $a0, invalid_review
    syscall
    j     review_loop
    nop
hide_cards:
    li    $t0, -1
    sw    $t0, first_index
    sw    $t0, second_index
    sw    $zero, phase
    jal   draw_board
    nop
    j     choice_loop
    nop

found_match:
    la    $t4, matched
    addu  $t5, $t4, $t2
    addu  $t6, $t4, $t3
    li    $t7, 1
    sw    $t7, 0($t5)
    sw    $t7, 0($t6)
    lw    $t0, pairs_found
    addiu $t0, $t0, 1
    sw    $t0, pairs_found
    li    $t1, -1
    sw    $t1, first_index
    sw    $t1, second_index
    sw    $zero, phase
    beq   $t0, 8, game_won
    nop
    jal   draw_board
    nop
    li    $v0, 4
    la    $a0, match_message
    syscall
    jal   print_progress
    nop
    j     choice_loop
    nop

invalid_choice:
    li    $v0, 4
    la    $a0, invalid_number
    syscall
    j     choice_loop
    nop
matched_choice:
    li    $v0, 4
    la    $a0, already_matched
    syscall
    j     choice_loop
    nop
repeated_choice:
    li    $v0, 4
    la    $a0, same_card
    syscall
    j     choice_loop
    nop

game_won:
    li    $t0, 3
    sw    $t0, phase
    jal   draw_board
    nop
    jal   print_progress
    nop
    li    $v0, 4
    la    $a0, win_message
    syscall
    li    $v0, 1
    lw    $a0, attempts
    syscall
    li    $v0, 4
    la    $a0, win_end
    syscall
replay_loop:
    li    $v0, 4
    la    $a0, replay_prompt
    syscall
    jal   read_number
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

# init_game resets progress
init_game:
    sw    $zero, attempts
    sw    $zero, pairs_found
    sw    $zero, phase
    li    $t0, -1
    sw    $t0, first_index
    sw    $t0, second_index
    la    $t0, cards
    la    $t1, matched
    li    $t2, 0
init_loop:
    andi  $t3, $t2, 7
    sw    $t3, 0($t0)
    sw    $zero, 0($t1)
    addiu $t0, $t0, 4
    addiu $t1, $t1, 4
    addiu $t2, $t2, 1
    blt   $t2, 16, init_loop
    nop
    jr    $ra
    nop

shuffle_cards:
    li    $t0, 15
    la    $t1, cards
shuffle_loop:
    li    $a0, 0
    addiu $a1, $t0, 1
    li    $v0, 42
    syscall
    sll   $t2, $t0, 2
    addu  $t2, $t2, $t1
    sll   $t3, $a0, 2
    addu  $t3, $t3, $t1
    lw    $t4, 0($t2)
    lw    $t5, 0($t3)
    sw    $t5, 0($t2)
    sw    $t4, 0($t3)
    addiu $t0, $t0, -1
    bgtz  $t0, shuffle_loop
    nop
    jr    $ra
    nop

validate_choice:
    sll   $t0, $a0, 2
    la    $t1, matched
    addu  $t0, $t0, $t1
    lw    $t0, 0($t0)
    bnez  $t0, validate_matched
    nop
    lw    $t0, first_index
    beq   $a0, $t0, validate_same
    nop
    li    $v0, 0
    jr    $ra
    nop
validate_matched:
    li    $v0, 1
    jr    $ra
    nop
validate_same:
    li    $v0, 2
    jr    $ra
    nop

read_number:
    la    $a0, input_buffer
    sb    $zero, 62($a0)
    li    $a1, 64
    li    $v0, 8
    syscall
    la    $t0, input_buffer
    lbu   $t1, 62($t0)
    bnez  $t1, read_invalid
    nop
read_leading:
    lbu   $t1, 0($t0)
    beqz  $t1, read_blank
    nop
    beq   $t1, 32, read_leading_next
    nop
    beq   $t1, 9, read_leading_next
    nop
    beq   $t1, 10, read_leading_next
    nop
    beq   $t1, 13, read_leading_next
    nop
    li    $t2, 0
    li    $t3, 0
read_digits:
    lbu   $t1, 0($t0)
    blt   $t1, 48, read_trailing
    nop
    bgt   $t1, 57, read_trailing
    nop
    addiu $t3, $t3, 1
    bgt   $t3, 2, read_invalid
    nop
    mul   $t2, $t2, 10
    addiu $t1, $t1, -48
    addu  $t2, $t2, $t1
    addiu $t0, $t0, 1
    j     read_digits
    nop
read_leading_next:
    addiu $t0, $t0, 1
    j     read_leading
    nop
read_trailing:
    beqz  $t3, read_invalid
    nop
    lbu   $t1, 0($t0)
    beqz  $t1, read_valid
    nop
    beq   $t1, 32, read_trailing_next
    nop
    beq   $t1, 9, read_trailing_next
    nop
    beq   $t1, 10, read_trailing_next
    nop
    beq   $t1, 13, read_trailing_next
    nop
    j     read_invalid
    nop
read_trailing_next:
    addiu $t0, $t0, 1
    j     read_trailing
    nop
read_valid:
    move  $v0, $t2
    jr    $ra
    nop
read_blank:
    li    $v0, -2
    jr    $ra
    nop
read_invalid:
    li    $v0, -1
    jr    $ra
    nop

print_reveal:
    move  $t0, $a0
    li    $v0, 4
    la    $a0, card_message
    syscall
    li    $v0, 1
    addiu $a0, $t0, 1
    syscall
    li    $v0, 4
    la    $a0, colon_space
    syscall
    sll   $t1, $t0, 2
    la    $t2, cards
    addu  $t1, $t1, $t2
    lw    $a0, 0($t1)
    addiu $a0, $a0, 65
    li    $v0, 11
    syscall
    li    $v0, 4
    la    $a0, newline
    syscall
    jr    $ra
    nop

print_progress:
    li    $v0, 4
    la    $a0, progress_try
    syscall
    li    $v0, 1
    lw    $a0, attempts
    syscall
    li    $v0, 4
    la    $a0, progress_pairs
    syscall
    li    $v0, 1
    lw    $a0, pairs_found
    syscall
    li    $v0, 4
    la    $a0, out_of_eight
    syscall
    jr    $ra
    nop

draw_board:
    addiu $sp, $sp, -24
    sw    $ra, 20($sp)
    sw    $s0, 16($sp)
    jal   clear_screen
    nop
    li    $a0, 3
    li    $a1, 2
    la    $a2, title_try
    li    $a3, 0x00f8fafc
    jal   draw_text
    nop
    li    $a0, 17
    li    $a1, 2
    lw    $a2, attempts
    li    $a3, 0x00f8fafc
    jal   draw_number
    nop
    li    $a0, 49
    li    $a1, 2
    lw    $a2, pairs_found
    li    $a3, 0x00f8fafc
    jal   draw_number
    nop
    li    $a0, 53
    li    $a1, 2
    li    $a2, 47
    li    $a3, 0x00f8fafc
    jal   draw_char
    nop
    li    $a0, 57
    li    $a1, 2
    li    $a2, 56
    li    $a3, 0x00f8fafc
    jal   draw_char
    nop
    li    $s0, 0
draw_board_loop:
    move  $a0, $s0
    jal   draw_card
    nop
    addiu $s0, $s0, 1
    blt   $s0, 16, draw_board_loop
    nop

    lw    $t0, phase
    beq   $t0, 1, draw_second_footer
    nop
    beq   $t0, 2, draw_review_footer
    nop
    beq   $t0, 3, draw_win_footer
    nop
    li    $a0, 12
    la    $a2, footer_first
    j     draw_footer
    nop
draw_second_footer:
    li    $a0, 10
    la    $a2, footer_second
    j     draw_footer
    nop
draw_review_footer:
    li    $a0, 6
    la    $a2, footer_review
    j     draw_footer
    nop
draw_win_footer:
    li    $a0, 10
    la    $a2, footer_win
draw_footer:
    li    $a1, 58
    li    $a3, 0x00f8fafc
    jal   draw_text
    nop
    lw    $s0, 16($sp)
    lw    $ra, 20($sp)
    addiu $sp, $sp, 24
    jr    $ra
    nop

clear_screen:
    la    $t0, screen
    li    $t1, 4096
    li    $t2, 0x000f172a
    lw    $t3, phase
    bne   $t3, 3, clear_loop
    nop
    li    $t2, 0x00052e16
clear_loop:
    sw    $t2, 0($t0)
    addiu $t0, $t0, 4
    addiu $t1, $t1, -1
    bnez  $t1, clear_loop
    nop
    jr    $ra
    nop

draw_card:
    addiu $sp, $sp, -40
    sw    $ra, 36($sp)
    sw    $s0, 32($sp)
    sw    $s1, 28($sp)
    sw    $s2, 24($sp)
    sw    $s3, 20($sp)
    sw    $s4, 16($sp)
    move  $s0, $a0
    li    $t0, 4
    div   $s0, $t0
    mflo  $t1
    mfhi  $t2
    mul   $s1, $t2, 15
    addiu $s1, $s1, 3
    mul   $s2, $t1, 12
    addiu $s2, $s2, 9
    sll   $t0, $s0, 2
    la    $t1, matched
    addu  $t0, $t0, $t1
    lw    $s4, 0($t0)
    move  $s3, $s4
    bnez  $s3, card_colors
    nop
    lw    $t0, first_index
    beq   $s0, $t0, card_selected
    nop
    lw    $t0, second_index
    bne   $s0, $t0, card_colors
    nop
card_selected:
    li    $s3, 1
card_colors:
    li    $t6, 0x001d4ed8
    li    $t7, 0x0060a5fa
    beqz  $s3, card_rectangle
    nop
    li    $t6, 0x00fffbeb
    li    $t7, 0x00fbbf24
    beqz  $s4, card_rectangle
    nop
    li    $t6, 0x0014532d
    li    $t7, 0x004ade80
card_rectangle:
    la    $t8, screen
    li    $t0, 0
card_row:
    li    $t1, 0
card_col:
    move  $t3, $t6
    beqz  $t0, card_outline
    nop
    beq   $t0, 9, card_outline
    nop
    beqz  $t1, card_outline
    nop
    beq   $t1, 12, card_outline
    nop
    j     card_store
    nop
card_outline:
    move  $t3, $t7
card_store:
    addu  $t2, $s2, $t0
    sll   $t2, $t2, 6
    addu  $t2, $t2, $s1
    addu  $t2, $t2, $t1
    sll   $t2, $t2, 2
    addu  $t2, $t2, $t8
    sw    $t3, 0($t2)
    addiu $t1, $t1, 1
    blt   $t1, 13, card_col
    nop
    addiu $t0, $t0, 1
    blt   $t0, 10, card_row
    nop
    bnez  $s3, card_letter
    nop

    addiu $a2, $s0, 1
    addiu $a0, $s1, 5
    blt   $a2, 10, card_hidden_number
    nop
    addiu $a0, $s1, 3
card_hidden_number:
    addiu $a1, $s2, 2
    li    $a3, 0x00f8fafc
    jal   draw_number
    nop
    j     card_done
    nop
card_letter:
    sll   $t0, $s0, 2
    la    $t1, cards
    addu  $t0, $t0, $t1
    lw    $t0, 0($t0)
    addiu $a2, $t0, 65
    sll   $t0, $t0, 2
    la    $t1, pair_colors
    addu  $t0, $t0, $t1
    lw    $a3, 0($t0)
    beqz  $s4, card_draw_letter
    nop
    li    $a3, 0x00bbf7d0
card_draw_letter:
    addiu $a0, $s1, 5
    addiu $a1, $s2, 2
    jal   draw_char
    nop
card_done:
    lw    $s4, 16($sp)
    lw    $s3, 20($sp)
    lw    $s2, 24($sp)
    lw    $s1, 28($sp)
    lw    $s0, 32($sp)
    lw    $ra, 36($sp)
    addiu $sp, $sp, 40
    jr    $ra
    nop

draw_text:
    addiu $sp, $sp, -40
    sw    $ra, 36($sp)
    sw    $s0, 32($sp)
    sw    $s1, 28($sp)
    sw    $s2, 24($sp)
    sw    $s3, 20($sp)
    move  $s0, $a0
    move  $s1, $a1
    move  $s2, $a2
    move  $s3, $a3
text_loop:
    lbu   $a2, 0($s2)
    beqz  $a2, text_done
    nop
    move  $a0, $s0
    move  $a1, $s1
    move  $a3, $s3
    jal   draw_char
    nop
    addiu $s0, $s0, 4
    addiu $s2, $s2, 1
    j     text_loop
    nop
text_done:
    lw    $s3, 20($sp)
    lw    $s2, 24($sp)
    lw    $s1, 28($sp)
    lw    $s0, 32($sp)
    lw    $ra, 36($sp)
    addiu $sp, $sp, 40
    jr    $ra
    nop

draw_number:
    addiu $sp, $sp, -40
    sw    $ra, 36($sp)
    sw    $s0, 32($sp)
    sw    $s1, 28($sp)
    sw    $s2, 24($sp)
    sw    $s3, 20($sp)
    sw    $s4, 16($sp)
    move  $s0, $a0
    move  $s1, $a1
    move  $s3, $a3
    la    $s2, number_buffer
    li    $s4, 0
    move  $t0, $a2
    li    $t1, 10
number_build:
    divu  $t0, $t1
    mflo  $t0
    mfhi  $t2
    addiu $t2, $t2, 48
    sb    $t2, 0($s2)
    addiu $s2, $s2, 1
    addiu $s4, $s4, 1
    bnez  $t0, number_build
    nop
number_draw:
    addiu $s2, $s2, -1
    lbu   $a2, 0($s2)
    move  $a0, $s0
    move  $a1, $s1
    move  $a3, $s3
    jal   draw_char
    nop
    addiu $s0, $s0, 4
    addiu $s4, $s4, -1
    bnez  $s4, number_draw
    nop
    lw    $s4, 16($sp)
    lw    $s3, 20($sp)
    lw    $s2, 24($sp)
    lw    $s1, 28($sp)
    lw    $s0, 32($sp)
    lw    $ra, 36($sp)
    addiu $sp, $sp, 40
    jr    $ra
    nop

draw_char:
    blt   $a2, 32, char_done
    nop
    bgt   $a2, 90, char_done
    nop
    addiu $t0, $a2, -32
    mul   $t0, $t0, 5
    la    $t8, font_data
    addu  $t0, $t0, $t8
    la    $t8, screen
    li    $t1, 0
char_row:
    lbu   $t3, 0($t0)
    li    $t2, 0
char_col:
    li    $t4, 4
    srlv  $t4, $t4, $t2
    and   $t5, $t3, $t4
    beqz  $t5, char_next
    nop
    addu  $t6, $a1, $t1
    bgeu  $t6, 64, char_next
    nop
    addu  $t7, $a0, $t2
    bgeu  $t7, 64, char_next
    nop
    sll   $t6, $t6, 6
    addu  $t6, $t6, $t7
    sll   $t6, $t6, 2
    addu  $t6, $t6, $t8
    sw    $a3, 0($t6)
char_next:
    addiu $t2, $t2, 1
    blt   $t2, 3, char_col
    nop
    addiu $t0, $t0, 1
    addiu $t1, $t1, 1
    blt   $t1, 5, char_row
    nop
char_done:
    jr    $ra
    nop
