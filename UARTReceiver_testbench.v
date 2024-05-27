`timescale 1ns/1ps

module UARTReceiver_testbench();
	reg Rx_in; //Receiver Input from Transmitter
	reg clk; //external 50Mhz clk
	reg reset; //User reset input
	reg [2:0]BC; //user baud rate control (~B3&~B2&B1)?9'd217:(~B3&B2&~B1)?9'd109:(~B3&B2&B1)?9'd72:(B3&~B2&~B1)?9'd36:9'd434;
	wire [7:0]DataOut; //8 output bits based on the transmitters input
	wire Mreset; //sends a reset signal to the transmitter
	reg PbitEna;
	wire ena; //add or remove and for testbench purpose only
	
/*module UARTReceiver(
	input Rx_in, //Receiver Input from Transmitter
	input clk, //external 50Mhz clk
	input reset, //User reset input
	input [2:0]BC, //user baud rate control (~B3&~B2&B1)?9'd217:(~B3&B2&~B1)?9'd109:(~B3&B2&B1)?9'd72:(B3&~B2&~B1)?9'd36:9'd434;
	output [7:0]DataOut, //8 output bits based on the transmitters input
	output Mreset, //sends a reset signal to the transmitter
	output wire ena //add or remove and for testbench purpose only
);*/
		

	
	UARTReceiver UARTReceiverInstance(
		.Rx_in(Rx_in),
		.clk(clk),
		.PbitEna(PbitEna),
		.reset(reset),
		.BC(BC),
		.DataOut(DataOut),
		.Mreset(Mreset),
		.ena(ena)
	);
	
	initial begin
		clk = 0; // Set the clock input to 0
		forever #1 clk = ~clk; // Toggle the clock every T/72 units of time
	end
	
	initial begin
		Rx_in = 1;     
		reset = 0;
		BC = 3'd0;
		PbitEna = 1'b1;
		
		#850 Rx_in=1; //I
		#850 Rx_in=1; //I
		#850 Rx_in=1; //I
		#850 Rx_in=1; //I
		#850 Rx_in=1; //I
		#850 Rx_in=1; //I
		#850 Rx_in=1; //I
		#850 Rx_in=1; //I
		#850 Rx_in=1; //I
		#850 Rx_in=1; //I
		#850 Rx_in=1; //I
		#850 Rx_in=1; //I
		#850 Rx_in=1; //I
		#850 Rx_in=1; //I
		#868 Rx_in=0; //S
		#868 Rx_in=1; //D0 
		#868 Rx_in=0; //D1 
		#868 Rx_in=1; //D2
		#868 Rx_in=0; //D3 
		#868 Rx_in=0; //D4 
		#868 Rx_in=0; //D5 
		#868 Rx_in=0; //D6 
		#868 Rx_in=1; //D7 
		#868 Rx_in=1; //P8 88773
		#868 Rx_in=1; //Sb 96019
		#868 Rx_in=1; //Sb 96019
		#868 Rx_in=1; //Sb 96019
		#868 Rx_in=1; //Sb 96019
		#868 Rx_in=1; //Sb 96019
		#868 reset=1;
		#868 reset=0;
		
		
		//correct even parity 
		#868 BC=3'b100;
		#220 Rx_in=1; //baud rate change Idle state
		#72 Rx_in=1;
		#72 Rx_in=1;
		#72 Rx_in=1;
		#72 Rx_in=1;
		#72 Rx_in=1;
		#72 Rx_in=1;
		#72 Rx_in=1;
		#72 Rx_in=1;
		#72 Rx_in=1;
		#72 Rx_in=1;
		#72 Rx_in=1;
		#72 Rx_in=1;
		#72 Rx_in=0; //S
		#72 Rx_in=1; //D0 
		#72 Rx_in=1; //D1 
		#72 Rx_in=1; //D2
		#72 Rx_in=1; //D3 
		#72 Rx_in=0; //D4 
		#72 Rx_in=0; //D5 
		#72 Rx_in=1; //D6 
		#72 Rx_in=1; //D7 
		#72 Rx_in=0; //P8 
		#72 Rx_in=1; //Sb 
		#72 Rx_in=1; //Sb 
		#72 Rx_in=1; //Sb
		#72 Rx_in=1; //Sb 
		#72 Rx_in=1; //Sb 
		#72 reset=1;
		#72 reset=0;
		
		
		#72 PbitEna=1'b0; //Sb

		
		//wrong even parity
		#72 Rx_in=1;  //I 
		#72 Rx_in=0; //S 110839
		#72 Rx_in=1; //D0 
		#72 Rx_in=1; //D1 
		#72 Rx_in=1; //D2 133235
		#72 Rx_in=0; //D3 
		#72 Rx_in=0; //D4 
		#72 Rx_in=0; //D5 155441
		#72 Rx_in=1; //D6 16282911
		#72 Rx_in=0; //D7 
		#72 Rx_in=1; //P8 111
		#72 Rx_in=1; //Sb 
		#72 Rx_in=1; //I 
		

		//wrong odd parity
		#72 Rx_in=1; //I 
		#72 Rx_in=0; //S 
		#72 Rx_in=1; //D 
		#72 Rx_in=1; //D 
		#72 Rx_in=1; //D 
		#72 Rx_in=1; //D 
		#72 Rx_in=1; //D 
		#72 Rx_in=0; //D 
		#72 Rx_in=0; //D 
		#72 Rx_in=0; //D 
		#72 Rx_in=0; //P 
		#72 Rx_in=1; //Sb 
		#72 Rx_in=1; //I 
		
		//right odd parity
		

		#1000 Rx_in=0; //I

		
		#0 $finish;
		
		
		
	end
	
	
	initial begin
		$monitor("simtime=%g, clk=%b, BC=%b, Rx_in=%b, ena=%b, reset=%b, Mreset=%b, DataOut=%b", $time,clk,BC,Rx_in,ena,reset,Mreset,DataOut);
	end
	

	
endmodule	
