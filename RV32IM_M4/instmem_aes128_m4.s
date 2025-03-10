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
   li      t5, 0xFFFF0000
   not     t6, t5
   # ラウンド鍵生成のループの準備
   la    a0,  round_key  # a0にラウンド鍵のアドレスをロード
   addi  t0,  a0,  160   # t0 = a0 + 160 (40ワード = 160バイト)
   la    t1,  aes_round_const  # t1にラウンド定数のアドレスをロード
aes_128_enc_ks_l0:
   # 現在のラウンド鍵 (C0, C1, C2, C3) を保存
   and     t3 , a2, t6
   slli    t4, a1, 16
   or     t3 , t3 , t4
   sw      t3,  0(a0)          # C0
   and     t3 , a4, t6
   slli    t4, a3, 16
   or     t3 , t3 , t4
   sw      t3,  4(a0)          # C1
   and     t3 , a1, t5
   srli    t4, a2, 16
   or     t3 , t3 , t4
   sw      t3,  8(a0)          # C2
   and     t3 , a3, t5
   srli    t4, a4, 16
   or     t3 , t3 , t4
   sw      t3, 12(a0)          # C3
   # ラウンド鍵がt0に到達したら終了
   beq  a0,  t0,  aes_128_enc_ks_finish
   addi  a0,  a0,  16  # a0を16バイト進める
   # ラウンド定数のバイトをロード
   lbu   t2,  0(t1)    # ラウンド定数
   addi  t1,  t1,  4   # 次のラウンド定数のアドレス
   xor   a1,  a1,  t2  # C0にラウンド定数をXOR
   # C3を右に8ビットローテート
   slli  s0,  a4,  24  # T1 = C3 << 24
   srli  s1,  a4,  8   # T2 = C3 >> 8
   or    s0,  s0,  s1  # T1 = (C3 << 24) | (C3 >> 8)
   subbytes  s0,  s0   # T1に対してS-boxを適用
   # C0, C1, C2, C3を順にXORしてラウンド鍵を生成
   xor  a1,  a1,  s0  # C0 ^= S-box(C3)
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
   lw    s6,   0(a7)  # 平文ブロックのロード (P0)
   lw    s7,   4(a7)  # 平文ブロックのロード (P1)
   lw    s8,   8(a7)  # 平文ブロックのロード (P2)
   lw    s9,  12(a7)  # 平文ブロックのロード (P3)
   and   s2,  s7,  t6
   slli  t4,  s6,  16
   or    s2,  s2,  t4
   and   s3,  s9,  t6
   slli  t4,  s8,  16
   or    s3,  s3,  t4
   and   s4,  s6,  t5
   srli  t4,  s7,  16
   or    s4,  s4,  t4
   and   s5,  s8,  t5
   srli  t4,  s9,  16
   or    s5,  s5,  t4
   # 最初のラウンド鍵をロードしてAddRoundKey
   lw    s6,  0(a0)    # ラウンド鍵 K0
   lw    s7,  4(a0)    # ラウンド鍵 K1
   lw    s8,  8(a0)    # ラウンド鍵 K2
   lw    s9, 12(a0)    # ラウンド鍵 K3
   xor   s2,  s2,  s6  # P0 ^= K0
   xor   s3,  s3,  s7  # P1 ^= K1
   xor   s4,  s4,  s8  # P2 ^= K2
   xor   s5,  s5,  s9  # P3 ^= K3
   addi  a0,  a0,  16  # a0を16バイト進める
aes_enc_block_loop:
   encsrsblo  s6,  s2,  s3  # SubBytes / ShiftRows
   encsrsblo  s7,  s3,  s2
   encsrsbhi  s8,  s4,  s5
   encsrsbhi  s9,  s5,  s4
   encmix     s2,  s6,  s8  #  MixColumns
   encmix     s3,  s7,  s9
   encmix     s4,  s8,  s6
   encmix     s5,  s9,  s7
   # ラウンド鍵をロードしてAddRoundKey
   lw    s6,   0(a0)   # ラウンド鍵 K0
   lw    s7,   4(a0)   # ラウンド鍵 K1
   lw    s8,   8(a0)   # ラウンド鍵 K2
   lw    s9,  12(a0)   # ラウンド鍵 K3
   xor   s2,  s2,  s6  # P0 ^= K0
   xor   s3,  s3,  s7  # P1 ^= K1
   xor   s4,  s4,  s8  # P2 ^= K2
   xor   s5,  s5,  s9  # P3 ^= K3
   addi  a0,  a0,  16  # a0を16バイト進める
   bne   a0,  a6,  aes_enc_block_loop
aes_enc_block_finish:
   encsrsblo  s6,  s2,  s3  # SubBytes / ShiftRows
   encsrsblo  s7,  s3,  s2
   encsrsbhi  s8,  s4,  s5
   encsrsbhi  s9,  s5,  s4
   # ラウンド鍵をロードしてAddRoundKey
   lw    s2,   0(a0)   # ラウンド鍵 K0
   lw    s3,   4(a0)   # ラウンド鍵 K1
   lw    s4,   8(a0)   # ラウンド鍵 K2
   lw    s5,  12(a0)   # ラウンド鍵 K3
   xor   s6,  s6,  s2  # P0 ^= K0
   xor   s7,  s7,  s3  # P1 ^= K1
   xor   s8,  s8,  s4  # P2 ^= K2
   xor   s9,  s9,  s5  # P3 ^= K3
   and   s2,  s8,  t5
   srli  t4,  s6,  16
   or    s2,  s2,  t4
   and   s3,  s6,  t6
   slli  t4,  s8,  16
   or    s3,  s3,  t4
   and   s4,  s9,  t5
   srli  t4,  s7,  16
   or    s4,  s4,  t4
   and   s5,  s7,  t6
   slli  t4,  s9,  16
   or    s5,  s5,  t4
   la   a7,  output_block
   sw   s2,   0(a7) 
   sw   s3,   4(a7) 
   sw   s4,   8(a7) 
   sw   s5,  12(a7)
aes_128_decrypt:
   la  a6,  round_key
   # 暗号文をロード
   li    a5,  10
   slli  a0,  a5,  4
   add   a0,  a0,  a6
   la    a7,  output_block
   lw    s6,   0(a7)  # 暗号文ブロックのロード (P0)
   lw    s7,   4(a7)  # 暗号文ブロックのロード (P1)
   lw    s8,   8(a7)  # 暗号文ブロックのロード (P2)
   lw    s9,  12(a7)  # 暗号文ブロックのロード (P3)
   and   s2,  s7,  t6
   slli  t4,  s6,  16
   or    s2,  s2,  t4
   and   s3,  s9,  t6
   slli  t4,  s8,  16
   or    s3,  s3,  t4
   and   s4,  s6,  t5
   srli  t4,  s7,  16
   or    s4,  s4,  t4
   and   s5,  s8,  t5
   srli  t4,  s9,  16
   or    s5,  s5,  t4
   # 最初のラウンド鍵をロードしてAddRoundKey
   lw    s6,   0(a0)   # ラウンド鍵 K0
   lw    s7,   4(a0)   # ラウンド鍵 K1
   lw    s8,   8(a0)   # ラウンド鍵 K2
   lw    s9,  12(a0)   # ラウンド鍵 K3
   xor   s2,  s2,  s6  # P0 ^= K0
   xor   s3,  s3,  s7  # P1 ^= K1
   xor   s4,  s4,  s8  # P2 ^= K2
   xor   s5,  s5,  s9  # P3 ^= K3
   addi  a0,  a0,  -16  # a0を16バイト戻す
   decsrsblo  s6,  s2,  s3  # InvSubBytes / InvShiftRows
   decsrsblo  s7,  s3,  s2
   decsrsbhi  s8,  s4,  s5
   decsrsbhi  s9,  s5,  s4
aes_dec_block_loop:
   # ラウンド鍵をロードしてAddRoundKey
   lw   s2,   0(a0)   # ラウンド鍵 K0
   lw   s3,   4(a0)   # ラウンド鍵 K1
   lw   s4,   8(a0)   # ラウンド鍵 K2
   lw   s5,  12(a0)   # ラウンド鍵 K3
   xor  s6,  s6,  s2  # P0 ^= K0
   xor  s7,  s7,  s3  # P1 ^= K1
   xor  s8,  s8,  s4  # P2 ^= K2
   xor  s9,  s9,  s5  # P3 ^= K3
   decmix     s2,  s6,  s8  #  InvMixColumns
   decmix     s3,  s7,  s9
   decmix     s4,  s8,  s6
   decmix     s5,  s9,  s7
   decsrsblo  s6,  s2,  s3  # InvSubBytes / InvShiftRows
   decsrsblo  s7,  s3,  s2
   decsrsbhi  s8,  s4,  s5
   decsrsbhi  s9,  s5,  s4
   addi  a0,  a0,  -16  # a0を16バイト戻す
   bne a0, a6, aes_dec_block_loop
aes_dec_block_finish:
   # ラウンド鍵をロードしてAddRoundKey
   lw   s6,   0(a0)   # ラウンド鍵 K0
   lw   s7,   4(a0)   # ラウンド鍵 K1
   lw   s8,   8(a0)   # ラウンド鍵 K2
   lw   s9,  12(a0)   # ラウンド鍵 K3
   xor  s2,  s2,  s6  # P0 ^= K0
   xor  s3,  s3,  s7  # P1 ^= K1
   xor  s4,  s4,  s8  # P2 ^= K2
   xor  s5,  s5,  s9  # P3 ^= K3
   and   s2,  s8,  t5
   srli  t4,  s6,  16
   or    s2,  s2,  t4
   and   s3,  s6,  t6
   slli  t4,  s8,  16
   or    s3,  s3,  t4
   and   s4,  s9,  t5
   srli  t4,  s7,  16
   or    s4,  s4,  t4
   and   s5,  s7,  t6
   slli  t4,  s9,  16
   or    s5,  s5,  t4
   la   a7,  output_block
   sw   s2,   0(a7) 
   sw   s3,   4(a7) 
   sw   s4,   8(a7) 
   sw   s5,  12(a7)
   jr   ra
.end