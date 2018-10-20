module stack_testbench ();

reg clock, write, push, pop;
reg [31:0] value;
wire [31:0] top, next;
    

stack s(clock, push, pop, write, value, top, next);

initial
begin
clock = 0;
value = 1;
write = 1;
push = 0;
pop = 0;
#20

value = 2;
write = 1;
push = 0;
pop = 0;
#20

value = 0;
write = 0;
push = 1;
pop = 0;
#20

value = 3;
write = 1;
push = 0;
pop = 0;
#20


value = 0;
write = 0;
push = 1;
pop = 0;
#20

value = 4;
write = 1;
push = 0;
pop = 0;
#20


value = 0;
write = 0;
push = 0;
pop = 1;
#20


value = 0;
write = 0;
push = 0;
pop = 1;
#20

value = 0;
write = 0;
push = 0;
pop = 1;
end

always
begin
    #10;
    clock = !clock;
end

initial
$monitor("top = %b next = %b write = %b value = %b push = %b pop = %b", top, next, write, value, push, pop);

initial
$dumpvars;

endmodule
