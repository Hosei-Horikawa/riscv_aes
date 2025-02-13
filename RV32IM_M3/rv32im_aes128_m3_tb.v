`timescale 1ns/1ns
module rv32im_aes128_m3_tb;
  reg         clk, clrn;
  wire [31:0] inst, pc, alu, mem;
  rv32im_aes128_m3 ra(clk, clrn, inst, pc, alu, mem);
  
  initial begin
        clk  = 1;
        clrn     = 0;
        #1 clrn = 1;
        #1949 $stop;
    end
    always #1 clk = !clk;
endmodule
