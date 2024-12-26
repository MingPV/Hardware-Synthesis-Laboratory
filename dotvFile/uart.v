`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2024 10:14:31 AM
// Design Name: 
// Module Name: uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart(
    input clk,
    input RsRx,
    input [7:0] data_transmit,
    input dte, // data_transmit_enable
    output RsTx,
    output [7:0] data_received,
    output received
    );
    
    reg en, last_rec;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire sent, received, baud;
//    wire [7:0] data_received;
    wire [7:0] data;
    
//    assign data_received = (dte)? data_out : data_out;
    assign data = (dte) ? data_transmit : data_received;    
    
    baudrate_gen baudrate_gen(clk, baud);
//    uart_rx receiver(baud, RsRx, received, data_out);
//    uart_tx transmitter(baud, data_received, en, sent, RsTx);
    uart_rx receiver(baud, RsRx, received, data_received);
    uart_tx transmitter(baud, data, en, sent, RsTx);
    
    always @(posedge baud) begin
        if (en) en = 0;
        if (~last_rec & received || dte) begin
            //data_in = data_out + 8'h01;
//            data_in = data_out;
            //8'h system
            //41 = A
            //30 = 0
            //ISO-8859-11 kor khai A1
            if ( 8'h00 <= data_in && data_in <= 8'hFF) en = 1;
            //if(data_in==8'hE0 ||data_in==8'hB8||data_in==8'h81) en = 1;//UTF-8 kor khai
        end
        last_rec = received;
    end
    
endmodule
