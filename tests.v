`timescale 1ps / 1ps
`define assert(signal, value) \
		if (signal !== value) begin \
			$display("ASSERTION FAILED #", $realtime / 1000000); \
			$finish; \
		end \
	else \
		$display("PASSED #", $realtime / 1000000);
	
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
	reg switch = 0;
	reg reset = 0;
	reg show_count = 0;
	wire [3:0] numpad_rows;
	wire [3:0] numpad_columns;
	wire [7:0] leds;
	wire [7:0] leds_control;

	reg [3:0] r_numpad_rows;
	reg [4:0] cur_btn = 5'b00000;

	reg [63:0] displayed = 0;

	main main(
		.clock(clock),
		.switch(switch),
		.reset(~reset),
		.show_count(show_count),
		.numpad_rows(numpad_rows),
		.numpad_columns(numpad_columns),
		.segments(leds),
		.segments_control(leds_control)
	);

	always @(*)
	begin
		#1
		clock <= !clock;
	end

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

		// #1
		#1000000
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_0})
		
		// #2
		show_count = 1;
		#1000000
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_1})
		
		// #3
		//WRITE 1
		show_count = 0;
		cur_btn = BTN_1;
		#1000000
		`assert(main.stack.top, 1)
		`assert(main.stack.count, 1)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_1})

		// #4
		//WRITE 12
		cur_btn = BTN_2;
		#1000000
		`assert(main.stack.top, 12)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_1, D_2})

		// #5
		//WRITE 123
		cur_btn = BTN_3;
		#1000000
		`assert(main.stack.top, 123)
		`assert(main.stack.count, 1)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_1, D_2, D_3})

		// #6
		//SWITCH TO HEX
		cur_btn = BTN_EMPTY;
		switch = 1;
		#1000000
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_7, D_B})

		// #7
		//PUSH
		cur_btn = BTN_A;
		switch = 0;
		#1000000
		`assert(main.stack.top, 0)
		`assert(main.stack.next, 123)
		`assert(main.stack.count, 2)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_0})

		// #8
		//WRITE 9
		cur_btn = BTN_9;
		#1000000
		`assert(main.stack.top, 9)
		`assert(main.stack.next, 123)
		`assert(main.stack.count, 2)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_9})

		// #9
		//WRITE 0
		cur_btn = BTN_0;
		#1000000
		`assert(main.stack.top, 90)
		`assert(main.stack.next, 123)
		`assert(main.stack.count, 2)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_9, D_0})

		// #10
		//RELEASE BUTTON
		cur_btn = BTN_EMPTY;
		#1000000
		`assert(main.stack.top, 90)
		`assert(main.stack.next, 123)
		`assert(main.stack.count, 2)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_9, D_0})

		// #11
		//WRITE 0
		cur_btn = BTN_0;
		#1000000
		`assert(main.stack.top, 900)
		`assert(main.stack.next, 123)
		`assert(main.stack.count, 2)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_9, D_0, D_0})

		// #12
		//PLUS
		cur_btn = BTN_B;
		#1000000
		`assert(main.stack.top, 1023)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_1, D_0, D_2, D_3})

		// #13
		//SWITCH_TO_HEX
		switch = 1;
		#1000000
		`assert(displayed, {D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_EMPTY, D_3, D_F, D_F})

		// #14
		switch = 0;
		cur_btn = BTN_A;
		#1000000
		`assert(main.stack.top, 0)
		`assert(main.stack.next, 1023)
		`assert(main.stack.count, 2)

		// #15
		cur_btn = BTN_8;
		#1000000
		`assert(main.stack.top, 8)
		`assert(main.stack.next, 1023)
		`assert(main.stack.count, 2)

		// #16
		cur_btn = BTN_C;
		#1000000
		`assert(main.stack.top, 1015)
		`assert(main.stack.next, 0)
		`assert(main.stack.count, 1)

		$display("TESTS ENDED");
		$stop;
	end

endmodule
