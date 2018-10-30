module main(
	//Just 50 MHz clock
	input clock,

	//Representation switch 
	input switch,

	//Reset signal
	input reset,
	
	//Show stack elements count switch
	input show_count,

	//Numpad rows and columns
	input [3:0] numpad_rows,
	output [3:0] numpad_columns,

	//Display segments and segments control
	output [7:0] segments,
	output [7:0] segments_control
);

//Numpad state
wire [4:0] pressed;

//Stack elements count
wire [5:0] count;

//First and second stack elements
wire [31:0] top, next;

//Evaluated new value
reg [31:0] new_value;

//Stack control signals
reg write, push, pop;

numpad numpad(
	.clock (clock),
	.rows (numpad_rows),
	.columns (numpad_columns),
	.value (pressed)
);

stack stack(
	.clock (clock),
	.reset (~reset),
	.push (push),
	.pop (pop),
	.write (write),
	.value (new_value),
	.top (top),
	.next (next),
	.count (count),
	.error (error)
);

display_bcd display(
	.clock (clock),
	.error (error),
	.switch (switch),
	.value (show_count ? count : top),
	.control (segments_control),
	.segments (segments)
);

always @(posedge clock)
begin
	case (pressed)
		5'b10000: // 1 is pressed
		begin
			write <= 1;
			new_value <= top * 10 + 1;
		end
		5'b10001: // 4 is pressed
		begin
			write <= 1;
			new_value <= top * 10 + 4;
		end
		5'b10010: // 7 is pressed
		begin
			write <= 1;
			new_value <= top * 10 + 7;
		end
		5'b10011: // 0 is pressed
		begin
			write <= 1;
			new_value <= top * 10;
		end
	 	5'b10100: // 2 is pressed
		begin
			write <= 1;
			new_value <= top * 10 + 2;
		end
		5'b10101: // 5 is pressed
		begin
			write <= 1;
			new_value <= top * 10 + 5;
		end
		5'b10110: // 8 is pressed
		begin
			write <= 1;
			new_value <= top * 10 + 8;
		end
		5'b11000: // 3 is pressed
		begin
			write <= 1;
			new_value <= top * 10 + 3;
		end
		5'b11001: // 6 is pressed
		begin
			write <= 1;
			new_value <= top * 10 + 6;
		end
		5'b11010: // 9 is pressed
		begin
			write <= 1;
			new_value <= top * 10 + 9;
		end
		5'b11100: // A (=) is pressed
		begin
			push <= 1;
		end
		5'b11101: // B (+) is pressed
		begin
			pop <= 1;
			write <= 1;
			new_value <= next + top;
		end
		5'b11110: // C (-) is pressed
		begin
			pop <= 1;
			write <= 1;
			new_value <= next - top;
		end
		5'b11111: // D (*) is pressed
		begin
			pop <= 1;
			write <= 1;
			new_value <= next * top;
		end
		5'b11011: // E (/) is pressed
		begin
			pop <= 1;
			write <= 1;
			if (!next[31] && !top[31])
				new_value <= next / top;
			else if(next[31] && top[31])
				new_value <= (-next) / -top;
			else if(next[31] && !top[31])
				new_value <= -((-next) / top);
			else
				new_value <= -(next / -top);
		end
		5'b10111: // F (unary -) is pressed
		begin
			write <= 1;
			new_value <= -top;
		end
		default:
		begin	
			write <= 0;
			push <= 0;
			pop <= 0;
		end
		
	endcase
end

endmodule
