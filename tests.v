`timescale 1ps / 1ps
`define testcase(label) \
	$display("\nTEST CASE: ", label, "\n");
`define assert(signal, value) \
		if (signal !== value) begin \
			$display("ASSERTION FAILED"); \
			$finish(1); \
		end \
		else \
			$display("PASSED");
	
module tests ();
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
	
	parameter BTN_1 = 5'b10000;
	parameter BTN_4 = 5'b10001;
	parameter BTN_7 = 5'b10010;
	parameter BTN_0 = 5'b10011;
	parameter BTN_2 = 5'b10100;
	parameter BTN_5 = 5'b10101;
	parameter BTN_8 = 5'b10110;
	parameter BTN_F = 5'b10111;
	parameter BTN_3 = 5'b11000;
	parameter BTN_6 = 5'b11001;
	parameter BTN_9 = 5'b11010;
	parameter BTN_E = 5'b11011;
	parameter BTN_A = 5'b11100;
	parameter BTN_B = 5'b11101;
	parameter BTN_C = 5'b11110;
	parameter BTN_D = 5'b11111;
	parameter BTN_EMPTY = 5'b00000;

	reg clock = 0;
	reg show_in_hex = 0;
	reg reset = 0;
	reg show_count = 0;
	reg alt_numpad_key = 0;
	wire alt_numpad_led;
	wire [3:0] numpad_rows;
	wire [3:0] numpad_columns;
	wire [7:0] leds;
	wire [7:0] leds_control;

	reg [3:0] r_numpad_rows;
	reg [4:0] cur_btn = BTN_EMPTY;

	reg [63:0] displayed = 0;

	main main(
		.clock(clock),
		.show_in_hex(show_in_hex),
		.reset(~reset),
		.alt_numpad_key(~alt_numpad_key),
		.alt_numpad_led(alt_numpad_led),
		.show_count(show_count),
		.numpad_rows(numpad_rows),
		.numpad_columns(numpad_columns),
		.display_leds(leds),
		.display_control(leds_control)
	);

	always @(*)
	begin
		#1
		clock <= !clock;
	end

	//Emulating numpad
	//10000 cycles delay
	always @(*)
	begin
		case (cur_btn)
		  BTN_1: r_numpad_rows <= {3'b000, ~numpad_columns[0]};
		  BTN_4: r_numpad_rows <= {2'b00, ~numpad_columns[0], 1'b0};
		  BTN_7: r_numpad_rows <= {1'b0, ~numpad_columns[0], 2'b00};
		  BTN_0: r_numpad_rows <= {~numpad_columns[0], 3'b000};
		  
		  BTN_2: r_numpad_rows <= {3'b000, ~numpad_columns[1]};
		  BTN_5: r_numpad_rows <= {2'b00, ~numpad_columns[1], 1'b0};
		  BTN_8: r_numpad_rows <= {1'b0, ~numpad_columns[1], 2'b00};
		  BTN_F: r_numpad_rows <= {~numpad_columns[1], 3'b000};
		  
		  BTN_3: r_numpad_rows <= {3'b000, ~numpad_columns[2]};
		  BTN_6: r_numpad_rows <= {2'b00, ~numpad_columns[2], 1'b0};
		  BTN_9: r_numpad_rows <= {1'b0, ~numpad_columns[2], 2'b00};
		  BTN_E: r_numpad_rows <= {~numpad_columns[2], 3'b000};
		  
		  BTN_A: r_numpad_rows <= {3'b000, ~numpad_columns[3]};
		  BTN_B: r_numpad_rows <= {2'b00, ~numpad_columns[3], 1'b0};
		  BTN_C: r_numpad_rows <= {1'b0, ~numpad_columns[3], 2'b00};
		  BTN_D: r_numpad_rows <= {~numpad_columns[3], 3'b000};
		  default: r_numpad_rows <= 4'b0000;
		endcase
	end

	//Emulating looking at display
	//100000 cycles delay
	always @(*)
	begin
		case (leds_control)
			8'b11111110: displayed[7:0] <= ~leds;
			8'b11111101: displayed[15:8] <= ~leds;
			8'b11111011: displayed[23:16] <= ~leds;
			8'b11110111: displayed[31:24] <= ~leds;
			8'b11101111: displayed[39:32] <= ~leds;
			8'b11011111: displayed[47:40] <= ~leds;
			8'b10111111: displayed[55:48] <= ~leds;
			8'b01111111: displayed[63:56] <= ~leds;
		endcase
	end

	assign numpad_rows = ~r_numpad_rows;

	initial
	begin
		$display("TESTS STARTED");

		`testcase("initial stack and display state")
		#200000
		`assert(main.stack.top, 0)
		`assert(main.stack.count, 1)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_0})
		
		`testcase("show elements count")
		show_count = 1;
		#200000
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_1})
		
		`testcase("write 1")
		show_count = 0;
		cur_btn = BTN_1;
		#200000
		`assert(main.stack.top, 1)
		`assert(main.stack.count, 1)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_1})

		`testcase("write 12")
		cur_btn = BTN_2;
		#200000
		`assert(main.stack.top, 12)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_1, D_2})

		`testcase("write 123")
		cur_btn = BTN_3;
		#200000
		`assert(main.stack.top, 123)
		`assert(main.stack.count, 1)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_1, D_2, D_3})

		`testcase("show in hexadecimal")
		cur_btn = BTN_EMPTY;
		show_in_hex = 1;
		#200000
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_7, D_B})

		`testcase("push to stack")
		cur_btn = BTN_B;
		show_in_hex = 0;
		#200000
		`assert(main.stack.top, 0)
		`assert(main.stack.next, 123)
		`assert(main.stack.count, 2)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_0})

		`testcase("write 9")
		cur_btn = BTN_9;
		#200000
		`assert(main.stack.top, 9)
		`assert(main.stack.next, 123)
		`assert(main.stack.count, 2)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_9})

		`testcase("write 90")
		cur_btn = BTN_0;
		#200000
		`assert(main.stack.top, 90)
		`assert(main.stack.next, 123)
		`assert(main.stack.count, 2)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_9, D_0})

		`testcase("release button")
		cur_btn = BTN_EMPTY;
		#200000
		`assert(main.stack.top, 90)
		`assert(main.stack.next, 123)
		`assert(main.stack.count, 2)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_9, D_0})

		`testcase("write 900")
		cur_btn = BTN_0;
		#200000
		`assert(main.stack.top, 900)
		`assert(main.stack.next, 123)
		`assert(main.stack.count, 2)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_9, D_0, D_0})

		`testcase("addition")
		alt_numpad_key = 1;
		cur_btn = BTN_EMPTY;
		#20000
		`assert(alt_numpad_led, 0)
		`assert(main.numpad.is_alt, 1)
		alt_numpad_key = 0;
		cur_btn = BTN_1;
		#200000
		`assert(alt_numpad_led, 1)
		`assert(main.numpad.is_alt, 0)
		`assert(main.stack.top, 1023)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_1, D_0, D_2, D_3})

		`testcase("show result in hexadecimal")
		show_in_hex = 1;
		#200000
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_3, D_F, D_F})

		`testcase("push to stack")
		show_in_hex = 0;
		cur_btn = BTN_B;
		#20000
		`assert(main.stack.top, 0)
		`assert(main.stack.next, 1023)
		`assert(main.stack.count, 2)

		`testcase("write 8")
		cur_btn = BTN_8;
		#20000
		`assert(main.stack.top, 8)
		`assert(main.stack.next, 1023)
		`assert(main.stack.count, 2)

		`testcase("subtraction")
		alt_numpad_key = 1;
		cur_btn = BTN_2;
		#20000
		`assert(main.stack.top, 1015)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		alt_numpad_key = 0;

		`testcase("push")
		cur_btn = BTN_B;
		#20000
		`assert(main.stack.top, 0)
		`assert(main.stack.next, 1015)
		`assert(main.stack.count, 2)

		`testcase("write 7")
		cur_btn = BTN_7;
		#20000
		`assert(main.stack.top, 7)
		`assert(main.stack.next, 1015)
		`assert(main.stack.count, 2)

		`testcase("multiplication")
		alt_numpad_key = 1;
		cur_btn = BTN_3;
		#20000
		`assert(main.stack.top, 7105)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		alt_numpad_key = 0;

		`testcase("push 6")
		cur_btn = BTN_B;
		#20000
		cur_btn = BTN_6;
		#20000
		`assert(main.stack.top, 6)
		`assert(main.stack.next, 7105)
		`assert(main.stack.count, 2)

		`testcase("division")
		alt_numpad_key = 1;
		cur_btn = BTN_A;
		#20000
		`assert(main.stack.top, 1184)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		alt_numpad_key = 0;

		`testcase("unary minus")
		cur_btn = BTN_F;
		#200000
		`assert(main.stack.top, -1184)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		`assert(displayed, {D_MINUS, D_EMPTY, D_EMPTY, D_EMPTY, D_1, D_1, D_8, D_4})

		`testcase("push -5")
		cur_btn = BTN_B;
		#20000	
		cur_btn = BTN_5;
		#20000
		cur_btn = BTN_F;
		#200000
		`assert(main.stack.top, -5)
		`assert(main.stack.next, -1184)
		`assert(main.stack.count, 2)
		`assert(displayed, {D_MINUS, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_5})

		`testcase("division of two negative with remainder")
		alt_numpad_key = 1;
		cur_btn = BTN_A;
		#200000
		`assert(main.stack.top, 236)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_2, D_3, D_6})
		alt_numpad_key = 0;

		`testcase("clear digit")
		cur_btn = BTN_EMPTY;
		#20000
		cur_btn = BTN_A;
		#200000
		`assert(main.stack.top, 23)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_2, D_3})

		`testcase("clear full number")
		cur_btn = BTN_E;
		#200000
		`assert(main.stack.top, 0)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_0})

		`testcase("push 7, push 8")
		cur_btn = BTN_7;
		#20000
		cur_btn = BTN_B;
		#20000
		cur_btn = BTN_8;
		#20000
		`assert(main.stack.top, 8)
		`assert(main.stack.next, 7)
		`assert(main.stack.count, 2)

		`testcase("swap")
		cur_btn = BTN_D;
		#20000
		`assert(main.stack.top, 7)
		`assert(main.stack.next, 8)
		`assert(main.stack.count, 2)

		`testcase("pop")
		cur_btn = BTN_C;
		#20000
		`assert(main.stack.top, 8)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)

		`testcase("increment, decrement, square, cube")
		alt_numpad_key = 1;
		cur_btn = BTN_6;
		#20000
		`assert(main.stack.top, 9)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		alt_numpad_key = 0;
		#20000

		alt_numpad_key = 1;
		cur_btn = BTN_B;
		#20000
		`assert(main.stack.top, 8)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		alt_numpad_key = 0;
		#20000

		alt_numpad_key = 1;
		cur_btn = BTN_4;
		#20000
		`assert(main.stack.top, 64)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		alt_numpad_key = 0;
		#20000

		alt_numpad_key = 1;
		cur_btn = BTN_5;
		#20000
		`assert(main.stack.top, 262144)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		alt_numpad_key = 0;
		#20000

		`testcase("division by 0, reset")
		cur_btn = BTN_B;
		#20000
		`assert(main.stack.top, 0)
		`assert(main.stack.next, 262144)
		`assert(main.stack.count, 2)
		#20000

		alt_numpad_key = 1;
		cur_btn = BTN_A;
		#200000
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_E, D_R, D_R, D_O, D_R})
		alt_numpad_key = 0;
		#20000

		reset = 1;
		#200000
		reset = 0;
		`assert(main.stack.top, 0)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_0})

		`testcase("write -4, write -44")
		cur_btn = BTN_4;
		#20000
		cur_btn = BTN_F;
		#20000
		cur_btn = BTN_4;
		#200000
		`assert(main.stack.top, -44)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		`assert(displayed, {D_MINUS, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_4, D_4})

		$display("\nTESTS ENDED");
		$stop;
	end

endmodule
