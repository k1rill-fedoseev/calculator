module stack(
	//Just 50 MHz clock
	input clock, 

	//Reset signal
	input reset,

	//PUSH operation control signal
	input push, 

	//POP operation control signal
	input pop, 

	//UPDATE operation control signal
	//UPDATE means write top stack element again
	input write,

	//Value to write
	input [31:0] value,

	//Top element
	output [31:0] top,

	//Second element from stack top 
	output [31:0] next,

	//Total elements count
	output [5:0] count,

	//Stack overflow error
	output error
);

//Stack memory for 32 words
reg [31:0] memory [0:31]; 

//Stack pointer on top element, indexing from 0
reg [5:0] pointer = 0;

//First element by default is 0
initial memory[0] = 0;

assign top = memory[pointer];

//Second element if such exists, 0 otherwise
assign next = pointer == 0 ? 0 : memory[pointer - 1];

assign count = pointer[4:0] + 1;
assign error = pointer[5];

always @(posedge clock)
begin
	//Reseting
	if (reset)
	begin
		memory[0] <= 0;
		pointer <= 0;
	end

	//Remove one element form stack
	if (pop)
		pointer <= pointer - 1;

	//Update top element
	if (write)
		memory[pointer - pop] <= value;

	//Push new zero element on top
	if (push)
	begin
		pointer <= pointer + 1;

		//Here pointer is still not updated, so +1
		memory[pointer + 1] <= 0;
	end 
end

endmodule
