module display_bcd (
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

reg [31:0] counter = 0, r_bcd;
reg [2:0] ctrl = 0;

reg [3:0] digit;

wire converted;
wire [31:0] bcd;


bcd_convert #(32, 8) bcd_convert( 
	.i_Clock(clock),
	.i_Binary(value),
	.i_Start(1),
	.o_BCD(bcd),
	.o_DV(converted));
	

	
assign control = ~(1 << ctrl);
assign segments = ~(digit < 5 
	? (digit < 3 
	? (digit < 2 
		? (digit == 0 
		? 8'b00111111 // 0
		: 8'b00000110) // 1
		: 8'b01011011) // 2
		: (digit == 3 
		? 8'b01001111 // 3
		: 8'b01100110)) // 4
	: (digit < 8 
	? (digit < 7 
		? (digit == 5 
		? 8'b01101101 // 5
		: 8'b01111101) // 6
		: 8'b00000111) // 7
	: (digit == 8 
		? 8'b01111111 // 8
			: 8'b01101111))); // 9

always  @(posedge clock)
begin
	case(ctrl)
		0: digit <= r_bcd[3:0];
		1: digit <= r_bcd[7:4];
		2: digit <= r_bcd[11:8];
		3: digit <= r_bcd[15:12];
		4: digit <= r_bcd[19:16];
		5: digit <= r_bcd[23:20];
		6: digit <= r_bcd[27:24];
		7: digit <= r_bcd[31:28];
	endcase
	if (counter == 10000)
	begin
	counter <= 0;
	ctrl <= ctrl + 1;
	end
	else
		counter <= counter + 1;
end

always @(posedge converted)
begin
	r_bcd <= bcd;
end

endmodule
