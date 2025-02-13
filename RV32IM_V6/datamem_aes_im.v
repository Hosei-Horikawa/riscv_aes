// data:
module datamem_aes_im (addr,datain,we,clk,dataout);
    input         clk;
    input   [3:0]  we;
    input  [31:0] addr;
    input  [31:0] datain;
    output [31:0] dataout;
    reg    [31:0] ram [0:31];
    assign dataout = ram[addr[6:2]];
    always @ (posedge clk)
      case (we)
        4'b1111: ram[addr[10:2]] = datain;
        4'b0011: ram[addr[9:2]] = datain;
        4'b0001: ram[addr[8:2]] = datain;
      endcase
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            ram[i] = 0;
        ram[5'h04] = 32'h04030201;
        ram[5'h05] = 32'h08070605;
        ram[5'h06] = 32'h0c0b0a09;
        ram[5'h07] = 32'h100f0e0d;
    end
endmodule
