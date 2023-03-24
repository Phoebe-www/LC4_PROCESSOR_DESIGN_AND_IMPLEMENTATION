
`timescale 1ns / 1ps
`default_nettype none

module lc4_divider(input  wire [15:0] i_dividend,
                   input  wire [15:0] i_divisor,
                   output wire [15:0] o_remainder,
                   output wire [15:0] o_quotient);

      /*** YOUR CODE HERE ***/
      wire [15:0] temp_remainder_1; wire [15:0] temp_dividend_1; wire [15:0] temp_quotient_1;
      wire [15:0] temp_remainder_2; wire [15:0] temp_dividend_2; wire [15:0] temp_quotient_2;
      wire [15:0] temp_remainder_3; wire [15:0] temp_dividend_3; wire [15:0] temp_quotient_3;
      wire [15:0] temp_remainder_4; wire [15:0] temp_dividend_4; wire [15:0] temp_quotient_4;
      wire [15:0] temp_remainder_5; wire [15:0] temp_dividend_5; wire [15:0] temp_quotient_5;
      wire [15:0] temp_remainder_6; wire [15:0] temp_dividend_6; wire [15:0] temp_quotient_6;
      wire [15:0] temp_remainder_7; wire [15:0] temp_dividend_7; wire [15:0] temp_quotient_7;
      wire [15:0] temp_remainder_8; wire [15:0] temp_dividend_8; wire [15:0] temp_quotient_8;
      wire [15:0] temp_remainder_9; wire [15:0] temp_dividend_9; wire [15:0] temp_quotient_9;
      wire [15:0] temp_remainder_10; wire [15:0] temp_dividend_10; wire [15:0] temp_quotient_10;
      wire [15:0] temp_remainder_11; wire [15:0] temp_dividend_11; wire [15:0] temp_quotient_11;
      wire [15:0] temp_remainder_12; wire [15:0] temp_dividend_12; wire [15:0] temp_quotient_12;
      wire [15:0] temp_remainder_13; wire [15:0] temp_dividend_13; wire [15:0] temp_quotient_13;
      wire [15:0] temp_remainder_14; wire [15:0] temp_dividend_14; wire [15:0] temp_quotient_14;
      wire [15:0] temp_remainder_15; wire [15:0] temp_dividend_15; wire [15:0] temp_quotient_15;
      wire [15:0] o_quotient_temp; wire [15:0] o_remainder_temp;

      lc4_divider_one_iter iter1(
            .i_dividend(i_dividend),
            .i_divisor(i_divisor),
            .i_remainder(16'b0),
            .i_quotient(16'b0),
            .o_dividend(temp_dividend_1),
            .o_remainder(temp_remainder_1),
            .o_quotient(temp_quotient_1)
      );

      lc4_divider_one_iter iter2(
            .i_dividend(temp_dividend_1),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_1),
            .i_quotient(temp_quotient_1),
            .o_dividend(temp_dividend_2),
            .o_remainder(temp_remainder_2),
            .o_quotient(temp_quotient_2)
      );

      lc4_divider_one_iter iter3(
            .i_dividend(temp_dividend_2),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_2),
            .i_quotient(temp_quotient_2),
            .o_dividend(temp_dividend_3),
            .o_remainder(temp_remainder_3),
            .o_quotient(temp_quotient_3)
      );

      lc4_divider_one_iter iter4(
            .i_dividend(temp_dividend_3),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_3),
            .i_quotient(temp_quotient_3),
            .o_dividend(temp_dividend_4),
            .o_remainder(temp_remainder_4),
            .o_quotient(temp_quotient_4)
      );

      lc4_divider_one_iter iter5(
            .i_dividend(temp_dividend_4),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_4),
            .i_quotient(temp_quotient_4),
            .o_dividend(temp_dividend_5),
            .o_remainder(temp_remainder_5),
            .o_quotient(temp_quotient_5)
      );

      lc4_divider_one_iter iter6(
            .i_dividend(temp_dividend_5),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_5),
            .i_quotient(temp_quotient_5),
            .o_dividend(temp_dividend_6),
            .o_remainder(temp_remainder_6),
            .o_quotient(temp_quotient_6)
      );

      lc4_divider_one_iter iter7(
            .i_dividend(temp_dividend_6),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_6),
            .i_quotient(temp_quotient_6),
            .o_dividend(temp_dividend_7),
            .o_remainder(temp_remainder_7),
            .o_quotient(temp_quotient_7)
      );    

      lc4_divider_one_iter iter8(
            .i_dividend(temp_dividend_7),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_7),
            .i_quotient(temp_quotient_7),
            .o_dividend(temp_dividend_8),
            .o_remainder(temp_remainder_8),
            .o_quotient(temp_quotient_8)
      );

      lc4_divider_one_iter iter9(
            .i_dividend(temp_dividend_8),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_8),
            .i_quotient(temp_quotient_8),
            .o_dividend(temp_dividend_9),
            .o_remainder(temp_remainder_9),
            .o_quotient(temp_quotient_9)
      );

      lc4_divider_one_iter iter10(
            .i_dividend(temp_dividend_9),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_9),
            .i_quotient(temp_quotient_9),
            .o_dividend(temp_dividend_10),
            .o_remainder(temp_remainder_10),
            .o_quotient(temp_quotient_10)
      );

      lc4_divider_one_iter iter11(
            .i_dividend(temp_dividend_10),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_10),
            .i_quotient(temp_quotient_10),
            .o_dividend(temp_dividend_11),
            .o_remainder(temp_remainder_11),
            .o_quotient(temp_quotient_11)
      );

      lc4_divider_one_iter iter12(
            .i_dividend(temp_dividend_11),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_11),
            .i_quotient(temp_quotient_11),
            .o_dividend(temp_dividend_12),
            .o_remainder(temp_remainder_12),
            .o_quotient(temp_quotient_12)
      );

      lc4_divider_one_iter iter13(
            .i_dividend(temp_dividend_12),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_12),
            .i_quotient(temp_quotient_12),
            .o_dividend(temp_dividend_13),
            .o_remainder(temp_remainder_13),
            .o_quotient(temp_quotient_13)
      );

      lc4_divider_one_iter iter14(
            .i_dividend(temp_dividend_13),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_13),
            .i_quotient(temp_quotient_13),
            .o_dividend(temp_dividend_14),
            .o_remainder(temp_remainder_14),
            .o_quotient(temp_quotient_14)
      );

      lc4_divider_one_iter iter15(
            .i_dividend(temp_dividend_14),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_14),
            .i_quotient(temp_quotient_14),
            .o_dividend(temp_dividend_15),
            .o_remainder(temp_remainder_15),
            .o_quotient(temp_quotient_15)
      );

      lc4_divider_one_iter iter16(
            .i_dividend(temp_dividend_15),
            .i_divisor(i_divisor),
            .i_remainder(temp_remainder_15),
            .i_quotient(temp_quotient_15),
            .o_dividend(),
            .o_remainder(o_remainder_temp),
            .o_quotient(o_quotient_temp)
      );

      assign o_quotient = (i_divisor == 0) ? 0 : o_quotient_temp;
      assign o_remainder = (i_divisor == 0) ? 0 : o_remainder_temp;
      


endmodule // lc4_divider

module lc4_divider_one_iter(input  wire [15:0] i_dividend,
                            input  wire [15:0] i_divisor,
                            input  wire [15:0] i_remainder,
                            input  wire [15:0] i_quotient,
                            output wire [15:0] o_dividend,
                            output wire [15:0] o_remainder,
                            output wire [15:0] o_quotient);

      /*** YOUR CODE HERE ***/
      wire [15:0] temp_remainder;
      assign temp_remainder = (i_remainder << 1) | (i_dividend >> 15) & 1;
      assign o_quotient = (temp_remainder < i_divisor) ? (i_quotient << 1) : (i_quotient << 1) | 1;
      assign o_remainder = (temp_remainder < i_divisor) ? temp_remainder : temp_remainder - i_divisor;
      assign o_dividend = i_dividend << 1;

endmodule
