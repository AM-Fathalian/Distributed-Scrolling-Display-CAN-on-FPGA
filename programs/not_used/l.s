# ==========================================================
# FIXED CODE - FINAL VERSION
# ==========================================================

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
# TIMER CONSTANTS
# ----------------------------------------------------------
li s3, 0x00000001     # Short delay bound
li s4, 0x8FFC000      # Longer delay bound

# ----------------------------------------------------------
# INITIALIZE DISPLAY / RING BUFFER
# ----------------------------------------------------------

# Preload display counter
li t1, 0x002000000   
sw t1, 4(s10)

# Clear display buffer
li t1, 0x00000100     
sw t1, 0(s10)

# ----------------------------------------------------------
# ENABLE STATE MACHINE
# ----------------------------------------------------------

li t1, 0x01
sw t1, 0(s10)         # Enable external logic that triggers interrupts


# ==========================================================
# CAN CONTROLLER INITIALIZATION
# ==========================================================

    # Disable host interrupts during config
    li t1, 0x00 << 16
    csrw mie, t1

# ---- Enter RESET mode ----
reset_mode:
    lb t3, 0(s2)            # load ModeControlReg
    li t2, 0x01
    and t3, t3, t2          # check reset bit
    bnez t3, end_reset_mode # if 1, we are in reset

    lb t1, 0(s2)
    li t2, 0x01
    or t1, t1, t2           # Set Reset Request bit
    sb t1, 0(s2)   
    j reset_mode
end_reset_mode:

# ---- Configure CAN ----
    # Clock Divider
    li t1, 0x00
    sb t1, 31(s2)

    # Disable interrupts inside CAN chip
    li t1, 0
    sb t1, 3(s2)

    # Baud Rate
    li t1, 0x18   # BTR0
    sb t1, 0x06(s2)
    li t1, 0x1c   # BTR1
    sb t1, 0x07(s2)

    # Acceptance Filter (Accept All)
    li t1, 0x00
    sb t1, 0x04(s2)
    li t1, 0xFF
    sb t1, 0x05(s2)

    # Output Control
    li t1, 0x02   # Tx1Float | Tx0PshPull | NormalMode
    sb t1, 8(s2)


# ---- Leave RESET mode ----
clear_reset:
    li t2, 0x00
    sb t2, 0(s2)            # Write 0 to control reg

    lb t1, 0(s2)            
    li t2, 0x01
    and t1, t1, t2          
    bnez t1, clear_reset    # Wait until bit is 0


# ---- Enable Interrupts ----
    li t1, 0x02             # Enable Receive Interrupt (RIE) inside CAN
    sb t1, 0x00(s2)

    # Enable Host Interrupts (External bits)
    li t1, 0xF << 16
    csrw mie, t1


# ----------------------------------------------------------
# BUILD CLIENT ID
# ----------------------------------------------------------
li t1, 0x01           # Client ID 

# ID LOW
li s5, 0x00
andi s5, t1, 0x07     
slli s5, s5, 5        

# ID HIGH
li t2, 0x00
srli t2, t1, 3        
ori s6, t2, 0x04      # Set standard frame bit

# ==========================================================
# MAIN LOOP
# ==========================================================

    # li t0, 0x10
    # li t1, 0x000F0000 
    # sw t0, 0(t1)      # Debug LED: Main Start

main_loop:
    # ------------------------------------------------------
    # CHECK: Clear Buffer Flag (bit 2)
    # ------------------------------------------------------
    andi t1, s1, 0x04
    beqz t1, check_speed_flag

    # Clear bit 2
    li t2, ~0x04
    and s1, s1, t2

    call send_clear_message

    li t2, 0x00000100     
    sw t2, 0(s10)      # Send clear command to display

    # ------------------------------------------------------
    # CHECK: Update Speed Flag (bit 1)
    # ------------------------------------------------------
check_speed_flag:
    andi t1, s1, 0x02
    beqz t1, check_send_flag 

    # Clear bit 1
    li t2, ~0x02
    and s1, s1, t2

    call read_switches
    call send_Speed_message

    # Update display with speed data
    slli t2, s7, 16
    sw t2, 4(s10)

    # ------------------------------------------------------
    # CHECK: Send Message Flag (bit 0)
    # ------------------------------------------------------
check_send_flag:
    andi t1, s1, 0x01
    beqz t1, check_can_flag

    # Clear bit 0
    li t2, ~0x01
    and s1, s1, t2

    call read_switches
    call send_CAN_message

    # Update display 
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

    # CRITICAL: Disable interrupts while reading shared data
    # This prevents the ISR from overwriting s8/s6/s9 while we use them
    li t1, 0
    csrw mie, t1 

    # Clear bit 3
    li t2, ~0x08
    and s1, s1, t2
    
    # Process the message
    call handle_can_message

    # Re-enable interrupts
    li t1, 0xF << 16
    csrw mie, t1

    j main_loop        

# ==========================================================
# DELAY & HELPER ROUTINES
# ==========================================================

small_wait:
    li t2, 0
inc_i2:
    addi t2, t2, 1
    ble t2, s3, inc_i2
    ret

read_switches:
    lw s7, 0(s0)       
    ret

# ==========================================================
# SEND ROUTINES
# ==========================================================

send_CAN_message:
    wait_tx_buffer_free_1:
        li t1, 0x000F0100
        lb t2, 2(t1)
        andi t2, t2, 0x04  
        beqz t2, wait_tx_buffer_free_1

    # Setup ID (Fixed: Don't use s6, it gets corrupted by ISR)
    li t1, 0x04            # Hardcoded ID High (Standard Frame)
    sb t1, 0x0A(s2)        
    li t1, 0x02
    or t2, s5, t1
    sb t2, 0x0B(s2)        

    # Data Payload
    li t1, 0x00
    sb t1, 0x0C(s2)        
    sb s7, 0x0D(s2)        

    # Trigger
    li t1, 0x01
    sb t1, 0x01(s2)
    ret

send_clear_message:
    wait_tx_buffer_free_2:
        li t1, 0x000F0100
        lb t2, 2(t1)
        andi t2, t2, 0x04  
        beqz t2, wait_tx_buffer_free_2

    li t1, 0x04            # Hardcoded ID High
    sb t1, 0x0A(s2)        
    li t1, 0x01
    or t2, s5, t1
    sb t2, 0x0B(s2)        

    li t1, 0x01
    sb t1, 0x0C(s2)        

    li t1, 0x01
    sb t1, 0x01(s2)
    ret

send_Speed_message:
    wait_tx_buffer_free_3:
        li t1, 0x000F0100
        lb t2, 2(t1)
        andi t2, t2, 0x04  
        beqz t2, wait_tx_buffer_free_3

    li t1, 0x04            # Hardcoded ID High
    sb t1, 0x0A(s2)        
    li t1, 0x03
    or t2, s5, t1
    sb t2, 0x0B(s2)        

    li t1, 0x02
    sb t1, 0x0C(s2)        
    sb s7, 0x0D(s2)        
    srl t2, s7, 8
    sb t2, 0x0E(s2)      

    li t1, 0x01
    sb t1, 0x01(s2)
    ret


# ==========================================================
# MESSAGE HANDLER
# ==========================================================
handle_can_message:
    # li t0, 0xFF
    # li t1, 0x000F0000 
    sw t0, 0(t1)   

    li t3, 0
    beq s8, t3, handle_switch_msg

    li t3, 1
    beq s8, t3, handle_clear_msg

    li t3, 2
    beq s8, t3, handle_speed_msg

    ret

handle_switch_msg:
    # li t0, 0x0F
    # li t1, 0x000F0000 
    sw t0, 0(t1)   

    li s11, 0x01000000
    slli t2, s6, 16    # CHANGED: t4 -> t2 (Safe from ISR)
    or s11, s11, t2
    sw s11, 0(s10)     
    ret

handle_clear_msg:
    # li t0, 0xF0
    # li t1, 0x000F0000 
    sw t0, 0(t1)   

    li t1, 0x00000100
    sw t1, 0(s10)
    ret

handle_speed_msg:
    # li t0, 0xAA
    # li t1, 0x000F0000 
    # sw t0, 0(t1)   

    slli t2, s9, 8     # High byte in bits 8-15
    or t2, t2, s6      # Low byte in bits 0-7, now t2 has full 16-bit value
    slli t2, t2, 16    # ✓ SHIFT TO BITS 16-31 (most significant bits)
    sw t2, 4(s10)      # Now matches transmitter format
    ret

    ret
    
# ==========================================================
# INTERRUPT SERVICE ROUTINES (FIXED)
# ==========================================================

.global _send_message_isr
_send_message_isr:
    # Use atomic OR or just set it. 
    # Since only s1 is touched, this is relatively safe.
    ori s1, s1, 0x01
    mret

.global _can_isr
_can_isr:
    # -----------------------------------------------------
    # FIX: USING SAFE REGISTERS (t4, t5, t6)
    # FIX: USING LBU (Unsigned Load)
    # -----------------------------------------------------
    
    # Debug LED using SAFE registers
    # li t4, 0x55
    # li t5, 0x000F0000 
    # sw t4, 0(t5)

    # Set Flag
    ori s1, s1, 0x08

    # Read ID/DLC using LBU
    lbu t6, 0x14(s2)   # Using t6 instead of t3
    lbu t5, 0x15(s2)   # Using t5 instead of t2
    andi t5, t5, 0x0F 

    # Compare DLC (using t6 for constant comparison)
    li t6, 3
    beq t6, t5, read_3

    li t6, 2
    beq t6, t5, read_2

    li t6, 1
    beq t6, t5, read_1

    j release_buffer

read_3:
    lbu s8, 0x16(s2)   # FIX: lbu prevents sign extension
    lbu s6, 0x17(s2)   # FIX: lbu
    lbu s9, 0x18(s2)   # FIX: lbu
    j release_buffer

read_2:
    lbu s8, 0x16(s2)   # FIX: lbu
    lbu s6, 0x17(s2)   # FIX: lbu
    j release_buffer

read_1:
    lbu s8, 0x16(s2)   # FIX: lbu

release_buffer:
    # Release buffer
    li t6, 0x04        # Using t6 (safe)
    sb t6, 0x01(s2)

    # Debug LED end
    # li t4, 0xCC
    # li t5, 0x000F0000 
    # sw t4, 0(t5)

    mret

.global _update_speed_isr
_update_speed_isr:
    ori s1, s1, 0x02
    mret

.global _clear_buffer_isr
_clear_buffer_isr:
    ori s1, s1, 0x04
    mret