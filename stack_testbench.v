module stack_testbench ();

reg clock, write, push, pop;
reg [31:0] value;
wire [5:0] count;
wire error;
wire [31:0] top, next;
    

stack s(
    .clock (clock), 
    .push (push),
    .pop (pop),
    .write (write),
    .value (value),
    .top (top),
    .next (next),
    .count (count),
    .error (error)
);

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
#60

value = 0;
write = 0;
push = 0;
pop = 0;

end

always
begin
    #10;
    clock = !clock;
end

initial
$monitor("top = %d next = %d write = %b value = %d push = %b pop = %b error = %b count = %d", top, next, write, value, push, pop, error, count);

initial
$dumpvars;

endmodule
