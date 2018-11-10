module numpad (
	//Just 50 MHz clock
	input clock,

	//Alternative keyboard
	input alt_key,

	//Alternative keyboard indicator
	output alt_led,

	//Numpad rows
	input [3:0] rows,

	//Numpad columns
	output [3:0] columns,

	//State change description [5:5] - is_changed, [4:4] - keyboard, [3:0] - button
	output [5:0] value
);

//  col 0  col 1  col 2  col 3
//
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

parameter BTN_EMPTY = 6'b000000;

//Previous pressed button
reg [5:0] prev = 0;

//Current pressed button
reg [5:0] cur = 0;

//Current column number
reg [1:0] col = 0;

//Counter for delay
reg [8:0] counter = 0;

//Rows pressed flags
reg [3:0] pressed = 0;

//Is alternative keyboard
reg is_alt = 0;

//Alt key on prev clock cycle
reg prev_alt_key = 0;

//Controlling column
assign columns = ~(1 << col);

assign alt_led = ~is_alt;

always @(posedge clock)
begin
	//Increase counter
	counter <= counter + 1;

	//Evaluating alternative keyboard signal
	if (value != BTN_EMPTY)
		is_alt <= 0;
	else
		is_alt <= (alt_key == 1 && prev_alt_key == 0) ? ~is_alt : is_alt;
	prev_alt_key <= alt_key;

	if (counter == 9'b1111111111)
	begin
		//Evaluating current button
		case(~rows)
			4'b0001:
			begin
			pressed[col] <= 1;
			cur <= {1'b1, ~is_alt, col, 2'b00};
			end
			4'b0010:
			begin
			pressed[col] <= 1;
			cur <= {1'b1, ~is_alt, col, 2'b01};
			end
			4'b0100:
			begin
			pressed[col] <= 1;
			cur <= {1'b1, ~is_alt, col, 2'b10};
			end
			4'b1000:
			begin
			pressed[col] <= 1;
			cur <= {1'b1, ~is_alt, col, 2'b11};
			end
			default:
			begin
			pressed[col] <= 0;
			cur <= pressed ? cur : BTN_EMPTY;
			end
		endcase	
	end

	//increase column number when counter is 9'011111111, using different edges of counter[8] to let counter pass through zero, to assert wire value if need
	if (counter == 9'b011111111)
	begin
		//Saving previous button every 4 iterations
		if (&col)
			prev <= cur;

		col <= col + 1;
	end
end

//Evaluating state change
//Comparing current and previous states without keyboard bit
assign value = (counter == 9'b000000000 && col == 2'b11 && {prev[5], prev[3:0]} != {cur[5], cur[3:0]}) ? cur : BTN_EMPTY;

endmodule
