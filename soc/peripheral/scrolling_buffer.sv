module scrolling_buffer (
input logic clk,
input logic rst,
input logic buffer_clear,
input logic buffer_write,
input logic [4:0] buffer_data,
input logic next_char,
output logic [4:0] hex_char,
output logic [7 : 0] led
);


logic [4:0] buffer_array [0:15];
logic [3:0] ptr_write;
logic [3:0] ptr_read;
logic [4:0] ptr_last; //MSB-Sign bit



typedef enum logic [0:0] {IDLE_WT, WRITE} write_state_t;
typedef enum logic [0:0] {IDLE_RD, READ} read_state_t;

write_state_t current_write_state, next_write_state;
read_state_t  current_read_state,  next_read_state;


always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        current_write_state <= IDLE_WT;
        ptr_write <= 4'd0;
        ptr_last  <= 5'b11111;
        current_read_state <= IDLE_RD;
        ptr_read <= 4'd0;
        hex_char <= 5'b11111;
    end else if (buffer_clear) begin
        current_write_state <= IDLE_WT;
        current_read_state <= IDLE_RD;
        ptr_write <= 4'd0;
        ptr_last  <= 5'b11111;
        ptr_read <= 4'd0;
        hex_char <= 5'b11111;
    end else begin
        current_write_state <= next_write_state;
        current_read_state <= next_read_state;

        if (current_write_state == WRITE) begin
            buffer_array[ptr_write] <= buffer_data;
            ptr_write <= ptr_write + 1;

            if (ptr_last != 5'b01111)
                ptr_last <= ptr_write; 
        end

        if (current_read_state == READ) begin

            //COMENT OUT THIS PART TO CHANGE THE BEHAVIOUR OF THE SCROLLING BUFFER TO THE PREVIOUS ONE
            // // hex_char <= buffer_array[ptr_read];
            // // ptr_read <= ptr_read + 1 % 16;

            // ptr_read <= ptr_read + 1 % 16;
            //     if(ptr_read <= ptr_last) begin //&
            //         //ptr_read <= 4'd0;
            //         hex_char <= buffer_array[ptr_read];
            //     end else begin
            //         hex_char <= 5'b11111; //THis causes a little glitch but is not visible by the himan eye (i think)
            //         if(ptr_read>=(16))begin //SIncre there are only 8 displays dont have to wait for the full clear
            //             ptr_read <= '0;
            //         end 
            //         //&
            //     end

            // // if(ptr_last != 5'b11111) begin
            // //     hex_char <= buffer_array[ptr_read];
            // //     if(ptr_read == ptr_last) begin
            // //         ptr_read <= 4'b0000;
            // //     end else begin
            // //         ptr_read <= (ptr_read + 1) %16;
            // //     end
            // //  end else begin
            // //     hex_char <= 5'd0;
            // // end




        //Change here
        if(ptr_last != 5'b11111) begin
                
                ptr_read <= ptr_read + 1; //&
                if(ptr_read <= ptr_last) begin //&
                    //ptr_read <= 4'd0;
                    hex_char <= buffer_array[ptr_read];
                end else begin
                    hex_char <= 5'b11111; //THis causes a little glitch but is not visible by the himan eye (i think)
                    if(ptr_read>=(8+ptr_last))begin //SIncre there are only 8 displays dont have to wait for the full clear
                        ptr_read <= '0;
                    end 
                    //&
                end

             end else begin
                hex_char <= 5'b11111;
            end


        end
    end
end


//Next State and output Logic Write

always_comb begin
    next_write_state = current_write_state;
    case (current_write_state)
        IDLE_WT: begin
            if (buffer_write) begin
                next_write_state = WRITE;
            end
        end
        WRITE: begin
            //buffer_array[ptr_write] = buffer_data;

            if (!buffer_write) begin
                next_write_state = IDLE_WT;
            end 
        end
    endcase
end





//Next State and output Logic Read
always_comb begin 
    next_read_state = current_read_state;
    case (current_read_state)
        IDLE_RD: begin
            if (next_char) begin
                next_read_state = READ;
            end
        end
        READ: begin
             
            if (!next_char) begin
                next_read_state = IDLE_RD;
            end
  
        end
    endcase

end




assign led = {ptr_read, buffer_array[ptr_read][3:0]};


endmodule