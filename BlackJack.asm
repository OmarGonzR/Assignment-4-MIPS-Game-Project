# BITMAP DISPLAY SETUP
#   Unit Width/Height: 4 pixels
#   Display Width/Height: 256
#   Base Address: 0x10010000 Then Connect to MIPS

.data 0x10010000
screen:         .space 16384
deck:           .space 208
player_hand:    .space 48
dealer_hand:    .space 48
deck_pos:       .word 0
player_count:   .word 0
dealer_count:   .word 0
reveal_dealer:  .word 0
result_code:    .word 0
wins:           .word 0
losses:         .word 0
pushes:         .word 0
input_buffer:   .space 64
rank_chars:     .asciiz "A23456789TJQK"
suit_chars:     .asciiz "CDHS"
title_dealer:   .asciiz "DEALER"
title_player:   .asciiz "YOU"
footer_play:    .asciiz "1 HIT 2 STAND"
footer_win:     .asciiz "YOU WIN"
footer_loss:    .asciiz "YOU LOSE"
footer_push:    .asciiz "PUSH"
footer_cancel:  .asciiz "NEW ROUND"

instructions:   .asciiz "\n=== BLACKJACK ===\nYou play against the computer dealer.\nGet closer to 21 than the dealer without going over.\n2-10 keep their value; J/Q/K = 10; A = 1 or 11.\nTwo-card 21 is Blackjack. If both have it, the round is a push.\nThe dealer hits below 17 and stands on every 17, including soft 17.\nReaching 21 automatically ends your turn.\nA fresh 52-card deck is shuffled each round.\n\nBitmap: dealer on top, you below. T means 10.\nSuits: C = clubs, D = diamonds, H = hearts, S = spades.\nOne dealer card is hidden until your turn ends.\n\nEnter 1 = Hit, 2 = Stand, or 0 = Quit, then press Enter.\nThis version has no betting, splitting, or doubling.\n"
turn_prompt:    .asciiz "\n1 = Hit, 2 = Stand, 0 = Quit: "
invalid_action: .asciiz "Invalid input. Enter 1, 2, or 0.\n"
dealer_label:   .asciiz "\nDealer: "
player_label:   .asciiz "\nYou:    "
total_label:    .asciiz " Total: "
hidden_card:    .asciiz "[hidden] "
hidden_total:   .asciiz "?"
newline:        .asciiz "\n"
dealer_turn:    .asciiz "\nDealer's turn. The hidden card is revealed.\n"
auto_stand:     .asciiz "\nYou reached 21. Your turn ends automatically.\n"
msg_blackjack:  .asciiz "\nBLACKJACK! You win.\n"
msg_both_bj:    .asciiz "\nBoth have Blackjack. Push! The round is a tie.\n"
msg_dealer_bj:  .asciiz "\nThe dealer has Blackjack. You lose.\n"
msg_bust:       .asciiz "\nYou went over 21. Bust! You lose.\n"
msg_dealer_bust:.asciiz "\nThe dealer went over 21. You win!\n"
msg_win:        .asciiz "\nYou have the higher total. You win!\n"
msg_loss:       .asciiz "\nThe dealer has the higher total. You lose.\n"
msg_push:       .asciiz "\nThe totals are equal. Push! The round is a tie.\n"
msg_cancel:     .asciiz "\nNo card can be dealt. Round cancelled; scores unchanged.\n"
stats_wins:     .asciiz "Record - Wins: "
stats_losses:   .asciiz "  Losses: "
stats_pushes:   .asciiz "  Pushes: "
replay_prompt:  .asciiz "\nPlay again? 1 = Yes, 0 = Quit: "
invalid_replay: .asciiz "Invalid input. Enter 1 or 0.\n"
goodbye:        .asciiz "\nThanks for playing Blackjack!\n"

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
    .byte 0,0,0,0,0
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
    .byte 7,1,2,0,2
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

new_round:
    jal   init_round
    nop
    jal   shuffle_deck
    nop
    la    $a0, player_hand
    la    $a1, player_count
    jal   deal_card
    nop
    bltz  $v0, cancel_round
    nop
    la    $a0, dealer_hand
    la    $a1, dealer_count
    jal   deal_card
    nop
    bltz  $v0, cancel_round
    nop
    la    $a0, player_hand
    la    $a1, player_count
    jal   deal_card
    nop
    bltz  $v0, cancel_round
    nop
    la    $a0, dealer_hand
    la    $a1, dealer_count
    jal   deal_card
    nop
    bltz  $v0, cancel_round
    nop
    jal   refresh
    nop

    la    $a0, player_hand
    lw    $a1, player_count
    jal   calculate_hand
    nop
    move  $s0, $v0
    la    $a0, dealer_hand
    lw    $a1, dealer_count
    jal   calculate_hand
    nop
    move  $s1, $v0
    bne   $s0, 21, check_dealer_blackjack
    nop
    beq   $s1, 21, both_blackjack
    nop
    la    $s2, msg_blackjack
    li    $s3, 1
    j     finish_round
    nop
check_dealer_blackjack:
    beq   $s1, 21, dealer_blackjack
    nop

player_loop:
    li    $v0, 4
    la    $a0, turn_prompt
    syscall
    jal   read_digit
    nop
    beqz  $v0, quit_game
    nop
    beq   $v0, 1, player_hit
    nop
    beq   $v0, 2, begin_dealer
    nop
    li    $v0, 4
    la    $a0, invalid_action
    syscall
    j     player_loop
    nop

player_hit:
    la    $a0, player_hand
    la    $a1, player_count
    jal   deal_card
    nop
    bltz  $v0, cancel_round
    nop
    la    $a0, player_hand
    lw    $a1, player_count
    jal   calculate_hand
    nop
    move  $s0, $v0
    bgt   $s0, 21, player_bust
    nop
    beq   $s0, 21, player_twenty_one
    nop
    jal   refresh
    nop
    j     player_loop
    nop

player_twenty_one:
    jal   refresh
    nop
    li    $v0, 4
    la    $a0, auto_stand
    syscall

begin_dealer:
    li    $t0, 1
    sw    $t0, reveal_dealer
    li    $v0, 4
    la    $a0, dealer_turn
    syscall
dealer_loop:
    jal   refresh
    nop
    la    $a0, dealer_hand
    lw    $a1, dealer_count
    jal   calculate_hand
    nop
    move  $s1, $v0
    bge   $s1, 17, compare_totals
    nop
    la    $a0, dealer_hand
    la    $a1, dealer_count
    jal   deal_card
    nop
    bltz  $v0, cancel_round
    nop
    j     dealer_loop
    nop

compare_totals:
    bgt   $s1, 21, dealer_bust
    nop
    bgt   $s0, $s1, player_wins
    nop
    blt   $s0, $s1, dealer_wins
    nop
    la    $s2, msg_push
    li    $s3, 3
    j     finish_round
    nop
both_blackjack:
    la    $s2, msg_both_bj
    li    $s3, 3
    j     finish_round
    nop
dealer_blackjack:
    la    $s2, msg_dealer_bj
    li    $s3, 2
    j     finish_round
    nop
player_bust:
    la    $s2, msg_bust
    li    $s3, 2
    j     finish_round
    nop
dealer_bust:
    la    $s2, msg_dealer_bust
    li    $s3, 1
    j     finish_round
    nop
player_wins:
    la    $s2, msg_win
    li    $s3, 1
    j     finish_round
    nop
dealer_wins:
    la    $s2, msg_loss
    li    $s3, 2
    j     finish_round
    nop
cancel_round:
    la    $s2, msg_cancel
    li    $s3, 4

finish_round:
    sw    $s3, result_code
    li    $t0, 1
    sw    $t0, reveal_dealer
    beq   $s3, 1, count_win
    nop
    beq   $s3, 2, count_loss
    nop
    beq   $s3, 3, count_push
    nop
    j     show_result
    nop
count_win:
    lw    $t0, wins
    addiu $t0, $t0, 1
    sw    $t0, wins
    j     show_result
    nop
count_loss:
    lw    $t0, losses
    addiu $t0, $t0, 1
    sw    $t0, losses
    j     show_result
    nop
count_push:
    lw    $t0, pushes
    addiu $t0, $t0, 1
    sw    $t0, pushes
show_result:
    jal   refresh
    nop
    li    $v0, 4
    move  $a0, $s2
    syscall
    jal   print_stats
    nop
replay_loop:
    li    $v0, 4
    la    $a0, replay_prompt
    syscall
    jal   read_digit
    nop
    beqz  $v0, quit_game
    nop
    beq   $v0, 1, new_round
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

init_round:
    sw    $zero, deck_pos
    sw    $zero, player_count
    sw    $zero, dealer_count
    sw    $zero, reveal_dealer
    sw    $zero, result_code
    la    $t0, player_hand
    li    $t1, 24
clear_hands_loop:
    sw    $zero, 0($t0)
    addiu $t0, $t0, 4
    addiu $t1, $t1, -1
    bnez  $t1, clear_hands_loop
    nop
    la    $t0, deck
    li    $t1, 0
fill_deck_loop:
    sw    $t1, 0($t0)
    addiu $t0, $t0, 4
    addiu $t1, $t1, 1
    blt   $t1, 52, fill_deck_loop
    nop
    jr    $ra
    nop

shuffle_deck:
    li    $t0, 51
    la    $t1, deck
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

deal_card:
    lw    $t0, 0($a1)
    bgeu  $t0, 12, deal_failed
    nop
    lw    $t1, deck_pos
    bgeu  $t1, 52, deal_failed
    nop
    sll   $t2, $t1, 2
    la    $t3, deck
    addu  $t2, $t2, $t3
    lw    $v0, 0($t2)
    sll   $t2, $t0, 2
    addu  $t2, $t2, $a0
    sw    $v0, 0($t2)
    addiu $t0, $t0, 1
    sw    $t0, 0($a1)
    addiu $t1, $t1, 1
    sw    $t1, deck_pos
    jr    $ra
    nop
deal_failed:
    li    $v0, -1
    jr    $ra
    nop

calculate_hand:
    move  $t0, $a0
    move  $t1, $a1
    li    $t2, 0
    li    $t3, 0
    li    $t4, 13
score_loop:
    beqz  $t1, adjust_aces
    nop
    lw    $t5, 0($t0)
    div   $t5, $t4
    mfhi  $t5
    addiu $t5, $t5, 1
    beq   $t5, 1, score_ace
    nop
    ble   $t5, 10, score_add
    nop
    li    $t5, 10
    j     score_add
    nop
score_ace:
    li    $t5, 11
    addiu $t3, $t3, 1
score_add:
    addu  $t2, $t2, $t5
    addiu $t0, $t0, 4
    addiu $t1, $t1, -1
    j     score_loop
    nop
adjust_aces:
    ble   $t2, 21, score_done
    nop
    beqz  $t3, score_done
    nop
    addiu $t2, $t2, -10
    addiu $t3, $t3, -1
    j     adjust_aces
    nop
score_done:
    move  $v0, $t2
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

refresh:
    addiu $sp, $sp, -24
    sw    $ra, 20($sp)
    jal   draw_table
    nop
    jal   print_state
    nop
    lw    $ra, 20($sp)
    addiu $sp, $sp, 24
    jr    $ra
    nop

print_state:
    addiu $sp, $sp, -24
    sw    $ra, 20($sp)
    li    $v0, 4
    la    $a0, dealer_label
    syscall
    la    $a0, dealer_hand
    lw    $a1, dealer_count
    lw    $t0, reveal_dealer
    xori  $a2, $t0, 1
    jal   print_hand
    nop
    li    $v0, 4
    la    $a0, total_label
    syscall
    lw    $t0, reveal_dealer
    beqz  $t0, print_hidden_total
    nop
    la    $a0, dealer_hand
    lw    $a1, dealer_count
    jal   calculate_hand
    nop
    move  $a0, $v0
    li    $v0, 1
    syscall
    j     print_player_state
    nop
print_hidden_total:
    li    $v0, 4
    la    $a0, hidden_total
    syscall
print_player_state:
    li    $v0, 4
    la    $a0, player_label
    syscall
    la    $a0, player_hand
    lw    $a1, player_count
    li    $a2, 0
    jal   print_hand
    nop
    li    $v0, 4
    la    $a0, total_label
    syscall
    la    $a0, player_hand
    lw    $a1, player_count
    jal   calculate_hand
    nop
    move  $a0, $v0
    li    $v0, 1
    syscall
    li    $v0, 4
    la    $a0, newline
    syscall
    lw    $ra, 20($sp)
    addiu $sp, $sp, 24
    jr    $ra
    nop

print_hand:
    addiu $sp, $sp, -40
    sw    $ra, 36($sp)
    sw    $s0, 32($sp)
    sw    $s1, 28($sp)
    sw    $s2, 24($sp)
    sw    $s3, 20($sp)
    move  $s0, $a0
    move  $s1, $a1
    move  $s3, $a2
    li    $s2, 0
print_hand_loop:
    bge   $s2, $s1, print_hand_done
    nop
    beqz  $s3, print_visible_card
    nop
    bne   $s2, 1, print_visible_card
    nop
    li    $v0, 4
    la    $a0, hidden_card
    syscall
    j     print_hand_next
    nop
print_visible_card:
    lw    $a0, 0($s0)
    jal   print_card
    nop
print_hand_next:
    addiu $s0, $s0, 4
    addiu $s2, $s2, 1
    j     print_hand_loop
    nop
print_hand_done:
    lw    $s3, 20($sp)
    lw    $s2, 24($sp)
    lw    $s1, 28($sp)
    lw    $s0, 32($sp)
    lw    $ra, 36($sp)
    addiu $sp, $sp, 40
    jr    $ra
    nop

print_card:
    li    $t0, 13
    div   $a0, $t0
    mflo  $t2
    mfhi  $t1
    beqz  $t1, print_face
    nop
    bge   $t1, 10, print_face
    nop
    addiu $a0, $t1, 1
    li    $v0, 1
    syscall
    j     print_suit
    nop
print_face:
    la    $t0, rank_chars
    addu  $t0, $t0, $t1
    lbu   $a0, 0($t0)
    li    $v0, 11
    syscall
print_suit:
    li    $v0, 11
    li    $a0, 40
    syscall
    la    $t0, suit_chars
    addu  $t0, $t0, $t2
    lbu   $a0, 0($t0)
    syscall
    li    $a0, 41
    syscall
    li    $a0, 32
    syscall
    jr    $ra
    nop

print_stats:
    li    $v0, 4
    la    $a0, stats_wins
    syscall
    li    $v0, 1
    lw    $a0, wins
    syscall
    li    $v0, 4
    la    $a0, stats_losses
    syscall
    li    $v0, 1
    lw    $a0, losses
    syscall
    li    $v0, 4
    la    $a0, stats_pushes
    syscall
    li    $v0, 1
    lw    $a0, pushes
    syscall
    li    $v0, 4
    la    $a0, newline
    syscall
    jr    $ra
    nop

draw_table:
    addiu $sp, $sp, -24
    sw    $ra, 20($sp)
    jal   clear_screen
    nop
    li    $a0, 3
    li    $a1, 2
    la    $a2, title_dealer
    li    $a3, 0x00f8fafc
    jal   draw_text
    nop
    li    $a0, 3
    li    $a1, 31
    la    $a2, title_player
    li    $a3, 0x00f8fafc
    jal   draw_text
    nop

    lw    $t0, reveal_dealer
    beqz  $t0, draw_unknown_score
    nop
    la    $a0, dealer_hand
    lw    $a1, dealer_count
    jal   calculate_hand
    nop
    move  $a2, $v0
    li    $a0, 50
    li    $a1, 2
    li    $a3, 0x00f8fafc
    jal   draw_number
    nop
    j     draw_player_score
    nop
draw_unknown_score:
    li    $a0, 50
    li    $a1, 2
    li    $a2, 63
    li    $a3, 0x00f8fafc
    jal   draw_char
    nop
draw_player_score:
    la    $a0, player_hand
    lw    $a1, player_count
    jal   calculate_hand
    nop
    move  $a2, $v0
    li    $a0, 50
    li    $a1, 31
    li    $a3, 0x00f8fafc
    jal   draw_number
    nop

    la    $a0, dealer_hand
    lw    $a1, dealer_count
    li    $a2, 9
    lw    $t0, reveal_dealer
    xori  $a3, $t0, 1
    jal   draw_hand
    nop
    la    $a0, player_hand
    lw    $a1, player_count
    li    $a2, 38
    li    $a3, 0
    jal   draw_hand
    nop

    lw    $t0, result_code
    beq   $t0, 1, draw_win_footer
    nop
    beq   $t0, 2, draw_loss_footer
    nop
    beq   $t0, 3, draw_push_footer
    nop
    beq   $t0, 4, draw_cancel_footer
    nop
    li    $a0, 6
    la    $a2, footer_play
    j     draw_footer
    nop
draw_win_footer:
    li    $a0, 18
    la    $a2, footer_win
    j     draw_footer
    nop
draw_loss_footer:
    li    $a0, 16
    la    $a2, footer_loss
    j     draw_footer
    nop
draw_push_footer:
    li    $a0, 24
    la    $a2, footer_push
    j     draw_footer
    nop
draw_cancel_footer:
    li    $a0, 14
    la    $a2, footer_cancel
draw_footer:
    li    $a1, 58
    li    $a3, 0x00f8fafc
    jal   draw_text
    nop
    lw    $ra, 20($sp)
    addiu $sp, $sp, 24
    jr    $ra
    nop

clear_screen:
    li    $t8, 0x0094a3b8
    lw    $t4, result_code
    beq   $t4, 1, border_win
    nop
    beq   $t4, 2, border_loss
    nop
    beq   $t4, 3, border_push
    nop
    j     background_start
    nop
border_win:
    li    $t8, 0x0022c55e
    j     background_start
    nop
border_loss:
    li    $t8, 0x00ef4444
    j     background_start
    nop
border_push:
    li    $t8, 0x00facc15
background_start:
    li    $t0, 0
    la    $t2, screen
background_row:
    li    $t1, 0
background_col:
    li    $t3, 0x000b4f42
    beqz  $t0, background_border
    nop
    beq   $t0, 63, background_border
    nop
    beqz  $t1, background_border
    nop
    beq   $t1, 63, background_border
    nop
    beq   $t0, 29, background_divider
    nop
    beq   $t0, 57, background_divider
    nop
    j     background_store
    nop
background_border:
    move  $t3, $t8
    j     background_store
    nop
background_divider:
    li    $t3, 0x002e7768
background_store:
    sw    $t3, 0($t2)
    addiu $t2, $t2, 4
    addiu $t1, $t1, 1
    blt   $t1, 64, background_col
    nop
    addiu $t0, $t0, 1
    blt   $t0, 64, background_row
    nop
    jr    $ra
    nop

draw_hand:
    addiu $sp, $sp, -40
    sw    $ra, 36($sp)
    sw    $s0, 32($sp)
    sw    $s1, 28($sp)
    sw    $s2, 24($sp)
    sw    $s3, 20($sp)
    sw    $s4, 16($sp)
    move  $s0, $a0
    move  $s1, $a1
    move  $s2, $a2
    move  $s3, $a3
    li    $s4, 0
draw_hand_loop:
    bge   $s4, $s1, draw_hand_done
    nop
    li    $t0, 6
    div   $s4, $t0
    mflo  $t1
    mfhi  $t2
    mul   $a0, $t2, 10
    addiu $a0, $a0, 3
    mul   $a1, $t1, 10
    addu  $a1, $a1, $s2
    lw    $a2, 0($s0)
    beqz  $s3, draw_hand_visible
    nop
    bne   $s4, 1, draw_hand_visible
    nop
    li    $a2, -1
draw_hand_visible:
    jal   draw_card
    nop
    addiu $s0, $s0, 4
    addiu $s4, $s4, 1
    j     draw_hand_loop
    nop
draw_hand_done:
    lw    $s4, 16($sp)
    lw    $s3, 20($sp)
    lw    $s2, 24($sp)
    lw    $s1, 28($sp)
    lw    $s0, 32($sp)
    lw    $ra, 36($sp)
    addiu $sp, $sp, 40
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
    move  $s1, $a1
    move  $s2, $a2
    li    $t5, 0x00f8fafc
    li    $t6, 0x0094a3b8
    bgez  $s2, card_box_start
    nop
    li    $t5, 0x002563eb
    li    $t6, 0x00bfdbfe
card_box_start:
    la    $t8, screen
    li    $t0, 0
card_box_row:
    li    $t1, 0
card_box_col:
    move  $t7, $t5
    beqz  $t0, card_outline
    nop
    beq   $t0, 8, card_outline
    nop
    beqz  $t1, card_outline
    nop
    beq   $t1, 8, card_outline
    nop
    j     card_box_store
    nop
card_outline:
    move  $t7, $t6
card_box_store:
    addu  $t2, $s1, $t0
    sll   $t2, $t2, 6
    addu  $t2, $t2, $s0
    addu  $t2, $t2, $t1
    sll   $t2, $t2, 2
    addu  $t2, $t2, $t8
    sw    $t7, 0($t2)
    addiu $t1, $t1, 1
    blt   $t1, 9, card_box_col
    nop
    addiu $t0, $t0, 1
    blt   $t0, 9, card_box_row
    nop
    bltz  $s2, card_draw_back
    nop

    li    $t0, 13
    div   $s2, $t0
    mflo  $s4
    mfhi  $t1
    li    $s3, 0x000f172a
    beq   $s4, 1, card_red
    nop
    beq   $s4, 2, card_red
    nop
    j     card_draw_rank
    nop
card_red:
    li    $s3, 0x00dc2626
card_draw_rank:
    la    $t0, rank_chars
    addu  $t0, $t0, $t1
    lbu   $a2, 0($t0)
    addiu $a0, $s0, 1
    addiu $a1, $s1, 1
    move  $a3, $s3
    jal   draw_char
    nop
    la    $t0, suit_chars
    addu  $t0, $t0, $s4
    lbu   $a2, 0($t0)
    addiu $a0, $s0, 5
    addiu $a1, $s1, 3
    move  $a3, $s3
    jal   draw_char
    nop
    j     card_done
    nop
card_draw_back:
    addiu $a0, $s0, 3
    addiu $a1, $s1, 2
    li    $a2, 63
    li    $a3, 0x00f8fafc
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
    move  $s0, $a0
    move  $s1, $a1
    move  $s2, $a2
    move  $s3, $a3
    blt   $s2, 10, draw_ones
    nop
    li    $t0, 10
    div   $s2, $t0
    mflo  $a2
    mfhi  $s2
    addiu $a2, $a2, 48
    jal   draw_char
    nop
    addiu $s0, $s0, 4
draw_ones:
    move  $a0, $s0
    move  $a1, $s1
    addiu $a2, $s2, 48
    move  $a3, $s3
    jal   draw_char
    nop
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
    beqz  $t5, char_next_col
    nop
    addu  $t6, $a1, $t1
    bgeu  $t6, 64, char_next_col
    nop
    addu  $t7, $a0, $t2
    bgeu  $t7, 64, char_next_col
    nop
    sll   $t6, $t6, 6
    addu  $t6, $t6, $t7
    sll   $t6, $t6, 2
    addu  $t6, $t6, $t8
    sw    $a3, 0($t6)
char_next_col:
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
