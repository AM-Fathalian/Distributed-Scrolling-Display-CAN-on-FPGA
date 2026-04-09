module scrolling_controller(
    input  logic        clk,
    input  logic        rst,
    input  logic        on_off,
    output logic        cnt_start,
    input  logic        cnt_done,
    output logic        next_char,
    input  logic [4:0]  hex_char,
    output logic [3:0]  seg_data,
    output logic        seg_off,
    output logic        seg_shift,
    output logic        seg_write,
    output logic        seg_clear
);

    typedef enum logic [1:0] {
        OFF,
        UPDATE,
        WAIT
    } state_t;

    state_t current_state, next_state;

    //============================================================
    // Next-state logic (combinational)
    //============================================================
    always_comb begin
        next_state = current_state;

        case (current_state)
            OFF: begin
                if (on_off)
                    next_state = UPDATE;
            end

            UPDATE: begin
                if (on_off)
                    next_state = OFF;
                else
                    next_state = WAIT;
            end

            WAIT: begin
                if (on_off)
                    next_state = OFF;
                else if (cnt_done)
                    next_state = UPDATE;
            end

            default: next_state = OFF;
        endcase
    end

    //============================================================
    // State register + Output logic (single always_ff)
    //============================================================
    
    always_ff @(posedge clk or posedge rst) begin
     if(rst) begin // 1. Default Assignments (Crucial for combinational logic to prevent latches)
     current_state <= OFF;
         seg_shift  <= 0;
         seg_write  <= 0;
         seg_clear  <= 1; // Default to '0' or a safe state
         cnt_start  <= 0;
         next_char  <= 0;
         // These outputs need default assignments too, as they are used in the case logic
         seg_data   <= 0;
         seg_off    <= 1;
     end
     else begin
     // The logic is now purely based on the current state and next state
     current_state <= next_state;
               seg_shift  <= 1'b0;
            seg_write  <= 1'b0;
            seg_clear  <= 1'b0;
            cnt_start  <= 1'b0;
            next_char  <= 1'b0;
     case (current_state)
         OFF: begin
             if (!on_off) begin
                 // Outputs remain at default (0)
                 seg_shift  <= 0;
                 seg_write  <= 0;
                 seg_clear  <= 0;
                 cnt_start  <= 0;
                 next_char  <= 0;
             end else begin
                 seg_data  <= hex_char[3:0];
                 seg_shift <= 1;
                 seg_write <= 1;
                 seg_clear <= 0; // Already 0 by default
                 seg_off   <= hex_char[4];
                 cnt_start <= 1;
                 next_char <= 1;
             end
         end
         UPDATE: begin
             if (!on_off) begin
                 seg_data  <= hex_char[3:0];
                 seg_shift <= 1;
                 seg_write <= 1;
                 seg_clear = 0; // Already 0 by default
                 seg_off   <= hex_char[4];
                 cnt_start <= 0;
                 next_char <= 0;
             end else begin
                 seg_clear <= 1;
                 cnt_start <= 0;
                 next_char <= 0;
             end
         end
         WAIT: begin
             if (!on_off) begin
                 seg_shift <= 0;
                 seg_write <= 0;
                 seg_clear <= 0;
                 if (!cnt_done) begin
                     cnt_start <= 0;
                     next_char <= 0;
                 end else begin
                     cnt_start <= 1;
                     next_char <= 1;
                 end
             end else begin
                 seg_clear <= 1;
                 cnt_start <= 0;
                 next_char <= 0;
             end
         end
        
         default: begin
             // Safety: assign a known state for any unhandled'current_state' value
             // (Often, these just rely on the default assignments at thetop)
             seg_shift  <= 0;
             seg_write  <= 0;
             seg_clear  <= 1; // Default to '0' or a safe state
             cnt_start  <= 0;
             next_char  <= 0;
             seg_data   <= 0;
             seg_off    <= 1;
         end
     endcase
     end
end

    
    
    // always_ff @(posedge clk or posedge rst) begin
    //     if (rst) begin
    //         current_state <= OFF;

    //         seg_data   <= 4'b0;
    //         seg_off    <= 1'b0;
    //         seg_shift  <= 1'b0;
    //         seg_write  <= 1'b0;
    //         seg_clear  <= 1'b1;
    //         cnt_start  <= 1'b0;
    //         next_char  <= 1'b0;
    //     end
    //     else begin
    //         // update state
    //         current_state <= next_state;

    //         // ---------- defaults ----------
    //         seg_shift  <= 1'b0;
    //         seg_write  <= 1'b0;
    //         seg_clear  <= 1'b0;
    //         cnt_start  <= 1'b0;
    //         next_char  <= 1'b0;

    //         case (current_state)

    //             OFF: begin
    //                 if(on_off) begin

    //                 end else begin

    //                 end
                    
    //             end

    //             UPDATE: begin
    //                 seg_data  <= hex_char[3:0];
    //                 seg_off   <= hex_char[4];
    //                 seg_shift <= 1'b1;
    //                 seg_write <= 1'b1;
    //                 cnt_start <= 1'b1;
    //                 next_char <= 1'b1;
    //             end

    //             WAIT: begin
    //                 if (cnt_done) begin
    //                     cnt_start <= 1'b1;
    //                     next_char <= 1'b1;
    //                 end
    //             end

    //             default: ;
    //         endcase
    //     end
    // end

endmodule
