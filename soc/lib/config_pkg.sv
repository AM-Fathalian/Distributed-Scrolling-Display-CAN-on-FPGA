import data_bus_pkg::*;
package config_pkg;
//---------------------------
// RST active level override
//---------------------------
	parameter logic RST_ACTIVE_HIGH = 0;

//---------------------------
// memory config
//---------------------------
	parameter int IMEMSZ = 1024; //this is actually WORD-size!

	parameter string PROGRAMFILENAME = "/import/home/jmueller/Desktop/labss24/programs/blinky.rom";
	// parameter string PROGRAMFILENAME = "riscv-programs/blinky.rom";


//---------------------------
// bus config -- indexing and masking
//---------------------------
    parameter logic [data_bus_pkg::NSLV-1 : 0] SLV_MASK_VECTOR = 'b111101;
    parameter logic [data_bus_pkg::NMST-1 : 0] MST_MASK_VECTOR = 'b1;
// >> Master indx <<
	parameter int CFG_CORE = 0;

// >> Slave indx  <<
	parameter int CFG_MEM = 0;
	parameter int CFG_DMEM = CFG_MEM+1; //currently not implemented
	parameter int CFG_LED = CFG_DMEM+1;
    parameter int CFG_SW  = CFG_LED+1; //&&&
	parameter int CFG_SEVEN_SEG = CFG_SW+1; //&&&
	parameter int CFG_SCROLLING_TOP = CFG_SW+1; //&&&
	parameter int CFG_CAN = CFG_SCROLLING_TOP+1; 
	

	parameter int n_words = 1; // &&&
//---------------------------
// bus config -- address config
//---------------------------
// slave select mechanisms:
// base address (BADR) == address mask (MADR) && current request address
// base addresses:
	parameter data_bus_pkg::base_addr_type CFG_BADR_MEM   = 'h00000000;// fixed, must start from 0
	parameter data_bus_pkg::base_addr_type CFG_BADR_DMEM  = CFG_BADR_MEM + IMEMSZ*4;
	parameter data_bus_pkg::base_addr_type CFG_BADR_LED   = 'h000F0000;
	parameter data_bus_pkg::base_addr_type CFG_BADR_SW    = CFG_BADR_LED + 32'h00000020; // next available base address &&&
	parameter data_bus_pkg::base_addr_type CFG_BADR_SEVEN_SEG = CFG_BADR_SW + 32'h00000020; // next available base address &&&
	parameter data_bus_pkg::base_addr_type CFG_BADR_SCROLLING_TOP = CFG_BADR_SEVEN_SEG + 32'h00000020; // next available base address &&&
	parameter data_bus_pkg::base_addr_type CFG_BADR_CAN =  32'h000F0100; // next available base address &&&
// address masks:
	parameter data_bus_pkg::addr_mask_type CFG_MADR_ZERO  = 0;
	parameter data_bus_pkg::addr_mask_type CFG_MADR_FULL  = 'h3FFFFF;
	parameter data_bus_pkg::addr_mask_type CFG_MADR_MEM   = 'h3FFFFF - (IMEMSZ*4 -1);
	parameter data_bus_pkg::addr_mask_type CFG_MADR_DMEM  = 'h3FFFFF - (256 -1); // uses 6 word-bits, size 256 byte
	parameter data_bus_pkg::addr_mask_type CFG_MADR_LED   = 'h3FFFFF; // size = 1 byte
	parameter data_bus_pkg::addr_mask_type CFG_MADR_SW   = 'h3FFFFF; // size = 1 byte // &&&
	parameter data_bus_pkg::addr_mask_type CFG_MADR_SEVEN_SEG = 'h3FFFFF - (16 -1);// size = 2 bytes // &&& DO it need to be 2 bytes? IMPORTANT**********************
	parameter data_bus_pkg::addr_mask_type CFG_MADR_SCROLLING_TOP = 'h3FFFFF - (8 -1);
	parameter data_bus_pkg::addr_mask_type CFG_MADR_CAN = 'h3FFFFF - (32 -1);

	endpackage
