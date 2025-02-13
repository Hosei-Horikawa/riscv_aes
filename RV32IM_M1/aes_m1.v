module aes_m1 (sub,mix,a,inv,c);
    input         sub,mix,inv;
    input  [31:0] a;
    output [31:0] c;
    
    wire [31:0] result_subbytes;
    wire [31:0] result_mixcols;
    
    aes_sbox sbox1(sub,a[ 7: 0],inv,result_subbytes[ 7: 0]);
    aes_sbox sbox2(sub,a[15: 8],inv,result_subbytes[15: 8]);
    aes_sbox sbox3(sub,a[23:16],inv,result_subbytes[23:16]);
    aes_sbox sbox4(sub,a[31:24],inv,result_subbytes[31:24]);
    
    aes_mixcols mixs(mix,a,inv,result_mixcols);
    
    assign c = (mix) ? result_mixcols : result_subbytes;
    
endmodule
