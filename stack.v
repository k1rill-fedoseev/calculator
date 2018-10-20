module stack(
    input clock, push, pop, write,
    input [31:0] value,
    output [31:0] top, next,
    output [5:0] count,
    output error
);

reg [31:0] memory [0:63]; 
reg [6:0] pointer = 0; // stack pointer, indexing from 0

initial memory[0] = 0;

assign top = memory[pointer];
assign next = memory[pointer == 0 ? 0 : (pointer - 1)];
assign count = pointer[5:0] + 1;
assign error = pointer[6]; // catch error via pointer overflow

always @(posedge clock)
begin
    if (write)
        memory[pointer] = value;  
    else begin
	if (push) begin
	    pointer = pointer + 1;
            memory[pointer] = 0;
        end 
        else begin
            if (pop)
            	pointer = pointer - 1;
      	end
    end
end

endmodule
