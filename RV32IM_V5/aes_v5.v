module aes_v5 (sub,a,sbsr,mix,vb,inv,vc);
    input          sub,sbsr,mix,inv;
    input   [31:0] a;
    input  [127:0] vb;
    output [127:0] vc;   
    
    // Sub-bytes input/output
    wire [ 7:0] sbinf_00 ,sbinf_01 ,sbinf_02 ,sbinf_03,
                sbinf_10 ,sbinf_11 ,sbinf_12 ,sbinf_13,
                sbinf_20 ,sbinf_21 ,sbinf_22 ,sbinf_23,
                sbinf_30 ,sbinf_31 ,sbinf_32 ,sbinf_33;
    wire [ 7:0] sbini_00 ,sbini_01 ,sbini_02 ,sbini_03,
                sbini_10 ,sbini_11 ,sbini_12 ,sbini_13,
                sbini_20 ,sbini_21 ,sbini_22 ,sbini_23,
                sbini_30 ,sbini_31 ,sbini_32 ,sbini_33;
    wire [ 7:0] sbfwd_00,sbfwd_01,sbfwd_02,sbfwd_03,
                sbfwd_10,sbfwd_11,sbfwd_12,sbfwd_13,
                sbfwd_20,sbfwd_21,sbfwd_22,sbfwd_23,
                sbfwd_30,sbfwd_31,sbfwd_32,sbfwd_33;
    wire [ 7:0] sbinv_00,sbinv_01,sbinv_02,sbinv_03,
                sbinv_10,sbinv_11,sbinv_12,sbinv_13,
                sbinv_20,sbinv_21,sbinv_22,sbinv_23,
                sbinv_30,sbinv_31,sbinv_32,sbinv_33;

    // Mix columns input/output
    wire [ 7:0] mi0_0, mi0_1, mi0_2, mi0_3,
                mi0_4, mi0_5, mi0_6, mi0_7;
    wire [ 7:0] mi1_0, mi1_1, mi1_2, mi1_3,
                mi1_4, mi1_5, mi1_6, mi1_7;
    wire [ 7:0] mo0_00, mo0_01,mo0_10, mo0_11,
                mo0_20, mo0_21,mo0_30, mo0_31;
    wire [ 7:0] mo1_00, mo1_01,mo1_10, mo1_11,
                mo1_20, mo1_21,mo1_30, mo1_31;
    
    // SubBytes/ShiftRows selections.
    wire [ 7:0] sbsr_sbin_00 = vb[ 23: 16];
    wire [ 7:0] sbsr_sbin_01 = vb[  7:  0];
    wire [ 7:0] sbsr_sbin_02 = vb[ 15:  8];
    wire [ 7:0] sbsr_sbin_03 = vb[ 63: 56];
    wire [ 7:0] sbsr_sbin_10 = vb[ 55: 48];
    wire [ 7:0] sbsr_sbin_11 = vb[ 39: 32];
    wire [ 7:0] sbsr_sbin_12 = vb[ 47: 40];
    wire [ 7:0] sbsr_sbin_13 = vb[ 31: 24];
    wire [ 7:0] sbsr_sbin_20 = vb[119:112];
    wire [ 7:0] sbsr_sbin_21 = vb[111:104];
    wire [ 7:0] sbsr_sbin_22 = vb[103: 96];
    wire [ 7:0] sbsr_sbin_23 = vb[ 95: 88];
    wire [ 7:0] sbsr_sbin_30 = vb[ 87: 80];
    wire [ 7:0] sbsr_sbin_31 = vb[ 79: 72];
    wire [ 7:0] sbsr_sbin_32 = vb[ 71: 64];
    wire [ 7:0] sbsr_sbin_33 = vb[127:120];
    
    assign sbinf_00 = sbsr_sbin_00;
    assign sbinf_01 = sbsr_sbin_01;
    assign sbinf_02 = sbsr_sbin_02;
    assign sbinf_03 = sbsr_sbin_03;
    assign sbinf_10 = sbsr_sbin_10;
    assign sbinf_11 = sbsr_sbin_11;
    assign sbinf_12 = sbsr_sbin_12;
    assign sbinf_13 = sbsr_sbin_13;
    assign sbinf_20 = sbsr_sbin_20;
    assign sbinf_21 = sbsr_sbin_21;
    assign sbinf_22 = sbsr_sbin_22;
    assign sbinf_23 = sbsr_sbin_23;
    assign sbinf_30 = sub ? vb[103: 96] : sbsr_sbin_30;
    assign sbinf_31 = sub ? vb[111:104] : sbsr_sbin_31;
    assign sbinf_32 = sub ? vb[119:112] : sbsr_sbin_32;
    assign sbinf_33 = sub ? vb[127:120] : sbsr_sbin_33;
    
    // under retry
    assign sbini_00 = vb[ 23: 16];
    assign sbini_01 = vb[  7:  0];
    assign sbini_02 = vb[ 47: 40];
    assign sbini_03 = vb[ 31: 24];
    assign sbini_10 = vb[ 55: 48];
    assign sbini_11 = vb[ 39: 32];
    assign sbini_12 = vb[ 15:  8];
    assign sbini_13 = vb[ 63: 56];
    assign sbini_20 = vb[119:112];
    assign sbini_21 = vb[ 79: 72];
    assign sbini_22 = vb[103: 96];
    assign sbini_23 = vb[127:120];
    assign sbini_30 = vb[ 87: 80];
    assign sbini_31 = vb[111:104];
    assign sbini_32 = vb[ 71: 64];
    assign sbini_33 = vb[ 95: 88];
                                   
    wire [127:0] sbsr_fwd = {sbfwd_31, sbfwd_30, sbfwd_33, sbfwd_32,
                             sbfwd_21, sbfwd_20, sbfwd_23, sbfwd_22,
                             sbfwd_12, sbfwd_10, sbfwd_13, sbfwd_11,
                             sbfwd_02, sbfwd_00, sbfwd_03, sbfwd_01};
                                                                   
    wire [127:0] sbsr_inv = {sbinv_31, sbinv_30, sbinv_33, sbinv_32,
                             sbinv_21, sbinv_20, sbinv_23, sbinv_22,
                             sbinv_12, sbinv_10, sbinv_13, sbinv_11,
                             sbinv_02, sbinv_00, sbinv_03, sbinv_01};

    wire [127:0] result_sbsr = inv ? sbsr_inv : sbsr_fwd;
    
    wire [31:0] sbfwd = {sbfwd_30,sbfwd_33,sbfwd_32,sbfwd_31};
    wire [127:0] result_sb;
    assign result_sb[ 31: 0] = sbfwd ^ a ^ vb[31:0];
    assign result_sb[ 63:32] = sbfwd ^ a ^ vb[31:0] ^ vb[63:32];
    assign result_sb[ 95:64] = sbfwd ^ a ^ vb[31:0] ^ vb[63:32] ^ vb[95:64];
    assign result_sb[127:96] = sbfwd ^ a ^ vb[31:0] ^ vb[63:32] ^ vb[95:64] ^ vb[127:96];
    
    // MixColumn selections.
    assign mi0_3 = vb[ 23: 16];
    assign mi0_2 = vb[ 31: 24];
    assign mi0_1 = vb[ 87: 80];
    assign mi0_0 = vb[ 95: 88];
    assign mi1_3 = vb[  7:  0];
    assign mi1_2 = vb[ 15:  8];
    assign mi1_1 = vb[ 71: 64];
    assign mi1_0 = vb[ 79: 72];
  
    assign mi0_7 = vb[ 55: 48];
    assign mi0_6 = vb[ 63: 56];
    assign mi0_5 = vb[119:112];
    assign mi0_4 = vb[127:120];
    assign mi1_7 = vb[ 39: 32];
    assign mi1_6 = vb[ 47: 40];
    assign mi1_5 = vb[103: 96];
    assign mi1_4 = vb[111:104];
  
    wire [31:0] mc_00        = {mi0_3, mi0_2, mi0_1, mi0_0};
    wire [31:0] mc_01        = {mi1_3, mi1_2, mi1_1, mi1_0};
    wire [31:0] mc_00r       = {mi0_2, mi0_1, mi0_0, mi0_3};
    wire [31:0] mc_01r       = {mi1_2, mi1_1, mi1_0, mi1_3};
    wire [31:0] mc_10        = {mi0_7, mi0_6, mi0_5, mi0_4};
    wire [31:0] mc_11        = {mi1_7, mi1_6, mi1_5, mi1_4};
    wire [31:0] mc_10r       = {mi0_6, mi0_5, mi0_4, mi0_7};
    wire [31:0] mc_11r       = {mi1_6, mi1_5, mi1_4, mi1_7};
    wire [31:0] mc_20        = {mi0_1, mi0_0, mi0_3, mi0_2};
    wire [31:0] mc_21        = {mi1_1, mi1_0, mi1_3, mi1_2};
    wire [31:0] mc_20r       = {mi0_0, mi0_3, mi0_2, mi0_1};
    wire [31:0] mc_21r       = {mi1_0, mi1_3, mi1_2, mi1_1};
    wire [31:0] mc_30        = {mi0_5, mi0_4, mi0_7, mi0_6};
    wire [31:0] mc_31        = {mi1_5, mi1_4, mi1_7, mi1_6};
    wire [31:0] mc_30r       = {mi0_4, mi0_7, mi0_6, mi0_5};
    wire [31:0] mc_31r       = {mi1_4, mi1_7, mi1_6, mi1_5};
  
    wire [127:0] result_mix  = {mo0_31, mo0_30, mo1_31, mo1_30,
                                mo0_21, mo0_20, mo1_21, mo1_20,
                                mo0_11, mo0_10, mo1_11, mo1_10,
                                mo0_01, mo0_00, mo1_01, mo1_00};
    
    // Result multiplexing
    assign  vc = mix ? result_mix  :
                 sub ? result_sb   :
                       result_sbsr ;
    
    // Submodule instances
    aes_f_sbox sbox_f00(sbinf_00, sbfwd_00);
    aes_f_sbox sbox_f01(sbinf_01, sbfwd_01);
    aes_f_sbox sbox_f02(sbinf_02, sbfwd_02);
    aes_f_sbox sbox_f03(sbinf_03, sbfwd_03);
    aes_f_sbox sbox_f10(sbinf_10, sbfwd_10);
    aes_f_sbox sbox_f11(sbinf_11, sbfwd_11);
    aes_f_sbox sbox_f12(sbinf_12, sbfwd_12);
    aes_f_sbox sbox_f13(sbinf_13, sbfwd_13);
    aes_f_sbox sbox_f20(sbinf_20, sbfwd_20);
    aes_f_sbox sbox_f21(sbinf_21, sbfwd_21);
    aes_f_sbox sbox_f22(sbinf_22, sbfwd_22);
    aes_f_sbox sbox_f23(sbinf_23, sbfwd_23);
    aes_f_sbox sbox_f30(sbinf_30, sbfwd_30);
    aes_f_sbox sbox_f31(sbinf_31, sbfwd_31);
    aes_f_sbox sbox_f32(sbinf_32, sbfwd_32);
    aes_f_sbox sbox_f33(sbinf_33, sbfwd_33);

    aes_i_sbox sbox_i00(sbini_00, sbinv_00);
    aes_i_sbox sbox_i01(sbini_01, sbinv_01);
    aes_i_sbox sbox_i02(sbini_02, sbinv_02);
    aes_i_sbox sbox_i03(sbini_03, sbinv_03);
    aes_i_sbox sbox_i10(sbini_10, sbinv_10);
    aes_i_sbox sbox_i11(sbini_11, sbinv_11);
    aes_i_sbox sbox_i12(sbini_12, sbinv_12);
    aes_i_sbox sbox_i13(sbini_13, sbinv_13);
    aes_i_sbox sbox_i20(sbini_20, sbinv_20);
    aes_i_sbox sbox_i21(sbini_21, sbinv_21);
    aes_i_sbox sbox_i22(sbini_22, sbinv_22);
    aes_i_sbox sbox_i23(sbini_23, sbinv_23);
    aes_i_sbox sbox_i30(sbini_30, sbinv_30);
    aes_i_sbox sbox_i31(sbini_31, sbinv_31);
    aes_i_sbox sbox_i32(sbini_32, sbinv_32);
    aes_i_sbox sbox_i33(sbini_33, sbinv_33);

    aes_mix_byte mix_00 (mc_00 , inv, mo0_00);
    aes_mix_byte mix_01 (mc_01 , inv, mo1_00);
    aes_mix_byte mix_02 (mc_00r, inv, mo0_01);
    aes_mix_byte mix_03 (mc_01r, inv, mo1_01);
    aes_mix_byte mix_10 (mc_10 , inv, mo0_10);
    aes_mix_byte mix_11 (mc_11 , inv, mo1_10);
    aes_mix_byte mix_12 (mc_10r, inv, mo0_11);
    aes_mix_byte mix_13 (mc_11r, inv, mo1_11);
    aes_mix_byte mix_20 (mc_20 , inv, mo0_20);
    aes_mix_byte mix_21 (mc_21 , inv, mo1_20);
    aes_mix_byte mix_22 (mc_20r, inv, mo0_21);
    aes_mix_byte mix_23 (mc_21r, inv, mo1_21);
    aes_mix_byte mix_30 (mc_30 , inv, mo0_30);
    aes_mix_byte mix_31 (mc_31 , inv, mo1_30);
    aes_mix_byte mix_32 (mc_30r, inv, mo0_31);
    aes_mix_byte mix_33 (mc_31r, inv, mo1_31);

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