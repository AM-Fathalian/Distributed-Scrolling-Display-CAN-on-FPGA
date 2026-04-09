import data_bus_pkg::*;
import config_pkg::*;

module db_reg_intf #(
	parameter base_addr_type base_addr,
	parameter addr_mask_type addr_mask,
	parameter int unsigned n_words = 1, 
	parameter logic [n_words-1:0] [31:0] reg_init = '0
) (
	input logic clk,
	input logic rst,
	output logic [n_words-1:0] [31:0] reg_data_o,
	input logic [n_words-1:0] [31:0] reg_data_i,
	input logic new_data_i,
	output logic reg_read_o,
	DATA_BUS.Slave dslv
);

	typedef enum { IDLE, ACCESS } ACCESS_STATE;
	ACCESS_STATE state_q, state_d;
	logic [n_words-1:0] [31:0] reg_data_q, reg_data_d;
	logic [$clog2(n_words > 1 ? n_words : 2)-1:0] addr_word;  // At least 1 bit
	//logic [n_words-1:0] addr_word; // word address (= byte address / 4) &&&

	assign reg_data_o = reg_data_q;
	

	assign dslv.err = 1'b0;
	assign dslv.conf.base_addr = base_addr;
	assign dslv.conf.addr_mask = addr_mask;
	
	always_comb begin: mem2dslv_fsm
		reg_data_d = reg_data_q;
		dslv.gnt = 0;
		dslv.rvalid = 0;
		state_d = state_q;
		reg_read_o = 1'b0;//&&&
		addr_word = (dslv.addr) >> 2;; // Shift right to get word address (same as dividing by 4) &&&

		if (new_data_i) begin			//&&&
			reg_data_d = reg_data_i;	//&&&
			reg_read_o = 1'b1;		//&&&
		end
        case (state_q)
            IDLE: begin
				dslv.rvalid = 0;
                if(dslv.req) begin
					dslv.gnt = 1'b1;
					if (dslv.we) begin // write request
						reg_data_d[addr_word] = dslv.wdata; // write operation &&& //Maybe add mask to avoid  writing to invalid addresses
					end
					else begin 
						dslv.rdata = reg_data_q[addr_word]; // read request //&&& //Maybe add mask to avoid  writing to invalid addresses
					end					
					state_d  = ACCESS;
				end else begin
					dslv.gnt = 1'b0;
					state_d  = IDLE;
				end
            end
            ACCESS: begin
				dslv.rvalid = 1'b1;
				if(dslv.req) begin     // successive request
					dslv.gnt = 1'b1;
					state_d  = ACCESS;
					if (dslv.we)
						reg_data_d[addr_word] = dslv.wdata; // write operation &&& //Maybe add mask to avoid  writing to invalid addresses
					else begin 
						dslv.rdata = reg_data_q[addr_word]; // read request //&&& //Maybe add mask to avoid  writing to invalid addresses
					end	
					
				end else begin         // no new request
					dslv.gnt = 1'b0;
					state_d  = IDLE;
				end
            end
		endcase
    end

	always_ff @(posedge clk) begin: fsm_regs
		if (rst) begin
			state_q <= IDLE;
			reg_data_q <= reg_init;
		end else begin
			state_q <= state_d;
			reg_data_q <= reg_data_d; 
		end
	end

endmodule