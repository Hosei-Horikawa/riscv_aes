module aes_m3 (mix,a,b,inv,num,c);
    input         mix,inv;
    input   [1:0] num;
    input  [31:0] a,b;
    output [31:0] c;
    
    // SBox Instruction
    wire [7:0] bytes_in [3:0];
    
    assign bytes_in[0] = b[ 7: 0];
    assign bytes_in[1] = b[15: 8];
    assign bytes_in[2] = b[23:16];
    assign bytes_in[3] = b[31:24];

    wire [7:0] sel_byte = bytes_in[num];
    
    wire [7:0] sbox_out;
    
    aes_sbox sbox(1'b1,sel_byte,inv,sbox_out);
    
    // Mix Instruction
    wire [ 7:0] mix_b3 =       xtN(sbox_out, (inv ? 11 : 3))            ;
    wire [ 7:0] mix_b2 = inv ? xtN(sbox_out, (      13    )) : sbox_out ;
    wire [ 7:0] mix_b1 = inv ? xtN(sbox_out, (       9    )) : sbox_out ;
    wire [ 7:0] mix_b0 =       xtN(sbox_out, (inv ? 14 : 2))            ;

    wire [31:0] result_mix = {mix_b3, mix_b2, mix_b1, mix_b0};
    
    wire [31:0] result = mix ? result_mix : {24'b0,sbox_out};
    
    wire [31:0] rotated =
                {32{num == 2'b00}} & {result                     } |
                {32{num == 2'b01}} & {result[23:0], result[31:24]} |
                {32{num == 2'b10}} & {result[15:0], result[31:16]} |
                {32{num == 2'b11}} & {result[ 7:0], result[31: 8]} ;
    
    assign c  = rotated ^ a;

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
    
endmodule
