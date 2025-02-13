module aes_mixcols(mix,in,inv,out);
  input         mix;
  input  [31:0] in;   // Input
  input         inv;  // Inverse
  output [31:0] out;  // Output
  
  wire [31:0] col_enc;
  wire [31:0] col_dec;
  
  aes_mix_enc enc(in,col_enc);
  aes_mix_dec dec(in,col_dec);
  
  assign out = mix ? inv ? col_dec : col_enc : out;

endmodule

module aes_mix_enc(in,out);
  input  [31:0] in;   // Input
  output [31:0] out;  // Output
  
  wire [ 7:0] b0 = in[ 7: 0];
  wire [ 7:0] b1 = in[15: 8];
  wire [ 7:0] b2 = in[23:16];
  wire [ 7:0] b3 = in[31:24];
    
  wire [31:0] mix_in_3 = {b3, b0, b1, b2};
  wire [31:0] mix_in_2 = {b2, b3, b0, b1};
  wire [31:0] mix_in_1 = {b1, b2, b3, b0};
  wire [31:0] mix_in_0 = {b0, b1, b2, b3};

  wire [ 7:0] mix_out_3;
  wire [ 7:0] mix_out_2;
  wire [ 7:0] mix_out_1;
  wire [ 7:0] mix_out_0;
  
  aes_mix_byte_enc mix_enc1(mix_in_0,mix_out_0);
  aes_mix_byte_enc mix_enc2(mix_in_1,mix_out_1);
  aes_mix_byte_enc mix_enc3(mix_in_2,mix_out_2);
  aes_mix_byte_enc mix_enc4(mix_in_3,mix_out_3);

  assign out = {mix_out_3, mix_out_2, mix_out_1, mix_out_0};

endmodule
  
module aes_mix_byte_enc(in,out);
  input  [31:0] in;   // Input
  output  [7:0] out;  // Output 
  
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

  wire [7:0] b3 = in[ 7: 0];
  wire [7:0] b2 = in[15: 8];
  wire [7:0] b1 = in[23:16];
  wire [7:0] b0 = in[31:24];

  assign out = xtN(b0,4'd2) ^ xtN(b1,4'd3) ^ b2 ^ b3;
  
endmodule

module aes_mix_dec(in,out);
  input  [31:0] in;   // Input
  output [31:0] out;  // Output
  
  wire [ 7:0] b0 = in[ 7: 0];
  wire [ 7:0] b1 = in[15: 8];
  wire [ 7:0] b2 = in[23:16];
  wire [ 7:0] b3 = in[31:24];
    
  wire [31:0] mix_in_3 = {b3, b0, b1, b2};
  wire [31:0] mix_in_2 = {b2, b3, b0, b1};
  wire [31:0] mix_in_1 = {b1, b2, b3, b0};
  wire [31:0] mix_in_0 = {b0, b1, b2, b3};

  wire [ 7:0] mix_out_3;
  wire [ 7:0] mix_out_2;
  wire [ 7:0] mix_out_1;
  wire [ 7:0] mix_out_0;
  
  aes_mix_byte_dec mix_dec1(mix_in_0,mix_out_0);
  aes_mix_byte_dec mix_dec2(mix_in_1,mix_out_1);
  aes_mix_byte_dec mix_dec3(mix_in_2,mix_out_2);
  aes_mix_byte_dec mix_dec4(mix_in_3,mix_out_3);

  assign out = {mix_out_3, mix_out_2, mix_out_1, mix_out_0};

endmodule 

module aes_mix_byte_dec(in,out);
  input  [31:0] in;   // Input
  output  [7:0] out;  // Output 
  
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

  wire [7:0] b3 = in[ 7: 0];
  wire [7:0] b2 = in[15: 8];
  wire [7:0] b1 = in[23:16];
  wire [7:0] b0 = in[31:24];

  assign out = xtN(b0,4'he) ^ xtN(b1,4'hb) ^ xtN(b2,4'hd) ^ xtN(b3,4'h9);
  
endmodule