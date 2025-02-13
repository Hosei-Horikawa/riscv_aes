module rv32imv_aes128_v5 (clk, clrn, inst, pc, mem);
  parameter     VLEN = 128;                   // bits, hardware implementation
  input         clk, clrn;           // clk: 50MHz
  output [31:0] inst, pc;
  output [VLEN-1:0] mem;
  wire    [3:0] wmem;
  wire   [VLEN-1:0] alu_out, b;
  wire          vector;
  
  riscv_rv32imv_aes128_v5_cpu rrc (clk, clrn, inst, mem, pc, alu_out, b, wmem, vector);
  
  instmem_aes128_v5 imem (pc,inst);
  
  datamem_aes128_imv dmem (alu_out, b, wmem, clk, mem, vector);
endmodule
