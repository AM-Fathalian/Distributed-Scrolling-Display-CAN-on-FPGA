`timescale 1ns / 1ns

module warmup3_1_tb;

 parameter time clk_period = 10;
    logic clk = 0;
    logic rst;
    logic DP;
    logic CA;
    logic CB;
    logic CC;
    logic CD;
    logic CE;
    logic CF;
    logic CG;
    logic [7:0] AN;

    // signal declarations
    lt16soc_top #(
        .RST_ACTIVE_HIGH(1'b1)
    ) dut (
        .clk_sys(clk),
        .rst(rst),

        .btn(),
        .sw(),
        .led(),

        .DP(DP),
        .CA(CA),
        .CB(CB),
        .CC(CC),
        .CD(CD),
        .CE(CE),
        .CF(CF),
        .CG(CG),
        .AN(AN)
    );

    always #(clk_period/2) clk = ~clk;

    initial begin
        rst = 0;
        #10;
        rst = 1;

        #100000000000000;
        
        $finish;
    end
endmodule