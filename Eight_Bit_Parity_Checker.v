//Parity Bit checker that checks if the data with a given parity bit matches its parity bit
module Eight_Bit_Parity_Checker(
	input [8:0]data, //9 bits with the data[8](the MSB) being the parity bit
	input clk,
	output [7:0]DataOut //outputs the 8-bits if parity matches
);

	reg [7:0] datar; //pipeline reg
	reg PPAss;
	always@(posedge clk) //pipeline
		datar <= data[7:0]; 
		
	always@(*) begin
		PPAss = (^data[7:0] == data[8])?1'b1:1'b0;
	end

	assign DataOut = (PPAss)? datar:8'd0;
	

	
endmodule
