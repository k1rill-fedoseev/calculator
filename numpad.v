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
reg [3:0] prev = 0;

//Cuurent pressed button
reg [3:0] cur = 0;

//Cuurent column number
reg [2:0] col = 0;

//Controlling column
assign colums = 1 << col[1:0];

always @(posedge clock)
begin
	col <= col + 1;
	
	//Evaluating current button
	case(rows)
		4'b0001: cur <= col * 4;
		4'b0010: cur <= col * 4 + 1;
		4'b0100: cur <= col * 4 + 2;
		4'b1000: cur <= col * 4 + 3;
	endcase
end

always @(posedge col[2])
begin
	//Saving previous button every 4 iterations
	prev <= cur;
end

//Evaluating state change
assign value = cur == prev ? 5'b00000 : {1'b1,cur};

endmodule
