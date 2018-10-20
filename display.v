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

reg [13:0] counter = 0;
reg [2:0] ctrl = 0;

reg [3:0] digit;

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
begin: a1
    digit <= value / (10 ** ctrl) % 10;
    counter = counter + 1;
    if (counter == 10000)
    begin
    counter = 0;
    ctrl = ctrl + 1;
	if (ctrl == 8)
	    ctrl = 0;
    end
end

endmodule
