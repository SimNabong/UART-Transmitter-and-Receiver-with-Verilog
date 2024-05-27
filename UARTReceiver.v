/*The top level entity for the UART receiver with baud control and parity Bit. This module includes the modules BaudControl, UARTReceiverStateMachine, and Eight_Bit_Parity_Checker
*/
module UARTReceiver(
	input Rx_in, //Receiver Input from Transmitter
	input clk, //external 50Mhz clk
	input reset, //User reset input
	input [2:0]BC, //user baud rate control selection (~B3&~B2&B1)?9'd217:(~B3&B2&~B1)?9'd109:(~B3&B2&B1)?9'd72:(B3&~B2&~B1)?9'd36:9'd434;
	output [7:0]DataOut, //8 output bits based on the transmitters input
	output Mreset, //sends a reset signal to the transmitter
	output ena
);
	/*
	50Mhz/bps=clkfrequency/bps
	parameter Baud_9600 = 9'd434; //9600 bauds * 12 = 112500 bps;
	parameter Baud_19200 = 9'd217; //19200 bauds * 12 = 230400 bps;
	parameter Baud_38400 = 9'd109; //38400 bauds * 12 =  460800 bps; with 108=462963bps
	parameter Baud_57600 = 9'd72; //57600 bauds * 12 = 691200 bps; 694444
	parameter Baud_115200 = 9'd36; //115200 bauds * 12 = 1382400 bps;
	*/			
	
	
	wire enaw;	
	reg Rx_inr=1'b0;
	reg Rx_inr1;	
	wire [8:0]dataw;	
	
	assign ena = enaw;
	
	always@(posedge clk) begin
		if(enaw)
			Rx_inr1 <= Rx_in;
	end
	
	always@(posedge clk) begin
		if(enaw)
			Rx_inr <= Rx_inr1;
	end
	
	BaudControl BaudControlIns(.clk(clk), .BC(BC), .ena(enaw)); //ena is a derived clk from the 50MHz clk
	UARTReceiverStateMachine UARTReceiverStateMachineInst(.Rx_in(Rx_inr), .clk(clk), .ena(enaw), .reset(reset), .Dout(dataw), .Mreset(Mreset));//outputs a slow pulse of data(dataw) to a sync before going to a parity bit checker
	Eight_Bit_Parity_Checker Eight_Bit_Parity_Checker_Inst(.data(dataw), .DataOut(DataOut)); //parity checker that outputs the 8 bit data	
endmodule

//Parity Bit checker that checks if the data with a given parity bit matches its parity bit
module Eight_Bit_Parity_Checker(
	input [8:0]data, //9 bits with the data[8](the MSB) being the parity bit
	input PbitEna,
	output [7:0]DataOut //outputs the 8-bits if parity matches
);

	assign DataOut = (~PbitEna || (^data[7:0] == data[8]))?data[7:0]:8'd0;

endmodule


//state machine that takes the uart data with parity bit
module UARTReceiverStateMachine(
	input Rx_in, //received UART data from the Master
	input clk, //clk that will have a modified rate
	input ena, //has a controlled baud rate
	input reset, //synchronous reset
	output [8:0] Dout, //9-Bits sent to the P-checker
	output wire Mreset //sends a bit to the master to reset the masters(transmitters) signal
);

	//states of the state machine
	parameter Idle=4'd0,Start=4'd1,d0=4'd2,d1=4'd3,d2=4'd4,d3=4'd5,d4=4'd6,d5=4'd7,d6=4'd8,d7=4'd9,ParityB=4'd10,Stop=4'd11,Error=4'd12;
	
	reg [3:0] state,next_state; //place holder
	reg [8:0] Drs; //temp data that might get sent to the Parity checker
	
	
	always@(posedge clk) begin //updates the state machine
		if(Mreset && ena)
			state <= Idle;
		else if(ena)
			state <= next_state;					
	end
	
	always@(*)begin //dictates what the "next_state" of the FSM moves to, depending on the "state" and the input Rx_in 
		case(state)
			Idle: 	next_state=(~Rx_in)?Start:Idle;
			Start:	next_state=d0;
			d0:		next_state=d1;
			d1:		next_state=d2;
			d2:		next_state=d3;
			d3:		next_state=d4;
			d4:		next_state=d5;
			d5:		next_state=d6;
			d6:		next_state=d7;
			d7:		next_state=ParityB;
			ParityB:	next_state=(Rx_in)?Stop:Error;
			Stop:		next_state=(Rx_in)?Idle:Start;
			Error:	next_state=(Rx_in)?Idle:Error;
			default:	next_state=Idle;
		endcase
	end
	
	
	always@(posedge clk)begin //places the data bits and the parity bit to the temporary register
		if(reset && ena)
			Drs <= 9'd0;
		else if(ena)
			case(next_state)
				d0:Drs[0] <= Rx_in;
				d1:Drs[1] <= Rx_in;
				d2:Drs[2] <= Rx_in;
				d3:Drs[3] <= Rx_in;
				d4:Drs[4] <= Rx_in;
				d5:Drs[5] <= Rx_in;
				d6:Drs[6] <= Rx_in;
				d7:Drs[7] <= Rx_in;
				ParityB:Drs[8] <= Rx_in;
				Error: Drs <= 9'd0;
				default: Drs <= Drs;
			endcase
	end
	
	reg [8:0] Doutr;
	
	always@(posedge clk)begin
		if(next_state==Stop && ena) //if condition is met, data and parity bit which was stored in Drs is sent to the parity checker
			Doutr <= Drs;
		else if(next_state==Error && ena)  //else if error, then gets zero'd
			Doutr <= 9'd0;
	end
	
	assign Dout = Doutr; 
	assign Mreset = reset||state==Error||(state==Stop&&next_state==Idle); //resets the state machine		
endmodule



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




