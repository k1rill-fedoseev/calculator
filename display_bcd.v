module display_bcd (
	//Just 50 MHz clock
	input clock,

	//Switching hexademical and decimal representations
	input switch,

	//Value to be displayed in binary format
	input [31:0] value,

	//Segments of display
	output [7:0] control,

	//LEDs of one segment
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

//All representation of used symbols
parameter D_ZERO = 8'b00111111;
parameter D_ONE = 8'b00000110;
parameter D_TWO = 8'b01011011;
parameter D_THREE = 8'b01001111;
parameter D_FOUR = 8'b01100110;
parameter D_FIVE = 8'b01101101;
parameter D_SIX = 8'b01111101;
parameter D_SEVEN = 8'b00000111;
parameter D_EIGHT = 8'b01111111;
parameter D_NINE = 8'b01101111;
parameter D_DOT = 8'b10000000;
parameter D_A = 8'b01110111;
parameter D_B = 8'b01111100;
parameter D_C = 8'b01011000;
parameter D_D = 8'b01011110;
parameter D_E = 8'b01111001;
parameter D_F = 8'b01110001;
parameter D_R = 8'b01010000;
parameter D_O = 8'b01011100;

//Delay counter, delaying 8192 clock cycles ~ 0.16 ms
reg [12:0] counter = 0,

//Saved Binary-Coded Decimal
reg [31:0] r_bcd;

//Number of segment that is active on current iteration 
reg [2:0] ctrl = 0;

//Current digit shown on the current segment
reg [3:0] digit;

//Asserted for 1 cycle when conversion to Binary-Coded Decimal is done
wire converted;

//Intermediate Binary-Coded decimal value
wire [31:0] bcd;

//Decoded number digits
wire [31:0] digits;

bcd_convert #(32, 8) bcd_convert( 
	.i_Clock(clock),
	.i_Binary(value),
	.i_Start(1),
	.o_BCD(bcd),
	.o_DV(converted));

//Switching final number representation
assign digits = switch ? r_bcd : value;

//Constolling segments
assign control = ~(1 << ctrl);

//Controlling LEDs
assign segments = ~
(digit == 0 ? D_ZERO :
(digit == 1 ? D_ONE :
(digit == 2 ? D_TWO :
(digit == 3 ? D_THREE :
(digit == 4 ? D_FOUR :
(digit == 5 ? D_FIVE :
(digit == 6 ? D_SIX :
(digit == 7 ? D_SEVEN :
(digit == 8 ? D_EIGHT :
(digit == 9 ? D_NINE :
(digit == 10 ? D_A :
(digit == 11 ? D_B :
(digit == 12 ? D_C :
(digit == 13 ? D_D :
(digit == 14 ? D_E :
(digit == 15 ? D_F :
))))))))))))))));

always  @(posedge clock)
begin
	//Select current digit
	case(ctrl)
		0: digit <= digits[3:0];
		1: digit <= digits[7:4];
		2: digit <= digits[11:8];
		3: digit <= digits[15:12];
		4: digit <= digits[19:16];
		5: digit <= digits[23:20];
		6: digit <= digits[27:24];
		7: digit <= digits[31:28];
	endcase

	//Increase current delay
	counter <= counter + 1;
end

always @(posedge counter[12])
begin
	//Delay is done, increase segment number
	ctrl <= ctrl + 1;
end

always @(posedge converted)
begin
	//Save converted Binary-Coded Decimal
	r_bcd <= bcd;
end

endmodule
