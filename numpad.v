module numpad (
	input clock,
	input [3:0] rows,
	output [3:0] columns,
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

reg [3:0] prev = 0;
reg [3:0] cur = 0;
reg [2:0] col = 0;

assign colums = 1 << col;

always @(posedge clock)
begin
	col <= col + 1;
	
	case(rows)
		4'b0001: cur <= col * 4;
		4'b0010: cur <= col * 4 + 1;
		4'b0100: cur <= col * 4 + 2;
		4'b1000: cur <= col * 4 + 3;
		default: cur <= 0;
	endcase
end

always @(posedge col[2])
begin
	prev <= cur;
end

assign value = cur == prev ? 5'b00000 : {1'b1,cur};

endmodule
