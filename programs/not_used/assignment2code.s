.global _main

_main:
    li s0, 0x000F0000   # LED base address
    li s2, 0            # loop counter
    li s3, 8            # loop counter top value
    li s4, 1            # wait counter top value: simulation
    # li s4, 0x1FC000     # wait counter top value: synthesis
    li s5, 0x000F0020  # SW base address

    loop:
        li s1, 0
        sw s1, 0(s0)
        call wait

        fill:
            slli s1, s1, 1
            addi s1, s1, 1
            sw s1, 0(s0)
            call wait

            addi s2, s2, 1
            ble s2, s3, fill
            li s2, 0 

        flush:
            slli s1, s1, 1
            sw s1, 0(s0)
            call wait

            addi s2, s2, 1
            ble s2, s3, flush
            li s2, 0
            j loop

wait:
    li t1, 0
    lw s6, 0(s5)    # save value read from switches
    addi s6, s6, 1
    inc_i:  #
        li t2, 0 #
        prescaler:#
            addi t2, t2, 1 #
            blt t2, s6, prescaler  #
        addi t1, t1, 1
        ble t1, s4, inc_i
    ret