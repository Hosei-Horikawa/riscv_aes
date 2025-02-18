module datamem_aes128_imv (addr,datain,we,clk,dataout,vector);
    parameter     VLEN = 128;                   // bits, hardware implementation
    input         clk,vector;
    input   [3:0] we;
    input  [VLEN-1:0] addr,datain;
    output [VLEN-1:0] dataout;
    reg    [31:0] ram [0:69];
	 assign dataout = (vector) ? 
							{ram[addr[104:98]],ram[addr[ 72:66]],ram[addr[ 40:34]],ram[addr[8:2]]} 
							: {96'h0,ram[addr[8:2]]};
    always @ (posedge clk)
      case (we)
        4'b1111: begin
                    ram[addr[10:2]] = datain[31:0];
                    if (vector) begin
								ram[addr[ 42:34]] = datain[ 63:32];
								ram[addr[ 74:66]] = datain[ 95:64];
								ram[addr[106:98]] = datain[127:96];
						  end
                 end
        4'b0011: ram[addr[9:2]] = datain[31:0];
        4'b0001: ram[addr[8:2]] = datain[31:0];
      endcase
    integer i;
    initial begin
        for (i = 0; i < 70; i = i + 1)
            ram[i] = 0;
        //round_const
        ram[7'h00] = 32'h00000001;
        ram[7'h01] = 32'h00000002;
        ram[7'h02] = 32'h00000004;
        ram[7'h03] = 32'h00000008;
        ram[7'h04] = 32'h00000010;
        ram[7'h05] = 32'h00000020;
        ram[7'h06] = 32'h00000040;
        ram[7'h07] = 32'h00000080;
        ram[7'h08] = 32'h0000001b;
        ram[7'h09] = 32'h00000036;
        //input
        ram[7'h0a] = 32'h53495459; //SITY
        ram[7'h0b] = 32'h49564552; //IVER
        ram[7'h0c] = 32'h4920554e; //I UN
        ram[7'h0d] = 32'h484f5345; //HOSE
        //output
        //ram[7'h0e]..ram[7'h11] = 32'h0
        //initial_key
        ram[7'h12] = 32'h2a2388a0;
        ram[7'h13] = 32'h6ca354fa;
        ram[7'h14] = 32'h76392cfe;
        ram[7'h15] = 32'h0539b117;
        //round_key
        //ram[7'h16]..ram[7'h1f] = 32'h0
    end
endmodule
