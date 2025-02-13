module rv32im_aes128_m2 (clk, clrn, inst, pc, alu, mem);
  input         clk, clrn;           // clk: 50MHz
  output [31:0] inst, pc, alu, mem;
  wire    [3:0] wmem;
  wire   [31:0] alu_out, b;
  
  riscv_rv32im_aes128_m2_cpu rrc (clk, clrn, inst, mem, pc, alu_out, b, wmem);
  
  instmem_aes128_m2 imem (pc,inst);
  
  datamem_aes128_im dmem (alu_out, b, wmem, clk, mem);
endmodule