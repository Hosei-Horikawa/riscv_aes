module aes_v1 (ark,a,sub,shift,mix,vb,inv,vc);
    input          ark,sub,shift,mix,inv;
    input   [31:0] a;
    input  [127:0] vb;
    output [127:0] vc;
    
    wire    [31:0] c;
    wire   [127:0] result_ark;
    wire   [127:0] result_subbytes;
    wire   [127:0] result_shiftrows;
    wire   [127:0] result_mixcols;
    
    wire    [31:0] rot_vb = {vb[103:96],vb[127:104]};
    
    aes_sbox_128 sbox(ark,rot_vb,sub,vb,inv,c,result_subbytes);
    
    assign result_ark[ 31: 0] = c ^ a ^ vb[31:0];
    assign result_ark[ 63:32] = c ^ a ^ vb[31:0] ^ vb[63:32];
    assign result_ark[ 95:64] = c ^ a ^ vb[31:0] ^ vb[63:32] ^ vb[95:64];
    assign result_ark[127:96] = c ^ a ^ vb[31:0] ^ vb[63:32] ^ vb[95:64] ^ vb[127:96];
    
    assign result_shiftrows = (inv) ? 
                              {vb[ 31: 24],vb[ 55: 48],vb[ 79: 72],vb[103:96],
                               vb[127:120],vb[ 23: 16],vb[ 47: 40],vb[ 71:64],
                               vb[ 95: 88],vb[119:112],vb[ 15:  8],vb[ 39:32],
                               vb[ 63: 56],vb[ 87: 80],vb[111:104],vb[  7: 0]}
                              : 
                              {vb[ 95: 88],vb[ 55: 48],vb[ 15:  8],vb[103:96],
                               vb[ 63: 56],vb[ 23: 16],vb[111:104],vb[ 71:64],
                               vb[ 31: 24],vb[119:112],vb[ 79: 72],vb[ 39:32],
                               vb[127:120],vb[ 87: 80],vb[ 47: 40],vb[  7: 0]};
    
    wire [ 7:0] mix_00  = vb[  7:  0];
    wire [ 7:0] mix_01  = vb[ 15:  8];
    wire [ 7:0] mix_02  = vb[ 23: 16];
    wire [ 7:0] mix_03  = vb[ 31: 24];
    wire [ 7:0] mix_10  = vb[ 39: 32];
    wire [ 7:0] mix_11  = vb[ 47: 40];
    wire [ 7:0] mix_12  = vb[ 55: 48];
    wire [ 7:0] mix_13  = vb[ 63: 56];
    wire [ 7:0] mix_20  = vb[ 71: 64];
    wire [ 7:0] mix_21  = vb[ 79: 72];
    wire [ 7:0] mix_22  = vb[ 87: 80];
    wire [ 7:0] mix_23  = vb[ 95: 88];
    wire [ 7:0] mix_30  = vb[103: 96];
    wire [ 7:0] mix_31  = vb[111:104];
    wire [ 7:0] mix_32  = vb[119:112];
    wire [ 7:0] mix_33  = vb[127:120];
	 
    wire [ 7:0] mixs_00 = mixcolumn(mix_00, mix_01, mix_02, mix_03, inv);
    wire [ 7:0] mixs_01 = mixcolumn(mix_01, mix_02, mix_03, mix_00, inv);
    wire [ 7:0] mixs_02 = mixcolumn(mix_02, mix_03, mix_00, mix_01, inv);
    wire [ 7:0] mixs_03 = mixcolumn(mix_03, mix_00, mix_01, mix_02, inv);
    wire [ 7:0] mixs_10 = mixcolumn(mix_10, mix_11, mix_12, mix_13, inv);
    wire [ 7:0] mixs_11 = mixcolumn(mix_11, mix_12, mix_13, mix_10, inv);
    wire [ 7:0] mixs_12 = mixcolumn(mix_12, mix_13, mix_10, mix_11, inv);
    wire [ 7:0] mixs_13 = mixcolumn(mix_13, mix_10, mix_11, mix_12, inv);
    wire [ 7:0] mixs_20 = mixcolumn(mix_20, mix_21, mix_22, mix_23, inv);
    wire [ 7:0] mixs_21 = mixcolumn(mix_21, mix_22, mix_23, mix_20, inv);
    wire [ 7:0] mixs_22 = mixcolumn(mix_22, mix_23, mix_20, mix_21, inv);
    wire [ 7:0] mixs_23 = mixcolumn(mix_23, mix_20, mix_21, mix_22, inv);
    wire [ 7:0] mixs_30 = mixcolumn(mix_30, mix_31, mix_32, mix_33, inv);
    wire [ 7:0] mixs_31 = mixcolumn(mix_31, mix_32, mix_33, mix_30, inv);
    wire [ 7:0] mixs_32 = mixcolumn(mix_32, mix_33, mix_30, mix_31, inv);
    wire [ 7:0] mixs_33 = mixcolumn(mix_33, mix_30, mix_31, mix_32, inv);

    assign result_mixcols = {mixs_33, mixs_32, mixs_31, mixs_30,
			     mixs_23, mixs_22, mixs_21, mixs_20,
			     mixs_13, mixs_12, mixs_11, mixs_10,
			     mixs_03, mixs_02, mixs_01, mixs_00};
    assign vc = result({ark,sub,shift,mix},
	        result_ark,result_subbytes,
	        result_shiftrows,result_mixcols);
	 
    function [127:0] result;
      input [3:0] asw;
      input [127:0] ark,sub,shift,mix;
        case (asw)
            4'b1000 : result = ark;
            4'b0100 : result = sub;
            4'b0010 : result = shift;
            4'b0001 : result = mix;
            default : result = 0;
        endcase
    endfunction
    
    //GF(2^8) 
    function [7:0] xt2; //x times 2
      input [7:0] a;
        xt2 = (a << 1) ^ (a[7] ? 8'h1b : 8'b0) ;
    endfunction
  
    function [7:0] xtN; //x times N
      input[7:0] a;
      input[3:0] b;
        xtN = (b[0] ?             a   : 0) ^
              (b[1] ? xt2(        a)  : 0) ^
              (b[2] ? xt2(xt2(    a)) : 0) ^
              (b[3] ? xt2(xt2(xt2(a))): 0) ;
    endfunction
    
    function [7:0] mixcolumn;
      input [7:0] b0, b1, b2, b3;
      input       inv;
        mixcolumn = (inv) ? xtN(b0,4'he) ^ xtN(b1,4'hb) ^ xtN(b2,4'hd) ^ xtN(b3,4'h9)
		          : xt2(b0) ^ (xt2(b1) ^ b1) ^ b2 ^ b3;
    endfunction
    
endmodule
