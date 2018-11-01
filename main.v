module main(
	//Just 50 MHz clock
	input clock,

	//Reset signal
	input reset,

	//Representation switch 
	input show_in_hex,
	
	//Show stack elements count switch
	input show_count,

	//Button, switches to operations keyboard
	input alt_numpad_key,

	//Alternative keyboard indicator
	output alt_numpad_led,

	//Numpad rows and columns
	input [3:0] numpad_rows,
	output [3:0] numpad_columns,

	//Display and display control
	output [7:0] display_leds,
	output [7:0] display_control
);

// 1  2  3  C
// 4  5  6  PUSH
// 7  8  9  POP
// 0  +- CE SWAP

parameter BTN_0 = 6'b110011;
parameter BTN_1 = 6'b110000;
parameter BTN_2 = 6'b110100;
parameter BTN_3 = 6'b111000;
parameter BTN_4 = 6'b110001;
parameter BTN_5 = 6'b110101;
parameter BTN_6 = 6'b111001;
parameter BTN_7 = 6'b110010;
parameter BTN_8 = 6'b110110;
parameter BTN_9 = 6'b111010;
parameter BTN_CLEAR_DIGIT = 6'b111100;
parameter BTN_PUSH = 6'b111101;
parameter BTN_POP = 6'b111110;
parameter BTN_SWAP = 6'b111111;
parameter BTN_CLEAR_NUMBER = 6'b111011;
parameter BTN_UNARY_MINUS = 6'b110111;

//  +   -   *   /
// sqr cbe inc dec

parameter BTN_ADDITION = 6'b100000;
parameter BTN_SUBTRACTION = 6'b100100;
parameter BTN_MULTIPLICATION = 6'b101000;
parameter BTN_DIVISION = 6'b101100;
parameter BTN_SQUARE = 6'b100001;
parameter BTN_CUBE = 6'b100101;
parameter BTN_INCREMENT = 6'b101001;
parameter BTN_DECREMENT = 6'b101101;

//Numpad state
wire [5:0] pressed;

//Stack elements count
wire [5:0] count;

//First and second stack elements
wire [31:0] top, next;

wire stack_error;

//Evaluated new value
reg [31:0] new_value;

//Stack control signals
reg write, push, pop, swap;

reg arithmetic_error = 0;

numpad numpad(
	.clock (clock),
	.alt_key (~alt_numpad_key),
	.alt_led (alt_numpad_led),
	.rows (numpad_rows),
	.columns (numpad_columns),
	.value (pressed)
);

stack stack(
	.clock (clock),
	.reset (~reset),
	.push (push),
	.pop (pop),
	.swap (swap),
	.write (write),
	.value (new_value),
	.top (top),
	.next (next),
	.count (count),
	.error (stack_error)
);

display_bcd display(
	.clock (clock),
	.error (stack_error || arithmetic_error),
	.show_in_hex (show_in_hex),
	.value (show_count ? count : top),
	.control (display_control),
	.leds (display_leds)
);

wire [31:0] res;
assign res = ((next[31] ? -next : next) / (top[31] ? -top : top));

always @(posedge clock)
begin
	if (~reset)
		arithmetic_error <= 0;

	case (pressed)
		BTN_0:
		begin
			write <= 1;
			new_value <= top * 10;
		end
		BTN_1:
		begin
			write <= 1;
			new_value <= top * 10 + 1;
		end
		BTN_2:
		begin
			write <= 1;
			new_value <= top * 10 + 2;
		end
		BTN_3:
		begin
			write <= 1;
			new_value <= top * 10 + 3;
		end
		BTN_4:
		begin
			write <= 1;
			new_value <= top * 10 + 4;
		end
		BTN_5:
		begin
			write <= 1;
			new_value <= top * 10 + 5;
		end
		BTN_6:
		begin
			write <= 1;
			new_value <= top * 10 + 6;
		end
		BTN_7:
		begin
			write <= 1;
			new_value <= top * 10 + 7;
		end
		BTN_8: 
		begin
			write <= 1;
			new_value <= top * 10 + 8;
		end
		BTN_9:
		begin
			write <= 1;
			new_value <= top * 10 + 9;
		end
		BTN_CLEAR_DIGIT:
		begin
			write <= 1;
			new_value <= top / 10;
		end
		BTN_CLEAR_NUMBER:
		begin
			write <= 1;
			new_value <= 0;
		end
		BTN_PUSH:
		begin
			push <= 1;
		end
		BTN_POP:
		begin
			pop <= 1;
		end
		BTN_SWAP:
		begin
			swap <= 1;
		end
		BTN_UNARY_MINUS:
		begin
			write <= 1;
			new_value <= -top;
		end
		BTN_ADDITION:
		begin
			pop <= 1;
			write <= 1;
			new_value <= next + top;
		end
		BTN_SUBTRACTION:
		begin
			pop <= 1;
			write <= 1;
			new_value <= next - top;
		end
		BTN_MULTIPLICATION:
		begin
			pop <= 1;
			write <= 1;
			new_value <= next * top;
		end
		BTN_DIVISION:
		begin
			pop <= 1;
			write <= 1;
			new_value <= (next[31] ^ top[31] ? -res : res);
			arithmetic_error <= ~(|top);
		end
		BTN_SQUARE:
		begin
			write <= 1;
			new_value <= top * top;
		end
		BTN_CUBE:
		begin
			write <= 1;
			new_value <= top * top * top;
		end
		BTN_INCREMENT:
		begin
			write <= 1;
			new_value <= top + 1;
		end
		BTN_DECREMENT:
		begin
			write <= 1;
			new_value <= top - 1;
		end
		default: // Nothing usefull is pressed
		begin	
			write <= 0;
			push <= 0;
			pop <= 0;
			swap <= 0;
		end
	endcase
end

endmodule
