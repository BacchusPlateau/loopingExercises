        icl 'equates.asm'
        icl 'routines.asm'

        org $2000

        .proc main
    
        mva #1 csrhinh
        mva #1 rowcrs
        mva #1 colcrs

        ;Exercise 1 — Sum of squares
        ;Calculate 1² + 2² + 3² + 4² = 1 + 4 + 9 + 16 = 30 and print the result. 
        ;Remember no multiply instruction — you'll need repeated addition to square each number!
        
        ;important zero page variables:
        ;cur_sum         = $A6    ; current running sum of current number
        ;cur_number      = $A7    ; current number we're computing square of
        ;sum_of_squares  = $A9    ; the sum of squares from 1 to n

        mva #4 cur_number               ; cur_number = high_number
        mva #0 sum_of_squares           ; sum_of_squares = 0
        lda #0                          ; a = 0
        ldx cur_number                  ; x = cur_number

sum_of_squares_inner:
        clc                             ; clear carry
        adc cur_number                  ; a += cur_number
        dex                             ; x--
        cpx #0                          ; x == 0?
        bne sum_of_squares_inner        ; branch if we are > 0

        sta cur_sum                     ; cur_sum = a
        lda sum_of_squares              ; a = sum_of_squares
        clc                             ; clear carry
        adc cur_sum                     ; a += cur_sum 
        sta sum_of_squares              ; sum_of_squares = a

        dec cur_number                  ; cur_number--
        lda cur_number                  ; a = cur_number

        cmp #0                          ; a == 0?
        beq done_sum                    ; if a==0, break out

        lda #0                          ; a = 0
        ldx cur_number                  ; x = cur_number
        
        jmp sum_of_squares_inner        ; back to the top
done_sum:        
        lda sum_of_squares              ; a = sum_of_squares
        jsr printDecimal        


        ;Exercise 2 — Factorial
        ;Calculate 5! = 5 × 4 × 3 × 2 × 1 = 120 and print it. 
        ;This needs nested loops — an outer loop for the multiplication count, and an 
        ;inner loop for the repeated addition that simulates each multiply.

        ;additional zero page variable
        ;factorial       = $AA    ; the factorial of a number

        mva #3 rowcrs                   ; set the cursor on row 3
        mva #1 colcrs                   ; set the cursor on column 1

        mva #7 cur_number               ; cur_number = starting number (try 6 or 7)
        mva cur_number cur_sum_lo       ; cur_sum_lo = cur_number
        mva #0 cur_sum_hi               ; cur_sum_hi = 0 (cur_sum starts as a small number, fits in 8 bits)

        lda cur_number
        sec
        sbc #1
        sta x_count                     ; x_count = cur_number - 1 (how many times to add)

fact_loop:
        ; A_lo/A_hi = 0  (running total for this multiplication pass)
        mva #0 acc_lo
        mva #0 acc_hi
        ldx x_count

fact_inner:
        ; acc += cur_sum  (16-bit addition)
        lda acc_lo
        clc
        adc cur_sum_lo
        sta acc_lo
        lda acc_hi
        adc cur_sum_hi
        sta acc_hi

        dex
        bne fact_inner

        ; cur_sum = acc
        lda acc_lo
        sta cur_sum_lo
        lda acc_hi
        sta cur_sum_hi

        dec cur_number
        lda cur_number
        cmp #1
        beq done_fact

        ; x_count = cur_number - 1
        lda cur_number
        sec
        sbc #1
        sta x_count

        jmp fact_loop
done_fact:

        mva cur_sum_lo p16_val_lo
        mva cur_sum_hi p16_val_hi
        jsr printBigDecimal

        ;Exercise 3 — Fibonacci sequence
        ;Print the first 8 Fibonacci numbers with spaces between them:
        ;1 1 2 3 5 8 13 21
        ;You'll need two variables tracking "previous" and "current" values.

        ;Exercise 4 — Digit sum
        ;Given the number 47, calculate the sum of its digits (4 + 7 = 11) and print the result. 
        ;Hint: use your printDecimal-style subtraction trick to extract digits, but instead of printing them, add them together!

        ;Exercise 5 — GCD (Greatest Common Divisor)
        ;Calculate the GCD of 48 and 18 using the Euclidean algorithm:
        ;while b != 0:
        ;    temp = b
        ;    b = a mod b
        ;    a = temp
        ;result = a
        ;This is the hardest one — you'll need a modulo operation which means repeated subtraction in a loop!
      
        


;===================================================================

halt:
        jsr fightAttract
        jmp halt

        .endp

;===================================================================
; Data section
;===================================================================
        ;.local string1
        ;.byte 'HELLO FROM STRING ONE!',0
        ;.endl


        run main