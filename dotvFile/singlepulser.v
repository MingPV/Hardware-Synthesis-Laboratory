`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 01:56:22 PM
// Design Name: 
// Module Name: singlepulser
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


module singlepulser(
    input clk,
    input en,
    output enable
    );
    
    reg [1:0] stage = 0;
    reg enable = 0;
    always @(posedge clk) begin
        if (stage == 0) begin
            if(en) begin
                enable = 1;
                stage = 1; 
            end
        end
        else if (stage == 1) begin
            if(en) begin
                stage = 2;
            end
            else begin
                stage = 0;
            end
                enable = 0;
        end
        else begin
            if(!en) begin
                stage = 0;
            end
        end
    end
    
endmodule
