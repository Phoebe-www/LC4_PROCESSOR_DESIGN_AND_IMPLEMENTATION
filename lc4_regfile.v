
`timescale 1ns / 1ps

// Prevent implicit wire declaration
`default_nettype none

module lc4_regfile #(parameter n = 16)
   (input  wire         clk,
    input  wire         gwe,
    input  wire         rst,
    input  wire [  2:0] i_rs,      // rs selector
    output wire [n-1:0] o_rs_data, // rs contents
    input  wire [  2:0] i_rt,      // rt selector
    output wire [n-1:0] o_rt_data, // rt contents
    input  wire [  2:0] i_rd,      // rd selector
    input  wire [n-1:0] i_wdata,   // data to write
    input  wire         i_rd_we    // write enable
    );

   /***********************
    * TODO YOUR CODE HERE *
    ***********************/
 wire [n-1:0] r0v, r1v, r2v, r3v, r4v, r5v, r6v, r7v;

    Nbit_reg #(n) r0 (.in(i_wdata),
                      .out(r0v),
                      .clk(clk),
                      .we(i_rd_we & (i_rd == 3'b000)),
                      .gwe(gwe),
                      .rst(rst));

    Nbit_reg #(n) r1 (.in(i_wdata),
                      .out(r1v),
                      .clk(clk),
                      .we(i_rd_we & (i_rd == 3'b001)),
                      .gwe(gwe),
                      .rst(rst));

    Nbit_reg #(n) r2 (.in(i_wdata),
                      .out(r2v),
                      .clk(clk),
                      .we(i_rd_we & (i_rd == 3'b010)),
                      .gwe(gwe),
                      .rst(rst));
    
    Nbit_reg #(n) r3 (.in(i_wdata),
                      .out(r3v),
                      .clk(clk),
                      .we(i_rd_we & (i_rd == 3'b011)),
                      .gwe(gwe),
                      .rst(rst));

    Nbit_reg #(n) r4 (.in(i_wdata),
                      .out(r4v),
                      .clk(clk),
                      .we(i_rd_we & (i_rd == 3'b100)),
                      .gwe(gwe),
                      .rst(rst));

    Nbit_reg #(n) r5 (.in(i_wdata), 
                      .out(r5v),
                      .clk(clk),
                      .we(i_rd_we & (i_rd == 3'b101)),
                      .gwe(gwe),
                      .rst(rst));

    Nbit_reg #(n) r6 (.in(i_wdata),
                      .out(r6v),
                      .clk(clk),
                      .we(i_rd_we & (i_rd == 3'b110)),
                      .gwe(gwe),
                      .rst(rst));
    
    Nbit_reg #(n) r7 (.in(i_wdata), 
                      .out(r7v),
                      .clk(clk),
                      .we(i_rd_we & (i_rd == 3'b111)),
                      .gwe(gwe),
                      .rst(rst));
    
    assign o_rs_data = (i_rs == 3'b000) ? r0v :
                       (i_rs == 3'b001) ? r1v :
                       (i_rs == 3'b010) ? r2v :
                       (i_rs == 3'b011) ? r3v :
                       (i_rs == 3'b100) ? r4v :
                       (i_rs == 3'b101) ? r5v :
                       (i_rs == 3'b110) ? r6v : r7v;

    assign o_rt_data = (i_rt == 3'b000) ? r0v :
                       (i_rt == 3'b001) ? r1v :
                       (i_rt == 3'b010) ? r2v :
                       (i_rt == 3'b011) ? r3v :
                       (i_rt == 3'b100) ? r4v :
                       (i_rt == 3'b101) ? r5v :
                       (i_rt == 3'b110) ? r6v : r7v;

endmodule
