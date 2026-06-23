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

        mva #6 cur_number               ; cur_number = starting number (try 6 or 7)
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


        ; Exercise 3 - adding numbers
        ; Add numbers 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 together one at a time 
        ; in a single loop, but stop early the moment the running total exceeds 20.
        ; Print the final total and print how many numbers you actually added.
        ; (Just a single loop, one adc, one comparison to decide when to stop early.)
        
        mva #5 rowcrs                   ; set the cursor on row 3
        mva #1 colcrs                   ; set the cursor on column 1

        ldx #0                          ; x=0
        ldy #0                          ; y=0 (holds how many numbers we added)
        lda #0                          ; a=0
        mva #0 p16_val_lo               ; p16_val_lo=0
addTo20:
        inx                             ; x++
        iny                             ; y++
        stx p16_val_lo                  ; p16_val_lo = x
        clc                             ; clear carry
        adc p16_val_lo                  ; a += p16_val_lo
        cmp #20                         ; a > 20?
        bcc addTo20                     ; branch if carry is clear, so this will branch until
                                        ; a is greather than 20 which will set the carry
        sty p16_val_hi                  ; save Y to p16_val_hi

        jsr printDecimal                ; print sum, should be 21        

        mva #6 rowcrs
        mva #1 colcrs

        lda p16_val_hi                  ; put the total numbers we added into a
        jsr printDecimal                ; print that total, should be 6

        ; Exercise 4 - Count occurrences
        ; Loop from 1 to 30. Count how many of those numbers are divisible by 3 
        ; (you already know how to test divisibility by 2 with and — divisibility 
        ; by 3 needs a different approach: subtract 3 repeatedly until you can't anymore, 
        ; and check if you land exactly on 0). Print the count at the end.

        mva #8 rowcrs                   ; set the cursor on row 3
        mva #1 colcrs                   ; set the cursor on column 1

        ldx #0                          ; loop counter
        ldy #0                          ; numbers divisible by 3

countOccurrenceOuter:
        inx                             ; x++
        cpx #31                         ; is x == 31?
        beq doneCountOccurrances        ; jump out

        txa                             ; a=x

 countOccurrenceInner:
        sec                             ; set carry
        sbc #3                          ; a-=3
        beq divBy3                      ; branch if the zero flag is set
        bcc countOccurrenceOuter        ; we've gone negative, the carry is cleared, branch to top "branch if borrowed"
        ; assume a>0
        jmp countOccurrenceInner        ; keep subtracting

divBy3:
        iny                             ; y++
        jmp countOccurrenceOuter        ; back to top

doneCountOccurrances:
        tya                             ; a=y
        jsr printDecimal                ; print total, should be 10


        ; Exercise 5 - Min and max
        ; You have a hardcoded list of 5 numbers in a .byte table: 12, 45, 3, 78, 22. 
        ; Loop through the table using indexed addressing (lda table,x) and find the largest value. Print it.

        ; load first entry into a "best so far" variable
        ; loop x from 1 to 4:
        ;    load numbers[x]
        ;    compare to "best so far"
        ;    if bigger, replace "best so far"
        ; print "best so far"

        mva #10 rowcrs                  ; set the cursor on row 10
        mva #1 colcrs                   ; set the cursor on column 1

        ldx #0                          ; x = 0
        mva #0 p16_val_lo              ; p16_val_lo = 0, holds the biggest

findBiggest:
        lda numbers,x                   ; a = numbers[x]
        inx                             ; x++

        cpx #.len numbers               ; is x == len(numbers)?
        beq doneBiggest

        cmp p16_val_lo                  ; compare A with p16_val_lo
        bcs replaceValue                ; if p16_val_lo > a, branch
        jmp findBiggest

replaceValue:
        sta p16_val_lo                  ; p16_val_lo = a
        jmp findBiggest

doneBiggest:
        lda p16_val_lo
        jsr printDecimal                ; print result, should be 78

;===================================================================

halt:
        jsr fightAttract
        jmp halt

        .endp

;===================================================================
; Data section
;===================================================================
        .local numbers
        .byte 78, 45, 3, 12, 22
        .endl


        run main