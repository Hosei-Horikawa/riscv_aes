module riscv_rv32imv_aes128_v2_cpu (clk,clrn,inst,mem,pc,alu_out,b,wmem,vector);
    parameter     VLEN = 128;                   // bits, hardware implementation
    input             clk, clrn;           // clock and reset
    input      [31:0] inst;                // instruction
    input  [VLEN-1:0] mem;                  // load data
    output     [31:0] pc;                  // program counter
    output reg [VLEN-1:0] alu_out;              // alu output
    output     [VLEN-1:0] b;
    output reg  [3:0] wmem;
    output reg        vector;              // for vector load

    // control signals
    reg           wreg;                    // write regfile
    reg           rmem;                    // write/read memory
    reg    [31:0] mem_out;                 // mem output
    reg    [31:0] m_addr;                  // mem address
    reg    [31:0] next_pc;                 // next pc
    reg    [31:0] d_t_mem;
    wire   [31:0] pc_plus_4 = pc + 4;      // pc + 4
    
    //matrix register   horizontal[vertical]
    integer       LMUL;                         // number of vector registers used in one instruction
    reg     [9:0] SEW;                          // selected element width
    reg     [9:0] VLMAX;                        // maximum number of elements that can be executed in one instruction
    integer       AVL;                          // number of elements specified
    wire    [7:0] wire_vlen = VLEN;
    reg     [3:0] d;

    // instruction format
    wire    [6:0] opcode = inst[6:0];   //
    wire    [2:0] func3  = inst[14:12]; //
    wire    [6:0] func7  = inst[31:25]; //
    wire    [4:0] rd     = inst[11:7];  //
    wire    [4:0] rs     = inst[19:15]; // = rs1
    wire    [4:0] rt     = inst[24:20]; // = rs2
    wire    [4:0] shamt  = inst[24:20]; // == rs2
    wire          sign   = inst[31];
    wire   [11:0] imm    = inst[31:20];
    wire    [5:0] func6  = inst[31:26]; //
    wire   [10:0] zimm   = inst[30:20];
    wire    [4:0] lsumop = inst[24:20];
    wire    [2:0] mop    = inst[28:26];
    wire    [2:0] width  = inst[14:12];
    wire    [4:0] vs1    = inst[19:15];
    wire    [4:0] vs2    = inst[24:20];
    wire    [4:0] vd     = inst[11:7];
    wire    [4:0] simm5  = inst[19:15];
    wire          vm     = inst[25];   // vector mask
    

    // branch offset            31:13          12      11       10:5         4:1     0
    wire   [31:0] broffset  = {{19{sign}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};   // beq, bne,  blt,  bge,   bltu, bgeu
    wire   [31:0] simm      = {{20{sign}},inst[31:20]};                                    // lw,  addi, slti, sltiu, xori, ori,  andi, jalr
    wire   [31:0] stimm     = {{20{sign}},inst[31:25],inst[11:7]};                         // sw
    wire   [31:0] uimm      = {inst[31:12],12'h0};                                         // lui, auipc
    wire   [31:0] jaloffset = {{11{sign}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0}; // jal
    // jal target               31:21          20       19:12       11       10:1      0

    // instruction decode
    wire i_auipc   = (opcode == 7'b0010111);
    wire i_lui     = (opcode == 7'b0110111);
    wire i_jal     = (opcode == 7'b1101111);
    wire i_jalr    = (opcode == 7'b1100111) & (func3 == 3'b000);
    wire i_beq     = (opcode == 7'b1100011) & (func3 == 3'b000);
    wire i_bne     = (opcode == 7'b1100011) & (func3 == 3'b001);
    wire i_blt     = (opcode == 7'b1100011) & (func3 == 3'b100);
    wire i_bge     = (opcode == 7'b1100011) & (func3 == 3'b101);
    wire i_bltu    = (opcode == 7'b1100011) & (func3 == 3'b110);
    wire i_bgeu    = (opcode == 7'b1100011) & (func3 == 3'b111);
    wire i_lb      = (opcode == 7'b0000011) & (func3 == 3'b000);
    wire i_lh      = (opcode == 7'b0000011) & (func3 == 3'b001);
    wire i_lw      = (opcode == 7'b0000011) & (func3 == 3'b010);
    wire i_lbu     = (opcode == 7'b0000011) & (func3 == 3'b100);
    wire i_lhu     = (opcode == 7'b0000011) & (func3 == 3'b101);
    wire i_sb      = (opcode == 7'b0100011) & (func3 == 3'b000);
    wire i_sh      = (opcode == 7'b0100011) & (func3 == 3'b001);
    wire i_sw      = (opcode == 7'b0100011) & (func3 == 3'b010);
    wire i_addi    = (opcode == 7'b0010011) & (func3 == 3'b000);
    wire i_slti    = (opcode == 7'b0010011) & (func3 == 3'b010);
    wire i_sltiu   = (opcode == 7'b0010011) & (func3 == 3'b011);
    wire i_xori    = (opcode == 7'b0010011) & (func3 == 3'b100);
    wire i_ori     = (opcode == 7'b0010011) & (func3 == 3'b110);
    wire i_andi    = (opcode == 7'b0010011) & (func3 == 3'b111);
    wire i_csrrw   = (opcode == 7'b1110011) & (func3 == 3'b001);
    wire i_slli    = (opcode == 7'b0010011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire i_srli    = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire i_srai    = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire i_add     = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000000);
    wire i_sub     = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0100000);
    wire i_sll     = (opcode == 7'b0110011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire i_slt     = (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000000);
    wire i_sltu    = (opcode == 7'b0110011) & (func3 == 3'b011) & (func7 == 7'b0000000);
    wire i_xor     = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000000);
    wire i_srl     = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire i_sra     = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire i_or      = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000000);
    wire i_and     = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000000);
    wire m_mul     = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000001);
    wire m_mulh    = (opcode == 7'b0110011) & (func3 == 3'b001) & (func7 == 7'b0000001);
    wire m_mulhsu  = (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000001);
    wire m_mulhu   = (opcode == 7'b0110011) & (func3 == 3'b011) & (func7 == 7'b0000001);
    wire m_div     = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000001);
    wire m_divu    = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0000001);
    wire m_rem     = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000001);
    wire m_remu    = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000001);
    wire v_vle32   = (opcode == 7'b0000111) & (width == 3'b110) & (lsumop == 5'b00000) & (mop == 3'b000);
    wire v_vse32   = (opcode == 7'b0100111) & (width == 3'b110) & (lsumop == 5'b00000) & (mop == 3'b000);
    wire v_vsetvli = (opcode == 7'b1010111) & (func3 == 3'b111) & (sign  == 1'b0);
    wire v_vxorvv  = (opcode == 7'b1010111) & (func3 == 3'b000) & (func6 == 6'b001011);
    
    //for aes
    wire v_vaddrkvx        = (opcode == 7'b1011011) & (func3 == 3'b100) & (func6 == 6'b100000);
    wire v_vsubshiftv      = (opcode == 7'b1011011) & (func3 == 3'b000) & (func6 == 6'b000110);
    wire v_vmixcolumnsv    = (opcode == 7'b1011011) & (func3 == 3'b000) & (func6 == 6'b000010);
    wire v_vinvsubshiftv   = (opcode == 7'b1011011) & (func3 == 3'b000) & (func6 == 6'b000111);
    wire v_vinvmixcolumnsv = (opcode == 7'b1011011) & (func3 == 3'b000) & (func6 == 6'b000101);
    
    // data written to register file
    wire        i_load = i_lw | i_lb | i_lbu | i_lh | i_lhu | i_csrrw;
    wire [31:0] data_2_rf = i_load ? mem_out : alu_out;
    
    wire        v_vstore = v_vse32;              // | ... (other v stores)
    
    // vector register file, VLEN = 128 bits, ELEN = 32 bits
    wire             v_vload = v_vle32;    // | ... (other v loads)
    reg  [VLEN-1:0]  vregfile [0:31];                 // v0 - v31, 128 bits for each
    wire             sew32 = (SEW == 32);
    wire [VLEN-1:0]  va = vregfile[vs1];              // read port 1
    wire [VLEN-1:0]  vb = vregfile[vs2];              // read port 2
    reg  [VLEN-1:0]  v_mem_out;
    reg  [VLEN-1:0]  v_alu_out;
    wire [VLEN-1:0]  v_data_2_rf  = v_vload ? v_mem_out : v_alu_out;

    // register file
    reg    [31:0] regfile [0:31];                          // x0 - x31, should be [0:31]
    wire   [31:0] a = (rs==0) ? 0 : regfile[rs];           // read port
    wire   [31:0] ap4 = a + 4;
    wire   [31:0] ap8 = a + 8;
    wire   [31:0] ap12 = a + 12;
    wire   [31:0] b32 = (rt==0) ? 0 : regfile[rt];
    wire   [VLEN-1:0] b  = (v_vstore) ? vregfile[vd] : {96'h0,b32};           // read port
    
    reg            wpc; 
    reg      [7:0] we;                                     // write enable
    
    //vector
    wire     [9:0] wid = {zimm,1'b0};     // width of data per element
    reg      [2:0] vlmul;
    reg      [2:0] vsew;
    reg            vta;
    reg            vma;
    integer        vleng;       // = vector length
    
    reg      [5:0] cnt_mul;               // count
    reg      [5:0] cnt_div;
    wire     [5:0] cnt = cnt_mul | cnt_div;
    wire           ready_mul  = ~|cnt_mul;                    // ready = 1 if cnt_mul = 0
    wire           ready_div  = ~|cnt_div;
    wire           ready = ready_mul & ready_div; // ready = 1 if cnt = 0
    reg            change_mul;
    
    // pc
    reg    [31:0]  pc;
    always @ (posedge clk or negedge clrn) begin
        if (!clrn) pc <= 0;
        else if (ready) pc <= next_pc;
    end
    
    //vset
    always @ (negedge clk or negedge clrn) begin
        if (!clrn) begin
            LMUL <= 0;
            SEW <= 0; 
            VLMAX <= 0; 
            AVL <= 0;
            we <= 0;
            d <= 0;
            vleng <= 0;
        end 
        else begin
            if (v_vsetvli) begin
                if (~|rs == 1) begin       // rs = 0 -> 1 == 1 
                    if (~|rd == 1) begin   // rs = 0, rd = 0
                    //chage the vtype
                    end 
                    else begin             // rs = 0, rd = !0
                        vleng = VLMAX;
                    end 
                end 
                else begin                // rs = !0, rd = *
                    AVL = a;
                    //VLMAX = VLEN * LMUL / SEW;
                    LMUL = 4;
                    SEW = 32;
                    VLMAX = wire_vlen >> 5;
                    if (AVL <= VLMAX) vleng = AVL;
                    // vleng = AVL / 2 + AVL % 2
                    else if (AVL < (VLMAX << 2)) vleng = AVL >> 1 + AVL[0];
                    else if (AVL >= (VLMAX << 2)) vleng = VLMAX;
                end
                d = vleng;
                case (vleng)
                    1: we <= 1'b1;
                    2: we <= 2'b11;
                    3: we <= 3'b111;
                    4: we <= 4'b1111;
                endcase
            end
        end
    end
    
    integer       h;
    always @ (posedge clk or negedge clrn) begin
        if (!clrn) begin
            for (h = 0; h < 32; h = h + 1) begin
                regfile[h] <= 0;
                vregfile[h] <= 0;
		end
        end else begin
            if (wreg && |rd) 
                regfile[rd] <= data_2_rf;                  // write port
				if (wpc) begin
                // write port
                if (we[0]) vregfile[vd][ 31:  0] <= v_data_2_rf[ 31:  0];
                if (we[1]) vregfile[vd][ 63: 32] <= v_data_2_rf[ 63: 32];
                if (we[2]) vregfile[vd][ 95: 64] <= v_data_2_rf[ 95: 64];
                if (we[3]) vregfile[vd][127: 96] <= v_data_2_rf[127: 96];
            end
        end
    end
    
    // for AES
    wire        ark = v_vaddrkvx;
    // Encrypt (0) or decrypt (1)
    wire            dec = 1 & (v_vinvsubshiftv | v_vinvmixcolumnsv);
    wire            subshift = v_vsubshiftv | v_vinvsubshiftv;
    wire            mixcolumns = v_vmixcolumnsv | v_vinvmixcolumnsv;
    wire [VLEN-1:0] aes_vc;
	 
    //mul
    reg    [63:0] mr;                                     // multiplication result
    reg           mul_fuse;
    wire          is_mul = m_mulh | m_mulhsu | m_mulhu;
    reg           re_mul;                                 // re_mul = 1 => not calculate of m_mul
    reg    [31:0] reg_a;
    reg    [31:0] reg_b;
    wire          eq_a = (reg_a == a) ? 1 : 0;
    wire          eq_b = (reg_b == b) ? 1 : 0;
    
    always @ (negedge clk or negedge clrn) begin
        if (!clrn) begin
            cnt_mul  <= 0;
            mul_fuse <= 0;
        end
        else begin
            if (is_mul | {m_mul && !re_mul}) begin
                if (cnt_mul == 6'd1 && {is_mul | m_mul}) begin
                    cnt_mul  <= 0;
                    mul_fuse <= 1;
                end
                else cnt_mul <= cnt_mul + 6'd1;
            end
            else if (mul_fuse)  mul_fuse <= 0;
        end
    end
    
    always @ (posedge clk or negedge clrn) begin
        if (!clrn) begin
            re_mul   <= 0;
            mr       <= 0;
            reg_a    <= 0;
            reg_b    <= 0;
        end
        else begin
            if (!ready_mul) begin
                change_mul = 0;
                if (m_mul && !re_mul) begin
                    mr = a * b;
                    change_mul = 1;
                end
                else if (is_mul) begin
                    case (is_mul)
                          m_mulh   : mr = $signed(a) * $signed(b);
                          m_mulhsu : mr = $signed(a) * $signed({1'b0,b});
                          m_mulhu  : mr = a * b;
                    endcase
                    re_mul <= 1;
                    change_mul = 1;
                end
            end
            else if (!mul_fuse && re_mul) re_mul <= 0;
            else change_mul = 0;
        end
    end
    
    //div
    reg    [31:0] q, r;                                  // quotient, remainder
    reg           div_fuse;
    wire          is_dr  = m_div | m_rem;
    wire          is_dru = m_divu | m_remu;
    reg     [1:0] stop_dr;                               // 1 -> is_dr stop, 2 -> is_dru stop
    reg    [31:0] reg_a_n;                               // for neg clk
    reg    [32:0] reg_r_n;
    reg    [31:0] reg_a_p, reg_b_p;                      // for pos clk
    reg    [32:0] reg_r_p;
    wire          a_si   = a[31], b_si = b[31];          // signed
    wire          ab_si  = a_si | b_si;

    
    always @ (negedge clk or negedge clrn) begin
        if (!clrn) begin
            cnt_div  <= 0;
            div_fuse <= 0;
            stop_dr  <= 2'd0;
            reg_a_n  <= 0;
            reg_r_n  <= 0;
        end 
        else begin
            if ({is_dr | is_dru} && ~|stop_dr) begin
                if (cnt_div == 6'd33 && is_dru) begin        // 1 -> load, 2-33 -> 32 cycles for divu
                    cnt_div <= 0;
                    div_fuse <= 1;
                    stop_dr  <= 2'd2;
                end 
                else if (cnt_div == 6'd33 && is_dr) begin
                    if (ab_si) begin                     // 2's complement for div && non-negative
                        if (a_si ^ b_si) reg_a_n = ~reg_a_p + 32'b1; 
                        if (a_si) reg_r_n = ~reg_r_p + 32'b1;
                        cnt_div <= cnt_div + 6'd1;
                    end  
                    else begin                           // 1 -> load, 2-33 -> 32 cycles for div && negative
                        cnt_div  <= 0;
                        div_fuse <= 1;
                        stop_dr  <= 2'd1;
                    end
                end 
                else if (cnt_div == 6'd34 && is_dr) begin    // 1 -> load, 2-34 -> 33 cycles for div && non-negative
                    cnt_div  <= 0;
                    div_fuse <= 1;
                    stop_dr  <= 2'd1;
                end 
                else cnt_div <= cnt_div + 6'd1;
            end
            else if (div_fuse) div_fuse <= 0;
            else if (!div_fuse && |stop_dr) stop_dr  <= 2'd0;
        end
    end

    always @ (posedge clk or negedge clrn) begin
        if (!clrn) begin
            reg_a_p  <= 0;
            reg_b_p  <= 0;
            reg_r_p  <= 0;
        end
        else begin
            if (is_dr || is_dru) begin
                if (cnt_div == 6'd1) begin
                    reg_a_p = {is_dr && a_si} ? {~a + 32'd1} : a;
                    reg_b_p = {is_dr && b_si} ? {~b + 32'd1} : b;
                    reg_r_p = 33'b0; 
                end
                else if (!ready_div) begin
                    if ({cnt_div == 6'd33 && is_dru} || {cnt_div == 6'd33 && is_dr && !ab_si}) begin
                        q = reg_a_p;
                        r = reg_r_p;
                    end
                    else if (cnt_div != 6'd34) begin
                        // r = ra_lshift - b
                        reg_r_p = {reg_r_p[31:0], reg_a_p[31]} - {1'b0, reg_b_p};
                        // r is negative -> quotient = 0, r is non-negative -> quotient = 1
                        reg_a_p = {reg_a_p[30:0], ~reg_r_p[32]};
                        // r is negative -> r = r + b
                        reg_r_p = reg_r_p[32] ? reg_r_p + {1'b0, reg_b_p} : reg_r_p;
                    end
                    if (cnt_div == 6'd34 && is_dr) begin 
                        q = reg_a_n;
                        r = reg_r_n;
                    end
                end
            end
        end
    end
    
    aes_v2 v2(ark,a,subshift,mixcolumns,vb,dec,aes_vc);
    
    // control signals, will be combinational circuit
    always @(*) begin                                      // 38 instructions
        alu_out = 0;                                       // alu output
        mem_out = 0;                                       // mem output
        m_addr  = 0;                                       // memory address
        wreg    = 0;                                       // write regfile
        wmem    = 4'b0000;                                 // write memory (sw)
        rmem    = 0;                                       // read  memory (lw)
        d_t_mem = b32;
        wpc     = 0;
        next_pc = pc_plus_4;
        vlmul = 0;
        vsew  = 0;
        vta   = 0;
        vma   = 0; 
        v_alu_out = 0;                                     // alu output for vector
  		    v_mem_out = 0; 
  		    vector   = 0;
        case (1'b1)
            i_add: begin                                   // add
                alu_out = a + b32;
                wreg    = 1; end
            i_sub: begin                                   // sub
                alu_out = a - b32;
                wreg    = 1; end
            i_and: begin                                   // and
                alu_out = a & b32;
                wreg    = 1; end
            i_or: begin                                    // or
                alu_out = a | b32;
                wreg    = 1; end
            i_xor: begin                                   // xor
                alu_out = a ^ b32;
                wreg    = 1; end
            i_sll: begin                                   // sll
                alu_out = a << b32[4:0];
                wreg    = 1; end
            i_srl: begin                                   // srl
                alu_out = a >> b32[4:0];
                wreg    = 1; end
            i_sra: begin                                   // sra
                alu_out = $signed(a) >>> b32[4:0];
                wreg    = 1; end
            i_slli: begin                                  // slli
                alu_out = a << shamt;
                wreg    = 1; end
            i_srli: begin                                  // srli
                alu_out = a >> shamt;
                wreg    = 1; end
            i_srai: begin                                  // srai
                alu_out = $signed(a) >>> shamt;
                wreg    = 1; end
            i_slt: begin                                   // slt
                if ($signed(a) < $signed(b32)) 
                  alu_out = 1; end
            i_sltu: begin                                  // sltu
                if ({1'b0,a} < {1'b0,b32}) //??
                  alu_out = 1; end
            i_addi: begin                                  // addi
                alu_out = a + simm;
                wreg    = 1; end
            i_andi: begin                                  // andi
                alu_out = a & simm;
                wreg    = 1; end
            i_ori: begin                                   // ori
                alu_out = a | simm;
                wreg    = 1; end
            i_xori: begin                                  // xori
                alu_out = a ^ simm;
                wreg    = 1; end
            i_slti: begin                                  // slti
                if ($signed(a) < $signed(simm)) 
                  alu_out = 1; end
            i_sltiu: begin                                 // sltiu
                if ({1'b0,a} < {1'b0,simm}) 
                  alu_out = 1; end
            i_lw: begin                                    // lw
                alu_out = a + simm;
                m_addr  = {alu_out[31:2],2'b00};           // alu_out[1:0] != 0, exception
                rmem    = 1;
                mem_out = mem;
                wreg    = 1; end
            i_lbu: begin                                   // lbu
                alu_out = a + simm;
                m_addr  = alu_out;
                rmem    = 1;
                case(m_addr[1:0])
                  2'b00: mem_out = {24'h0,mem[ 7: 0]};
                  2'b01: mem_out = {24'h0,mem[15: 8]};
                  2'b10: mem_out = {24'h0,mem[23:16]};
                  2'b11: mem_out = {24'h0,mem[31:24]};
                endcase
                wreg    = 1; end
            i_lb: begin                                    // lb
                alu_out = a + simm;
                m_addr  = alu_out;
                rmem    = 1;
                case(m_addr[1:0])
                  2'b00: mem_out = {{24{mem[ 7]}},mem[ 7: 0]};
                  2'b01: mem_out = {{24{mem[15]}},mem[15: 8]};
                  2'b10: mem_out = {{24{mem[23]}},mem[23:16]};
                  2'b11: mem_out = {{24{mem[31]}},mem[31:24]};
                endcase
                wreg    = 1; end
            i_lhu: begin                                   // lhu
                alu_out = a + simm;
                m_addr  = {alu_out[31:1],1'b0};            // alu_out[0] != 0, exception
                rmem    = 1;
                       case(m_addr[1])
                  1'b0: mem_out = {16'h0,mem[15: 0]};
                  1'b1: mem_out = {16'h0,mem[31:16]};
                endcase
                wreg    = 1; end
            i_lh: begin                                    // lh
                alu_out = a + simm;
                m_addr  = {alu_out[31:1],1'b0};            // alu_out[0] != 0, exception
                rmem    = 1;
                case(m_addr[1])
                  1'b0: mem_out = {{16{mem[15]}},mem[15: 0]};
                  1'b1: mem_out = {{16{mem[31]}},mem[31:16]};
                endcase
                wreg    = 1; end
            i_sb: begin                                    // sb
                alu_out = a + stimm;
                m_addr  = alu_out;
                wmem    = 4'b0001 << alu_out[1:0]; end
            i_sh: begin                                    // sh
                alu_out = a + stimm;
                m_addr  = {alu_out[31:1],1'b0};            // alu_out[0] != 0, exception
                wmem    = 4'b0011 << {alu_out[1],1'b0}; end
            i_sw: begin                                    // sw
                alu_out = a + stimm;
                m_addr  = {alu_out[31:2],2'b00};           // alu_out[1:0] != 0, exception
                wmem    = 4'b1111; end
            i_beq: begin                                   // beq
                if (a == b32) 
                  next_pc = pc + broffset; end
            i_bne: begin                                   // bne
                if (a != b32) 
                  next_pc = pc + broffset; end
            i_blt: begin                                   // blt
                if ($signed(a) < $signed(b32)) 
                  next_pc = pc + broffset; end
            i_bge: begin                                   // bge
                if ($signed(a) >= $signed(b32)) 
                  next_pc = pc + broffset; end
            i_bltu: begin                                  // bltu
                if ({1'b0,a} < {1'b0,b32}) 
                  next_pc = pc + broffset; end
            i_bgeu: begin                                  // bgeu
                if ({1'b0,a} >= {1'b0,b32}) 
                  next_pc = pc + broffset; end
            i_auipc: begin                                 // auipc
                alu_out = pc + uimm;
                wreg    = 1; end
            i_lui: begin                                   // lui
                alu_out = uimm;
                wreg    = 1; end
            i_jal: begin                                   // jal
                alu_out = pc_plus_4;
                wreg    = 1;
                next_pc = pc + jaloffset; end
            i_jalr: begin                                  // jalr
                alu_out = pc_plus_4;
                wreg    = 1;
                next_pc = (a + simm) & 32'hfffffffe; end
            i_csrrw: begin                                 // csrrw
                m_addr  = {20'h0,imm};
                if (rd != 0) begin
                    mem_out = mem;
                    wreg    = 1;
                end
                if (rs != 0) begin
                    d_t_mem = a;
                end
            end
            m_mul: begin
              alu_out = mr[31:0];
              if (change_mul) wreg = 1; end
            m_mulh: begin          //signed x signed
              alu_out = mr[63:32];
              wreg = 1; end
            m_mulhsu: begin        //signed x unsigned
              alu_out = mr[63:32];
              wreg = 1; end
            m_mulhu: begin         //unsigned x unsigned
              alu_out = mr[63:32];
              wreg = 1; end
            m_div: begin           //signed / signed
              alu_out = q;
              wreg = 1; end
            m_divu: begin          //unsigned / unsigned
              alu_out = q;
              wreg = 1; end
            m_rem: begin           //signed % signed
              alu_out = r;
              wreg = 1; end
            m_remu: begin          //unsigned % unsigned
              alu_out = r;
              wreg = 1; end
            v_vsetvli: begin
              vlmul [2:0] = zimm[2:0];
              vsew  [2:0] = zimm[5:3];
              vta         = zimm[6];
              vma         = zimm[7]; 
				      alu_out = d;
				      wreg = 1;end
            v_vle32: begin
              alu_out  = {ap12,ap8,ap4,a};
              m_addr  = {alu_out[31:2] ,2'b00};        // alu_outX[1:0] != 0, exception
              rmem    = 1;
              v_mem_out = {mem};
              wpc    = 1;
              vector = 1;
				    end
            v_vse32: begin
              alu_out  = {ap12,ap8,ap4,a};
              m_addr  = {alu_out[31:2] ,2'b00};        // alu_outX[1:0] != 0, exception
              wmem    = 4'b1111;
              vector = 1;
            end
            v_vxorvv: begin
              v_alu_out = va ^ vb; 
              wpc = 1; end
            v_vaddrkvx: begin
              v_alu_out = aes_vc;
              wpc = 1; end
            v_vsubshiftv: begin
              v_alu_out  = aes_vc;
              wpc = 1; end
            v_vmixcolumnsv: begin
              v_alu_out  = aes_vc;
              wpc = 1; end
            v_vinvsubshiftv: begin
              v_alu_out  = aes_vc;
              wpc = 1; end
            v_vinvmixcolumnsv: begin
              v_alu_out  = aes_vc;
              wpc = 1; end
            default: ;
        endcase
    end
endmodule