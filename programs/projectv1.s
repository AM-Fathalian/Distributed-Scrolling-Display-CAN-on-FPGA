#NUMBER OF HOURS WASTED: 48

.global _main
_main:

# ----------------------------------------------------------
# BASE ADDRESSES (memory-mapped peripherals)
# ----------------------------------------------------------

li s0, 0x000F0020     # Switch input register
li s10, 0x000F0060    # Scroll / ring buffer display
li s2, 0x000F0100     # CAN controller base address
li s1, 0              # s1 used as interrupt flag register (bits 0..3)

# ----------------------------------------------------------
# TIMER CONSTANTS (for software delays)
# ----------------------------------------------------------
li s3, 0x00000001     # Short delay bound
li s4, 0x8FFC000      #0x00001000     # Longer delay bound

# ----------------------------------------------------------
# INITIALIZE DISPLAY / RING BUFFER
# ----------------------------------------------------------

# Preload display counter
li t1, 0x002000000   #0x0000000F  syntheis: #0x02000000
sw t1, 4(s10)

# Clear display buffer
li t1, 0x00000100     
sw t1, 0(s10)

# ----------------------------------------------------------
# ENABLE STATE MACHINE / HARDWARE LOGIC
# ----------------------------------------------------------

li t1, 0x01
sw t1, 0(s10)          # Enable external logic that triggers interrupts


# ==========================================================
# CAN CONTROLLER INITIALIZATION (RUNS ONCE)
# ==========================================================
    # disable host interrupts
    li t1, 0x00 << 16
    csrw mie, t1

# ---- Enter RESET mode before configuring ----
# THIS IS ONE OF THE MOST IMPORTANT CHANGES, previosuly:
# li t1, 0x01
# sb t1, 0(s2)          # MOD = 1 → reset mode
# NOW:
reset_mode:
    lb t3, 0(s2)            # load ModeControlReg
    li t2, 0x01
    and t3, t3, t2          # ModeControlReg & RM_RR_Bit
    bnez t3, end_reset_mode # while((ModeControlReg & RM_RR_Bit ) == ClrByte)


lb t1, 0(s2)
li t2, 0x01
or t1, t1, t2
sb t1, 0(s2)   

    j reset_mode
end_reset_mode:


# THE 5 BIT of the register is 1, and without the OR,
#we overwrite them, breaking everything, while being an reserved bit

  # set clock divider register (not necessary actually)
    li t1, 0x00
    sb t1, 31(s2)

    # disable interrupts in IR
    li t1, 0
    sb t1, 3(s2)

# ---- Bit timing (baud rate) ----
li t1, 0x18   #18  sim 3
sb t1, 0x06(s2)       # BTR0

li t1, 0x1c   #1c  sim 1c
sb t1, 0x07(s2)       # BTR1

# ---- Acceptance filter: accept ALL frames ----
li t1, 0x00
sb t1, 0x04(s2)       # ACR = don't care

li t1, 0xFF
sb t1, 0x05(s2)       # AMR = mask disabled

    # set output control register
    # OutControlReg = Tx1Float | Tx0PshPull | NormalMode;
    li t1, 0x02             # Tx1Float | Tx0PshPull | NormalMode
    sb t1, 8(s2)


# ---- Leave reset, enter normal CAN mode ----
#SAME IMPORTANT CHANGE
clear_reset:
    li t2, 0x00
    sb t2, 0(s2)            # ModeControlReg = ClrByte;

    lb t1, 0(s2)            # load control register
    li t2, 0x01
    and t1, t1, t2          # ModeControlReg & RM_RR_Bit
    bnez t1, clear_reset    # while((ModeControlReg & RM_RR_Bit ) != ClrByte)



lb t1, 0(s2)
li t2, 0x00
or t1, t1, t2
sb t1, 0(s2)   

# ---- Enable receiver + RX interrupt ----
# li t1, 0x04           # RE = 1, RIE = 1
# sb t1, 0x0F(s2)

li t1, 0x02           # Enable receive interrupt
sb t1, 0x00(s2)

    # enable host interrupts
    li t1, 0xF << 16
    csrw mie, t1


# ----------------------------------------------------------
# BUILD 5-BIT CLIENT ID FOR CAN
# ----------------------------------------------------------
li t1, 0x01           # Client ID (only bits [4:0] are valid)

# ---- ID LOW (lower 3 bits go here, shifted into bits 7:5) ----
li s5, 0x00
andi s5, t1, 0x07     # keep only bits [2:0]
slli s5, s5, 5        # move them to bits [7:5]

# ---- ID HIGH (upper 2 bits + "standard frame" flag) ----
li t2, 0x00
srli t2, t1, 3        # extract bits [4:3]
ori s6, t2, 0x04      # set bit 3 = standard CAN frame

# ==========================================================
# MAIN LOOP
# ==========================================================

    li t0, 0x10
    li t1, 0x000F0000 # LED address
    sw t0, 0(t1)   # keep LED/debug write if you want

main_loop:
    # ------------------------------------------------------
    # CHECK: Clear Buffer Flag (bit 2)
    # ------------------------------------------------------
    andi t1, s1, 0x04
    beqz t1, check_speed_flag   # If 0, skip to next check

    # Clear bit 2
    li t2, ~0x04
    and s1, s1, t2



    call send_clear_message


    # li t0, 0x10
    # li t1, 0x000F0000 # LED address
    # sw t0, 0(t1)   # keep LED/debug write if you want



    li t2, 0x00000100     
    sw t2, 0(s10)               # Send clear command to display


    # ------------------------------------------------------
    # CHECK: Update Speed Flag (bit 1)
    # ------------------------------------------------------
check_speed_flag:
    andi t1, s1, 0x02
    beqz t1, check_send_flag    # If 0, skip to next check

    # Clear bit 1
    li t2, ~0x02
    and s1, s1, t2


    # Logic to update speed (read switches and update display)
    call read_switches
    call send_Speed_message


    # li t0, 0x13
    # li t1, 0x000F0000 # LED address
    # sw t0, 0(t1)   # keep LED/debug write if you want



    # Update display with speed data
    slli t2, s7, 16
    sw t2, 4(s10)

    # ------------------------------------------------------
    # CHECK: Send Message Flag (bit 0)
    # ------------------------------------------------------
check_send_flag:
    andi t1, s1, 0x01
    beqz t1, check_can_flag          # If nothing to send, restart loop


    # Clear bit 0
    li t2, ~0x01
    and s1, s1, t2




    # Execute original tasks
    call read_switches
    call send_CAN_message

    # li t0, 0xFF
    # li t1, 0x000F0000 # LED address
    # sw t0, 0(t1)   # keep LED/debug write if you want

    


    # Update display with switch data
    li s11, 0x01000000
    slli t4, s7, 16
    or s11, s11, t4
    sw s11, 0(s10)

    # ------------------------------------------------------
    # CHECK: Received message (bit 3)
    # ------------------------------------------------------
check_can_flag:
    andi t1, s1, 0x08
    beqz t1, main_loop

    # Clear bit 3
    li t2, ~0x08
    and s1, s1, t2

    call handle_can_message

    j main_loop        

# ==========================================================
# DELAY ROUTINES
# ==========================================================

small_wait:
    li t2, 0
inc_i2:
    addi t2, t2, 1
    ble t2, s3, inc_i2
    ret

wait:
    li t1, 0
inc_i:
    addi t1, t1, 1
    ble t1, s4, inc_i
    ret

# ==========================================================
# READ SWITCHES
# ==========================================================
read_switches:
    lw s7, 0(s0)       # Capture current switch state
    ret

# ==========================================================
# SEND CAN MESSAGE
# ==============    ============================================
send_CAN_message:

    #ANOTHER BUG PREVIUOUSLY: CALL WAIT_TX_BUUFER_FREE
    #BUT YOU CANNOT CALL A FUNCTION INSIDE ANOTHER FUNCTION, THE RET POINTER WILL BE OVERWRTITTEN,
    # AND WONT BE ABLE TO RETURN THE MAIN LOOP

    wait_tx_buffer_free_1:
        li t1, 0x000F0100
        lb t2, 2(t1)
        andi t2, t2, 0x04  # check TX buffer status
        beqz t2, wait_tx_buffer_free_1

    # 1) Setup ID and Control
    sb s6, 0x0A(s2)        # ID HIGH
    li t1, 0x02
    or t2, s5, t1
    sb t2, 0x0B(s2)        # ID LOW + DLC

    # 2) Data Payload
    li t1, 0x00
    sb t1, 0x0C(s2)        # Byte 0
    sb s7, 0x0D(s2)        # Byte 1 (The switches read in s7)

    # 3) Request Transmission
    li t1, 0x01
    sb t1, 0x01(s2)

        li t0, 0x33
    li t1, 0x000F0000 # LED address
    sw t0, 0(t1)   # keep LED/debug write if you want

    # # 4) Wait for hardware
    #     lbu t2, 0x02(s2)       # Read status
    # andi t2, t2, 0x08      # Mask TCS bit
    # beqz t2, wait_transmission_complete


    # 5) Update Ring Buffer
    # li s11, 0x01000000
    # #or s11, s11, s7        # Combine
    # sw s11, 0(s10)          # Store to scroll display


    ret


send_clear_message:

    wait_tx_buffer_free_2:
        li t1, 0x000F0100
        lb t2, 2(t1)
        andi t2, t2, 0x04  # check TX buffer status
        beqz t2, wait_tx_buffer_free_2

    # 1) Setup ID and Control
    sb s6, 0x0A(s2)        # ID HIGH
    li t1, 0x01
    or t2, s5, t1
    sb t2, 0x0B(s2)        # ID LOW + DLC

    # 2) Data Payload
    li t1, 0x01
    sb t1, 0x0C(s2)        # Byte 0

    # 3) Request Transmission
    li t1, 0x01
    sb t1, 0x01(s2)


    ret

send_Speed_message:

    wait_tx_buffer_free_3:
        li t1, 0x000F0100
        lb t2, 2(t1)
        andi t2, t2, 0x04  # check TX buffer status
        beqz t2, wait_tx_buffer_free_3
    # 1) Setup ID and Control
    sb s6, 0x0A(s2)        # ID HIGH
    li t1, 0x03
    or t2, s5, t1
    sb t2, 0x0B(s2)        # ID LOW + DLC

    # 2) Data Payload
    li t1, 0x02
    sb t1, 0x0C(s2)        # Byte 0
    sb s7, 0x0D(s2)        # Byte 1 (The switches read in s7, first 8 bits)
    srl t2, s7, 8
    sb t2, 0x0E(s2)      # Byte 2 (The switches read in s7, bits 8-15)

    # 3) Request Transmission
    li t1, 0x01
    sb t1, 0x01(s2)


    ret



# ==========================================================
# OPTIONAL WAIT ROUTINES (currently unused)
# ==========================================================

# wait_tx_buffer_free:
#     li t1, 0x000F0100
#     lb t2, 2(t1)
#     andi t2, t2, 0x04  # check TX buffer status
#     beqz t2, wait_tx_buffer_free
#     ret

# wait_transmission_complete:
#     wait_done:
#     lbu t2, 0x02(s2)       # Read status register
#     andi t2, 0x08      # Mask TCS bit
#     beqz t2, wait_done     # Wait until transmission finished

#     # Clear the interrupt / latch
#     lbu t1, 0x03(s2)

#     ret


handle_can_message:
    
    li t0, 0xFF
    li t1, 0x000F0000 # LED address
    sw t0, 0(t1)   # keep LED/debug write if you want


    li t3, 0
    beq s8, t3, handle_switch_msg

    li t3, 1
    beq s8, t3, handle_clear_msg

    li t3, 2
    beq s8, t3, handle_speed_msg

    ret

# ------------------------------------------------------
# Command 0: Switch Message
# ------------------------------------------------------
handle_switch_msg:

    li t0, 0x0F
    li t1, 0x000F0000 # LED address
    sw t0, 0(t1)   # keep LED/debug write if you want


    li s11, 0x01000000
    slli t4, s6, 16
    or s11, s11, t4
    sw s11, 0(s10)
    ret

# ------------------------------------------------------
# Command 1: Clear Display
# ------------------------------------------------------
handle_clear_msg:
    li t0, 0xF0
    li t1, 0x000F0000 # LED address
    sw t0, 0(t1)   # keep LED/debug write if you want


    li t1, 0x00000100
    sw t1, 0(s10)
    ret

# ------------------------------------------------------
# Command 2: Speed Message (16-bit)
# ------------------------------------------------------
handle_speed_msg:
    li t0, 0xAA
    li t1, 0x000F0000 # LED address
    sw t0, 0(t1)   # keep LED/debug write if you want

    slli t4, s9, 8
    or t4, t4, s6
    sw t4, 4(s10)
    ret



# ==========================================================
# INTERRUPT SERVICE ROUTINES
# ==========================================================

.global _send_message_isr
_send_message_isr:
    # Set bit 0 in flag register
    ori s1, s1, 0x01

    li t0, 0x01
    li t1, 0x000F0000 # LED address
    sw t0, 0(t1)   # keep LED/debug write if you want

    mret

.global _can_isr
_can_isr:
    li t0, 0x55
    li t1, 0x000F0000 # LED address
    sw t0, 0(t1)   # keep LED/debug write if you want

    # Set bit 3 in flag register
    ori s1, s1, 0x08

    lb t3, 0x14(s2)
    lb t2, 0x15(s2)  #ID + DLC
    andi t2, t2,  0x0F   #DLC


    li t3, 3
    beq t3, t2, read_3

    li t3, 2
    beq t3, t2, read_2

    li t3, 1
    beq t3, t2, read_1

    

    j release_buffer

    read_3:
    lb s8, 0x16(s2)   # command byte 
    lb s6, 0x17(s2)   #  data low
    lb s9, 0x18(s2)   # data high

    j release_buffer

    

    read_2:
    lb s8, 0x16(s2)   # command byte 
    lb s6, 0x17(s2)   #  data low
    j release_buffer

    read_1:
    lb s8, 0x16(s2)   # command byte 

    


    release_buffer:
    # release receive buffer
    li t1, 0x04
    sb t1, 0x01(s2)

    li t0, 0xCC
    li t1, 0x000F0000 # LED address
    sw t0, 0(t1)   # keep LED/debug write if you want

    mret

.global _update_speed_isr
_update_speed_isr:
    # Set bit 1 in flag register
    ori s1, s1, 0x02

    mret

.global _clear_buffer_isr
_clear_buffer_isr:
    # Set bit 2 in flag register
    ori s1, s1, 0x04

    mret