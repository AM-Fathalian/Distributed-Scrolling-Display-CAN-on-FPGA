.global _main

_main:
    li s0, 0x000F0040   #7seg base addressss
    li s1, 0x000F0048   # Right most 7-Segment Address - Explicitly Addressed (still not working) 
    li s3, 1            # small wait counter top value: simulation
    #li s4, 10            # wait counter top value: simulation 50

    li s5, 0x01000000   # shifts instruction
    li s6, 0x00010000   # clear instruction
    li s7, 0x00000100   # write instruction
    li s8, 0x00000010   # off instruction, write on, because otherwise does not make sense
    li s9, 0x01000100   # shif and add instruction
    
    li s4, 0xFFC000     # wait counter top value: synthesis

    loop:
        ##Start with 000000000
        li s2, 0x00000000   # Data to be displayed
        sw s2, 0(s0)        # Write data to 7-seg
        call small_wait
        li s2, 0x00000000
        sw s2, 4(s0)
        call small_wait
        # Sweep 0 to F on each digit
        ori s10, s9, 0x1  # shift and add instruction with data 1
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0x2  # shift and add instruction with data 2
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0x3  # shift and add instruction with data 3
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0x4  # shift and add instruction with data 4
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0x5  # shift and add instruction with data 5
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0x6  # shift and add instruction with data 6
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0x7  # shift and add instruction with data 7
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0x8  # shift and add instruction with data 8
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0x9  # shift and add instruction with data 9
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0xA  # shift and add instruction with data A
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0xB  # shift and add instruction with data B
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0xC  # shift and add instruction with data C
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0xD  # shift and add instruction with data D
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0xE  # shift and add instruction with data E
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0xF  # shift and add instruction with data F
        sw s10, 8(s0)      # Write data to 7-seg
        call wait

        ## Now turn off one by one
        sw s8, 8(s0)      # Write off instruction to 7-seg
        call small_wait
        sw s5, 8(s0)      # Write shift instruction to 7-seg
        call wait
        sw s8, 8(s0)      # Write off instruction to 7-seg
        call small_wait
        sw s5, 8(s0)      # Write shift instruction to 7-seg
        call wait
        sw s8, 8(s0)      # Write off instruction to 7-seg
        call small_wait
        sw s5, 8(s0)      # Write shift instruction to 7-seg
        call wait
        sw s8, 8(s0)      # Write off instruction to 7-seg
        call small_wait
        sw s5, 8(s0)      # Write shift instruction to 7-seg
        call wait
        sw s8, 8(s0)      # Write off instruction to 7-seg
        call small_wait
        sw s5, 8(s0)      # Write shift instruction to 7-seg
        call wait
        sw s8, 8(s0)      # Write off instruction to 7-seg
        call small_wait
        sw s5, 8(s0)      # Write shift instruction to 7-seg
        call wait
        sw s8, 8(s0)      # Write off instruction to 7-seg
        call small_wait
        sw s5, 8(s0)      # Write shift instruction to 7-seg
        call wait
        sw s8, 8(s0)      # Write off instruction to 7-seg
        call small_wait
        sw s5, 8(s0)      # Write shift instruction to 7-seg
        call wait
        
        ## Now write DEADBEEF by sweeping
        ori s10, s9, 0xF  # shift and add instruction with data F
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0xE  # shift and add instruction with data E
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0xE  # shift and add instruction with data E
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0xB  # shift and add instruction with data B
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0xD  # shift and add instruction with data D
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0xA  # shift and add instruction with data A
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0xE  # shift and add instruction with data E
        sw s10, 8(s0)      # Write data to 7-seg
        call wait
        ori s10, s9, 0xD  # shift and add instruction with data D
        sw s10, 8(s0)      # Write data to 7-seg
        call wait

        ## Now clear display
        sw s6, 8(s0)        # clear instruction
        call wait


        
        # li s2, 0x010000000   # shifts instruction
        # sw s2, 8(s0)        # Write data to 7-seg
        # call small_wait
        # sw s2, 8(s0)        # Write data to 7-seg
        # call wait

        # li s2, 0x0B0E0E0F   # Data to be displayed
        # sw s2, 0(s0)        # Write data to 7-seg
        # call small_wait
        # li s2, 0x010000000   # shifts instruction
        # sw s2, 8(s0)        # Write data to 7-seg

        # call wait

        j loop


small_wait:
    li t2, 0
    inc_i2:
        addi t2, t2, 1
        ble t2, s3, inc_i2 # Does time need to be the same as refresh rate of the 7-Segs? or No, it is handled by the simple_timer.sv
    ret
wait:
    li t1, 0
    inc_i:
        addi t1, t1, 1
        ble t1, s4, inc_i # Does time need to be the same as refresh rate of the 7-Segs? or No, it is handled by the simple_timer.sv
    ret