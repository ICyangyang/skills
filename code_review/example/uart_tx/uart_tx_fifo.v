// UART TX FIFO Submodule
// 16x8-bit synchronous FIFO implementation

module uart_tx_fifo (
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire [7:0]  PWDATA,
    input  wire        push,
    input  wire        pop,
    output reg  [7:0]  data_out,
    output wire        full,
    output wire        empty,
    output wire [4:0]  count,
    output wire [3:0]  ip_count,
    output wire [3:0]  op_count
);

// ==============================================
// FIFO Storage and Pointers
// ==============================================
reg [7:0] data_fifo[15:0];
reg [3:0] ip_count_r;
reg [3:0] op_count_r;
reg [4:0] count_r;

// ==============================================
// Output Assignments
// ==============================================
assign count     = count_r;
assign ip_count  = ip_count_r;
assign op_count  = op_count_r;
assign full      = (count_r == 5'd16);
assign empty     = (count_r == 5'd0);

// ==============================================
// FIFO Logic
// ==============================================
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        ip_count_r  <= 4'd0;
        op_count_r  <= 4'd0;
        count_r     <= 5'd0;
        data_out    <= 8'd0;
    end else begin
        case ({push, pop})
            2'b00: begin
                // No operation - maintain state
            end

            2'b01: begin
                // Read only
            if (count_r > 5'd0) begin
                count_r     <= count_r - 1'b1;
                op_count_r  <= op_count_r + 1'b1;
            end
        end

        2'b10: begin
            // Write only
            if (count_r <= 5'd15) begin
                data_fifo[ip_count_r] <= PWDATA;
                count_r     <= count_r + 1'b1;
                ip_count_r  <= ip_count_r + 1'b1;
            end
        end

        2'b11: begin
            // Simultaneous read and write
            if (count_r > 5'd0 && count_r <= 5'd15) begin
                data_fifo[ip_count_r] <= PWDATA;
                ip_count_r  <= ip_count_r + 1'b1;
                op_count_r  <= op_count_r + 1'b1;
                // count remains unchanged
            end else if (count_r == 5'd0) begin
                // FIFO empty - only write
                data_fifo[ip_count_r] <= PWDATA;
                count_r     <= count_r + 1'b1;
                ip_count_r  <= ip_count_r + 1'b1;
            end else if (count_r == 5'd16) begin
                // FIFO full - only read
                count_r     <= count_r - 1'b1;
                op_count_r  <= op_count_r + 1'b1;
            end
        end
    endcase

    // Update data_out (read-through design)
    data_out <= data_fifo[op_count_r];
end
end
endmodule
