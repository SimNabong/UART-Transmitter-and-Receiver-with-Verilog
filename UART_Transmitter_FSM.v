//UART Transmitter state machine that sends 1 bit at a time
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