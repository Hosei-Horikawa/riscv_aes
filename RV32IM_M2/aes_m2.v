module aes_m2 (sub,mix,a,b,inv,c);
    input             sub,mix,inv;
    input  [31:0] a,b;
    output [31:0] c;
    
    // SBox Instruction
    wire [31:0] result_subbytes;
    
    aes_sbox sbox1(sub,a[ 7: 0],inv,result_subbytes[ 7: 0]);
    aes_sbox sbox2(sub,b[15: 8],inv,result_subbytes[15: 8]);
    aes_sbox sbox3(sub,a[23:16],inv,result_subbytes[23:16]);
    aes_sbox sbox4(sub,b[31:24],inv,result_subbytes[31:24]);
    
    // Mix Instruction
    wire [ 7:0] mix_0    = a[ 7: 0];
    wire [ 7:0] mix_1    = a[15: 8];
    wire [ 7:0] mix_2    = b[23:16];
    wire [ 7:0] mix_3    = b[31:24];
    
    wire [ 7:0] mix_enc_0   = mixcolumn_enc(mix_0, mix_1, mix_2, mix_3);
    wire [ 7:0] mix_enc_1   = mixcolumn_enc(mix_1, mix_2, mix_3, mix_0);
    wire [ 7:0] mix_enc_2   = mixcolumn_enc(mix_2, mix_3, mix_0, mix_1);
    wire [ 7:0] mix_enc_3   = mixcolumn_enc(mix_3, mix_0, mix_1, mix_2);

    wire [31:0] mix_enc     = {mix_enc_3, mix_enc_2, mix_enc_1, mix_enc_0};

    wire [ 7:0] mix_dec_0   = mixcolumn_dec(mix_0, mix_1, mix_2, mix_3);
    wire [ 7:0] mix_dec_1   = mixcolumn_dec(mix_1, mix_2, mix_3, mix_0);
    wire [ 7:0] mix_dec_2   = mixcolumn_dec(mix_2, mix_3, mix_0, mix_1);
    wire [ 7:0] mix_dec_3   = mixcolumn_dec(mix_3, mix_0, mix_1, mix_2);
    
    wire [31:0] mix_dec     = {mix_dec_3, mix_dec_2, mix_dec_1, mix_dec_0};
    
    wire [31:0] result_mixcols  = inv ? mix_dec : mix_enc;

    assign c = (mix) ? result_mixcols : result_subbytes;

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
    
    function [7:0] mixcolumn_enc;
      input [7:0] b0, b1, b2, b3;
        mixcolumn_enc = xt2(b0) ^ (xt2(b1) ^ b1) ^ b2 ^ b3;
    endfunction

    function [7:0] mixcolumn_dec;
      input [7:0] b0, b1, b2, b3;
        mixcolumn_dec = xtN(b0,4'he) ^ xtN(b1,4'hb) ^ xtN(b2,4'hd) ^ xtN(b3,4'h9);
    endfunction
    
endmodule
