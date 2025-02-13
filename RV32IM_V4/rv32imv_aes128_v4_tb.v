`timescale 1ns/1ns
module rv32imv_aes128_v4_tb;
  reg         clk, clrn;
  wire [31:0] inst, pc;
  wire [127:0] mem;
  rv32imv_aes128_v4 ra(clk, clrn, inst, pc, mem);
  
  initial begin
        clk  = 1;
        clrn     = 0;
        #1 clrn = 1;
        #393 $stop;
    end
    always #1 clk = !clk;
endmodule