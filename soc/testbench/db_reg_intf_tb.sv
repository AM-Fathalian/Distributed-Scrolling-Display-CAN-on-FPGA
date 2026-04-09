`timescale 1ns/1ps

// Import your packages
import data_bus_pkg::*;
import config_pkg::*;

module tb_db_reg_intf;

    // --------------------------------------------------------------------
    // Parameters (you can adjust these based on your pkg definitions)
    // --------------------------------------------------------------------
    localparam int n_words = 1; // assuming one 32-bit register
    localparam base_addr_type BASE_ADDR = CFG_BADR_SW;
    localparam addr_mask_type ADDR_MASK = CFG_MADR_SW;

    // --------------------------------------------------------------------
    // Signals
    // --------------------------------------------------------------------
    logic clk;
    logic rst;
    logic [n_words-1:0][31:0] reg_data_o;
    logic [n_words-1:0][31:0] reg_data_i;
    logic new_data_i;

    DATA_BUS dslv(); // Create the DATA_BUS interface instance

    // --------------------------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------------------------
    db_reg_intf #(
        .base_addr(BASE_ADDR),
        .addr_mask(ADDR_MASK),
        .reg_init('{32'h00000000})
    ) dut (
        .clk(clk),
        .rst(rst),
        .reg_data_o(reg_data_o),
        .reg_data_i(reg_data_i),
        .new_data_i(new_data_i),
        .dslv(dslv)
    );

    // --------------------------------------------------------------------
    // Clock Generation
    // --------------------------------------------------------------------
    always #5 clk = ~clk;

    // --------------------------------------------------------------------
    // Task: Write to Register
    // --------------------------------------------------------------------
    task automatic write_reg(input logic [31:0] wdata);
        @(posedge clk);
        dslv.req  <= 1;
        dslv.we   <= 1;
        dslv.wdata <= wdata;
        dslv.be   <= 4'b1111; // full word write
        @(posedge clk);
        dslv.req <= 0;
    endtask

    // --------------------------------------------------------------------
    // Task: Read with Byte Enable
    // --------------------------------------------------------------------
    task automatic read_reg(input logic [3:0] be, input logic [31:0] data_i);
        @(posedge clk);
        dslv.req  <= 1;
        dslv.we   <= 0;
        dslv.be   <= be;
        reg_data_i <= data_i;
        @(posedge clk);
        dslv.req <= 0;
    endtask

    // --------------------------------------------------------------------
    // Test Sequence
    // --------------------------------------------------------------------
    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        dslv.req = 0;
        dslv.we  = 0;
        dslv.be  = 4'b0000;
        dslv.wdata = 32'h0;
        reg_data_i = '{32'h0};
        new_data_i = 1;
        #20;
        rst = 0;

        $display("\n--- TEST START ---");

        // 1️⃣ Full write to register
        write_reg(32'hFFFFFFFF);
        #20;
        $display("After full write: reg_data_o = %h", reg_data_o[0]);

        // 2️⃣ Byteenable test: 0101 (update bits [23:16] & [7:0])
        reg_data_i = '{32'hAABBAABB}; // want 0xAA in [23:16], 0xBB in [7:0]
        read_reg(4'b0101, reg_data_i);
        #20;
        $display("After be=0101 read: reg_data_o = %h", reg_data_o[0]);
        $display("After be=0101 read: dslv.rdata = %h", dslv.rdata);

        // 3️⃣ Byteenable test: 0011 (lower 16 bits)
        reg_data_i = '{32'hCCDDCCDD};
        read_reg(4'b0011, reg_data_i);
        #20;
        $display("After be=0011 read: reg_data_o = %h", reg_data_o[0]);
        $display("After be=0011 read: dslv.rdata = %h", dslv.rdata);

        $display("\n--- TEST END ---");
        #20;
        $finish;
    end

endmodule