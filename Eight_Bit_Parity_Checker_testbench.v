`timescale 1ns/1ps

module Eight_Bit_Parity_Checker_testbench();
    reg [8:0] data;
	 reg clk;
    wire [7:0]DataOut;

    // Instantiate the ParityChecker module
	Eight_Bit_Parity_Checker Pchecker(.data(data), .clk(clk), .DataOut(DataOut));
	initial begin
		clk = 0; // Set the clock input to 0
		forever #1 clk = ~clk; // Toggle the clock every T/2 units of time
	end

   initial begin
       data = 9'b0;
       #20 data = 9'b000000000;
		 #20 data = 9'b110111111; // correct parity
		 #20 data = 9'b111111111; // Icorrect parity
       #20 data = 9'b100001111; // Incorrect parity
       #20 data = 9'b000001111; // Correct parity
       #20 data = 9'b101001111; // Correct parity
		 #20 data = 9'd0;
       #0 $finish;
   end

   initial begin
       $monitor("simtime=%g, data=%b, clk=%b, DataOut=%b", $time, data,clk,DataOut);
   end
endmodule
