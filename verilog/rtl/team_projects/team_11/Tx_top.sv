`include "src/Tx_external_shift_register_top.sv"
`include "UART_Tx.sv"
//`include "src/lcd1602.sv"

module Tx_top(
    input logic clk, nrst, msg_tx_ctrl,
    input logic [127:0] msg_1,
    output logic tx_dout,
    output logic success
);
    //keypad controller
        
        logic stop;
        logic transmit_ready;
        logic [7:0] data_send;
        logic tx_ctrl;
        

        Tx_external_shift_register_top ext_shift_top(.clk(clk), .nrst(nrst), .transmit_ready(transmit_ready), .msg_tx_ctrl(msg_tx_ctrl), .msg_1(msg_1), .data_send(data_send), .tx_ctrl(tx_ctrl));

    // UART_TX  
        UART_Tx tx(.clk(clk), .nrst(nrst), .data_send(data_send), .tx_ctrl(tx_ctrl), .transmit_ready(transmit_ready), .success(success), .tx_dout(tx_dout));

endmodule