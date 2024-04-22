//Parity Bit checker that checks if the data with a given parity bit matches its parity bit
module Eight_Bit_Parity_Checker(
	input [8:0]data, //9 bits with the data[8](the MSB) being the parity bit
	input clk,
	output reg [7:0]DataOut //outputs the 8-bits if parity matches
);

	//data[8] is the parity bit along with the 8-bits(data[0] to data[7]) of data
	always@(posedge clk) begin	
		if(^data[7:0] == data[8]) //checks if parity matches
			DataOut[7:0]<=data[7:0];
		else
			DataOut[7:0] = 8'b00000000;
	end
	

	
endmodule