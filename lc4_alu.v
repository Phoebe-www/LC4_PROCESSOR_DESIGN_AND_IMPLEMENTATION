/* 
Hao Pan - haop
Siyun Wang - wsiyun
 */

`timescale 1ns / 1ps
`default_nettype none

module lc4_alu(input  wire [15:0] i_insn,
               input wire [15:0]  i_pc,
               input wire [15:0]  i_r1data,
               input wire [15:0]  i_r2data,
               output wire [15:0] o_result);

   wire [3:0] cls = i_insn[15:12];

   // logic operations
   wire [15:0] and_res;
   wire [15:0] or_res;
   wire [15:0] not_res;
   wire [15:0] xor_res;

   assign and_res = i_insn[5] == 1'b0 ? i_r1data & i_r2data : 
                    i_insn[4] == 1'b0 ? i_r1data & (16'b0 | i_insn[4:0]) :
                    i_r1data & ((16'hffff << 5) | i_insn[4:0]);
   assign or_res = i_r1data | i_r2data;
   assign not_res = ~i_r1data;
   assign xor_res = i_r1data ^ i_r2data;

   // DIV, MOD
   wire [15:0] div_res;
   wire [15:0] mod_res;

   lc4_divider div0(.i_dividend(i_r1data),
                    .i_divisor(i_r2data),
                    .o_quotient(div_res),
                    .o_remainder(mod_res));

   // MUL
   wire [15:0] mul_res = i_r1data * i_r2data;

   // JSRR, JSR
   wire [15:0] jsrr_res = i_r1data;
   wire [15:0] jsr_res = (i_pc & 16'b1000000000000000) | (i_insn[10:0] << 4);

   // RTI
   wire [15:0] rti_res = i_r1data;

   // CONST, HICONST
   wire [15:0] const_res = i_insn[8] == 1'b0 ? 16'b0 | i_insn[8:0] : 
                           (16'hffff << 9) | i_insn[8:0];
   wire [15:0] hiconst_res = (i_insn[7:0] << 8) | (i_r1data & 16'hff);

   // SLL, SRA, SRL
   wire [15:0] sll_res = i_r1data << i_insn[3:0];
   wire [15:0] sra_res = $signed(i_r1data) >>> i_insn[3:0];
   wire [15:0] srl_res = i_r1data >> i_insn[3:0];

   // JMPR
   wire [15:0] jmpr_res = i_r1data;

   // TRAP
   wire [15:0] trap_res = 16'b1000000000000000 | i_insn[7:0];

   // Comparison operations
   wire [15:0] cmp_res;
   wire [15:0] cmpu_res;
   wire [15:0] cmpi_res;
   wire [15:0] cmpiu_res;

   assign cmp_res = cla_res == 16'b0 ? 16'b0:
                    (i_r1data[15] == 1'b0) & (i_r2data[15] == 1'b1) ? 16'b1:
                    (i_r1data[15] == 1'b1) & (i_r2data[15] == 1'b0) ? 16'hffff:
                    cla_res[15] == 1'b0 ? 16'b1:
                    16'hffff;
   assign cmpu_res = i_r1data == i_r2data ? 16'b0:
                     i_r1data > i_r2data ? 16'b1:
                     16'hffff;
   assign cmpi_res = cla_res == 16'b0 ? 16'b0:
                     (i_r1data[15] == 1'b0) & (i_insn[6] == 1'b1) ? 16'b1:
                     (i_r1data[15] == 1'b1) & (i_insn[6] == 1'b0) ? 16'hffff:
                     cla_res[15] == 1'b0 ? 16'b1:
                     16'hffff;
   assign cmpiu_res = i_r1data == (16'b0 | i_insn[6:0]) ? 16'b0:
                      i_r1data > (16'b0 | i_insn[6:0]) ? 16'b1:
                      16'hffff;

   // operations with CLA
   wire [15:0] a;
   wire [15:0] b;
   wire cin;  // carry in
   wire [15:0] cla_res; // carry look ahead result

   assign a =  cls == 4'b0000 ? i_pc:
               cls == 4'b0001 ? i_r1data:
               cls == 4'b0010 ? i_r1data:
               cls == 4'b0110 ? i_r1data:
               cls == 4'b0111 ? i_r1data:
               cls == 4'b1100 ? i_pc:
               16'b0;

   assign b =  (cls == 4'b0000) & (i_insn[8] == 1'b0) ? 16'b0 | i_insn[8:0]:
               (cls == 4'b0000) & (i_insn[8] == 1'b1) ? (16'hff << 9) | i_insn[8:0]:
               (cls == 4'b0001) & (i_insn[5:3] == 3'b000) ? i_r2data:
               (cls == 4'b0001) & (i_insn[5:3] == 3'b010) ? ~i_r2data:
               (cls == 4'b0001) & (i_insn[5] == 1'b1) & (i_insn[4] == 1'b1) ? (16'hffff << 5) | i_insn[4:0]:
               (cls == 4'b0001) & (i_insn[5] == 1'b1) & (i_insn[4] == 1'b0) ? (16'b0) | i_insn[4:0]:
               (cls == 4'b0010) & (i_insn[8:7] == 2'b00) ? ~i_r2data:
               (cls == 4'b0010) & (i_insn[8:7] == 2'b01) ? ~i_r2data:
               (cls == 4'b0010) & (i_insn[8:7] == 2'b10) & (i_insn[6] == 1'b0) ? ~(16'b0 | i_insn[6:0]):
               (cls == 4'b0010) & (i_insn[8:7] == 2'b10) & (i_insn[6] == 1'b1) ? ~(16'hffff << 7 | i_insn[6:0]):
               (cls == 4'b0110) & (i_insn[5] == 1'b1) ? 16'hfff << 6 | i_insn[5:0]:
               (cls == 4'b0110) & (i_insn[5] == 1'b0) ? 16'b0 | i_insn[5:0]:
               (cls == 4'b0111) & (i_insn[5] == 1'b1) ? 16'hfff << 6 | i_insn[5:0]:
               (cls == 4'b0111) & (i_insn[5] == 1'b0) ? 16'b0 | i_insn[5:0]:
               (cls == 4'b1100) & (i_insn[11] == 1'b1) & (i_insn[10] == 1'b1) ? 16'hfff << 11 | i_insn[10:0]:
               (cls == 4'b1100) & (i_insn[11] == 1'b1) & (i_insn[10] == 1'b0) ? 16'b0 | i_insn[10:0]:
               16'b0;

   assign cin =  (cls == 4'b0000) ? 1'b1:
                 (cls == 4'b0001) & (i_insn[5:3] == 3'b010) ? 1'b1:
                 (cls == 4'b0010) ? 1'b1:
                 (cls == 4'b1100) & (i_insn[11] == 1'b1) ? 1'b1:
                  1'b0;

   cla16 cla0(.a(a),
              .b(b),
              .cin(cin),
              .sum(cla_res));

   // ALU outputs
   wire [15:0] arith_res;
   wire [15:0] cmp_module_res;
   wire [15:0] logic_res;
   wire [15:0] shift_mod_res;

   assign arith_res = (i_insn[5:3] == 3'b001) ? mul_res:
                      (i_insn[5:3] == 3'b011) ? div_res:
                      cla_res;

   assign cmp_module_res = (i_insn[8:7] == 2'b00) ? cmp_res:
                           (i_insn[8:7] == 2'b01) ? cmpu_res:
                           (i_insn[8:7] == 2'b10) ? cmpi_res:
                           (i_insn[8:7] == 2'b11) ? cmpiu_res:
                           16'b0;

   assign logic_res = (i_insn[5:3] == 3'b001) ? not_res:
                      (i_insn[5:3] == 3'b010) ? or_res:
                      (i_insn[5:3] == 3'b011) ? xor_res:
                      and_res;

   assign shift_mod_res = (i_insn[5:4] == 2'b00) ? sll_res:
                          (i_insn[5:4] == 2'b01) ? sra_res:
                          (i_insn[5:4] == 2'b10) ? srl_res:
                          (i_insn[5:4] == 2'b11) ? mod_res:
                           16'b0;

   assign o_result = (cls == 4'b0000) ? cla_res:
                     (cls == 4'b0001) ? arith_res:
                     (cls == 4'b0010) ? cmp_module_res:
                     (cls == 4'b0100) & (i_insn[11] == 1'b0) ? jsrr_res: 
                     (cls == 4'b0100) & (i_insn[11] == 1'b1) ? jsr_res:
                     (cls == 4'b0101) ? logic_res:
                     (cls == 4'b0110) ? cla_res:
                     (cls == 4'b0111) ? cla_res:
                     (cls == 4'b1000) ? rti_res:
                     (cls == 4'b1001) ? const_res:
                     (cls == 4'b1010) ? shift_mod_res:
                     (cls == 4'b1100) & (i_insn[11] == 1'b0) ? jmpr_res:
                     (cls == 4'b1100) & (i_insn[11] == 1'b1) ? cla_res:
                     (cls == 4'b1101) ? hiconst_res:
                     (cls == 4'b1111) ? trap_res:
                     16'b0;

endmodule
