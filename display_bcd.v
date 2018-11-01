module display_bcd (
	//Just 50 MHz clock
	input clock,

	//Switching hexademical and decimal representations
	input show_in_hex,

	//Asserted if something is going wrong, displaing error message
	input error,

	//Value to be displayed in binary format
	input [31:0] value,

	//Segments of display
	output [7:0] control,

	//LEDs of one segment
	output [7:0] leds
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
parameter D_0 = 8'b00111111;
parameter D_1 = 8'b00000110;
parameter D_2 = 8'b01011011;
parameter D_3 = 8'b01001111;
parameter D_4 = 8'b01100110;
parameter D_5 = 8'b01101101;
parameter D_6 = 8'b01111101;
parameter D_7 = 8'b00000111;
parameter D_8 = 8'b01111111;
parameter D_9 = 8'b01101111;
parameter D_DOT = 8'b10000000;
parameter D_A = 8'b01110111;
parameter D_B = 8'b01111100;
parameter D_C = 8'b01011000;
parameter D_D = 8'b01011110;
parameter D_E = 8'b01111001;
parameter D_F = 8'b01110001;
parameter D_R = 8'b01010000;
parameter D_O = 8'b01011100;
parameter D_MINUS = 8'b01000000;
parameter D_EMPTY = 8'b00000000;

parameter D_E_CODE = 14;
parameter D_R_CODE = 16;
parameter D_O_CODE = 17;
parameter D_MINUS_CODE = 18;
parameter D_EMPTY_CODE = 31;

//Delay counter, delaying 8192 clock cycles ~ 0.16 ms
reg [12:0] counter = 0;

//Saved Binary-Coded Decimal
reg [31:0] r_bcd;

//Number of segment that is active on current iteration 
reg [2:0] ctrl = 0;

//Current digit shown on the current segment
reg [4:0] digit;

//Asserted for 1 cycle when conversion to Binary-Coded Decimal is done
wire converted;

//Intermediate Binary-Coded decimal value
wire [31:0] bcd;

//Decoded number digits
wire [31:0] digits;

//Number sign
wire sign;

//Digits from unsigned numbers
wire [31:0] unsigned_number;

bcd_convert #(32, 8) bcd_convert( 
	.i_Clock(clock),
	.i_Binary(unsigned_number),
	.i_Start(1'b1),
	.o_BCD(bcd),
	.o_DV(converted));

//Get number sign
assign sign = value[31];

//Get unsigned number
assign unsigned_number = sign ? -value : value;

//Switching final number representation
assign digits = show_in_hex ? unsigned_number : r_bcd;

//Constolling segments
assign control = ~(1 << ctrl);

//Controlling LEDs
assign leds = ~
(digit == 0 ? D_0 :
(digit == 1 ? D_1 :
(digit == 2 ? D_2 :
(digit == 3 ? D_3 :
(digit == 4 ? D_4 :
(digit == 5 ? D_5 :
(digit == 6 ? D_6 :
(digit == 7 ? D_7 :
(digit == 8 ? D_8 :
(digit == 9 ? D_9 :
(digit == 10 ? D_A :
(digit == 11 ? D_B :
(digit == 12 ? D_C :
(digit == 13 ? D_D :
(digit == 14 ? D_E :
(digit == 15 ? D_F :
(digit == 16 ? D_R :
(digit == 17 ? D_O : 
(digit == 18 ? D_MINUS : 
D_EMPTY
)))))))))))))))))));

always @(posedge clock)
begin
	if (error)
		//Display error message
		case(ctrl)
			0: digit <= D_R_CODE;
			1: digit <= D_O_CODE;
			2: digit <= D_R_CODE;
			3: digit <= D_R_CODE;
			4: digit <= D_E_CODE;
			5: digit <= D_EMPTY_CODE;
			6: digit <= D_EMPTY_CODE;
			7: digit <= D_EMPTY_CODE;
		endcase
	else
		//Select current digit
		case(ctrl)
			0: digit <= digits[3:0];
			1: digit <= digits[31:4] ? digits[7:4] : D_EMPTY_CODE;
			2: digit <= digits[31:8] ? digits[11:8] : D_EMPTY_CODE;
			3: digit <= digits[31:12] ? digits[15:12] : D_EMPTY_CODE;
			4: digit <= digits[31:16] ? digits[19:16] : D_EMPTY_CODE;
			5: digit <= digits[31:20] ? digits[23:20] : D_EMPTY_CODE;
			6: digit <= digits[31:24] ? digits[27:24] : D_EMPTY_CODE;
			7: digit <= sign ? D_MINUS_CODE : (digits[31:28] ? digits[31:28] : D_EMPTY_CODE);
		endcase

	//Increase current delay
	counter <= counter + 1;
	
	//Delay is done, increase segment number
	if (counter == 13'b1000000000000)
		ctrl <= ctrl + 1;
	
	//Save converted Binary-Coded Decimal
	if (converted)
		r_bcd <= bcd;
end

endmodule
