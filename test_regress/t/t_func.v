// $Id$
// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed into the Public Domain, for any use,
// without warranty, 2003 by Wilson Snyder.

module t;
   reg [2:0] value;
   reg [31:0] global;
   reg [31:0] vec [1:0];

   initial begin
      global = 1;
      value = 2;
      if (add(value) != 3'd3) $stop;
      if (global != 2) $stop;
      if (add(add(3'd1)) != 3'd3) $stop;
      if (global != 4) $stop;
      if (munge4(4'b0010) != 4'b1011) $stop;
      if (toint(2) != 3) $stop;
      if (global != 5) $stop;
      setit;
      incr(global,global,32'h10);
      if (global != 32'h17) $stop;
      nop(32'h11);

      global = 32'h00000001;
      flipupperbit(global,4'd4);
      flipupperbit(global,4'd12);
      if (global !== 32'h10100001) $stop;

      if (nil_func(32'h12,32'h12) != 32'h24) $stop;
      nil_task(32'h012,32'h112,global);
      if (global !== 32'h124) $stop;
      
      vec[0] = 32'h333;
      vec[1] = 32'habc;
      incr(vec[1],vec[0],vec[1]);
      if (vec[0] != 32'h333) $stop;
      if (vec[1] != 32'hdef) $stop;

      incr(vec[2],vec[0],vec[2]);  // Reading/Writing past end of vector!

      $write("*-* All Finished *-*\n");
      $finish;
   end

   function [2:0] add;
      input [2:0] fromv;
      begin
	 add = fromv + 3'd1;
	 begin : named
	    reg [31:0] flocal;
	    flocal = 1;
	    global = global + flocal;
	 end : named	// SystemVerilog end labels
      end
   endfunction

   function [3:0] munge4;
      input [3:0] fromv; // Different fromv than the 'fromv' signal above
      reg one;
      begin : named
	 reg [1:0] flocal;
	 // Function calling a function
	 one = 1'b1;
	 munge4 = {one, add(fromv[2:0])};
      end
   endfunction

   task setit;
      reg [31:0] temp;
      begin
	 temp = global + 32'h1;
	 global = temp + 32'h1;
      end
   endtask

   task incr (
	      // Check a V2K style input/output list
    output [31:0] z,
    input [31:0]  a, inc
	      );
      z = a + inc;
   endtask

   task nop;
      input  [31:0] a;
      begin
      end
   endtask

   task flipupperbit;
      inout [31:0] vector;
      input [3:0] bitnum;
      reg [4:0]   bitnum2;
      begin
	 bitnum2 = {1'b1, bitnum};	// A little math to test constant propagation
	 vector[bitnum2] = vector[bitnum2] ^ 1'b1;
      end
   endtask

   task nil_task;
      input [31:0] a;
      input [31:0] b;
      output [31:0] q;
      // verilator no_inline_task
      q = nil_func(a, b);
   endtask

   function [31:0] nil_func;
      input [31:0] fa;
      input [31:0] fb;
      // verilator no_inline_task
      nil_func = fa + fb;
   endfunction

   function integer toint;
      input integer fa;
      toint = fa + 32'h1;
   endfunction

endmodule
