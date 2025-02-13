module instmem_aes128_v1 (a,inst);
    input  [31:0] a;
    output [31:0] inst;
    wire   [31:0] rom [0:63];
    // aes_128_enc_key_schedule:
    assign rom[6'h00] = 32'b00000000010000000000010010010011; // li  s1, 4
    assign rom[6'h01] = 32'b00000001000001001111010001010111; // vsetvli s0, s1, e32
    assign rom[6'h02] = 32'b00000100100000000000001010010011; // la  t0,  initial_key
    assign rom[6'h03] = 32'b00000010000000101110000100000111; // vle32  v2,  t0    
    assign rom[6'h04] = 32'b00000101100000000000010100010011; // la    a0,  round_key
    assign rom[6'h05] = 32'b00001010000001010000001010010011; // addi  t0,  a0,  160
    assign rom[6'h06] = 32'b00000000000000000000001100010011; // la    t1,  aes_round_const
    // aes_128_enc_ks_l0:
    assign rom[6'h07] = 32'b00000010000001010110000100100111; // vse32  v2,  a0   
    assign rom[6'h08] = 32'b00000000010101010000110001100011; // beq   a0,  t0,  aes_128_enc_ks_finish
    assign rom[6'h09] = 32'b00000001000001010000010100010011; // addi  a0,  a0,  16
    assign rom[6'h0a] = 32'b00000000000000110100001110000011; // lbu   t2,  0(t1)
    assign rom[6'h0b] = 32'b00000000010000110000001100010011; // addi  t1,  t1,  4
    assign rom[6'h0c] = 32'b10000010001000111100000101011011; // vaddrk.vx  v2,  v2,  t2
    assign rom[6'h0d] = 32'b11111110100111111111000001101111; // j  aes_128_enc_ks_l0
    // aes_128_enc_ks_finish:
    assign rom[6'h0e] = 32'b00000101100000000000010100010011; // la  a0, round_key
    // aes_128_encrypt:
    assign rom[6'h0f] = 32'b00000000101000000000011110010011; // li    a5, 10
    assign rom[6'h10] = 32'b00000000010001111001100000010011; // slli  a6, a5, 4
    assign rom[6'h11] = 32'b00000000101010000000100000110011; // add   a6, a6, a0
    assign rom[6'h12] = 32'b00000010100000000000100010010011; // la    a7, input_block
    assign rom[7'h13] = 32'b00000010000010001110000010000111; // vle32.v  v1,  a7
    assign rom[7'h14] = 32'b00000010000001010110000110000111; // vle32.v  v3,  a0
    assign rom[7'h15] = 32'b00101110001100001000000011010111; // vxor.vv  v1,  v1,  v3
    assign rom[6'h16] = 32'b00000001000001010000010100010011; // addi  a0,  a0,  16
    // aes_enc_block_loop:
    assign rom[7'h17] = 32'b00000010000100000000000011011011; // vsubbytes.v    v1,  v1
    assign rom[7'h18] = 32'b00000110000100000000000011011011; // vshiftrows.v   v1,  v1
    assign rom[7'h19] = 32'b00001010000100000000000011011011; // vmixColumns.v  v1,  v1
    assign rom[7'h1a] = 32'b00000010000001010110000110000111; // vle32.v  v3,  a0
    assign rom[7'h1b] = 32'b00101110001100001000000011010111; // vxor.vv  v1,  v1,  v3
    assign rom[6'h1c] = 32'b00000001000001010000010100010011; // addi  a0,  a0,  16
    assign rom[6'h1d] = 32'b11111111000001010001010011100011; // bne   a0,  a6,  aes_enc_block_loop
    // aes_enc_block_finish:
    assign rom[7'h1e] = 32'b00000010000100000000000011011011; // vsubbytes.v   v1,  v1
    assign rom[7'h1f] = 32'b00000110000100000000000011011011; // vshiftrows.v  v1,  v1
    assign rom[7'h20] = 32'b00000010000001010110000110000111; // vle32.v  v3,  a0
    assign rom[7'h21] = 32'b00101110001100001000000011010111; // vxor.vv  v1,  v1,  v3
    assign rom[6'h22] = 32'b00000011100000000000100010010011; // la  a7,  output_block
    assign rom[6'h23] = 32'b00000010000010001110000010100111; // vse32.v  v1,  a7
    // aes_128_decrypt:
    assign rom[6'h24] = 32'b00000101100000000000100000010011; // la  a6,  round_key
    assign rom[6'h25] = 32'b00000000101000000000011110010011; // li    a5,  10
    assign rom[6'h26] = 32'b00000000010001111001010100010011; // slli  a0,  a5,  4
    assign rom[6'h27] = 32'b00000001000001010000010100110011; // add   a0,  a0,  a6
    assign rom[6'h28] = 32'b00000011100000000000100010010011; // la    a7,  output_block
    assign rom[7'h29] = 32'b00000010000010001110000010000111; // vle32.v   v1,   a7
    assign rom[7'h2a] = 32'b00000010000001010110000110000111; // vle32.v  v3,  a0
    assign rom[7'h2b] = 32'b00101110001100001000000011010111; // vxor.vv  v1,  v1,  v3
    assign rom[6'h2c] = 32'b11111111000001010000010100010011; // addi  a0,  a0,  -16
    // aes_dec_block_loop:
    assign rom[7'h2d] = 32'b00001110000100000000000011011011; // vinvshiftrows.v  v1,  v1
    assign rom[7'h2e] = 32'b00010010000100000000000011011011; // vinvsubbytes.v   v1,  v1
    assign rom[7'h2f] = 32'b00000010000001010110000110000111; // vle32.v  v3,  a0
    assign rom[7'h30] = 32'b00101110001100001000000011010111; // vxor.vv  v1,  v1,  v3
    assign rom[7'h31] = 32'b00010110000100000000000011011011; // vinvmixcolumns.v  v1,  v1
    assign rom[6'h32] = 32'b11111111000001010000010100010011; // addi  a0,  a0,  -16
    assign rom[6'h33] = 32'b11111111000001010001010011100011; // bne   a0,  a6,  aes_dec_block_loop
    // aes_dec_block_finish:
    assign rom[7'h34] = 32'b00001110000100000000000011011011; // vinvshiftrows.v  v1,  v1
    assign rom[7'h35] = 32'b00010010000100000000000011011011; // vinvsubbytes.v   v1,  v1
    assign rom[7'h36] = 32'b00000010000001010110000110000111; // vle32.v  v3,  a0
    assign rom[7'h37] = 32'b00101110001100001000000011010111; // vxor.vv  v1,  v1,  v3
    assign rom[6'h38] = 32'b00000011100000000000100010010011; //la  a7, output_block
    assign rom[6'h39] = 32'b00000010000010001110000010100111; // vse32.v  v1,  a7
    assign rom[6'h3a] = 32'b00000000000000001000000001100111; // jr  ra
    assign rom[6'h3b] = 32'b00000000000000000000000000000000; // 
    assign rom[6'h3c] = 32'b00000000000000000000000000000000; // 
    assign rom[6'h3d] = 32'b00000000000000000000000000000000; // 
    assign rom[6'h3e] = 32'b00000000000000000000000000000000; // 
    assign rom[6'h3f] = 32'b00000000000000000000000000000000; // 
    assign inst = rom[a[7:2]];
endmodule
