`timescale 1ns/1ps

module UART_Transmitter_FSM_testbench();
	reg clk;
	reg Rxi;
	reg [7:0]UI;
	wire Txout;
	
	UART_Transmitter_FSM UART_TransmitterInst(.clk(clk), .Rxi(Rxi), .UI(UI), .Txout(Txout));
	
	initial begin
		clk = 0; //initialized clock to 0 
		forever #1 clk = ~clk; //clock toggling forever
	end
	
	initial begin
		Rxi = 1; 
		UI=8'b00000000;
		#7 Rxi=0;UI=8'd0;
		#50 UI=8'b00000000;
		#50 UI=8'b00000000;
		#50 UI=8'b00111000; //odd parity bit
		#50 UI=8'b11110000; //even parity bit
		#50 UI=8'b11101000; //even pbit 73 mistake
		#50 UI=8'b11001100;
		#50 UI=8'b00000000;
		#0 $finish;
	end
	
	initial begin
		$monitor("simtime=%g, clk=%b, Rxi=%b, UI=%b, Txout=%b", $time,clk,Rxi,UI,Txout);
	end 
	

endmodule