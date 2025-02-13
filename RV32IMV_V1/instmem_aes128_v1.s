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
   li  s1, 4  #num of elem
   vsetvli s0, s1, e32
   # 初期鍵をロードする (C0, C1, C2, C3)
   la  t0,  initial_key  # t0に初期鍵のアドレスをロード
   vle32  v2,  t0        # 初期鍵
   # ラウンド鍵生成のループの準備
   la    a0,  round_key  # a0にラウンド鍵のアドレスをロード
   addi  t0,  a0,  160   # t0 = a0 + 160 (40ワード = 160バイト)
   la    t1,  aes_round_const  # t1にラウンド定数のアドレスをロード
aes_128_enc_ks_l0:
   # 現在のラウンド鍵を保存
   vse32  v2,  a0
   # ラウンド鍵がt0に到達したら終了
   beq   a0,  t0,  aes_128_enc_ks_finish
   addi  a0,  a0,  16  # a0を16バイト進める
   # ラウンド定数のバイトをロード
   lbu   t2,  0(t1)   # ラウンド定数
   addi  t1,  t1,  4  # 次のラウンド定数のアドレス
   vaddrk.vx  v2,  v2,  t2  #ラウンド鍵を生成
   # ループの最初に戻る
   j  aes_128_enc_ks_l0
aes_128_enc_ks_finish:
   la  a0, round_key  # a0にラウンド鍵のアドレスをロード
aes_128_encrypt:
   # 平文をロード
   li    a5, 10
   slli  a6, a5, 4
   add   a6, a6, a0
   la    a7, input_block
   vle32.v  v1,  a7  # 平文ブロックのロード
   # 最初のラウンド鍵をロードしてAddRoundKey
   vle32.v  v3,  a0  # ラウンド鍵 
   vxor.vv  v1,  v1,  v3
   addi  a0,  a0,  16  # a0を16バイト進める
aes_enc_block_loop:
   vsubbytes.v    v1,  v1
   vshiftrows.v   v1,  v1
   vmixColumns.v  v1,  v1
   # ラウンド鍵をロードしてAddRoundKey
   vle32.v  v3,  a0  # ラウンド鍵
   vxor.vv  v1,  v1,  v3
   addi  a0,  a0,  16  # a0を16バイト進める
   bne   a0,  a6,  aes_enc_block_loop
aes_enc_block_finish:
   vsubbytes.v   v1,  v1
   vshiftrows.v  v1,  v1
   # ラウンド鍵をロードしてAddRoundKey
   vle32.v  v3,  a0  # ラウンド鍵
   vxor.vv  v1,  v1,  v3
   la  a7,  output_block
   vse32.v  v1,  a7
aes_128_decrypt:
   la  a6,  round_key
   # 暗号文をロード
   li    a5,  10
   slli  a0,  a5,  4
   add   a0,  a0,  a6
   la    a7,  output_block
   vle32.v   v1,   a7  # 暗号文ブロックのロード
   # 最初のラウンド鍵をロードしてAddRoundKey
   vle32.v  v3,  a0  # ラウンド鍵 
   vxor.vv  v1,  v1,  v3
   addi  a0,  a0,  -16  # a0を16バイト戻す
aes_dec_block_loop:
   vinvshiftrows.v  v1,  v1
   vinvsubbytes.v   v1,  v1
   # ラウンド鍵をロードしてAddRoundKey
   vle32.v  v3,  a0  # ラウンド鍵 
   vxor.vv  v1,  v1,  v3
   vinvmixcolumns.v  v1,  v1
   addi  a0,  a0,  -16  # a0を16バイト戻す
   bne   a0,  a6,  aes_dec_block_loop
aes_dec_block_finish:
   vinvshiftrows.v  v1,  v1
   vinvsubbytes.v   v1,  v1
   # ラウンド鍵をロードしてAddRoundKey
   vle32.v  v3,  a0  # ラウンド鍵 
   vxor.vv  v1,  v1,  v3
   la  a7, output_block
   vse32.v  v1,  a7
   jr  ra
.end