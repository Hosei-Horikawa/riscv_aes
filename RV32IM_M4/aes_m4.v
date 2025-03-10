module aes_m4 (sub,sbsr,mix,hi,a,b,inv,c);
    input         sub,sbsr,mix,hi,inv;
    input  [31:0] a,b;
    output [31:0] c;
    
    // Sub-bytes input/output
    wire [ 7:0] sbinf_0 ,sbinf_1 ,sbinf_2 ,sbinf_3 ;
    wire [ 7:0] sbini_0 ,sbini_1 ,sbini_2 ,sbini_3 ;
    wire [ 7:0] sbfwd_0,sbfwd_1,sbfwd_2,sbfwd_3;
    wire [ 7:0] sbinv_0,sbinv_1,sbinv_2,sbinv_3;

    // Mix columns input/output
    wire [ 7:0] mi0_0, mi0_1, mi0_2, mi0_3;
    wire [ 7:0] mi1_0, mi1_1, mi1_2, mi1_3;
    wire [ 7:0] mo0_0, mo0_1;
    wire [ 7:0] mo1_0, mo1_1;
    
    // SubBytes/ShiftRows selections.
    wire [ 7:0] sbsr_sbin_0 = hi  ? b[23:16] : a[23:16];
    wire [ 7:0] sbsr_sbin_1 = hi  ? b[15: 8] : a[ 7: 0];
    wire [ 7:0] sbsr_sbin_2 = hi  ? b[ 7: 0] : a[15: 8];
    wire [ 7:0] sbsr_sbin_3 = hi  ? a[31:24] : b[31:24];
    
    assign      sbinf_0     = sub ? a[ 7: 0] : sbsr_sbin_0;
    assign      sbinf_1     = sub ? a[15: 8] : sbsr_sbin_1;
    assign      sbinf_2     = sub ? a[23:16] : sbsr_sbin_2;
    assign      sbinf_3     = sub ? a[31:24] : sbsr_sbin_3;
    
    aes_f_sbox sbox_f0(sbinf_0, sbfwd_0);
    aes_f_sbox sbox_f1(sbinf_1, sbfwd_1);
    aes_f_sbox sbox_f2(sbinf_2, sbfwd_2);
    aes_f_sbox sbox_f3(sbinf_3, sbfwd_3);

    assign      sbini_0     = hi  ? b[23:16] : a[23:16];
    assign      sbini_1     = hi  ? a[15: 8] : a[ 7: 0];
    assign      sbini_2     = hi  ? b[ 7: 0] : b[15: 8];
    assign      sbini_3     = hi  ? b[31:24] : a[31:24];
    
    aes_i_sbox sbox_i0(sbini_0, sbinv_0);
    aes_i_sbox sbox_i1(sbini_1, sbinv_1);
    aes_i_sbox sbox_i2(sbini_2, sbinv_2);
    aes_i_sbox sbox_i3(sbini_3, sbinv_3);
    
    wire [31:0] sbsr_fwd    = hi  ? {sbfwd_1, sbfwd_0, sbfwd_3, sbfwd_2}: 
                                    {sbfwd_2, sbfwd_0, sbfwd_3, sbfwd_1}; 
                                                                   
    wire [31:0] sbsr_inv    = hi  ? {sbinv_1, sbinv_0, sbinv_3, sbinv_2}: 
                                    {sbinv_2, sbinv_0, sbinv_3, sbinv_1}; 

    wire [31:0] result_sbsr = inv ? sbsr_inv : sbsr_fwd;
    wire [31:0] result_sb   = {sbfwd_3, sbfwd_2, sbfwd_1, sbfwd_0};
    
    // MixColumn selections.
    assign      mi0_3       = a[23:16];
    assign      mi0_2       = a[31:24];
    assign      mi0_1       = b[23:16];
    assign      mi0_0       = b[31:24];
    assign      mi1_3       = a[ 7: 0];
    assign      mi1_2       = a[15: 8];
    assign      mi1_1       = b[ 7: 0];
    assign      mi1_0       = b[15: 8];
  
    wire [31:0] mc_0        = {mi0_3, mi0_2, mi0_1, mi0_0};
    wire [31:0] mc_1        = {mi1_3, mi1_2, mi1_1, mi1_0};
    wire [31:0] mc_0r       = {mi0_2, mi0_1, mi0_0, mi0_3};
    wire [31:0] mc_1r       = {mi1_2, mi1_1, mi1_0, mi1_3};
    
    aes_mix_byte mix_0 (mc_0 , inv, mo0_0);
    aes_mix_byte mix_1 (mc_1 , inv, mo1_0);
    aes_mix_byte mix_2 (mc_0r, inv, mo0_1);
    aes_mix_byte mix_3 (mc_1r, inv, mo1_1);
  
    wire [31:0] result_mix  = {mo0_1, mo0_0, mo1_1, mo1_0};
    
    // Result multiplexing
    assign  c = mix ? result_mix  :
                sub ? result_sb   :
                      result_sbsr ;

endmodule

module aes_f_sbox(in,fout);
    input  [7:0] in;
    output [7:0] fout;
    wire [20:0] t1;
    wire [17:0] t2;

    sbox_aes_top top(in,t1 );
    sbox_inv_mid mid(t1,t2 );
    sbox_aes_out out(t2,fout);

endmodule

module aes_i_sbox(in,iout);
    input  [7:0] in;
    output [7:0] iout;
    wire [20:0] t1;
    wire [17:0] t2;

    sbox_aesi_top top (in,t1 );
    sbox_inv_mid  mid (t1,t2 );
    sbox_aesi_out out (t2,iout);

endmodule

module sbox_aes_top(x,y);
    input   [7:0] x;
    output [20:0] y;
    wire    [5:0] t;

    assign  y[ 0] = x[ 0];
    assign  y[ 1] = x[ 7] ^  x[ 4];
    assign  y[ 2] = x[ 7] ^  x[ 2];
    assign  y[ 3] = x[ 7] ^  x[ 1];
    assign  y[ 4] = x[ 4] ^  x[ 2];
    assign  t[ 0] = x[ 3] ^  x[ 1];
    assign  y[ 5] = y[ 1] ^  t[ 0];
    assign  t[ 1] = x[ 6] ^  x[ 5];
    assign  y[ 6] = x[ 0] ^  y[ 5];
    assign  y[ 7] = x[ 0] ^  t[ 1];
    assign  y[ 8] = y[ 5] ^  t[ 1];
    assign  t[ 2] = x[ 6] ^  x[ 2];
    assign  t[ 3] = x[ 5] ^  x[ 2];
    assign  y[ 9] = y[ 3] ^  y[ 4];
    assign  y[10] = y[ 5] ^  t[ 2];
    assign  y[11] = t[ 0] ^  t[ 2];
    assign  y[12] = t[ 0] ^  t[ 3];
    assign  y[13] = y[ 7] ^  y[12];
    assign  t[ 4] = x[ 4] ^  x[ 0];
    assign  y[14] = t[ 1] ^  t[ 4];
    assign  y[15] = y[ 1] ^  y[14];
    assign  t[ 5] = x[ 1] ^  x[ 0];
    assign  y[16] = t[ 1] ^  t[ 5];
    assign  y[17] = y[ 2] ^  y[16];
    assign  y[18] = y[ 2] ^  y[ 8];
    assign  y[19] = y[15] ^  y[13];
    assign  y[20] = y[ 1] ^  t[ 3];

endmodule

module sbox_inv_mid(x,y);
    input  [20:0] x;
    output [17:0] y;
    wire   [45:0] t;

    assign  t[ 0] = x[ 3] ^  x[12];
    assign  t[ 1] = x[ 9] &  x[ 5];
    assign  t[ 2] = x[17] &  x[ 6];
    assign  t[ 3] = x[10] ^  t[ 1];
    assign  t[ 4] = x[14] &  x[ 0];
    assign  t[ 5] = t[ 4] ^  t[ 1];
    assign  t[ 6] = x[ 3] &  x[12];
    assign  t[ 7] = x[16] &  x[ 7];
    assign  t[ 8] = t[ 0] ^  t[ 6];
    assign  t[ 9] = x[15] &  x[13];
    assign  t[10] = t[ 9] ^  t[ 6];
    assign  t[11] = x[ 1] &  x[11];
    assign  t[12] = x[ 4] &  x[20];
    assign  t[13] = t[12] ^  t[11];
    assign  t[14] = x[ 2] &  x[ 8];
    assign  t[15] = t[14] ^  t[11];
    assign  t[16] = t[ 3] ^  t[ 2];
    assign  t[17] = t[ 5] ^  x[18];
    assign  t[18] = t[ 8] ^  t[ 7];
    assign  t[19] = t[10] ^  t[15];
    assign  t[20] = t[16] ^  t[13];
    assign  t[21] = t[17] ^  t[15];
    assign  t[22] = t[18] ^  t[13];
    assign  t[23] = t[19] ^  x[19];
    assign  t[24] = t[22] ^  t[23];
    assign  t[25] = t[22] &  t[20];
    assign  t[26] = t[21] ^  t[25];
    assign  t[27] = t[20] ^  t[21];
    assign  t[28] = t[23] ^  t[25];
    assign  t[29] = t[28] &  t[27];
    assign  t[30] = t[26] &  t[24];
    assign  t[31] = t[20] &  t[23];
    assign  t[32] = t[27] &  t[31];
    assign  t[33] = t[27] ^  t[25];
    assign  t[34] = t[21] &  t[22];
    assign  t[35] = t[24] &  t[34];
    assign  t[36] = t[24] ^  t[25];
    assign  t[37] = t[21] ^  t[29];
    assign  t[38] = t[32] ^  t[33];
    assign  t[39] = t[23] ^  t[30];
    assign  t[40] = t[35] ^  t[36];
    assign  t[41] = t[38] ^  t[40];
    assign  t[42] = t[37] ^  t[39];
    assign  t[43] = t[37] ^  t[38];
    assign  t[44] = t[39] ^  t[40];
    assign  t[45] = t[42] ^  t[41];
    assign  y[ 0] = t[38] &  x[ 7];
    assign  y[ 1] = t[37] &  x[13];
    assign  y[ 2] = t[42] &  x[11];
    assign  y[ 3] = t[45] &  x[20];
    assign  y[ 4] = t[41] &  x[ 8];
    assign  y[ 5] = t[44] &  x[ 9];
    assign  y[ 6] = t[40] &  x[17];
    assign  y[ 7] = t[39] &  x[14];
    assign  y[ 8] = t[43] &  x[ 3];
    assign  y[ 9] = t[38] &  x[16];
    assign  y[10] = t[37] &  x[15];
    assign  y[11] = t[42] &  x[ 1];
    assign  y[12] = t[45] &  x[ 4];
    assign  y[13] = t[41] &  x[ 2];
    assign  y[14] = t[44] &  x[ 5];
    assign  y[15] = t[40] &  x[ 6];
    assign  y[16] = t[39] &  x[ 0];
    assign  y[17] = t[43] &  x[12];

endmodule

module sbox_aes_out(x,y);
    input [17:0] x;
    output [7:0] y;
    wire [29:0] t;

    assign  t[ 0] = x[11] ^  x[12];
    assign  t[ 1] = x[ 0] ^  x[ 6];
    assign  t[ 2] = x[14] ^  x[16];
    assign  t[ 3] = x[15] ^  x[ 5];
    assign  t[ 4] = x[ 4] ^  x[ 8];
    assign  t[ 5] = x[17] ^  x[11];
    assign  t[ 6] = x[12] ^  t[ 5];
    assign  t[ 7] = x[14] ^  t[ 3];
    assign  t[ 8] = x[ 1] ^  x[ 9];
    assign  t[ 9] = x[ 2] ^  x[ 3];
    assign  t[10] = x[ 3] ^  t[ 4];
    assign  t[11] = x[10] ^  t[ 2];
    assign  t[12] = x[16] ^  x[ 1];
    assign  t[13] = x[ 0] ^  t[ 0];
    assign  t[14] = x[ 2] ^  x[11];
    assign  t[15] = x[ 5] ^  t[ 1];
    assign  t[16] = x[ 6] ^  t[ 0];
    assign  t[17] = x[ 7] ^  t[ 1];
    assign  t[18] = x[ 8] ^  t[ 8];
    assign  t[19] = x[13] ^  t[ 4];
    assign  t[20] = t[ 0] ^  t[ 1];
    assign  t[21] = t[ 1] ^  t[ 7];
    assign  t[22] = t[ 3] ^  t[12];
    assign  t[23] = t[18] ^  t[ 2];
    assign  t[24] = t[15] ^  t[ 9];
    assign  t[25] = t[ 6] ^  t[10];
    assign  t[26] = t[ 7] ^  t[ 9];
    assign  t[27] = t[ 8] ^  t[10];
    assign  t[28] = t[11] ^  t[14];
    assign  t[29] = t[11] ^  t[17];
    assign  y[ 0] = t[ 6] ^~ t[23];
    assign  y[ 1] = t[13] ^~ t[27];
    assign  y[ 2] = t[25] ^  t[29];
    assign  y[ 3] = t[20] ^  t[22];
    assign  y[ 4] = t[ 6] ^  t[21];
    assign  y[ 5] = t[19] ^~ t[28];
    assign  y[ 6] = t[16] ^~ t[26];
    assign  y[ 7] = t[ 6] ^  t[24];

endmodule

module sbox_aesi_top(x,y);
    input   [7:0] x;
    output [20:0] y;
    wire    [4:0] t;

    assign  y[17] = x[ 7] ^  x[ 4];
    assign  y[16] = x[ 6] ^~ x[ 4];
    assign  y[ 2] = x[ 7] ^~ x[ 6];
    assign  y[ 1] = x[ 4] ^  x[ 3];
    assign  y[18] = x[ 3] ^~ x[ 0];
    assign  t[ 0] = x[ 1] ^  x[ 0];
    assign  y[ 6] = x[ 6] ^~ y[17];
    assign  y[14] = y[16] ^  t[ 0];
    assign  y[ 7] = x[ 0] ^~ y[ 1];
    assign  y[ 8] = y[ 2] ^  y[18];
    assign  y[ 9] = y[ 2] ^  t[ 0];
    assign  y[ 3] = y[ 1] ^  t[ 0];
    assign  y[19] = x[ 5] ^~ y[ 1];
    assign  t[ 1] = x[ 6] ^  x[ 1];
    assign  y[13] = x[ 5] ^~ y[14];
    assign  y[15] = y[18] ^  t[ 1];
    assign  y[ 4] = x[ 3] ^  y[ 6];
    assign  t[ 2] = x[ 5] ^~ x[ 2];
    assign  t[ 3] = x[ 2] ^~ x[ 1];
    assign  t[ 4] = x[ 5] ^~ x[ 3];
    assign  y[ 5] = y[16] ^  t[ 2];
    assign  y[12] = t[ 1] ^  t[ 4];
    assign  y[20] = y[ 1] ^  t[ 3];
    assign  y[11] = y[ 8] ^  y[20];
    assign  y[10] = y[ 8] ^  t[ 3];
    assign  y[ 0] = x[ 7] ^  t[ 2];

endmodule

module sbox_aesi_out(x,y);
    input  [17:0] x;
    output  [7:0] y;
    wire   [29:0] t;

    assign  t[ 0] = x[ 2] ^  x[11];
    assign  t[ 1] = x[ 8] ^  x[ 9];
    assign  t[ 2] = x[ 4] ^  x[12];
    assign  t[ 3] = x[15] ^  x[ 0];
    assign  t[ 4] = x[16] ^  x[ 6];
    assign  t[ 5] = x[14] ^  x[ 1];
    assign  t[ 6] = x[17] ^  x[10];
    assign  t[ 7] = t[ 0] ^  t[ 1];
    assign  t[ 8] = x[ 0] ^  x[ 3];
    assign  t[ 9] = x[ 5] ^  x[13];
    assign  t[10] = x[ 7] ^  t[ 4];
    assign  t[11] = t[ 0] ^  t[ 3];
    assign  t[12] = x[14] ^  x[16];
    assign  t[13] = x[17] ^  x[ 1];
    assign  t[14] = x[17] ^  x[12];
    assign  t[15] = x[ 4] ^  x[ 9];
    assign  t[16] = x[ 7] ^  x[11];
    assign  t[17] = x[ 8] ^  t[ 2];
    assign  t[18] = x[13] ^  t[ 5];
    assign  t[19] = t[ 2] ^  t[ 3];
    assign  t[20] = t[ 4] ^  t[ 6];
    assign  t[22] = t[ 2] ^  t[ 7];
    assign  t[23] = t[ 7] ^  t[ 8];
    assign  t[24] = t[ 5] ^  t[ 7];
    assign  t[25] = t[ 6] ^  t[10];
    assign  t[26] = t[ 9] ^  t[11];
    assign  t[27] = t[10] ^  t[18];
    assign  t[28] = t[11] ^  t[25];
    assign  t[29] = t[15] ^  t[20];
    assign  y[ 0] = t[ 9] ^  t[16];
    assign  y[ 1] = t[14] ^  t[23];
    assign  y[ 2] = t[19] ^  t[24];
    assign  y[ 3] = t[23] ^  t[27];
    assign  y[ 4] = t[12] ^  t[22];
    assign  y[ 5] = t[17] ^  t[28];
    assign  y[ 6] = t[26] ^  t[29];
    assign  y[ 7] = t[13] ^  t[22];

endmodule