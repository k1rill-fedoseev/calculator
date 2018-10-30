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

//Current pressed button
reg [4:0] cur = 0;

//Current column number
reg [1:0] col = 0;

//Counter for delay
reg [8:0] counter = 0;

reg [3:0] changed = 0;

//Controlling column
assign columns = ~(1 << col);

always @(posedge clock)
begin
	//Increase counter
	counter <= counter + 1;
end

//counter goes grom 9'b111111111 to 9'b000000000, update current button, if any row is asserted
always @(negedge counter[8])
begin
	//Evaluating current button
	case(~rows)
		4'b0001:
		begin
		changed[col] <= 1;
		cur <= col[1:0] * 4 + 16;
		end
		4'b0010:
		begin
		changed[col] <= 1;
		cur <= col[1:0] * 4 + 17;
		end
		4'b0100:
		begin
		changed[col] <= 1;
		cur <= col[1:0] * 4 + 18;
		end
		4'b1000:
		begin
		changed[col] <= 1;
		cur <= col[1:0] * 4 + 19;
		end
		default:
		begin
		changed[col] <= 0;
		cur <= changed ? cur : 0;
		end
	endcase
end

//increase column number when counter goes from 9'011111111 to 9'b100000000, using different edges of counter[8] to let counter pass through zero, to assert wire value if need
always @(posedge counter[8])
begin
	col <= col + 1;
end

//Col goes from 2'b11 to 2'b00
always @(negedge col[1])
begin
	//Saving previous button every 4 iterations
	prev <= cur;
	//cur <= 0;
end

//Evaluating state change
assign value = (counter != 0 | col[1:0] != 2'b11 | prev == cur) ? 5'b00000 : cur;

endmodule
