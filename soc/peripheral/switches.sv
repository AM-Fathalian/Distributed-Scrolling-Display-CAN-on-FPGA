import data_bus_pkg::*;
import config_pkg::*;

module io_sw #(
	parameter base_addr_type base_addr = CFG_BADR_SW,
	parameter addr_mask_type addr_mask = CFG_MADR_SW
) (
    input  logic clk, 
    input  logic rst, 

	input logic [ 4: 0] btn,
	input logic [15: 0] sw,
    output logic irq_btn_right, 
    output logic irq_btn_bottom, 
    output logic irq_btn_left,

    DATA_BUS.Slave dslv
);

    logic [31:0] data;
    logic reg_read_o;

    db_reg_intf #(
        .base_addr(base_addr),
        .addr_mask(addr_mask),
        .reg_init(32'h0000000f)  
    ) db_reg_intf_inst(
        .clk(clk),
        .rst(rst),
        .reg_data_o(), //unconnected as mentioned in the exercise
        .reg_data_i(data),
		.new_data_i (1'b1), // Assume always new data available
        .reg_read_o (reg_read_o), // IRQ output when read occurs
        .dslv(dslv)
    );

    

    assign data[15:0] = sw;
    assign data[20:16] = btn;
    assign data[31:21] = 11'b0; // Upper bits set to 0

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            irq_btn_right <= 1'b0;
            irq_btn_bottom <= 1'b0;
            irq_btn_left <= 1'b0;

        end 
        else if (|btn) begin 
            case (btn)
                5'b10000: irq_btn_right <= 1'b1;
                5'b01000: irq_btn_bottom <= 1'b1;
                5'b00100: irq_btn_left <= 1'b1;
                default: ;

        endcase

        end

        else if (reg_read_o) begin
            irq_btn_right <= 1'b0;
            irq_btn_bottom <= 1'b0;
            irq_btn_left <= 1'b0;
        end
    end
    
endmodule