module numpad (
    input clock,
    input [3:0] rows,
    output [3:0] columns,
    output [4:0] value
);

//#############################
//#      #      #      #      #
//# 1(0) # 2(4) # 3(8) # A(12)#
//#      #      #      #      #
//#############################
//#      #      #      #      #
//# 4(3) # 5(5) # 6(9) # B(13)#
//#      #      #      #      #
//#############################
//#      #      #      #      #
//# 7(2) # 8(6) # 9(10)# C(14)#
//#      #      #      #      #
//#############################
//#      #      #      #      #
//# 0(3) # F(7) # E(11)# D(15)#
//#      #      #      #      #
//#############################
endmodule
