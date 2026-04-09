module scrolling_timer (
    input  logic        clk,
    input  logic        rst,
    input  logic        cnt_start,    // one-cycle pulse to start or restart
    output logic        cnt_done,     // one-cycle pulse when finished
    input  logic [31:0] cnt_value,     // starting count value
    output logic active 
);

    //logic        active;              // indicates timer is running
    logic [31:0] counter;             // countdown register

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            active   <= 1'b0;
            counter  <= 32'd0;
            cnt_done <= 1'b0;
        end else begin
            cnt_done <= 1'b0;  // default: low unless triggered this cycle

            // Start signal loads counter and activates countdown
            if (cnt_start) begin
                counter <= cnt_value;
                active  <= 1'b1;
            end else if (active) begin
                if (counter == 32'd0) begin
                    cnt_done <= 1'b1; // pulse done
                    active   <= 1'b0; // stop until next cnt_start
                end else begin
                    counter <= counter - 1'b1;
                end
            end
        end
    end
endmodule
