module numpad (
	//Just 50 MHz clock
	input clock,

	//Numpad rows
	input [3:0] rows,

	//Numpad columns
	output [3:0] columns,

	//State change description
	output [4:0] value
);

// #############################
// #      #      #      #      #
// # 1(0) # 2(4) # 3(8) # A(12)#  row 0
// #      #      #      #      #
// #############################
// #      #      #      #      #
// # 4(1) # 5(5) # 6(9) # B(13)#  row 1
// #      #      #      #      #
// #############################
// #      #      #      #      #
// # 7(2) # 8(6) # 9(10)# C(14)#  row 2
// #      #      #      #      #
// #############################
// #      #      #      #      #
// # 0(3) # F(7) # E(11)# D(15)#  row 3
// #      #      #      #      #
// #############################

//Previous pressed button
reg [4:0] prev = 0;

//Cuurent pressed button
reg [4:0] cur = 0;

//Cuurent column number
reg [1:0] col = 0;

//Counter for delay
reg [12:0] counter = 0;

//Controlling column
assign columns = ~(1 << col);

always @(posedge clock)
begin
	//Increase counter
	counter <= counter + 1;
end

always @(posedge counter[12])
begin
	col <= col + 1;

	//Evaluating current button
	case(~rows)
		4'b0001: cur <= col << 2 + 16;
		4'b0010: cur <= col << 2 + 17;
		4'b0100: cur <= col << 2 + 18;
		4'b1000: cur <= col << 2 + 19;
		default: cur <= 5'b00000;
	endcase
end

//Col goes from 2'b11 to 2'b00
always @(negedge col[1])
begin
	//Saving previous button every 4 iterations
	prev <= cur;
end

//Evaluating state change
assign value = (counter != 0 | prev == cur) ? 5'b00000 : cur;

endmodule
