.global _main
    _main:
        li s0, 0x000F0060 #Scroll top base addressss
        li s1, 0x000F0064 # Scroll top second word adrees 
        li s3, 1 # small wait counter top value: simulation 

        #li s4, 100 # wait counter top value: simulation 100 

        li s4, 0xFFFC000 # wait counter top value: synthesis 

    loop: 

        li s2, 0x002000000 #Initialize count value to F  0x00000000F   0x002000000
        sw s2, 0(s1) #Write to control register[1] 
        call small_wait 

        li s2, 0x00000100   # clear 
        sw s2, 0(s0)        # clear buffer
        call small_wait


        li s2, 0x01010000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 

       

        li s2, 0x01030000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 
        
        li s2, 0x01020000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 
        
        li s2, 0x01040000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 

        li s2, 0x01050000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 

        li s2, 0x01070000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 

        li s2, 0x01060000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 

        li s2, 0x01080000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 

        li s2, 0x01090000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 

        li s2, 0x010b0000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 

        li s2, 0x010a0000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 

        li s2, 0x010c0000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait

        li s2, 0x010d0000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait

        li s2, 0x010f0000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 
        li s2, 0x010e0000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 
        li s2, 0x01000000 # Write 1 
        sw s2, 0(s0) # Write data to scroll 
        call small_wait 
        
        li s2, 0x00000001 # on_off 
        sw s2, 0(s0) # Turn on state machine 
        call wait 


                ############ DEAD BEEF #########
        li s2, 0x00000001   # on_off 
        sw s2, 0(s0)        # Turn off state machine
        call small_wait

        li s2, 0x00000100   # clear 
        sw s2, 0(s0)        # clear buffer
        call small_wait

        li s2, 0x00000100   # clear 
        sw s2, 0(s0)        # clear buffer
        call small_wait

        li s2, 0x001000000     #Doubles scorlling spedd
        sw s2, 0(s1)            #Write to control register[1]
        call small_wait


        li s2, 0x010D0000   # Write D
        sw s2, 0(s0)        # Write data to scroll
        call small_wait
        li s2, 0x010E0000   # Write E
        sw s2, 0(s0)        # Write data to scroll
        call small_wait
        li s2, 0x010A0000   # Write A
        sw s2, 0(s0)        # Write data to scroll
        call small_wait
        li s2, 0x010D0000   # Write D
        sw s2, 0(s0)        # Write data to scroll
        call small_wait
        li s2, 0x010B0000   # Write B
        sw s2, 0(s0)        # Write data to scroll
        call small_wait
        li s2, 0x010E0000   # Write E
        sw s2, 0(s0)        # Write data to scroll
        call small_wait
        li s2, 0x010E0000   # Write E
        sw s2, 0(s0)        # Write data to scroll
        call small_wait
        li s2, 0x010F0000   # Write F
        sw s2, 0(s0)        # Write data to scroll
        call small_wait


        li s2, 0x00000001   # on_off 
        sw s2, 0(s0)        # Turn on state machine
        call small_wait


        call wait

        ############ 1 #########
        li s2, 0x00000001   # on_off 
        sw s2, 0(s0)        # Turn off state machine
        call small_wait

        li s2, 0x00000100   # clear 
        sw s2, 0(s0)        # clear buffer
        call small_wait

        li s2, 0x01010000   # Write 1
        sw s2, 0(s0)        # Write data to scroll
        call small_wait

        li s2, 0x00000001   # on_off 
        sw s2, 0(s0)        # Turn on state machine

        call wait



        ############ 2 3 #########
        li s2, 0x00000001   # on_off 
        sw s2, 0(s0)        # Turn off state machine
        call small_wait

        li s2, 0x00000100   # clear 
        sw s2, 0(s0)        # clear buffer
        call small_wait

        li s2, 0x01020000   # Write 2
        sw s2, 0(s0)        # Write data to scroll
        call small_wait

        li s2, 0x01030000   # Write 3
        sw s2, 0(s0)        # Write data to scroll
        call small_wait
        li s2, 0x00000001   # on_off 
        sw s2, 0(s0)        # Turn on state machine
        call wait

        ############ 0 0 0 0 0 #########
        li s2, 0x00000001   # on_off 
        sw s2, 0(s0)        # Turn off state machine
        call small_wait

        li s2, 0x00000100   # clear 
        sw s2, 0(s0)        # clear buffer
        call small_wait

        li s2, 0x01000000   # Write 0
        sw s2, 0(s0)        # Write data to scroll
        call small_wait

        li s2, 0x01000000   # Write 0
        sw s2, 0(s0)        # Write data to scroll
        call small_wait

        li s2, 0x01000000   # Write 0
        sw s2, 0(s0)        # Write data to scroll
        call small_wait

        li s2, 0x01000000   # Write 0
        sw s2, 0(s0)        # Write data to scroll
        call small_wait
        
        li s2, 0x01000000   # Write 0
        sw s2, 0(s0)        # Write data to scroll
        call small_wait

        li s2, 0x00000001   # on_off 
        sw s2, 0(s0)        # Turn on state machine

        call wait

        li s2, 0x00000001   # on_off 
        sw s2, 0(s0)        # Turn off state machine
        call small_wait

        li s2, 0x00000100   # clear 
        sw s2, 0(s0)        # clear buffer
        call small_wait

        
        
        
            j loop

# .global _main

# _main:
#     li s0, 0x000F0040   #Scroll top base addressss
#     li s1, 0x000F0044   # Scroll top second word adrees
#     li s3, 1            # small wait counter top value: simulation
#     li s4, 70            # wait counter top value: simulation 50

#     li s5, 0x01000000   # shifts instruction
#     li s6, 0x00010000   # clear instruction
#     li s7, 0x00000100   # write instruction
#     li s8, 0x00000010   # off instruction, write on, because otherwise does not make sense
#     li s9, 0x01000100   # shif and add instruction
    
#     #li s4, 0xFFC000     # wait counter top value: synthesis

#     li s2, 0x0000000F      #Initialize count value to F
#     sw s2, 0(s1)            #Write to control register[1]

#     loop:
#         ##Start with 000000000
#         li s2, 0x01010000   # Write 1
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x01030000   # Write 3
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x01020000   # Write 2
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x01040000   # Write 4
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x01050000   # Write 5
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x01070000   # Write 7
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x01060000   # Write 6
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x01080000   # Write 8
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x01090000   # Write 9
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x010B0000   # Write B
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x010A0000   # Write A
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x010C0000   # Write C
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x010D0000   # Write D
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x010F0000   # Write F
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x010E0000   # Write E
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x01000000   # Write 0
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait



        
#         li s2, 0x00000001   # on_off 
#         sw s2, 0(s0)        # Turn on state machine
#         call small_wait

#         call wait

#         ############ DEAD BEEF #########
#         li s2, 0x00000001   # on_off 
#         sw s2, 0(s0)        # Turn off state machine
#         call small_wait

#         li s2, 0x00000100   # clear 
#         sw s2, 0(s0)        # clear buffer
#         call small_wait

#         li s2, 0x00000007      #Doubles scorlling spedd
#         sw s2, 0(s1)            #Write to control register[1]
#         call small_wait


#         li s2, 0x010D0000   # Write D
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x010E0000   # Write E
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x010A0000   # Write A
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x010D0000   # Write D
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x010B0000   # Write B
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x010E0000   # Write E
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x010E0000   # Write E
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x010F0000   # Write F
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait

#         li s2, 0x00000001   # on_off 
#         sw s2, 0(s0)        # Turn on state machine
#         call small_wait

#         call wait

#         ############ 1 #########
#         li s2, 0x00000001   # on_off 
#         sw s2, 0(s0)        # Turn off state machine
#         call small_wait

#         li s2, 0x00000100   # clear 
#         sw s2, 0(s0)        # clear buffer
#         call small_wait

#         li s2, 0x01010000   # Write 1
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait

#         li s2, 0x00000001   # on_off 
#         sw s2, 0(s0)        # Turn on state machine

#         call wait



#         ############ 2 3 #########
#         li s2, 0x00000001   # on_off 
#         sw s2, 0(s0)        # Turn off state machine
#         call small_wait

#         li s2, 0x00000100   # clear 
#         sw s2, 0(s0)        # clear buffer
#         call small_wait

#         li s2, 0x01020000   # Write 2
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait

#         li s2, 0x01030000   # Write 3
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
#         li s2, 0x00000001   # on_off 
#         sw s2, 0(s0)        # Turn on state machine
#         call wait

#         ############ 0 0 0 0 0 #########
#         li s2, 0x00000001   # on_off 
#         sw s2, 0(s0)        # Turn off state machine
#         call small_wait

#         li s2, 0x00000100   # clear 
#         sw s2, 0(s0)        # clear buffer
#         call small_wait

#         li s2, 0x01000000   # Write 0
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait

#         li s2, 0x01000000   # Write 0
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait

#         li s2, 0x01000000   # Write 0
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait

#         li s2, 0x01000000   # Write 0
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait
        
#         li s2, 0x01000000   # Write 0
#         sw s2, 0(s0)        # Write data to scroll
#         call small_wait

#         li s2, 0x00000001   # on_off 
#         sw s2, 0(s0)        # Turn on state machine

#         call wait

#         li s2, 0x00000001   # on_off 
#         sw s2, 0(s0)        # Turn off state machine
#         call small_wait

#         li s2, 0x00000100   # clear 
#         sw s2, 0(s0)        # clear buffer
#         call small_wait


#         j loop


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