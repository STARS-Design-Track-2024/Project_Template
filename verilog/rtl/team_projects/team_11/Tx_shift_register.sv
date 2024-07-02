
module Tx_shift_register(
input logic clk,nrst, tx_ctrl, enable_s,
input logic [3:0] count,
input logic [7:0] data_send,

output logic bit_out
);

logic [7:0] next_out;
logic [7:0] shifted_data;

always_ff @(posedge clk, negedge nrst) begin
    if(!nrst) begin
        next_out <= '1;
    end
    else begin
        next_out <= shifted_data;
    end
end

always_comb begin
    if(tx_ctrl) begin
        shifted_data = data_send;
    end
    else if(enable_s) begin
        if(count == 4'd1) begin 
            shifted_data = {next_out[6:0], 1'b0};
        end
        else if(count == 4'd2) begin
            shifted_data = data_send;
        end
        else if(count == 4'd0) begin
            shifted_data = {next_out[6:0], 1'b1};
        end
        else if(count == 4'd10) begin 
            shifted_data = {next_out[6:0], 1'b0};
        end
        else begin 
            shifted_data = {1'b0, next_out[7:1]};
        end
    end
    else begin
        shifted_data = '1;
        //shifted_data = 8'b1;
    end
end

assign bit_out = next_out[0];
 
endmodule