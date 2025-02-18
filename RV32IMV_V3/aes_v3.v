module aes_v3 (ark,a,ss,ssm,vb,inv,vc);
    input             ark,ss,ssm,inv;
    input      [31:0] a;
    parameter         VLEN = 128;
    input  [VLEN-1:0] vb;
    output [VLEN-1:0] vc;
    
    wire     [31:0] c;
    wire    [127:0] result_ark;
    wire            subshift = ss | ssm;
    wire [VLEN-1:0] result_ss;
    wire [VLEN-1:0] result_ssm;            
    
    wire     [31:0] rot_vb = {vb[103:96],vb[127:104]};
    
    aes_sbox_shift_128 ss128(ark,rot_vb,subshift,vb,inv,c,result_ss);
    
    assign result_ark[ 31: 0] = c ^ a ^ vb[31:0];
    assign result_ark[ 63:32] = c ^ a ^ vb[31:0] ^ vb[63:32];
    assign result_ark[ 95:64] = c ^ a ^ vb[31:0] ^ vb[63:32] ^ vb[95:64];
    assign result_ark[127:96] = c ^ a ^ vb[31:0] ^ vb[63:32] ^ vb[95:64] ^ vb[127:96];
    
    wire [ 7:0] mix_00  = result_ss[  7:  0];
    wire [ 7:0] mix_01  = result_ss[ 15:  8];
    wire [ 7:0] mix_02  = result_ss[ 23: 16];
    wire [ 7:0] mix_03  = result_ss[ 31: 24];
    wire [ 7:0] mix_10  = result_ss[ 39: 32];
    wire [ 7:0] mix_11  = result_ss[ 47: 40];
    wire [ 7:0] mix_12  = result_ss[ 55: 48];
    wire [ 7:0] mix_13  = result_ss[ 63: 56];
    wire [ 7:0] mix_20  = result_ss[ 71: 64];
    wire [ 7:0] mix_21  = result_ss[ 79: 72];
    wire [ 7:0] mix_22  = result_ss[ 87: 80];
    wire [ 7:0] mix_23  = result_ss[ 95: 88];
    wire [ 7:0] mix_30  = result_ss[103: 96];
    wire [ 7:0] mix_31  = result_ss[111:104];
    wire [ 7:0] mix_32  = result_ss[119:112];
    wire [ 7:0] mix_33  = result_ss[127:120];
	 
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
   
   assign result_ssm = {mixs_33,mixs_32,mixs_31,mixs_30,
                        mixs_23,mixs_22,mixs_21,mixs_20,
                        mixs_13,mixs_12,mixs_11,mixs_10,
                        mixs_03,mixs_02,mixs_01,mixs_00};

    assign vc = result({ark,ss,ssm},
                        result_ark,result_ss,result_ssm);
	  
    function [127:0] result;
        input [2:0] asw;
        input [127:0] ark,ss,ssm;
        case (asw)
            3'b100 : result = ark;
            3'b010 : result = ss;
            3'b001 : result = ssm;
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
