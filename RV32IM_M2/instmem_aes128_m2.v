module instmem_aes128_m2 (a,inst);
    input  [31:0] a;
    output [31:0] inst;
    wire   [31:0] rom [0:255];
    // aes_128_enc_key_schedule:
    assign rom[8'h00] = 32'b00000100100000000000001010010011; // la  t0,  initial_key
    assign rom[8'h01] = 32'b00000000000000101010010110000011; // lw  a1,   0(t0)
    assign rom[8'h02] = 32'b00000000010000101010011000000011; // lw  a2,   4(t0)
    assign rom[8'h03] = 32'b00000000100000101010011010000011; // lw  a3,   8(t0)
    assign rom[8'h04] = 32'b00000000110000101010011100000011; // lw  a4,  12(t0)
    assign rom[8'h05] = 32'b00000101100000000000010100010011; // la    a0,  round_key
    assign rom[8'h06] = 32'b00001010000001010000001010010011; // addi  t0,  a0,  160
    assign rom[8'h07] = 32'b00000000000000000000001100010011; // la    t1,  aes_round_const
    assign rom[8'h08] = 32'b00000000101101010010000000100011; // sw  a1,   0(a0)
    assign rom[8'h09] = 32'b00000000110001010010001000100011; // sw  a1,   4(a0)
    assign rom[8'h0a] = 32'b00000000110101010010010000100011; // sw  a1,   8(a0)
    assign rom[8'h0b] = 32'b00000000111001010010011000100011; // sw  a1,  12(a0)
    assign rom[8'h0c] = 32'b00000010010101010000110001100011; // beq  a0,  t0,  aes_128_enc_ks_finish
    assign rom[8'h0d] = 32'b00000001000001010000010100010011; // addi  a0,  a0,  16
    assign rom[8'h0e] = 32'b00000000000000110100001110000011; // lbu   t2,  0(t1)
    assign rom[8'h0f] = 32'b00000000010000110000001100010011; // addi  t1,  t1,  4
    assign rom[8'h10] = 32'b00000000011101011100010110110011; // xor   a1,  a1,  t2
    assign rom[8'h11] = 32'b00000001100001110001010000010011; // slli  s0,  a4,  24
    assign rom[8'h12] = 32'b00000000100001110101010010010011; // srli  s1,  a4,  8
    assign rom[8'h13] = 32'b00000000100101000110010000110011; // or    s0,  s0,  s1
    assign rom[8'h14] = 32'b00000110100001000000010001111111; // subshift  s0,  s0,  s0
    assign rom[8'h15] = 32'b00000000100001011100010110110011; // xor  a1,  a1,  s0
    assign rom[8'h16] = 32'b00000000101101100100011000110011; // xor  a2,  a2,  a1
    assign rom[8'h17] = 32'b00000000110001101100011010110011; // xor  a3,  a3,  a2
    assign rom[8'h18] = 32'b00000000110101110100011100110011; // xor  a4,  a4,  a3
    assign rom[8'h19] = 32'b11111011110111111111000001101111; // j   aes_128_enc_ks_l0
    // aes_128_enc_ks_finish:
    assign rom[8'h1a] = 32'b00000101100000000000010100010011; // la  a0,  round_key
    // aes_128_encrypt:
    assign rom[8'h1b] = 32'b00000000101000000000011110010011; // li    a5,  10
    assign rom[8'h1c] = 32'b00000000010001111001100000010011; // slli  a6,  a5,  4
    assign rom[8'h1d] = 32'b00000000101010000000100000110011; // add   a6,  a6,  a0
    assign rom[8'h1e] = 32'b00000010100000000000100010010011; // la    a7,  input_block
    assign rom[8'h1f] = 32'b00000000000010001010100100000011; // lw    s2,   0(a7)
    assign rom[8'h20] = 32'b00000000010010001010100110000011; // lw    s3,   4(a7)
    assign rom[8'h21] = 32'b00000000100010001010101000000011; // lw    s4,   8(a7)
    assign rom[8'h22] = 32'b00000000110010001010101010000011; // lw    s5,  12(a7)
    assign rom[8'h23] = 32'b00000000000001010010101100000011; // lw    s6,  0(a0)
    assign rom[8'h24] = 32'b00000000010001010010101110000011; // lw    s7,  4(a0)
    assign rom[8'h25] = 32'b00000000100001010010110000000011; // lw    s8,  8(a0)
    assign rom[8'h26] = 32'b00000000110001010010110010000011; // lw    s9, 12(a0)
    assign rom[8'h27] = 32'b00000001011010010100100100110011; // xor   s2,  s2,  s6
    assign rom[8'h28] = 32'b00000001011110011100100110110011; // xor   s3,  s3,  s7
    assign rom[8'h29] = 32'b00000001100010100100101000110011; // xor   s4,  s4,  s8
    assign rom[8'h2a] = 32'b00000001100110101100101010110011; // xor   s5,  s5,  s9
    assign rom[8'h2b] = 32'b00000001000001010000010100010011; // addi  a0,  a0,  16
    assign rom[8'h2c] = 32'b00001111111100000000000110010011; // li    gp,  0xFF
    // aes_enc_block_loop:
    assign rom[8'h2d] = 32'b00000111001110010000101101111111; // subshift  s6,  s2,  s3
    assign rom[8'h2e] = 32'b00000111010110100000101111111111; // subshift  s7,  s3,  s5
    assign rom[8'h2f] = 32'b00000111010010011000110001111111; // subshift  s8,  s4,  s4
    assign rom[8'h30] = 32'b00000111001010101000110011111111; // subshift  s9,  s5,  s2
    assign rom[8'h31] = 32'b00001001011110110000100101111111; // shiftmix  s2,  s6,  s7
    assign rom[8'h32] = 32'b00001001100111000000100111111111; // shiftmix  s3,  s7,  s9
    assign rom[8'h33] = 32'b00001001011010111000101001111111; // shiftmix  s4,  s8,  s6
    assign rom[8'h34] = 32'b00001001100011001000101011111111; // shiftmix  s5,  s9,  s8
    assign rom[8'h35] = 32'b00000000000001010010101100000011; // lw    s6,   0(a0)
    assign rom[8'h36] = 32'b00000000010001010010101110000011; // lw    s7,   4(a0)
    assign rom[8'h37] = 32'b00000000100001010010110000000011; // lw    s8,   8(a0)
    assign rom[8'h38] = 32'b00000000110001010010110010000011; // lw    s9,  12(a0)
    assign rom[8'h39] = 32'b00000001011010010100100100110011; // xor   s2,  s2,  s6
    assign rom[8'h3a] = 32'b00000001011110011100100110110011; // xor   s3,  s3,  s7
    assign rom[8'h3b] = 32'b00000001100010100100101000110011; // xor   s4,  s4,  s8
    assign rom[8'h3c] = 32'b00000001100110101100101010110011; // xor   s5,  s5,  s9
    assign rom[8'h3d] = 32'b00000001000001010000010100010011; // addi  a0,  a0,  16
    assign rom[8'h3e] = 32'b11111011000001010001111011100011; // bne   a0,  a6,  aes_enc_block_loop
    // aes_enc_block_finish:
    assign rom[8'h3f] = 32'b11111111111111110000110110110111; // li   s11, 0xFFFF0000 (lui s11, %hi(0xFFFF0000))
    assign rom[8'h40] = 32'b00000000000011011000110110010011; // (addi s11, s11, %lo(0xFFFF0000))
    assign rom[8'h41] = 32'b11111111111111011100111000010011; // not  t3, s11
    assign rom[8'h42] = 32'b00000111001110010000101101111111; // subshift  s6,  s2,  s3
    assign rom[8'h43] = 32'b00000111010110100000101111111111; // subshift  s7,  s3,  s5
    assign rom[8'h44] = 32'b00000111010010011000110001111111; // subshift  s8,  s4,  s4
    assign rom[8'h45] = 32'b00000111001010101000110011111111; // subshift  s9,  s5,  s2
    assign rom[8'h46] = 32'b00000001110010110111110100110011; // and  s10,  s6,  t3
    assign rom[8'h47] = 32'b00000001101110111111100100110011; // and  s2,   s7,  s11
    assign rom[8'h48] = 32'b00000001101010010110100100110011; // or   s2,   s2,  s10
    assign rom[8'h49] = 32'b00000001110011000111110100110011; // and  s10,  s8,  t3
    assign rom[8'h4a] = 32'b00000001101111001111100110110011; // and  s3,   s9,  s11
    assign rom[8'h4b] = 32'b00000001101010011110100110110011; // or   s3,   s3,  s10
    assign rom[8'h4c] = 32'b00000001110010111111110100110011; // and  s10,  s7,  t3
    assign rom[8'h4d] = 32'b00000001101110110111101000110011; // and  s4,   s6,  s11
    assign rom[8'h4e] = 32'b00000001101010100110101000110011; // or   s4,   s4,  s10
    assign rom[8'h4f] = 32'b00000001110011001111110100110011; // and  s10,  s9,  t3
    assign rom[8'h50] = 32'b00000001101111000111101010110011; // and  s5,   s8,  s11
    assign rom[8'h51] = 32'b00000001101010101110101010110011; // or   s5,   s5,  s10
    assign rom[8'h52] = 32'b00000000000001010010101100000011; // lw   s6,   0(a0)
    assign rom[8'h53] = 32'b00000000010001010010101110000011; // lw   s7,   4(a0)
    assign rom[8'h54] = 32'b00000000100001010010110000000011; // lw   s8,   8(a0)
    assign rom[8'h55] = 32'b00000000110001010010110010000011; // lw   s9,  12(a0)
    assign rom[8'h56] = 32'b00000001011010010100100100110011; // xor  s2,  s2,  s6
    assign rom[8'h57] = 32'b00000001011110011100100110110011; // xor  s3,  s3,  s7
    assign rom[8'h58] = 32'b00000001100010100100101000110011; // xor  s4,  s4,  s8
    assign rom[8'h59] = 32'b00000001100110101100101010110011; // xor  s5,  s5,  s9
    assign rom[8'h5a] = 32'b00000011100000000000100010010011; // la   a7,  output_block
    assign rom[8'h5b] = 32'b00000001001010001010000000100011; // sw   s2,   0(a7)
    assign rom[8'h5c] = 32'b00000001001110001010001000100011; // sw   s3,   4(a7)
    assign rom[8'h5d] = 32'b00000001010010001010010000100011; // sw   s4,   8(a7)
    assign rom[8'h5e] = 32'b00000001010110001010011000100011; // sw   s5,  12(a7)
    // aes_128_decrypt:
    assign rom[8'h5f] = 32'b00000101100000000000100000010011; // la  a6,  round_key
    assign rom[8'h60] = 32'b00000000101000000000011110010011; // li    a5,  10
    assign rom[8'h61] = 32'b00000000010001111001010100010011; // slli  a0,  a5,  4
    assign rom[8'h62] = 32'b00000001000001010000010100110011; // add   a0,  a0,  a6
    assign rom[8'h63] = 32'b00000011100000000000100010010011; // la    a7,  output_block
    assign rom[8'h64] = 32'b00000000000010001010100100000011; // lw    s2,   0(a7)
    assign rom[8'h65] = 32'b00000000010010001010100110000011; // lw    s3,   4(a7)
    assign rom[8'h66] = 32'b00000000100010001010101000000011; // lw    s4,   8(a7)
    assign rom[8'h67] = 32'b00000000110010001010101010000011; // lw    s5,  12(a7)
    assign rom[8'h68] = 32'b00000000000001010010101100000011; // lw    s6,   0(a0)
    assign rom[8'h69] = 32'b00000000010001010010101110000011; // lw    s7,   4(a0)
    assign rom[8'h6a] = 32'b00000000100001010010110000000011; // lw    s8,   8(a0)
    assign rom[8'h6b] = 32'b00000000110001010010110010000011; // lw    s9,  12(a0)
    assign rom[8'h6c] = 32'b00000001011010010100100100110011; // xor   s2,  s2,  s6
    assign rom[8'h6d] = 32'b00000001011110011100100110110011; // xor   s3,  s3,  s7
    assign rom[8'h6e] = 32'b00000001100010100100101000110011; // xor   s4,  s4,  s8
    assign rom[8'h6f] = 32'b00000001100110101100101010110011; // xor   s5,  s5,  s9
    assign rom[8'h70] = 32'b11111111000001010000010100010011; // addi  a0,  a0,  -16
    assign rom[8'h71] = 32'b00001111111100000000000110010011; // li    gp,  0xFF
    // aes_dec_block_loop:
    assign rom[8'h72] = 32'b00000111010110010001101101111111; // invsubshift  s6,  s2,  s5
    assign rom[8'h73] = 32'b00000111001010011001101111111111; // invsubshift  s7,  s3,  s2
    assign rom[8'h74] = 32'b00000111001110100001110001111111; // invsubshift  s8,  s4,  s3
    assign rom[8'h75] = 32'b00000111010010101001110011111111; // invsubshift  s9,  s5,  s4
    assign rom[8'h76] = 32'b00001001100010110001100101111111; // invshiftmix  s2,  s6,  s8
    assign rom[8'h77] = 32'b00001001100110111001100111111111; // invshiftmix  s3,  s7,  s9
    assign rom[8'h78] = 32'b00001001011011000001101001111111; // invshiftmix  s4,  s8,  s6
    assign rom[8'h79] = 32'b00001001011111001001101011111111; // invshiftmix  s5,  s9,  s7
    assign rom[8'h7a] = 32'b00000000000001010010101100000011; // lw  s6,   0(a0)
    assign rom[8'h7b] = 32'b00000000010001010010101110000011; // lw  s7,   4(a0)
    assign rom[8'h7c] = 32'b00000000100001010010110000000011; // lw  s8,   8(a0)
    assign rom[8'h7d] = 32'b00000000110001010010110010000011; // lw  s9,  12(a0)
    assign rom[8'h7e] = 32'b00001001011010110001101101111111; // invshiftmix  s6,  s6,  s6
    assign rom[8'h7f] = 32'b00001001011110111001101111111111; // invshiftmix  s7,  s7,  s7
    assign rom[8'h80] = 32'b00001001100011000001110001111111; // invshiftmix  s8,  s8,  s8
    assign rom[8'h81] = 32'b00001001100111001001110011111111; // invshiftmix  s9,  s9,  s9
    assign rom[8'h82] = 32'b00000001011010010100100100110011; // xor  s2,  s2,  s6
    assign rom[8'h83] = 32'b00000001011110011100100110110011; // xor  s3,  s3,  s7
    assign rom[8'h84] = 32'b00000001100010100100101000110011; // xor  s4,  s4,  s8
    assign rom[8'h85] = 32'b00000001100110101100101010110011; // xor  s5,  s5,  s9
    assign rom[8'h86] = 32'b11111111000001010000010100010011; // addi  a0,  a0,  -16
    assign rom[8'h87] = 32'b11111011000001010001011011100011; // bne a0, a6, aes_dec_block_loop
    // aes_dec_block_finish:
    assign rom[8'h88] = 32'b11111111111111110000110110110111; // li   s11, 0xFFFF0000 (lui s11, %hi(0xFFFF0000))
    assign rom[8'h89] = 32'b00000000000011011000110110010011; // (addi s11, s11, %lo(0xFFFF0000))
    assign rom[8'h8a] = 32'b11111111111111011100111000010011; // not  t3, s11
    assign rom[8'h8b] = 32'b00000111010110010001101101111111; // invsubshift  s6,  s2,  s5
    assign rom[8'h8c] = 32'b00000111001010011001101111111111; // invsubshift  s7,  s3,  s2
    assign rom[8'h8d] = 32'b00000111001110100001110001111111; // invsubshift  s8,  s4,  s3
    assign rom[8'h8e] = 32'b00000111010010101001110011111111; // invsubshift  s9,  s5,  s4
    assign rom[8'h8f] = 32'b00000001110010110111110100110011; // and  s10,  s6,  t3
    assign rom[8'h90] = 32'b00000001101111000111100100110011; // and  s2,   s8,  s11
    assign rom[8'h91] = 32'b00000001101010010110100100110011; // or   s2,   s2,  s10
    assign rom[8'h92] = 32'b00000001110010111111110100110011; // and  s10,  s7,  t3
    assign rom[8'h93] = 32'b00000001101111001111100110110011; // and  s3,   s9,  s11
    assign rom[8'h94] = 32'b00000001101010011110100110110011; // or   s3,   s3,  s10
    assign rom[8'h95] = 32'b00000001110011000111110100110011; // and  s10,  s8,  t3
    assign rom[8'h96] = 32'b00000001101110110111101000110011; // and  s4,   s6,  s11
    assign rom[8'h97] = 32'b00000001101010100110101000110011; // or   s4,   s4,  s10
    assign rom[8'h98] = 32'b00000001110011001111110100110011; // and  s10,  s9,  t3
    assign rom[8'h99] = 32'b00000001101110111111101010110011; // and  s5,   s7,  s11
    assign rom[8'h9a] = 32'b00000001101010101110101010110011; // or   s5,   s5,  s10
    assign rom[8'h9b] = 32'b00000000000001010010101100000011; // lw   s6,   0(a0)
    assign rom[8'h9c] = 32'b00000000010001010010101110000011; // lw   s7,   4(a0)
    assign rom[8'h9d] = 32'b00000000100001010010110000000011; // lw   s8,   8(a0)
    assign rom[8'h9e] = 32'b00000000110001010010110010000011; // lw   s9,  12(a0)
    assign rom[8'h9f] = 32'b00000001011010010100100100110011; // xor  s2,  s2,  s6
    assign rom[8'ha0] = 32'b00000001011110011100100110110011; // xor  s3,  s3,  s7
    assign rom[8'ha1] = 32'b00000001100010100100101000110011; // xor  s4,  s4,  s8
    assign rom[8'ha2] = 32'b00000001100110101100101010110011; // xor  s5,  s5,  s9
    assign rom[8'ha3] = 32'b00000011100000000000100010010011; // la   a7,  output_block
    assign rom[8'ha4] = 32'b00000001001010001010000000100011; // sw   s2,   0(a7)
    assign rom[8'ha5] = 32'b00000001001110001010001000100011; // sw   s3,   4(a7)
    assign rom[8'ha6] = 32'b00000001010010001010010000100011; // sw   s4,   8(a7)
    assign rom[8'ha7] = 32'b00000001010110001010011000100011; // sw   s5,  12(a7)
    assign rom[8'ha8] = 32'b00000000000000001000000001100111; // jr   ra
    assign rom[8'ha9] = 32'b00000000000000000000000000000000; // 
    assign rom[8'haa] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hab] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hac] = 32'b00000000000000000000000000000000; // 
    assign rom[8'had] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hae] = 32'b00000000000000000000000000000000; // 
    assign rom[8'haf] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hb0] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hb1] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hb2] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hb3] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hb4] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hb5] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hb6] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hb7] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hb8] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hb9] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hba] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hbb] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hbc] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hbd] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hbe] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hbf] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hc0] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hc1] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hc2] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hc3] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hc4] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hc5] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hc6] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hc7] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hc8] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hc9] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hca] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hcb] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hcc] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hcd] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hce] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hcf] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hd0] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hd1] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hd2] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hd3] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hd4] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hd5] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hd6] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hd7] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hd8] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hd9] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hda] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hdb] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hdc] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hdd] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hde] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hdf] = 32'b00000000000000000000000000000000; // 
    assign rom[8'he0] = 32'b00000000000000000000000000000000; // 
    assign rom[8'he1] = 32'b00000000000000000000000000000000; // 
    assign rom[8'he2] = 32'b00000000000000000000000000000000; // 
    assign rom[8'he3] = 32'b00000000000000000000000000000000; // 
    assign rom[8'he4] = 32'b00000000000000000000000000000000; // 
    assign rom[8'he5] = 32'b00000000000000000000000000000000; // 
    assign rom[8'he6] = 32'b00000000000000000000000000000000; // 
    assign rom[8'he7] = 32'b00000000000000000000000000000000; // 
    assign rom[8'he8] = 32'b00000000000000000000000000000000; // 
    assign rom[8'he9] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hea] = 32'b00000000000000000000000000000000; // 
    assign rom[8'heb] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hec] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hed] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hee] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hef] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hf0] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hf1] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hf2] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hf3] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hf4] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hf5] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hf6] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hf7] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hf8] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hf9] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hfa] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hfb] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hfc] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hfd] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hfe] = 32'b00000000000000000000000000000000; // 
    assign rom[8'hff] = 32'b00000000000000000000000000000000; // 
    assign inst = rom[a[9:2]];
endmodule