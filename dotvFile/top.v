`timescale 1ns / 1ps

module top(
    input clk,              // 100MHz Basys 3
    input reset,            // sw[15]
    input set,              // btnC
    input up,               // btnU
    input down,             // btnD
    input left,             // btnL
    input right,            // btnR
    input [7:0] sw,         // sw[6:0] sets ASCII value
    input ja1,          // Receive from another board
    output ja2,         // Transmit to another board
    output wire RsTx, //uart
    input wire RsRx, //uart
    output hsync, vsync,    // VGA connector
    output [11:0] rgb,      // DAC, VGA connector
    output [6:0] seg,
    output dp,
    output [3:0] an       
    );
    
    // signals
    wire [9:0] w_x, w_y;
    wire w_vid_on, w_p_tick;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    
    wire [7:0] gnd_b; // GROUND_BUS
    wire received1, received2; // FROM Keyboard and FROM another board
    wire data_in;
    
    // instantiate vga controller
    vga_controller vga(.clk_100MHz(clk), .reset(reset), .video_on(w_vid_on),
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), 
                       .x(w_x), .y(w_y));
    
    // instantiate text generation circuit
    text_screen_gen tsg(.clk(clk), .reset(reset), .video_on(w_vid_on),
                        .up(up),
                        .sw(sw), .x(w_x), .y(w_y), .rgb(rgb_next), .data_fk(data_fk), .en(received1));
                     
    wire [7:0] data_fk; // use
    wire [7:0] data_null; // use
    wire en; // not use
     
//    uart uartMyKeyboardToMyBasys(clk,RsRx,sw[7:0],1'b0,RsTx, data_fk, en);

    // UART1 Receive from another and transmit to monitor
    uart uart1(.RsTx(RsTx), .data_transmit(gnd_b),
               .RsRx(ja1), .data_received(data_fk), .received(received1),
               .dte(1'b0), .clk(clk));
                
    // UART2 Receive from keyboard or switch and transmit to another
    uart uart2(.RsRx(RsRx), .data_transmit(sw[7:0]), 
               .RsTx(ja2), .data_received(data_null), .received(received2),
               .dte(up), .clk(clk));    
               
     // div clk for display
    wire [18:0] tclk;
    assign tclk[0] = clk;
    
    genvar c;
    generate for(c=0;c<18;c=c+1)
    begin
        clockDiv div(tclk[c+1], tclk[c]);
    end
    endgenerate
    wire targetClk;
    clockDiv ffdiv(targetClk, tclk[18]);
   
    // display logic
    reg [7:0] display_out;  
    wire enable;
    singlepulser singlepulser(.clk(clk), .en(received2), .enable(enable));
    always@(posedge up or posedge enable) begin
        if(up) display_out = sw;
        else if(enable) display_out = data_null; 
    end
    
    // segment display
    wire an0,an1,an2,an3;
    assign an = {an3,an2,an1,an0};
    quadSevenSeg tdm(seg,dp,an0,an1,an2,an3, data_fk[3:0] , data_fk[7:4], display_out[3:0], display_out[7:4], targetClk);
    
    // rgb buffer
    always @(posedge clk)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    // output
    assign rgb = rgb_reg;
    
endmodule