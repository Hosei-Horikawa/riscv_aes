module aes_mix_byte (col_in,inv,byte_out);
  input   [31:0] col_in ;
  input          inv;
  output  [ 7:0] byte_out;

  wire [7:0] b_dec;
  wire [7:0] b_enc;

  aes_mix_byte_enc enc(col_in,b_enc);
  aes_mix_byte_dec dec(col_in,b_dec);

assign byte_out = inv ? b_dec : b_enc;

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