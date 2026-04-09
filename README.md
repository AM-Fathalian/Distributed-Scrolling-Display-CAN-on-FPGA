# Distributed-Scrolling-Display-CAN-on-FPGA

This repository contains the publicly shareable portion of an educational SoC
project developed as part of an Embedded Systems Lab course.  It demonstrates
the full design stack: RISC-V assembly programming, custom peripheral design in
SystemVerilog, bus interconnect integration, and FPGA implementation on the
**Digilent Nexys A7-100T** board.

> **Note on private IP**: The processor core (`soc/core/cv32e40p/`), the clock
> divider IP (`soc/peripheral/clk_div/`), and the open-source CAN controller
> (`soc/peripheral/CAN/`) are third-party or institution-internal components.
> The files made by the project team are described in the
> [Team-Authored Files](#team-authored-files) section below.

---

## Table of Contents

1. [Assignment Specification](#assignment-specification)
   - [Project Overview (Assignment)](#project-overview-assignment)
   - [Development Target](#development-target)
   - [Switches and Buttons as System Input](#switches-and-buttons-as-system-input)
   - [The CAN Controller](#the-can-controller)
   - [The Data Protocol](#the-data-protocol)
   - [Testing](#testing)
   - [Initialization Problem](#initialization-problem)
   - [Completion](#completion)
2. [Project Overview](#project-overview)
3. [Repository Structure](#repository-structure)
4. [Architecture](#architecture)
   - [Processor Core](#processor-core)
   - [Bus Interconnect](#bus-interconnect)
   - [Memory](#memory)
   - [Peripherals](#peripherals)
5. [Memory Map](#memory-map)
6. [Team-Authored Files](#team-authored-files)
   - [System Configuration — `config_pkg.sv`](#system-configuration--config_pkgsv)
   - [Top Level](#top-level)
   - [Peripheral Modules](#peripheral-modules)
   - [Assembly Programs](#assembly-programs)
7. [Peripheral Reference](#peripheral-reference)
   - [LED Output](#led-output)
   - [Switch / Button Input](#switch--button-input)
   - [Scrolling 7-Segment Display](#scrolling-7-segment-display)
   - [CAN Bus Controller](#can-bus-controller)
8. [Assembly Programming Model](#assembly-programming-model)
   - [Interrupt Architecture](#interrupt-architecture)
   - [Boot Sequence](#boot-sequence)
   - [Register Conventions](#register-conventions)
9. [Building the Software](#building-the-software)
10. [Testbenches](#testbenches)
11. [Languages Used](#languages-used)

---

## Assignment Specification

> The full specification is also available as [`project2025c.pdf`](project2025c.pdf).
>
> *Source: Embedded Systems Laboratory, TU Kaiserslautern —
> apl. Prof. Dr.-Ing. Dominik Stoffel, Dipl.-Ing. Johannes Müller*

### Project Overview (Assignment)

The design project of this semester's Embedded Systems Lab extends previously
developed hardware and software.  The task is to develop a **client in a
distributed system**.  The main function of the system is to **synchronize a
dataset between all clients**.

Each client can modify the dataset using the switches and buttons (introduced in
Warmup 2).  To indicate the state of each client, the data is displayed using
the **scrolling text display** (from Warmup 4).  For synchronization, a simple
**CAN-based protocol** is provided to exchange data.

Each group plans the architecture in advance, identifies tasks, distributes
them among group members, and creates a schedule.  This plan is presented in a
review meeting before implementation begins.

---

### Development Target

Each client has a **data set consisting of 16 individual 5-bit values** that
encode hexadecimal characters, displayed on the scrolling text display.  The
data is shared by all clients in the system.

- Clients can make changes to the dataset using their buttons and switches.
- When a client changes the data it must **synchronize the change with all
  other clients** via the CAN bus.
- Only the scrolling **speed** and the **data set** need to be synchronous —
  not the exact time points of the changes on the display.

---

### Switches and Buttons as System Input

The switches component developed in Warmup 2 manages 5 buttons and 16
switches.  In this project the buttons implement three control functions
(each assigned to one button of your choice):

| Function | Input used |
|---|---|
| Add a 5-bit data item to the dataset | Bottom 5 switches |
| Clear the dataset | — |
| Update the scrolling speed | Top 16 switches |

For the scrolling speed the 16-bit switch value is interpreted as the **16 most
significant bits of a 32-bit unsigned number** (lower 16 bits filled with
zeros), keeping the speed in a human-observable range.

---

### The CAN Controller

The repository contains the hardware design for a CAN controller that is
functionally compatible with the **SJA1000 (and PCA82C200)**.  Use only the
basic transmit functions; do **not** use the PeliCAN mode.

- The controller is written in Verilog with an **8-bit Wishbone interface**
  (byte-accessible only).
- A SystemVerilog wrapper (`soc/peripheral/CAN/can_wrapper.sv`) connects it to
  the rest of the system.
- The wrapper does not extend its data interface beyond 8 bits, so only
  **byte-sized accesses** are allowed.

To physically interact with the CAN network a **CAN Transceiver Pmod** (RS-485
driver board) is connected to one of the Pmod connectors on the FPGA board.
The chosen connector's pins must be mapped in the `.xdc` constraints file.  The
maximum bit-rate is 16 Mbit/s; prior experience recommends choosing a
significantly lower value.

---

### The Data Protocol

The protocol uses three CAN frame types.  The **11-bit CAN ID** consists of a
6-bit fixed update code (`000001`) and a **5-bit client-unique node ID**.

#### Frame type 0 — Data Add

Sent when a client adds a character to the dataset.

| Field | Value |
|---|---|
| Frame type byte | `0x00` |
| Data byte | 5-bit character value |

Upon receiving a data-add frame the client should add the 5-bit character to
its dataset.  If the buffer is already full, the first element is overwritten
(consistent with the ring-buffer behaviour).

#### Frame type 1 — Dataset Clear

Sent when a client receives a clear command from the buttons.

| Field | Value |
|---|---|
| Frame type byte | `0x01` |

Both sender and receiver invoke the clear-buffer functionality of the display
controller.

#### Frame type 3 — Update Scrolling Speed

Sent when a client updates the scrolling speed.

| Field | Value |
|---|---|
| Frame type byte | `0x03` |
| Data bytes 1–2 | Bits [31:16] of the 32-bit scroll counter value (`cnt_value`) |

Multiple clients initiating updates at (roughly) the same time can cause race
conditions; consider how they can occur and how to avoid them.

---

### Testing

For successful verification, simulate a system with **multiple clients**: create
several instances of the SoC and connect their CAN ports together.  Adjust the
scrolling speed to reduce the simulation window size.

---

### Initialization Problem

Because the system is asynchronous and clients may be added or removed at any
time, a **new client does not start with a synchronized copy of the dataset**.
Consider possible solutions and present a protocol extension in the review
meeting.  Implementation of the solution is not required.

---

### Completion

**Review meeting** (before implementation):

- Present your project plan (hardware/software partitioning, task
  identification and distribution, timeline for implementation and testing).
- Schedule the meeting by contacting Prof. Stoffel.

**Demonstration** (after implementation), divided into two parts:

1. **Simulation**: at least two clients displaying patterns in sync; each
   client performs every update function at least once.
2. **FPGA implementation**: run on the Nexys A7-100T board; additional boards
   may be provided as peers in the CAN network.

The deadline is the last week of the lecture period.

---

## Project Overview

`lt16soc` is a 32-bit RISC-V SoC implemented in SystemVerilog and targeting the
Nexys A7-100T FPGA.  The system is designed as a complete embedded platform for
lab exercises, featuring:

- A **CV32E40P** RISC-V RV32IMC processor core
- A lightweight **OBI-compatible data bus interconnect**
- Memory-mapped **I/O peripherals** (LEDs, switches, 7-segment display, CAN)
- An **interrupt-driven software framework** written in RISC-V assembly
- A complete **CAN bus node** capable of transmitting and receiving frames

The project was developed iteratively across multiple work packages. The branch
[`FromWP4AgainAgainAgain`](https://github.com/alejandro3141592/esylab-backup/tree/FromWP4AgainAgainAgain)
contains the latest complete state of all team-authored files.

---

## Repository Structure

```
esylab-backup/
├── programs/                  # RISC-V assembly source code
│   ├── boot/
│   │   ├── boot.s             # Startup code (CSR init, interrupt enable)
│   │   └── vectortable.s      # Interrupt vector table
│   ├── not_used/              # Earlier / experimental program versions
│   ├── Makefile               # Build system
│   ├── platform.ld            # Linker script
│   ├── format_rom.py          # Post-processes objcopy output to .rom format
│   ├── projectv1.s            # Main project assembly (verbose / annotated)
│   └── projectv1_l.s          # Main project assembly (clean version)
│
└── soc/
    ├── core/
    │   ├── corewrapper.sv     # Wraps CV32E40P; exposes INSTR_BUS / DATA_BUS
    │   └── cv32e40p/          # CV32E40P processor core (third-party IP)
    │
    ├── lib/
    │   ├── config_pkg.sv      # ★ System address map & bus configuration
    │   ├── data_bus_pkg.sv    # DATA_BUS type definitions & constants
    │   ├── data_bus_intf.sv   # DATA_BUS SystemVerilog interface
    │   └── instr_bus_intf.sv  # INSTR_BUS SystemVerilog interface
    │
    ├── mem/
    │   ├── memdiv_32.sv       # Dual-port memory (instruction + data)
    │   ├── memwrapper.sv      # Glues memdiv_32 to INSTR_BUS and DATA_BUS
    │   ├── mem2db.sv          # DATA_BUS ↔ memory adapter
    │   └── mem2ib.sv          # INSTR_BUS ↔ memory adapter
    │
    ├── peripheral/
    │   ├── CAN/               # CAN controller (third-party Verilog)
    │   │   └── can_wrapper.sv # ★ OBI wrapper for the CAN controller
    │   ├── clk_div/           # Xilinx clock-wizard IP (100 MHz → 50 MHz)
    │   ├── clk_div.v          # Top-level clock divider stub
    │   ├── db_reg_intf.sv     # ★ Multi-word data bus register interface
    │   ├── db_reg_intf_simple.sv # ★ Single-word data bus register interface
    │   ├── hex2physical.sv    # ★ Hex digit → 7-segment cathode LUT
    │   ├── led.sv             # ★ LED output peripheral
    │   ├── scrolling_buffer.sv   # ★ 16-entry ring buffer for hex chars
    │   ├── scrolling_controller.sv # ★ FSM driving the display pipeline
    │   ├── scrolling_timer.sv    # ★ Configurable countdown timer
    │   ├── scrolling_top.sv      # ★ Scrolling display top module
    │   ├── seven_segment_display.sv     # ★ 8-digit 7-seg driver (basic)
    │   ├── seven_segment_display_adv.sv # ★ 8-digit 7-seg driver (advanced)
    │   ├── simple_timer.sv    # ★ Simple reload countdown timer
    │   └── switches.sv        # ★ Switch + button input with IRQ generation
    │
    ├── testbench/             # Simulation testbenches
    │
    └── top/
        ├── data_interconnect.sv # ★ OBI bus interconnect (master/slave mux)
        ├── top.sv               # ★ SoC top-level module
        └── top.xdc              # Xilinx pin constraints (Nexys A7-100T)
```

★ = team-authored file

---

## Architecture

```
                         ┌─────────────────────────────────────────┐
                         │              lt16soc_top                 │
  clk_sys ──► clk_div ──►│                                         │
  rst     ──────────────►│  ┌──────────────┐   INSTR_BUS           │
                         │  │ corewrapper  │──────────────────────►│──► memwrapper
                         │  │ (CV32E40P)   │   DATA_BUS            │
                         │  └──────────────┘──────────────────────►│
                         │                                         │
                         │  ┌────────────────────────────────────┐ │
                         │  │         data_interconnect          │ │
                         │  │  (OBI master/slave bus fabric)     │ │
                         │  └──┬─────┬──────┬──────────┬─────────┘ │
                         │     │     │      │          │           │
                         │  memwrapper  led  switches  scrolling_top  can_wrapper
                         └─────────────────────────────────────────┘
```

### Processor Core

The CPU is a **CV32E40P** (formerly RI5CY) implementing **RV32IMC** — the
standard 32-bit RISC-V ISA with the integer multiplication/division (M) and
compressed instruction (C) extensions.  It is wrapped by `corewrapper.sv`,
which connects it to the internal bus interfaces and routes 16 fast-interrupt
lines from the peripherals.

The core boots from address `0x00000080` (after the vector table at `0x40` and
boot code at `0x80`).

### Bus Interconnect

`data_interconnect.sv` implements a simple single-master OBI-compatible
interconnect.  It decodes the current master's address against each slave's
`base_addr`/`addr_mask` pair (read from a configuration sideband) and routes
the transaction.  A two-state FSM (IDLE / ACCESS) tracks outstanding
transactions to correctly return `rvalid`/`rdata` to the master.

### Memory

A single `memdiv_32` block serves both the instruction bus (read-only,
word-aligned) and the data bus (read/write, byte-enable).  Size is configured
by `IMEMSZ` in `config_pkg.sv` (default 1 024 words = 4 KB).  The `.rom` file
produced by the build system is loaded into this memory at synthesis/simulation
time.

### Peripherals

| Module | Slave index | Base address | Notes |
|---|---|---|---|
| `memwrapper` | 0 | `0x00000000` | Unified instruction + data memory |
| `io_led` | 2 | `0x000F0000` | 8-bit LED output |
| `io_sw` | 3 | `0x000F0020` | 16 switches + 5 buttons, 3 IRQ lines |
| `scrolling_top` | 4 | `0x000F0060` | Scrolling 7-segment display |
| `can_wrapper` | 5 | `0x000F0100` | SJA1000-compatible CAN controller |

---

## Memory Map

```
Address Range          Size     Peripheral
─────────────────────────────────────────────────────────
0x00000000 – 0x00000FFF   4 KB   Instruction / Data memory
0x000F0000 – 0x000F001F   32 B   LED output register
0x000F0020 – 0x000F003F   32 B   Switch / button input register
0x000F0060 – 0x000F0067    8 B   Scrolling display (2 × 32-bit words)
0x000F0100 – 0x000F011F   32 B   CAN controller registers
```

### Scrolling Display Register Layout

| Word offset | Bit(s) | Function |
|---|---|---|
| 0 | `[0]` | Rising edge → **on/off toggle** (enables/disables scrolling) |
| 0 | `[8]` | Rising edge → **buffer clear** |
| 0 | `[20:16]` | 5-bit hex character to write into the ring buffer |
| 0 | `[24]` | Rising edge → **buffer write** (latches `[20:16]`) |
| 1 | `[31:0]` | Scroll timer reload value (clock cycles per character step) |

### Switch / Button Register Layout

| Bit(s) | Function |
|---|---|
| `[15:0]` | Switch state (SW0–SW15) |
| `[20:16]` | Button state (BTN0–BTN4) |
| `[31:21]` | Reserved (reads 0) |

---

## Team-Authored Files

### System Configuration — `config_pkg.sv`

`soc/lib/config_pkg.sv` is the single source of truth for the entire SoC
configuration.  It imports `data_bus_pkg` and defines:

- **`RST_ACTIVE_HIGH`** — reset polarity override
- **`IMEMSZ`** — instruction memory size in words
- **`PROGRAMFILENAME`** — path to the `.rom` file used at simulation time
- **Slave/master index constants** (`CFG_CORE`, `CFG_LED`, `CFG_SW`, …)
- **`SLV_MASK_VECTOR`** — bit-vector enabling/disabling individual slaves on
  the interconnect
- **Base addresses** (`CFG_BADR_*`) and **address masks** (`CFG_MADR_*`) for
  every peripheral

### Top Level

**`soc/top/top.sv`** (`lt16soc_top`) instantiates every subsystem and wires
them together:

- Inverts the external reset to produce an active-high internal reset
- Passes the system clock through the Xilinx clock-wizard IP to produce the
  50 MHz design clock
- Aggregates four interrupt lines (`irq_lines[3:0]`) from buttons and CAN

**`soc/top/data_interconnect.sv`** implements the address-decode and
request-routing logic described in the [Bus Interconnect](#bus-interconnect)
section.

**`soc/top/top.xdc`** provides Xilinx Vivado pin constraints for the
Nexys A7-100T (clock, switches, LEDs, 7-segment anodes/cathodes, UART/CAN
transceiver signals).

### Peripheral Modules

| File | Description |
|---|---|
| `db_reg_intf.sv` | Generic OBI slave register bank; supports N words, read/write, optional writeback from hardware, and a `reg_read_o` strobe used as an interrupt source |
| `db_reg_intf_simple.sv` | Simplified single-word version of the above (write-only from the bus side) |
| `led.sv` (`io_led`) | Wraps `db_reg_intf_simple`; drives 8 LED outputs from bus bits `[7:0]` |
| `switches.sv` (`io_sw`) | Wraps `db_reg_intf`; presents switches and buttons as a read-only register; generates three edge-sensitive IRQ lines (right / bottom / left buttons) |
| `hex2physical.sv` | Pure combinational LUT mapping a 5-bit hex value (0–F + blank) to the 8 cathode signals of one 7-segment digit |
| `simple_timer.sv` | Synchronous countdown timer with configurable `timer_start` reload value; asserts `timer_overflow` for one cycle on each wrap |
| `seven_segment_display.sv` | Time-multiplexed 8-digit 7-segment display; accepts write/shift/clear/off control pulses; uses `simple_timer` for ~1 kHz refresh |
| `seven_segment_display_adv.sv` | Extended version of the above; adds an extra control-register word and uses `db_reg_intf` directly |
| `scrolling_timer.sv` | One-shot countdown timer; loads `cnt_value` on `cnt_start` and fires a one-cycle `cnt_done` pulse at expiry |
| `scrolling_buffer.sv` | 16-entry circular ring buffer; separates write and read pointers; on `next_char`, advances the read pointer and outputs the next 5-bit hex character; blanks the display when all written characters have scrolled past |
| `scrolling_controller.sv` | Three-state Mealy FSM (OFF → UPDATE → WAIT) that drives `seven_segment_display` signals; advances `scrolling_buffer` on each timer tick |
| `scrolling_top.sv` | Top-level assembly of the scrolling subsystem; instantiates `db_reg_intf`, `scrolling_timer`, `scrolling_buffer`, `scrolling_controller`, and `seven_segment_display`; detects rising edges on control bits and forwards them to the appropriate submodule |

### Assembly Programs

Both `programs/projectv1.s` and `programs/projectv1_l.s` implement the same
application at different annotation levels.  They are the primary deliverable
of the software work package.

**Boot infrastructure (`programs/boot/`)**

| File | Role |
|---|---|
| `vectortable.s` | 16-entry interrupt vector table placed at `0x40`; entries 0–3 jump to named ISR labels; entries 4–15 execute `mret` |
| `boot.s` | Sets `mtvec` to vectored mode (`base=0, mode=1`), enables fast interrupts in `mie` (bits `[19:16]`), globally enables interrupts in `mstatus`, then jumps to `_main` |

**Application (`projectv1_l.s` — clean version)**

The program implements a **CAN bus node** that:

1. Initialises the scrolling display (loads scroll timer, clears buffer,
   enables the state machine)
2. Configures the SJA1000-compatible CAN controller in reset mode, programs
   bit-timing registers (BTR0/BTR1), sets an open acceptance filter, and
   leaves reset mode with the receive interrupt enabled
3. Builds a 5-bit CAN node ID from hardcoded constants and formats it into the
   CAN ID high/low bytes
4. Enters a **flag-based main loop** that tests four bits of the `s1` interrupt
   flag register and dispatches to the corresponding handler:

   | Flag bit | Source | Action |
   |---|---|---|
   | `s1[0]` | Button right IRQ | Read switches → transmit CAN frame → update display with switch values |
   | `s1[1]` | Button bottom IRQ | Read switches → transmit speed CAN frame → update display with speed |
   | `s1[2]` | Button left IRQ | Transmit "clear" CAN frame → clear display buffer |
   | `s1[3]` | CAN receive IRQ | Read and process incoming CAN frame |

5. Each ISR (`_send_message_isr`, `_update_speed_isr`, `_clear_buffer_isr`,
   `_can_isr`) saves/restores registers, sets the corresponding flag bit in
   `s1`, and returns with `mret`

---

## Peripheral Reference

### LED Output

```
Base address : 0x000F0000
Access       : write word (only bits [7:0] are used)
```

Write an 8-bit value to set the 16 on-board LEDs (lower byte only in this
configuration).

**Example:**
```asm
li  t0, 0x000F0000
li  t1, 0b10101010
sw  t1, 0(t0)
```

### Switch / Button Input

```
Base address : 0x000F0020
Access       : read word
Interrupts   : irq_lines[0] (right button), [1] (bottom button), [2] (left button)
```

Reading this register also clears any pending button interrupt.

**Example:**
```asm
li  t0, 0x000F0020
lw  t1, 0(t0)       # t1[15:0] = switches, t1[20:16] = buttons
```

### Scrolling 7-Segment Display

```
Base address : 0x000F0060
Word 0       : control register
Word 1       : scroll timer reload value (cycles per step)
```

The display stores up to 16 hex characters in a ring buffer and scrolls them
across the 8-digit display at the programmed rate.

**Typical initialisation sequence:**
```asm
li  s10, 0x000F0060

# 1. Set scroll speed (e.g., 0x02000000 cycles per step)
li  t1, 0x02000000
sw  t1, 4(s10)

# 2. Clear the ring buffer
li  t1, 0x00000100   # bit [8] rising edge
sw  t1, 0(s10)

# 3. Enable scrolling (bit [0] rising edge)
li  t1, 0x01
sw  t1, 0(s10)
```

**Writing a character (hex digit 0xA):**
```asm
# Place value in bits [20:16], trigger write with bit [24]
li  t1, 0x010A0000   # bit[24]=1, bits[20:16]=0x0A
sw  t1, 0(s10)
```

### CAN Bus Controller

```
Base address : 0x000F0100
Protocol     : SJA1000 BasicCAN (byte-addressed, 8-bit registers)
Access       : byte (sb/lb) only — wider accesses trigger an error
Interrupt    : irq_lines[3] (receive interrupt, active low)
```

The CAN controller must be configured in reset mode before programming timing
registers.  The wrapper translates the internal OBI 32-bit bus to the
SJA1000's 8-bit Wishbone interface.  See the assembly source for the full
initialisation and transmit/receive sequences.

---

## Assembly Programming Model

### Interrupt Architecture

The CPU uses **vectored mode** (`mtvec[1:0] = 01`).  Each interrupt source is
mapped to a fixed entry in the vector table at address `0x40`:

| Vector index | IRQ line | Source |
|---|---|---|
| 0 (`mie[16]`) | Button right | `io_sw` |
| 1 (`mie[17]`) | Button bottom | `io_sw` |
| 2 (`mie[18]`) | Button left | `io_sw` |
| 3 (`mie[19]`) | CAN receive | `can_wrapper` |

ISRs are kept short: they save temporary registers, set the corresponding flag
bit in the software flag register (`s1`), and return.  All actual processing
happens in the main loop.

### Boot Sequence

```
0x00000040   vectortable.s   Interrupt vector table (j _isr_label or mret)
0x00000080   boot.s          CSR setup → j _main
0x000000xx   projectv1_l.s   Application code
```

### Register Conventions

The assembly programs use the following saved-register assignments:

| Register | Role |
|---|---|
| `s0` | Switch peripheral base address (`0x000F0020`) |
| `s1` | Software interrupt flag register (bits 0–3) |
| `s2` | CAN controller base address (`0x000F0100`) |
| `s3` | Short delay loop bound |
| `s4` | Long delay loop bound |
| `s5` | CAN ID low byte (formatted) |
| `s6` | CAN ID high byte (formatted) |
| `s7` | Last switch value read |
| `s10` | Scrolling display base address (`0x000F0060`) |

---

## Building the Software

**Prerequisites:** A RISC-V 32-bit bare-metal toolchain (`riscv32-unknown-elf`).

```bash
cd programs
make          # produces projectv1.rom, projectv1_l.rom, etc.
make clean    # remove intermediate files
```

The build pipeline:

```
*.s  →  (riscv32-unknown-elf-as)  →  *.o
*.o  →  (riscv32-unknown-elf-ld -T platform.ld)  →  *.elf
*.elf  →  (riscv32-unknown-elf-objcopy -O verilog)  →  *.txt
*.txt  →  (python3 format_rom.py)  →  *.rom
```

Update `PROGRAMFILENAME` in `soc/lib/config_pkg.sv` to point to the desired
`.rom` file before synthesising or simulating.

---

## Testbenches

Simulation testbenches live in `soc/testbench/`.  They cover individual
peripherals as well as integrated platform scenarios:

| Testbench | Component under test |
|---|---|
| `platform_tb.sv` | Full SoC integration |
| `db_reg_intf_tb.sv` | `db_reg_intf` bus interface |
| `hex2physical_tb.sv` | `hex2physical` LUT |
| `seven_segment_display_tb.sv` | 7-segment display driver |
| `simple_timer_tb.sv` | `simple_timer` |
| `warmup1_tb.sv` – `warmup_4_3_tb.sv` | Incremental warm-up exercises |

---

## Languages Used

- **SystemVerilog** — SoC design (peripherals, interconnect, top level)
- **Verilog** — CAN controller (third-party), clock-divider IP
- **RISC-V Assembly** — application and boot firmware
- **Python** — `.rom` formatter (`format_rom.py`)
- **Tcl/XDC** — Vivado constraints
