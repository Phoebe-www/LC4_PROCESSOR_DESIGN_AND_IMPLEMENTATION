/* TODO: INSERT NAME AND PENNKEY HERE */

`timescale 1ns / 1ps
`default_nettype none

/**
 * @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b;
   assign p = a | b;
endmodule

/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals 
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits collectively generate a carry (ignoring cin)
 * @param pout whether these 4 bits collectively would propagate an incoming carry (ignoring cin)
 * @param cout the carry outs for the low-order 3 bits
 */
module gp4(input wire [3:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [2:0] cout);
 assign gout = gin[3] | (pin[3] & gin[2]) | (pin[3] & pin[2] & gin[1]) | (pin[3] & pin[2] & pin[1] & gin[0]);
 assign pout = (& pin);
 assign cout[0] = gin[0] | (pin[0] & cin);
 assign cout[1] = gin[1] | (pin[1] & gin[0])| (pin[1] & pin[0] & cin);
 assign cout[2] = gin[2] | (pin[2] & gin[1]) | (pin[2] & pin[1] & gin[0]) | (pin[2] & pin[1] & pin[0] & cin);

endmodule

/**
 * 16-bit Carry-Lookahead Adder
 * @param a first input
 * @param b second input
 * @param cin carry in
 * @param sum sum of a + b + carry-in
 */
module cla16
  (input wire [15:0]  a, b,
   input wire         cin,
   output wire [15:0] sum);
wire [15:0] cout;
wire[4:0] pout;
wire[4:0] gout;
wire[15:0] pin;
wire[15:0] gin;
genvar i;
	for (i=0; i<16; i=i+1)
	begin
            gp1 d (a[i], b[i], gin[i], pin[i]);
        end
gp4 d0 (gin[3:0], pin[3:0], cin, pout[0], gout[0], cout[2:0]);
gp4 d1 (gin[7:4], pin[7:4], cout[3],  pout[1], gout[1], cout[6:4]);
gp4 d2 (gin[11:8], pin[11:8], cout[7], pout[2], gout[2], cout[10:8]);
gp4 d3 (gin[15:12], pin[15:12], cout[11], pout[3], gout[3], cout[14:12]);
gp4 d4 (pout[3:0], gout[3:0], cin, pout[4], gout[4], {cout[11], cout[7], cout[3]});
assign sum[15:0] = a[15:0] ^ b[15:0] ^ {cout[14:0], cin};
endmodule


/** Lab 2 Extra Credit, see details at
  https://github.com/upenn-acg/cis501/blob/master/lab2-alu/lab2-cla.md#extra-credit
 If you are not doing the extra credit, you should leave this module empty.
 */
module gpn
  #(parameter N = 4)
  (input wire [N-1:0] gin, pin,
   input wire  cin,
   output wire gout, pout,
   output wire [N-2:0] cout);
wire [N-1:0] gi;
wire [N-1:0] co;
assign gi[0] = gin[0];
assign co[0] = cin;
genvar i;
	for (i=0; i<N-1; i=i+1)
	begin
       	assign co[i+1] = gin[i] | (pin[i] & co[i]);
	assign gi[i+1] = gin[i+1] | (pin[i+1] & gi[i]);
	end
assign pout = (& pin);
assign gout = gi[N-1];
assign cout = co[N-1:1];
endmodule