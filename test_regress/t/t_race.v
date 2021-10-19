module flip_flop(q, data, clock, reset);
	input data;
	input clock;
	input reset;
	output q;
	reg q;
	always @(posedge clock ,negedge reset) begin
		if(!reset)
			q <= 1'b0;
		else
			q <= data;
	end
endmodule

module t_race(clock, data, reset, d_out);
	input clock;
	input data;
	input reset;
	output d_out;
	wire clk_2;
	wire q_d;
	reg [7:0] cyc; initial cyc=0;

	flip_flop u_clk_div(clk_2, ~clk_2, clock, reset);
	flip_flop u_dff1(q_d, data, clock, reset);
	flip_flop u_dff2(d_out, q_d, clk_2, reset);
	
	//assert property (@(posedge clk_2) disable iff(!reset) $rose(q_d) |=> $rose(d_out) )
	//else begin
	//	$display("Error: [%0t] rose(q_d) and rose(d_out) occurs simultaneously! ", $time);
	//	$finish;
	//end

	always @ (posedge clock) begin
		cyc <= cyc + 8'h1;
		if(cyc == 16 && d_out == 1'b0) begin 
			$write("*-* All Finished *-*\n");
		end
		if (cyc==20) begin
	 		$finish;
		end	
	end
	initial begin
		$dumpfile("test_top.vcd");
		$dumpvars();
	end
endmodule
