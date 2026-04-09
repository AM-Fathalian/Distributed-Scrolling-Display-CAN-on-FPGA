module simple_timer # (
logic [31:0] timer_start
)(
    input logic clk,
    input logic rst,
    output logic timer_overflow
);


logic [31:0] counter;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        // Reset logic
        timer_overflow <= 1'b0;
        counter <= timer_start;
    end else begin
        counter <= counter - 1;
        if (counter == 32'd0) begin
            timer_overflow <= 1'b1;
            counter <= timer_start; // Reload the counter
        end else begin
            timer_overflow <= 1'b0;
        end
    end
end

endmodule