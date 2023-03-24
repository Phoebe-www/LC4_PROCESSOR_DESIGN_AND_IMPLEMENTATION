/* Group 45, Members:
   Hao Pan - Pennkey: haop
   Siyun Wang - Pennkey: wsiyun

   Lab 4: Pipelined Processor(fully-bypassed)

   lc4_pipeline.v
   This file contains the top-level module for the LC-4 processor.
   It instantiates the control unit, register file, ALU, and data memory.
   It also instantiates the testbench module, which is used to test the processor.
   Part of code from lab3: lc4_single.v */

`timescale 1ns / 1ps

// disable implicit wire declaration
`default_nettype none

module lc4_processor
   (input wire         clk, // main clock
    input wire         rst, // global reset
    input wire         gwe, // global we for single-step clock
                                    
    output wire [15:0] o_cur_pc, // Address to read from instruction memory
    input wire [15:0]  i_cur_insn, // Output of instruction memory
    output wire [15:0] o_dmem_addr, // Address to read/write from/to data memory
    input wire [15:0]  i_cur_dmem_data, // Output of data memory
    output wire        o_dmem_we, // Data memory write enable
    output wire [15:0] o_dmem_towrite, // Value to write to data memory
   
    output wire [1:0]  test_stall, // Testbench: is this is stall cycle? (don't compare the test values)
    output wire [15:0] test_cur_pc, // Testbench: program counter
    output wire [15:0] test_cur_insn, // Testbench: instruction bits
    output wire        test_regfile_we, // Testbench: register file write enable
    output wire [2:0]  test_regfile_wsel, // Testbench: which register to write in the register file 
    output wire [15:0] test_regfile_data, // Testbench: value to write into the register file
    output wire        test_nzp_we, // Testbench: NZP condition codes write enable
    output wire [2:0]  test_nzp_new_bits, // Testbench: value to write to NZP bits
    output wire        test_dmem_we, // Testbench: data memory write enable
    output wire [15:0] test_dmem_addr, // Testbench: address to read/write memory
    output wire [15:0] test_dmem_data, // Testbench: value read/writen from/to memory

    input wire [7:0]   switch_data, // Current settings of the Zedboard switches
    output wire [7:0]  led_data // Which Zedboard LEDs should be turned on?
    );
   
   /***** OUR CODE STARTS HERE *****/
   assign led_data = switch_data;
   // Always execute one instruction each cycle
   assign test_test_stall = wb_pc == 16'h0 ? 2'b10 : 2'b00;

   wire [1:0] test_test_stall;

   Nbit_reg #(2) stall_reg (.in(test_test_stall), .out(test_stall), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   /*** Fetch Stage ***/   
      // pc wires attached to the PC register's ports
      wire [15:0]   pc;      // Current program counter (read out from pc_reg)
      wire [15:0]   next_pc; // Next program counter (you compute this and feed it into next_pc)
      wire pc_we;            // Write enable for the PC register
      assign o_cur_pc = pc;
      
      // Program counter register, starts at 8200h at bootup
      Nbit_reg #(16, 16'h8200) pc_reg (.in(next_pc), .out(pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      
      // Stall and flush wires
      wire [1:0] d_stall, x_stall, m_stall, wb_stall;

   /*** Decode Stage ***/
      // get program counter + 1
      cla16 pcp1_adder(.a(pc), .b(16'b0), .cin(1'b1), .sum(pcp1));

      // Fetch to Decode reg
      wire [15:0] d_insn, d_pc, d_pcp1, pcp1;

      Nbit_reg #(16, 16'b0) fd_insn(.in(i_cur_insn), .out(d_insn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16, 16'h8200) fd_pc(.in(pc), .out(d_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16, 16'h8200) fd_pcp1(.in(pcp1), .out(d_pcp1), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

      // Instanciate decoder
      wire d_r1re, d_r2re, d_regfile_we, d_nzp_we, d_pcp1_sel, d_is_ld, d_is_str, d_is_br, d_is_ctl_insn;
      wire [2:0] d_r1sel, d_r2sel, d_wsel; // selector
      lc4_decoder decoder(
         .insn(d_insn),
         .r1sel(d_r1sel),
         .r1re(d_r1re),
         .r2sel(d_r2sel),
         .r2re(d_r2re),
         .wsel(d_wsel),
         .regfile_we(d_regfile_we),
         .nzp_we(d_nzp_we),
         .select_pc_plus_one(d_pcp1_sel),
         .is_load(d_is_ld),
         .is_store(d_is_str),
         .is_branch(d_is_br),
         .is_control_insn(d_is_ctl_insn)
      );

      // instanciate reg file
      wire [15:0] rs_data, rt_data, w_data; // data
      lc4_regfile regfile(
         .clk(clk),
         .gwe(gwe), 
         .rst(rst), 
         .i_rs(d_r1sel),
         .o_rs_data(rs_data),
         .i_rt(d_r2sel),
         .o_rt_data(rt_data),
         .i_rd(wb_wsel),
         .i_wdata(w_data),
         .i_rd_we(wb_regfile_we)
      );

      // reg input mux
      assign w_data = wb_is_ld ? wb_dmem_data:
                      wb_pcp1_sel ? wb_pcp1: // When select_pc_plus_one, write PC+1 to reg file
                      wb_alu_res; // Otherwise, write alu result of writeback stage to reg file


      // TODO: D stage stall reg and logic
      Nbit_reg #(2, 2'b10) fd_stall(.in(wb_stall), .out(d_stall), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   /*** Execute Stage ***/
      // Decode to Execute reg
      wire [15:0] x_insn, x_pc, x_pcp1, x_rs_data, x_rt_data; // do we need x_rd_data?
      wire [2:0] x_r1sel, x_r2sel, x_wsel;
      wire x_r1re, x_r2re, x_regfile_we, x_nzp_we, x_pcp1_sel, x_is_ld, x_is_str, x_is_br, x_is_ctl_insn;
      wire [8:0] x_crl; // X control signals
      
      Nbit_reg #(16) dx_insn(.in(d_insn), .out(x_insn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) dx_pc(.in(d_pc), .out(x_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) dx_pcp1(.in(d_pcp1), .out(x_pcp1), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) dx_rs_data(.in(rs_data_bp), .out(x_rs_data), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) dx_rt_data(.in(rt_data_bp), .out(x_rt_data), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

      Nbit_reg #(3) dx_rs_sel(.in(d_r1sel), .out(x_r1sel), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(3) dx_rt_sel(.in(d_r2sel), .out(x_r2sel), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(3) dx_w_sel(.in(d_wsel), .out(x_wsel), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

      Nbit_reg #(9) dx_crl(.in({d_r1re, d_r2re, d_regfile_we, d_nzp_we, d_pcp1_sel, d_is_ld, d_is_str, d_is_br, d_is_ctl_insn}), 
                           .out(x_crl), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

      assign x_r1re = x_crl[8];
      assign x_r2re = x_crl[7];
      assign x_regfile_we = x_crl[6];
      assign x_nzp_we = x_crl[5];
      assign x_pcp1_sel = x_crl[4];
      assign x_is_ld = x_crl[3];
      assign x_is_str = x_crl[2];
      assign x_is_br = x_crl[1];
      assign x_is_ctl_insn = x_crl[0];

      // instantiate ALU
      wire [15:0] alu_res;
      lc4_alu alu(
         .i_insn(x_insn),
         .i_pc(x_pc),
         .i_r1data(x_rs_data_bp),
         .i_r2data(x_rt_data_bp),
         .o_result(alu_res)
      );

      // instantiate NZP reg
      wire [2:0] nzp_in, nzp_out;
      wire [15:0] nzp_sel;
      assign nzp_sel = x_is_ld ? i_cur_dmem_data : // load
                     x_insn[15:12] == 4'b1111 ? x_pcp1 : // trap
                     alu_res; // other ctl insns
      assign nzp_in = nzp_sel == 16'b0 ? 3'b010 : // =0
                     nzp_sel[15] == 1'b1 ? 3'b100 : // <0
                     3'b001; // >0
      Nbit_reg #(3) nzp_reg(.in(nzp_in), .out(nzp_out), .clk(clk), .we(x_nzp_we), .gwe(gwe), .rst(rst));

      // TODO: DX stall reg and logic
      wire is_stall = x_is_ld & ((d_r1sel == x_wsel) | (~d_is_str & (d_r2sel == x_wsel)));
      wire [1:0] x_stall_in = is_stall ? 2'b11 :
                              d_insn == 16'b0 ? 2'b10 :
                              2'b0;

      assign pc_we = x_stall_in != 0 ? 1'b1 : 1'b0;
      //assign fd_we = x_stall_in != 0 ? 1'b1 : 1'b0; 

      Nbit_reg #(2) dx_stall(.in(x_stall_in), .out(x_stall), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

      // NOP kicks in when getting a stall
      wire [15:0] d_in_insn = (x_stall_in == 2'b11) ? 16'b0 : // op a NOP
                               d_insn;
      // update DX insn reg
      //Nbit_reg #(16, 16'b0) dx_insn(.in(d_in_insn), .out(x_insn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

      // TODO: add sign extension and left shift
      // sign extend 5-bit imm
      // wire [15:0] imm5_ext = {16{d_insn[4]}}, imm_lsh = d_insn[4:0] << 1;
      // sign extend 9-bit imm
      // wire [15:0] imm9_ext = {16{d_insn[8]}}, imm9_lsh = d_insn[8:0] << 1;

   /*** Memory Stage ***/
      // Execute to Memory reg
      wire [15:0] m_insn, m_pc, m_pcp1, m_alu_res, m_rt_data;
      wire [2:0] m_nzp, m_r1sel, m_r2sel, m_wsel;
      wire [8:0] m_crl; // control signals
      wire m_r1re, m_r2re, m_regfile_we, m_nzp_we, m_pcp1_sel, m_is_ld, m_is_str, m_is_br, m_is_ctl_insn;

      Nbit_reg #(16) xm_insn(.in(x_insn), .out(m_insn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) xm_pc(.in(x_pc), .out(m_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) xm_pcp1(.in(x_pcp1), .out(m_pcp1), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) xm_alu_res(.in(alu_res), .out(m_alu_res), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) xm_rt_data(.in(x_rt_data), .out(m_rt_data), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(3) xm_nzp(.in(nzp_out), .out(m_nzp), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      
      Nbit_reg #(3) xm_wsel(.in(x_wsel), .out(m_wsel), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      
      Nbit_reg #(9) xm_ctl(.in(x_crl), .out(m_crl), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      
      assign m_r1re = m_crl[8];
      assign m_r2re = m_crl[7];
      assign m_regfile_we = m_crl[6];
      assign m_nzp_we = m_crl[5];
      assign m_pcp1_sel = m_crl[4];
      assign m_is_ld = m_crl[3];
      assign m_is_str = m_crl[2];
      assign m_is_br = m_crl[1];
      assign m_is_ctl_insn = m_crl[0];

      // branch logic
      wire is_br;
      assign is_br = (m_nzp == 3'b100) & (m_insn[11] == 1'b1) ? 1'b1 : // branch n
                     (m_nzp == 3'b010) & (m_insn[10] == 1'b1) ? 1'b1 : // branch z
                     (m_nzp == 3'b001) & (m_insn[9]  == 1'b1) ? 1'b1 : // branch p
                     1'b0;
      assign next_pc = (m_is_br & is_br) | m_is_ctl_insn ? m_alu_res : pcp1;

      // assign data memory wires
      assign o_dmem_addr = (m_is_ld | m_is_str) ? m_alu_res : 16'h0000;
      //assign o_dmem_towrite = rt_data;
      assign o_dmem_we = m_is_str;
      
      // M Stage stall reg
      Nbit_reg #(2, 2'b10) xm_stall(.in(x_stall), .out(m_stall), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   /*** Writeback Stage ***/
      // Memory to Writeback reg
      wire [15:0] wb_insn, wb_pc, wb_pcp1, wb_alu_res, wb_dmem_data; 
      wire [15:0] wb_dmem_addr, wb_dmem_towrite;
      wire wb_r1re, wb_r2re, wb_regfile_we, wb_nzp_we, wb_pcp1_sel, wb_is_ld, wb_is_str, wb_is_br, wb_is_ctl_insn;
      wire wb_dmem_we;
      wire [2:0] wb_nzp, wb_wsel;
      wire [8:0] wb_crl; // control signals

      Nbit_reg #(16) mw_insn(.in(m_insn), .out(wb_insn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) mw_pc(.in(m_pc), .out(wb_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) mw_pcp1(.in(m_pcp1), .out(wb_pcp1), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) mw_alu_data(.in(m_alu_res), .out(wb_alu_res), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) mw_dmem_data(.in(i_cur_dmem_data), .out(wb_dmem_data), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) mw_dmem_addr(.in(o_dmem_addr), .out(wb_dmem_addr), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(16) mw_dmem_towrite(.in(o_dmem_towrite), .out(wb_dmem_towrite), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

      Nbit_reg #(3) mw_wsel(.in(m_wsel), .out(wb_wsel), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
      Nbit_reg #(3) mw_nzp(.in(m_nzp), .out(wb_nzp), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

      Nbit_reg #(9) mw_ctl(.in(m_crl), .out(wb_crl), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

      assign wb_r1re = wb_crl[8];
      assign wb_r2re = wb_crl[7];
      assign wb_regfile_we = wb_crl[6];
      assign wb_nzp_we = wb_crl[5];
      assign wb_pcp1_sel = wb_crl[4];
      assign wb_is_ld = wb_crl[3];
      assign wb_is_str = wb_crl[2];
      assign wb_is_br = wb_crl[1];
      assign wb_is_ctl_insn = wb_crl[0];

      // Test signals
      assign test_cur_insn = wb_insn;
      assign test_cur_pc = wb_pc;
      assign test_regfile_we = wb_regfile_we;
      assign test_regfile_wsel = wb_wsel;
      assign test_regfile_data = w_data;
      assign test_nzp_we = wb_nzp_we;
      assign test_nzp_new_bits = test_nzp; //wb_nzp;

      wire [2:0] test_nzp;
      assign test_nzp = (w_data == 16'b0) ? 3'b010 : (w_data[15] == 1'b1) ? 3'b100 : 3'b001;

      assign test_dmem_we = wb_is_str;
      assign test_dmem_addr = wb_dmem_addr;
      assign test_dmem_data = wb_is_ld ? wb_dmem_data :
                              wb_is_str ? wb_dmem_towrite :
                              16'b0;

   /*** Bypassing ***/
   // WD Bypassing
   wire [15:0] w_data_bp;
   assign w_data_bp = wb_is_ld ? wb_dmem_data:
                      wb_alu_res; // Otherwise, write alu result of writeback stage to reg file
   
   wire [15:0] rs_data_bp = (wb_wsel == d_r1sel) & (wb_regfile_we) ? w_data_bp : rs_data;
   wire [15:0] rt_data_bp = (wb_wsel == d_r2sel) & (wb_regfile_we) ? w_data_bp : rt_data;
   // WX & MX Bypassing
   wire [15:0] x_rs_data_bp = (x_r1sel == m_wsel) & (m_regfile_we) ? m_alu_res : (x_r1sel == wb_wsel) & (wb_regfile_we) ? w_data_bp : x_rs_data;
   wire [15:0] x_rt_data_bp = (x_r2sel == m_wsel) & (m_regfile_we) ? m_alu_res : (x_r2sel == wb_wsel) & (wb_regfile_we) ? w_data_bp : x_rt_data;
   // WM Bypassing
   wire [15:0] m_rt_data_bp = (wb_wsel == m_r2sel & wb_is_ld & m_is_str) ? w_data_bp : m_rt_data;
   assign o_dmem_towrite = m_rt_data_bp;
   /***** OUR CODE ENDS HERE *****/

/* Add $display(...) calls in the always block below to
    * print out debug information at the end of every cycle.
    * 
    * You may also use if statements inside the always block
    * to conditionally print out information.
    *
    * You do not need to resynthesize and re-implement if this is all you change;
    * just restart the simulation.
    */

`ifndef NDEBUG
   always @(posedge gwe) begin
      // $display("%d %h %h %h %h %h", $time, f_pc, d_pc, e_pc, m_pc, test_cur_pc);
  //    if (F_pc >= 16'h8232)begin
  //       $display(" F_pc:%h,D_pc:%h,X_pc:%h,M_pc:%h,W_pc:%h,stall:%d", F_pc,D_pc,X_pc,M_pc,W_pc,stall );
  //       $display(" D_rs_sel:%d, D_rt_sel:%d,X_rs_sel:%d, X_rt_sel:%d, M_rd_sel:%d, W_rd_sel:%d",D_rs_sel,D_rt_sel, X_rs_sel,X_rt_sel,M_rd_sel,W_rd_sel );
      //$display(" X_alu_out:%h, W_alu_out:%h, M_alu_out:%h", X_alu_out, W_alu_out, M_alu_out );
   //      $display(" D_rs_out:%h, D_rt_out:%h,X_alu_r1_in:%h, X_alu_r2_in:%h, W_wdata:%h",D_rs_out,D_rt_out, X_alu_r1_in, X_alu_r2_in,W_wdata );
  //       $display();
   //   end
      // Start each $display() format string with a %d argument for time
      // it will make the output easier to read.  Use %b, %h, and %d
      // for binary, hex, and decimal output of additional variables.
      // You do not need to add a \n at the end of your format string.
     // if ($time < 1000)
    //  $display("%d %h %h %h %h %h %h", $time, test_cur_pc, x_rs_data_bp, x_rs_data, x_rt_data_bp, x_rs_data, test_regfile_data);

      // Try adding a $display() call that prints out the PCs of
      // each pipeline stage in hex.  Then you can easily look up the
      // instructions in the .asm files in test_data.

      // basic if syntax:
      // if (cond) begin
      //    ...;
      //    ...;
      // end

      // Set a breakpoint on the empty $display() below
      // to step through your pipeline cycle-by-cycle.
      // You'll need to rewind the simulation to start
      // stepping from the beginning.

      // You can also simulate for XXX ns, then set the
      // breakpoint to start stepping midway through the
      // testbench.  Use the $time printouts you added above (!)
      // to figure out when your problem instruction first
      // enters the fetch stage.  Rewind your simulation,
      // run it for that many nano-seconds, then set
      // the breakpoint.

      // In the objects view, you can change the values to
      // hexadecimal by selecting all signals (Ctrl-A),
      // then right-click, and select Radix->Hexadecimal.

      // To see the values of wires within a module, select
      // the module in the hierarchy in the "Scopes" pane.
      // The Objects pane will update to display the wires
      // in that module.

      //$display(); 
   end
`endif

endmodule

