module aes_v4 (ark,a,ss,ssm,va,vb,inv,vc);
    input             ark,ss,ssm,inv;
    input      [31:0] a;
    parameter         VLEN = 128;
    input  [VLEN-1:0] va,vb;
    output [VLEN-1:0] vc;
    
    wire     [31:0] c;
    wire    [127:0] result_ark;
    wire            subshift = ss | ssm;
    wire [VLEN-1:0] result_ss;
    wire [VLEN-1:0] result_ssm;
    
    wire     [31:0] rot_vb = {vb[103:96],vb[127:104]};            
    
    aes_sbox_shift_128 ss128(ark,rot_vb,subshift,va,inv,c,result_ss);
    
    assign result_ark[ 31: 0] = c ^ a ^ vb[31:0];
    assign result_ark[ 63:32] = c ^ a ^ vb[31:0] ^ vb[63:32];
    assign result_ark[ 95:64] = c ^ a ^ vb[31:0] ^ vb[63:32] ^ vb[95:64];
    assign result_ark[127:96] = c ^ a ^ vb[31:0] ^ vb[63:32] ^ vb[95:64] ^ vb[127:96];
    
    // Mix Instruction
    wire [7:0] mix_03 =       xtN(result_ss[  7:  0], (inv ? 11 : 3))                     ;
    wire [7:0] mix_02 = inv ? xtN(result_ss[  7:  0], (      13    )) : result_ss[  7:  0];
    wire [7:0] mix_01 = inv ? xtN(result_ss[  7:  0], (       9    )) : result_ss[  7:  0];
    wire [7:0] mix_00 =       xtN(result_ss[  7:  0], (inv ? 14 : 2))                     ;
    wire [7:0] mix_13 =       xtN(result_ss[ 15:  8], (inv ? 11 : 3))                     ;
    wire [7:0] mix_12 = inv ? xtN(result_ss[ 15:  8], (      13    )) : result_ss[ 15:  8];
    wire [7:0] mix_11 = inv ? xtN(result_ss[ 15:  8], (       9    )) : result_ss[ 15:  8];
    wire [7:0] mix_10 =       xtN(result_ss[ 15:  8], (inv ? 14 : 2))                     ;
    wire [7:0] mix_23 =       xtN(result_ss[ 23: 16], (inv ? 11 : 3))                     ;
    wire [7:0] mix_22 = inv ? xtN(result_ss[ 23: 16], (      13    )) : result_ss[ 23: 16];
    wire [7:0] mix_21 = inv ? xtN(result_ss[ 23: 16], (       9    )) : result_ss[ 23: 16];
    wire [7:0] mix_20 =       xtN(result_ss[ 23: 16], (inv ? 14 : 2))                     ;
    wire [7:0] mix_33 =       xtN(result_ss[ 31: 24], (inv ? 11 : 3))                     ;
    wire [7:0] mix_32 = inv ? xtN(result_ss[ 31: 24], (      13    )) : result_ss[ 31: 24];
    wire [7:0] mix_31 = inv ? xtN(result_ss[ 31: 24], (       9    )) : result_ss[ 31: 24];
    wire [7:0] mix_30 =       xtN(result_ss[ 31: 24], (inv ? 14 : 2))                     ;
    wire [7:0] mix_43 =       xtN(result_ss[ 39: 32], (inv ? 11 : 3))                     ;
    wire [7:0] mix_42 = inv ? xtN(result_ss[ 39: 32], (      13    )) : result_ss[ 39: 32];
    wire [7:0] mix_41 = inv ? xtN(result_ss[ 39: 32], (       9    )) : result_ss[ 39: 32];
    wire [7:0] mix_40 =       xtN(result_ss[ 39: 32], (inv ? 14 : 2))                     ;
    wire [7:0] mix_53 =       xtN(result_ss[ 47: 40], (inv ? 11 : 3))                     ;
    wire [7:0] mix_52 = inv ? xtN(result_ss[ 47: 40], (      13    )) : result_ss[ 47: 40];
    wire [7:0] mix_51 = inv ? xtN(result_ss[ 47: 40], (       9    )) : result_ss[ 47: 40];
    wire [7:0] mix_50 =       xtN(result_ss[ 47: 40], (inv ? 14 : 2))                     ;
    wire [7:0] mix_63 =       xtN(result_ss[ 55: 48], (inv ? 11 : 3))                     ;
    wire [7:0] mix_62 = inv ? xtN(result_ss[ 55: 48], (      13    )) : result_ss[ 55: 48];
    wire [7:0] mix_61 = inv ? xtN(result_ss[ 55: 48], (       9    )) : result_ss[ 55: 48];
    wire [7:0] mix_60 =       xtN(result_ss[ 55: 48], (inv ? 14 : 2))                     ;
    wire [7:0] mix_73 =       xtN(result_ss[ 63: 56], (inv ? 11 : 3))                     ;
    wire [7:0] mix_72 = inv ? xtN(result_ss[ 63: 56], (      13    )) : result_ss[ 63: 56];
    wire [7:0] mix_71 = inv ? xtN(result_ss[ 63: 56], (       9    )) : result_ss[ 63: 56];
    wire [7:0] mix_70 =       xtN(result_ss[ 63: 56], (inv ? 14 : 2))                     ;
    wire [7:0] mix_83 =       xtN(result_ss[ 71: 64], (inv ? 11 : 3))                     ;
    wire [7:0] mix_82 = inv ? xtN(result_ss[ 71: 64], (      13    )) : result_ss[ 71: 64];
    wire [7:0] mix_81 = inv ? xtN(result_ss[ 71: 64], (       9    )) : result_ss[ 71: 64];
    wire [7:0] mix_80 =       xtN(result_ss[ 71: 64], (inv ? 14 : 2))                     ;
    wire [7:0] mix_93 =       xtN(result_ss[ 79: 72], (inv ? 11 : 3))                     ;
    wire [7:0] mix_92 = inv ? xtN(result_ss[ 79: 72], (      13    )) : result_ss[ 79: 72];
    wire [7:0] mix_91 = inv ? xtN(result_ss[ 79: 72], (       9    )) : result_ss[ 79: 72];
    wire [7:0] mix_90 =       xtN(result_ss[ 79: 72], (inv ? 14 : 2))                     ;
    wire [7:0] mix_a3 =       xtN(result_ss[ 87: 80], (inv ? 11 : 3))                     ;
    wire [7:0] mix_a2 = inv ? xtN(result_ss[ 87: 80], (      13    )) : result_ss[ 87: 80];
    wire [7:0] mix_a1 = inv ? xtN(result_ss[ 87: 80], (       9    )) : result_ss[ 87: 80];
    wire [7:0] mix_a0 =       xtN(result_ss[ 87: 80], (inv ? 14 : 2))                     ;
    wire [7:0] mix_b3 =       xtN(result_ss[ 95: 88], (inv ? 11 : 3))                     ;
    wire [7:0] mix_b2 = inv ? xtN(result_ss[ 95: 88], (      13    )) : result_ss[ 95: 88];
    wire [7:0] mix_b1 = inv ? xtN(result_ss[ 95: 88], (       9    )) : result_ss[ 95: 88];
    wire [7:0] mix_b0 =       xtN(result_ss[ 95: 88], (inv ? 14 : 2))                     ;
    wire [7:0] mix_c3 =       xtN(result_ss[103: 96], (inv ? 11 : 3))                     ;
    wire [7:0] mix_c2 = inv ? xtN(result_ss[103: 96], (      13    )) : result_ss[103: 96];
    wire [7:0] mix_c1 = inv ? xtN(result_ss[103: 96], (       9    )) : result_ss[103: 96];
    wire [7:0] mix_c0 =       xtN(result_ss[103: 96], (inv ? 14 : 2))                     ;
    wire [7:0] mix_d3 =       xtN(result_ss[111:104], (inv ? 11 : 3))                     ;
    wire [7:0] mix_d2 = inv ? xtN(result_ss[111:104], (      13    )) : result_ss[111:104];
    wire [7:0] mix_d1 = inv ? xtN(result_ss[111:104], (       9    )) : result_ss[111:104];
    wire [7:0] mix_d0 =       xtN(result_ss[111:104], (inv ? 14 : 2))                     ;
    wire [7:0] mix_e3 =       xtN(result_ss[119:112], (inv ? 11 : 3))                     ;
    wire [7:0] mix_e2 = inv ? xtN(result_ss[119:112], (      13    )) : result_ss[119:112];
    wire [7:0] mix_e1 = inv ? xtN(result_ss[119:112], (       9    )) : result_ss[119:112];
    wire [7:0] mix_e0 =       xtN(result_ss[119:112], (inv ? 14 : 2))                     ;
    wire [7:0] mix_f3 =       xtN(result_ss[127:120], (inv ? 11 : 3))                     ;
    wire [7:0] mix_f2 = inv ? xtN(result_ss[127:120], (      13    )) : result_ss[127:120];
    wire [7:0] mix_f1 = inv ? xtN(result_ss[127:120], (       9    )) : result_ss[127:120];
    wire [7:0] mix_f0 =       xtN(result_ss[127:120], (inv ? 14 : 2))                     ;
    
    wire [7:0] mix_0 = mix_00 ^ mix_13 ^ mix_22 ^ mix_31;
    wire [7:0] mix_1 = mix_01 ^ mix_10 ^ mix_23 ^ mix_32;
    wire [7:0] mix_2 = mix_02 ^ mix_11 ^ mix_20 ^ mix_33;
    wire [7:0] mix_3 = mix_03 ^ mix_12 ^ mix_21 ^ mix_30;
    wire [7:0] mix_4 = mix_40 ^ mix_53 ^ mix_62 ^ mix_71;
    wire [7:0] mix_5 = mix_41 ^ mix_50 ^ mix_63 ^ mix_72;
    wire [7:0] mix_6 = mix_42 ^ mix_51 ^ mix_60 ^ mix_73;
    wire [7:0] mix_7 = mix_43 ^ mix_52 ^ mix_61 ^ mix_70;
    wire [7:0] mix_8 = mix_80 ^ mix_93 ^ mix_a2 ^ mix_b1;
    wire [7:0] mix_9 = mix_81 ^ mix_90 ^ mix_a3 ^ mix_b2;
    wire [7:0] mix_a = mix_82 ^ mix_91 ^ mix_a0 ^ mix_b3;
    wire [7:0] mix_b = mix_83 ^ mix_92 ^ mix_a1 ^ mix_b0;
    wire [7:0] mix_c = mix_c0 ^ mix_d3 ^ mix_e2 ^ mix_f1;
    wire [7:0] mix_d = mix_c1 ^ mix_d0 ^ mix_e3 ^ mix_f2;
    wire [7:0] mix_e = mix_c2 ^ mix_d1 ^ mix_e0 ^ mix_f3;
    wire [7:0] mix_f = mix_c3 ^ mix_d2 ^ mix_e1 ^ mix_f0;

    assign result_ssm = {mix_f, mix_e, mix_d, mix_c,
                         mix_b, mix_a, mix_9, mix_8,
                         mix_7, mix_6, mix_5, mix_4,
                         mix_3, mix_2, mix_1, mix_0};
    
    assign vc = result({ark,ss,ssm},vb,
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
