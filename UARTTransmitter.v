//top module entity for the UART transmitter which includes the BaudControl and the UART_Transmitter modules. 
module UARTTransmitter(
	input clk, //50Mhz
	input PbitEna, //if high then Parity bit is checked and sent
	input Rxi, //receiver that receives the reset signal from the UART receiver
	output ena, //not connected
	input [7:0]UI, //User data inputs
	input [2:0]BC, //baud control can include 3 more baud rate selections
	output Txo	 //Transmitted UART signal
);

	/* baud rate selections (~BC[2]&~BC[1]&BC[0])?Baud_19200:(~BC[2]&BC[1]&~BC[0])?Baud_38400:(~BC[2]&BC[1]&BC[0])?Baud_57600:(BC[2]&~BC[1]&~BC[0])?Baud_115200:Baud_9600;
	50Mhz/bps=clkfrequency/bps
	parameter Baud_9600 = 434; 9600 bauds * 12 = 112500 bps;
	parameter Baud_19200 = 217; 19200 bauds * 12 = 230400 bps;
	parameter Baud_38400 = 108 or 109; 38400 bauds * 12 =  460800 bps; with 108=462963bps
	parameter Baud_57600 = 72; 57600 bauds * 12 = 691200 bps; 694444
	parameter Baud_115200 = 36; 115200 bauds * 12 = 1382400 bps;
	*/
	
	wire enaw; //modified clk rate for the transmitter	
	
	assign ena = enaw;

	
	BaudControl BaudControlInst(.clk(clk), .BC(BC), .ena(enaw));
	
	UART_Transmitter_FSM UART_TransmitterInst(.clk(clk), .PbitEna(PbitEna), .ena(enaw), .Rxi(Rxi), .UI(UI), .Txout(Txo));
		
endmodule


_______________________________________________________________________________________________________________________________________________

//UART Transmitter state machine module that sends 1 bit at a time
module UART_Transmitter_FSM(
	input clk, //gets modified by the baud controller
	input ena,
	input PbitEna,
	input Rxi, //reset input signal from the receiver
	input [7:0]UI, //8 user inputs
	output reg Txout //transmitted UART signal with parity bit to the Receiver	
);	


	parameter Max_Cntr=4'd15; //max counter and the amount of bits that gets transmitted
	reg [3:0] Cntr = 4'd0; //initializes the counter
	wire Pbit; //parity bit net
	
	assign Pbit = (PbitEna)?^UI[7:0]:1'b1; //nets the parity bit
	
	always@(posedge clk) begin //counts to 15
		if((Cntr==Max_Cntr||Rxi)&&ena)
			Cntr <= 4'd0;
		else if(ena)
			Cntr <= Cntr+1'b1;
	end
	

	always@(posedge clk) begin //updates what gets outputted depending on counter
		if(~ena)
			Txout <= 1'b1;
		else
			case(Cntr)
				4'd2:Txout<=1'b0; //start bit
				4'd3:Txout<=UI[0]; //8-bits UI are the data bits
				4'd4:Txout<=UI[1];
				4'd5:Txout<=UI[2];
				4'd6:Txout<=UI[3];
				4'd7:Txout<=UI[4];
				4'd8:Txout<=UI[5];
				4'd9:Txout<=UI[6];
				4'd10:Txout<=UI[7];
				4'd11:Txout<=Pbit; //parity bit
				default:Txout<=1'b1; //Idle/Stop bits
			endcase
	end


endmodule

_______________________________________________________________________________________________________________________________________________
//generates an enable signal that triggers at certain Bits Per Second(bps)
module BaudControl(
	input clk, //50MHz clk//User Input Baud controls
	input [2:0]BC, //baud controller conditions
	output reg ena //Clk with modified BPS
);

	//top 5 most used baud rates
	//50Mhz/bps=clkfrequency/bps
	parameter Baud_9600 = 9'd434; //9600 bauds * 12 = 112500 bps;
	parameter Baud_19200 = 9'd217; //19200 bauds * 12 = 230400 bps;
	parameter Baud_38400 = 9'd109; //38400 bauds * 12 =  460800 bps; with 108=462963bps
	parameter Baud_57600 = 9'd72; //57600 bauds * 12 = 691200 bps; 694444
	parameter Baud_115200 = 9'd36; //115200 bauds * 12 = 1382400 bps;


	reg [8:0] Cntr = 9'd0; //counter register
	reg [8:0] Max_Cntr1; //max counter register
	wire [8:0] Max_Cntr; //net for the max counter
		
	//BC conditions that picks the baud rate 
	assign Max_Cntr=(~BC[2]&~BC[1]&BC[0])?Baud_19200:(~BC[2]&BC[1]&~BC[0])?Baud_38400:(~BC[2]&BC[1]&BC[0])?Baud_57600:(BC[2]&~BC[1]&~BC[0])?Baud_115200:Baud_9600;
	
	always@(posedge clk) begin //loads the value of the max counter
		Max_Cntr1 <= Max_Cntr;
	end
		
	
	always@(posedge clk) begin //updates and increments the counter
		if(Cntr==Max_Cntr1) 
			Cntr <= 9'd0;
		else
			Cntr <= Cntr + 1'b1;
	end
	
	always@(*) begin //toggles Txo_clk
		if(Cntr==Max_Cntr1)
			ena <= 1'b1;
		else
			ena <= 1'b0;
	end
	
	
	
	
endmodule

