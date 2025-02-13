.data
aes_round_const:
   .word 0x01
   .word 0x02
   .word 0x04
   .word 0x08
   .word 0x10
   .word 0x20
   .word 0x40
   .word 0x80
   .word 0x1b
   .word 0x36
input_block:
   # 暗号化対象のデータ
   .word 0x53495459  # SITY
   .word 0x49564552  # IVER
   .word 0x4920554e  # I UN
   .word 0x484f5345  # HOSE
output_block:
   .zero 16
initial_key:
   .word 0x2a2388a0  # C0 初期鍵
   .word 0x6ca354fa  # C1 初期鍵
   .word 0x76392cfe  # C2 初期鍵
   .word 0x0539b117  # C3 初期鍵
round_key:
   .zero 4

.text
aes_128_enc_key_schedule:
   # 初期鍵をロードする (C0, C1, C2, C3)
   la  t0,  initial_key  # t0に初期鍵のアドレスをロード
   lw  a1,   0(t0)       # C0 = 初期鍵[0]
   lw  a2,   4(t0)       # C1 = 初期鍵[1]
   lw  a3,   8(t0)       # C2 = 初期鍵[2]
   lw  a4,  12(t0)       # C3 = 初期鍵[3]
   # ラウンド鍵生成のループの準備
   la    a0,  round_key  # a0にラウンド鍵のアドレスをロード
   addi  t0,  a0,  160   # t0 = a0 + 160 (40ワード = 160バイト)
   la    t1,  aes_round_const  # t1にラウンド定数のアドレスをロード
aes_128_enc_ks_l0:
   # 現在のラウンド鍵 (C0, C1, C2, C3) を保存
   sw  a1,   0(a0)  # C0
   sw  a2,   4(a0)  # C1
   sw  a3,   8(a0)  # C2
   sw  a4,  12(a0)  # C3
   # ラウンド鍵がt0に到達したら終了
   beq  a0,  t0,  aes_128_enc_ks_finish
   addi  a0,  a0,  16  # a0を16バイト進める
   # ラウンド定数のバイトをロード
   lbu   t2,  0(t1)    # ラウンド定数
   addi  t1,  t1,  4   # 次のラウンド定数のアドレス
   xor   a1,  a1,  t2  # C0にラウンド定数をXOR
   # C3を右に8ビットローテート
   slli  s0,  a4,  24     # T1 = C3 << 24
   srli  s1,  a4,  8      # T2 = C3 >> 8
   or    s0,  s0,  s1     # T1 = (C3 << 24) | (C3 >> 8)
   # T1に対してS-boxを適用
   ss  a1,  a1,  s0,  0 
   ss  a1,  a1,  s0,  1 
   ss  a1,  a1,  s0,  2
   ss  a1,  a1,  s0,  3
   # C1, C2, C3を順にXORしてラウンド鍵を生成
   xor  a2,  a2,  a1  # C1 ^= C0
   xor  a3,  a3,  a2  # C2 ^= C1
   xor  a4,  a4,  a3  # C3 ^= C2
   # ループの最初に戻る
   j   aes_128_enc_ks_l0
aes_128_enc_ks_finish:
   la  a0,  round_key   # a0にラウンド鍵のアドレスをロード
aes_128_encrypt:
   # 平文をロード
   li    a5,  10
   slli  a6,  a5,  4
   add   a6,  a6,  a0
   la    a7,  input_block
   lw    s2,   0(a7)  # 平文ブロックのロード (P0)
   lw    s3,   4(a7)  # 平文ブロックのロード (P1)
   lw    s4,   8(a7)  # 平文ブロックのロード (P2)
   lw    s5,  12(a7)  # 平文ブロックのロード (P3)
   # 最初のラウンド鍵をロードしてAddRoundKey
   lw    s6,   0(a0)   # ラウンド鍵 K0
   lw    s7,   4(a0)   # ラウンド鍵 K1
   lw    s8,   8(a0)   # ラウンド鍵 K2
   lw    s9,  12(a0)   # ラウンド鍵 K3
   xor   s2,  s2,  s6  # P0 ^= K0
   xor   s3,  s3,  s7  # P1 ^= K1
   xor   s4,  s4,  s8  # P2 ^= K2
   xor   s5,  s5,  s9  # P3 ^= K3
aes_enc_block_loop:
   # ラウンド鍵をロード
   lw   s6,   0(a0)  # ラウンド鍵 K0
   lw   s7,   4(a0)  # ラウンド鍵 K1
   lw   s8,   8(a0)  # ラウンド鍵 K2
   lw   s9,  12(a0)  # ラウンド鍵 K3
   ssm  s6,  s6,  s2,  0
   ssm  s7,  s7,  s3,  0
   ssm  s8,  s8,  s4,  0
   ssm  s9,  s9,  s5,  0
   ssm  s6,  s6,  s3,  1
   ssm  s7,  s7,  s4,  1
   ssm  s8,  s8,  s5,  1
   ssm  s9,  s9,  s2,  1
   ssm  s6,  s6,  s4,  2
   ssm  s7,  s7,  s5,  2
   ssm  s8,  s8,  s2,  2
   ssm  s9,  s9,  s3,  2
   ssm  s6,  s6,  s5,  3
   ssm  s7,  s7,  s2,  3
   ssm  s8,  s8,  s3,  3
   ssm  s9,  s9,  s4,  3
   # ラウンド鍵をロード
   lw   s2,  32(a0)  # ラウンド鍵 K0
   lw   s3,  36(a0)  # ラウンド鍵 K1
   lw   s4,  40(a0)  # ラウンド鍵 K2
   lw   s5,  44(a0)  # ラウンド鍵 K3
   addi a0,  a0,  32
   beq  a0, a6, aes_enc_block_finish
   ssm  s2,  s2,  s6,  0
   ssm  s3,  s3,  s7,  0
   ssm  s4,  s4,  s8,  0
   ssm  s5,  s5,  s9,  0
   ssm  s2,  s2,  s7,  1
   ssm  s3,  s3,  s8,  1
   ssm  s4,  s4,  s9,  1
   ssm  s5,  s5,  s6,  1
   ssm  s2,  s2,  s8,  2
   ssm  s3,  s3,  s9,  2
   ssm  s4,  s4,  s6,  2
   ssm  s5,  s5,  s7,  2
   ssm  s2,  s2,  s9,  3
   ssm  s3,  s3,  s6,  3
   ssm  s4,  s4,  s7,  3
   ssm  s5,  s5,  s8,  3
   j   aes_enc_block_loop
aes_enc_block_finish:
   ss  s2,  s2,  s6,  0
   ss  s3,  s3,  s7,  0
   ss  s4,  s4,  s8,  0
   ss  s5,  s5,  s9,  0
   ss  s2,  s2,  s7,  1
   ss  s3,  s3,  s8,  1
   ss  s4,  s4,  s9,  1
   ss  s5,  s5,  s6,  1
   ss  s2,  s2,  s8,  2
   ss  s3,  s3,  s9,  2
   ss  s4,  s4,  s6,  2
   ss  s5,  s5,  s7,  2
   ss  s2,  s2,  s9,  3
   ss  s3,  s3,  s6,  3
   ss  s4,  s4,  s7,  3
   ss  s5,  s5,  s8,  3
   la  a7,  output_block
   sw  s2,   0(a7) 
   sw  s3,   4(a7) 
   sw  s4,   8(a7) 
   sw  s5,  12(a7)
aes_128_decrypt:
   la  a6,  round_key
   # 暗号文をロード
   li    a5,  10
   slli  a0,  a5,  4
   add   a0,  a0,  a6
   la    a7,  output_block
   lw    s2,   0(a7)  # 暗号文ブロックのロード (P0)
   lw    s3,   4(a7)  # 暗号文ブロックのロード (P1)
   lw    s4,   8(a7)  # 暗号文ブロックのロード (P2)
   lw    s5,  12(a7)  # 暗号文ブロックのロード (P3)
   # 最初のラウンド鍵をロードしてAddRoundKey
   lw    s6,   0(a0)   # ラウンド鍵 K0
   lw    s7,   4(a0)   # ラウンド鍵 K1
   lw    s8,   8(a0)   # ラウンド鍵 K2
   lw    s9,  12(a0)   # ラウンド鍵 K3
   xor   s2,  s2,  s6  # P0 ^= K0
   xor   s3,  s3,  s7  # P1 ^= K1
   xor   s4,  s4,  s8  # P2 ^= K2
   xor   s5,  s5,  s9  # P3 ^= K3
   addi  a0,  a0,  -32  # a0を16バイト戻す
aes_dec_block_loop:
   # ラウンド鍵をロードしてAddRoundKey
   lw  s6,  16(a0)   # ラウンド鍵 K0
   lw  s7,  20(a0)   # ラウンド鍵 K1
   lw  s8,  24(a0)   # ラウンド鍵 K2
   lw  s9,  28(a0)   # ラウンド鍵 K3
   ss  s10, zero,  s6,  0
   ss  s10,  s10,  s6,  1
   ss  s10,  s10,  s6,  2
   ss  s10,  s10,  s6,  3
   issm  s6, zero,  s10,  0
   issm  s6,   s6,  s10,  1
   issm  s6,   s6,  s10,  2
   issm  s6,   s6,  s10,  3
   ss  s10, zero,  s7,  0
   ss  s10,  s10,  s7,  1
   ss  s10,  s10,  s7,  2
   ss  s10,  s10,  s7,  3
   issm  s7, zero,  s10,  0
   issm  s7,   s7,  s10,  1
   issm  s7,   s7,  s10,  2
   issm  s7,   s7,  s10,  3
   ss  s10, zero,  s8,  0
   ss  s10,  s10,  s8,  1
   ss  s10,  s10,  s8,  2
   ss  s10,  s10,  s8,  3
   issm  s8, zero,  s10,  0
   issm  s8,   s8,  s10,  1
   issm  s8,   s8,  s10,  2
   issm  s8,   s8,  s10,  3
   ss  s10, zero,  s9, 0
   ss  s10,  s10,  s9, 1
   ss  s10,  s10,  s9, 2
   ss  s10,  s10,  s9, 3
   issm  s9, zero,  s10, 0
   issm  s9,   s9,  s10, 1
   issm  s9,   s9,  s10, 2
   issm  s9,   s9,  s10, 3
   issm  s6,   s6,  s2,  0
   issm  s7,   s7,  s3,  0
   issm  s8,   s8,  s4,  0
   issm  s9,   s9,  s5,  0
   issm  s6,   s6,  s3,  1
   issm  s7,   s7,  s4,  1
   issm  s8,   s8,  s5,  1
   issm  s9,   s9,  s2,  1
   issm  s6,   s6,  s4,  2
   issm  s7,   s7,  s5,  2
   issm  s8,   s8,  s2,  2
   issm  s9,   s9,  s3,  2
   issm  s6,   s6,  s5,  3
   issm  s7,   s7,  s2,  3
   issm  s8,   s8,  s3,  3
   issm  s9,   s9,  s4,  3
   lw    s2,  0(a0)  # ラウンド鍵 K0
   lw    s3,  4(a0)  # ラウンド鍵 K1
   lw    s4,  8(a0)  # ラウンド鍵 K2
   lw    s5, 12(a0)  # ラウンド鍵 K3
   bne   a0, a6, aes_dec_block_loop
   addi  a0,  a0,  -32  # a0を16バイト戻す
   ss  s10,  zero,  s2,  0
   ss  s10,   s10,  s2,  1
   ss  s10,   s10,  s2,  2
   ss  s10,   s10,  s2,  3
   issm  s2, zero, s10, 0
   issm  s2,   s2, s10, 1
   issm  s2,   s2, s10, 2
   issm  s2,   s2, s10, 3
   ss    s10, zero,  s3, 0
   ss    s10,  s10,  s3, 1
   ss    s10,  s10,  s3, 2
   ss    s10,  s10,  s3, 3
   issm  s3, zero, s10, 0
   issm  s3,   s3, s10, 1
   issm  s3,   s3, s10, 2
   issm  s3,   s3, s10, 3
   ss    s10, zero,  s4, 0
   ss    s10,  s10,  s4, 1
   ss    s10,  s10,  s4, 2
   ss    s10,  s10,  s4, 3
   issm  s4, zero, s10, 0
   issm  s4,   s4, s10, 1
   issm  s4,   s4, s10, 2
   issm  s4,   s4, s10, 3
   ss    s10, zero,  s5, 0
   ss    s10,  s10,  s5, 1
   ss    s10,  s10,  s5, 2
   ss    s10,  s10,  s5, 3
   issm  s5, zero, s10, 0
   issm  s5,   s5, s10, 1
   issm  s5,   s5, s10, 2
   issm  s5,   s5, s10, 3
   issm  s2, s2, s6, 0
   issm  s3, s3, s7, 0
   issm  s4, s4, s8, 0
   issm  s5, s5, s9, 0
   issm  s2, s2, s7, 1
   issm  s3, s3, s8, 1
   issm  s4, s4, s9, 1
   issm  s5, s5, s6, 1
   issm  s2, s2, s8, 2
   issm  s3, s3, s9, 2
   issm  s4, s4, s6, 2
   issm  s5, s5, s7, 2
   issm  s2, s2, s9, 3
   issm  s3, s3, s6, 3
   issm  s4, s4, s7, 3
   issm  s5, s5, s8, 3
   j  aes_dec_block_loop
aes_dec_block_finish:
   iss  s2, s2, s6, 0
   iss  s3, s3, s7, 0
   iss  s4, s4, s8, 0
   iss  s5, s5, s9, 0
   iss  s2, s2, s7, 1
   iss  s3, s3, s8, 1
   iss  s4, s4, s9, 1
   iss  s5, s5, s6, 1
   iss  s2, s2, s8, 2
   iss  s3, s3, s9, 2
   iss  s4, s4, s6, 2
   iss  s5, s5, s7, 2
   iss  s2, s2, s9, 3
   iss  s3, s3, s6, 3
   iss  s4, s4, s7, 3
   iss  s5, s5, s8, 3
   la   a7,  output_block
   sw   s2,   0(a7) 
   sw   s3,   4(a7) 
   sw   s4,   8(a7) 
   sw   s5,  12(a7)
   jr   ra
.end