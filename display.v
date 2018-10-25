module display (
	input clock,
	input [31:0] value,
	output [7:0] control,
	output [7:0] segments
);

//  ###0###
// #       #
// #       #
// 5       1
// #       #
// #       #
//  ###6###
// #       #
// #       #
// 4       2
// #       # ###
// #       # #7#
//  ###3###  ###

//        76543210
//
// 0 - 8'b00111111
// 1 - 8'b00000110
// 2 - 8'b01011011
// 3 - 8'b01001111
// 4 - 8'b01100110
// 5 - 8'b01101101
// 6 - 8'b01111101
// 7 - 8'b00000111
// 8 - 8'b01111111
// 9 - 8'b01101111
// . - 8'b10000000
// A - 8'b01110111
// b - 8'b01111100
// c - 8'b01011000
// d - 8'b01011110
// E - 8'b01111001
// F - 8'b01110001
// r - 8'b01010000
// o - 8'b01011100

reg [13:0] counter = 0;
reg [2:0] ctrl = 0;

reg [3:0] digit [0:7];

wire [3:0] dig;

assign dig = digit[ctrl] > 9 ? digit[ctrl] - 10 : digit[ctrl];

assign control = ~(1 << ctrl);
assign segments = ~(dig < 5 
	? (dig < 3 
	? (dig < 2 
		? (dig == 0 
		? 8'b00111111 // 0
		: 8'b00000110) // 1
		: 8'b01011011) // 2
		: (dig == 3 
		? 8'b01001111 // 3
		: 8'b01100110)) // 4
	: (dig < 8 
	? (dig < 7 
		? (dig == 5 
		? 8'b01101101 // 5
		: 8'b01111101) // 6
		: 8'b00000111) // 7
	: (dig == 8 
		? 8'b01111111 // 8
			: 8'b01101111))); // 9
			
always  @(posedge clock)
begin
	digit[0] <= value;
	digit[1] <= (value >> 1) / 5;
	digit[2] <= (value >> 2) / 25;
	digit[3] <= (value >> 3) / 125;
	digit[4] <= (value >> 4) / 625;
	digit[5] <= (value >> 5) / 3125;
	digit[6] <= (value >> 6) / 15625;
	digit[7] <= (value >> 7) / 78125;
	if (counter == 10000)
	begin
	counter <= 0;
		if (ctrl == 7)
			ctrl <= 0;
		else
			ctrl <= ctrl + 1;
	end
	else
		counter <= counter + 1;
end

endmodule
