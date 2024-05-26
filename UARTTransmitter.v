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