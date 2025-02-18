module riscv_rv32im_aes128_m1_cpu (clk,clrn,inst,mem,pc,alu_out,b,wmem); 
    input             clk, clrn;                             // clock and reset
    input      [31:0] inst;                                  // instruction
    input      [31:0] mem;                                   // load data
    output     [31:0] pc;                                    // program counter
    output reg [31:0] alu_out;                               // alu output
    output     [31:0] b;
    output reg  [3:0] wmem;

    // control signals
    reg           wreg;                                      // write regfile
    reg           rmem;                                      // write/read memory
    reg    [31:0] mem_out;                                   // mem output
    reg    [31:0] m_addr;                                    // mem address
    reg    [31:0] next_pc;                                   // next pc
    reg    [31:0] d_t_mem;
    wire   [31:0] pc_plus_4 = pc + 4;                        // pc + 4

    // instruction format
    wire    [6:0] opcode = inst[6:0];   //
    wire    [2:0] func3  = inst[14:12]; //
    wire    [6:0] func7  = inst[31:25]; //
    wire    [4:0] rd     = inst[11:7];  //
    wire    [4:0] rs     = inst[19:15]; // = rs1
    wire    [4:0] rt     = inst[24:20]; // = rs2
    wire    [4:0] shamt  = inst[24:20]; // == rs2;
    wire          sign   = inst[31];
    wire   [11:0] imm    = inst[31:20];

    // branch offset            31:13          12      11       10:5         4:1     0
    wire   [31:0] broffset  = {{19{sign}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};   // beq, bne,  blt,  bge,   bltu, bgeu
    wire   [31:0] simm      = {{20{sign}},inst[31:20]};                                    // lw,  addi, slti, sltiu, xori, ori,  andi, jalr
    wire   [31:0] stimm     = {{20{sign}},inst[31:25],inst[11:7]};                         // sw
    wire   [31:0] uimm      = {inst[31:12],12'h0};                                         // lui, auipc
    wire   [31:0] jaloffset = {{11{sign}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0}; // jal
    // jal target               31:21          20       19:12       11       10:1      0

    // instruction decode
    wire i_auipc = (opcode == 7'b0010111);
    wire i_lui   = (opcode == 7'b0110111);
    wire i_jal   = (opcode == 7'b1101111);
    wire i_jalr  = (opcode == 7'b1100111) & (func3 == 3'b000);
    wire i_beq   = (opcode == 7'b1100011) & (func3 == 3'b000);
    wire i_bne   = (opcode == 7'b1100011) & (func3 == 3'b001);
    wire i_blt   = (opcode == 7'b1100011) & (func3 == 3'b100);
    wire i_bge   = (opcode == 7'b1100011) & (func3 == 3'b101);
    wire i_bltu  = (opcode == 7'b1100011) & (func3 == 3'b110);
    wire i_bgeu  = (opcode == 7'b1100011) & (func3 == 3'b111);
    wire i_lb    = (opcode == 7'b0000011) & (func3 == 3'b000);
    wire i_lh    = (opcode == 7'b0000011) & (func3 == 3'b001);
    wire i_lw    = (opcode == 7'b0000011) & (func3 == 3'b010);
    wire i_lbu   = (opcode == 7'b0000011) & (func3 == 3'b100);
    wire i_lhu   = (opcode == 7'b0000011) & (func3 == 3'b101);
    wire i_sb    = (opcode == 7'b0100011) & (func3 == 3'b000);
    wire i_sh    = (opcode == 7'b0100011) & (func3 == 3'b001);
    wire i_sw    = (opcode == 7'b0100011) & (func3 == 3'b010);
    wire i_addi  = (opcode == 7'b0010011) & (func3 == 3'b000);
    wire i_slti  = (opcode == 7'b0010011) & (func3 == 3'b010);
    wire i_sltiu = (opcode == 7'b0010011) & (func3 == 3'b011);
    wire i_xori  = (opcode == 7'b0010011) & (func3 == 3'b100);
    wire i_ori   = (opcode == 7'b0010011) & (func3 == 3'b110);
    wire i_andi  = (opcode == 7'b0010011) & (func3 == 3'b111);
    wire i_csrrw = (opcode == 7'b1110011) & (func3 == 3'b001);
    wire i_slli  = (opcode == 7'b0010011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire i_srli  = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire i_srai  = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire i_add   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000000);
    wire i_sub   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0100000);
    wire i_sll   = (opcode == 7'b0110011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire i_slt   = (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000000);
    wire i_sltu  = (opcode == 7'b0110011) & (func3 == 3'b011) & (func7 == 7'b0000000);
    wire i_xor   = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000000);
    wire i_srl   = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire i_sra   = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire i_or    = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000000);
    wire i_and   = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000000);
    wire m_mul   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000001);
    wire m_mulh  = (opcode == 7'b0110011) & (func3 == 3'b001) & (func7 == 7'b0000001);
    wire m_mulhsu= (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000001);
    wire m_mulhu = (opcode == 7'b0110011) & (func3 == 3'b011) & (func7 == 7'b0000001);
    wire m_div   = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000001);
    wire m_divu  = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0000001);
    wire m_rem   = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000001);
    wire m_remu  = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000001);
    
    wire i_subbytes      = (opcode == 7'b1111111) & (func3 == 3'b000) & (func7 == 7'b0000001);
    wire i_invsubbytes   = (opcode == 7'b1111111) & (func3 == 3'b001) & (func7 == 7'b0000001);
    wire i_mixcolumns    = (opcode == 7'b1111111) & (func3 == 3'b000) & (func7 == 7'b0000010);
    wire i_invmixcolumns = (opcode == 7'b1111111) & (func3 == 3'b001) & (func7 == 7'b0000010);
    
    // data written to register file
    wire        i_load = i_lw | i_lb | i_lbu | i_lh | i_lhu | i_csrrw;
    wire [31:0] data_2_rf = i_load ? mem_out : alu_out;
    
    // for aes
    wire        dec = 1 & (i_invsubbytes | i_invmixcolumns); //Encrypt (0) or decrypt (1)
    wire [31:0] aes_c;
    wire        subbytes = i_subbytes | i_invsubbytes;
    wire        mixcolumns = i_mixcolumns | i_invmixcolumns;

    // register file
    reg    [31:0] regfile [1:31];                          // x1 - x31, should be [1:31]
    wire   [31:0] a = (rs==0) ? 0 : regfile[rs];           // read port
    wire   [31:0] b = (rt==0) ? 0 : regfile[rt];           // read port
    integer       h;
    always @ (posedge clk or negedge clrn) begin
        if (!clrn) begin
            for (h = 1; h < 32; h = h + 1)
                 regfile[h] = 0;
        end else begin
            if (wreg && (rd != 0)) begin
                 regfile[rd] <= data_2_rf;                 // write port
            end
        end
    end
	 
    reg      [5:0] cnt_mul;               // count
    reg      [5:0] cnt_div;
	 
    wire     [5:0] cnt = cnt_mul | cnt_div;
    wire           ready_mul  = ~|cnt_mul;                    // ready = 1 if cnt_mul = 0
    wire           ready_div  = ~|cnt_div;
    wire           ready = ready_mul & ready_div; // ready = 1 if cnt = 0
    reg            change_mul;
    reg            change_div;
    wire           change = change_mul | change_div;        // Orders needing counts
    
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
        
    // pc
    reg    [31:0]  pc;
    always @ (posedge clk or negedge clrn) begin
        if (!clrn) pc <= 0;
        else if (ready) pc <= next_pc;
    end
    
    aes_m1 m1(subbytes,mixcolumns,a,dec,aes_c);
    
    // control signals, will be combinational circuit
    always @(*) begin                                      // 38 instructions
        alu_out = 0;                                       // alu output
        mem_out = 0;                                       // mem output
        m_addr  = 0;                                       // memory address
        wreg    = 0;                                       // write regfile
        wmem    = 4'b0000;                                 // write memory (sw)
        rmem    = 0;                                       // read  memory (lw)
        d_t_mem = b;
        next_pc = pc_plus_4;
        case (1'b1)
            i_add: begin                                   // add
                alu_out = a + b;
                wreg    = 1; end
            i_sub: begin                                   // sub
                alu_out = a - b;
                wreg    = 1; end
            i_and: begin                                   // and
                alu_out = a & b;
                wreg    = 1; end
            i_or: begin                                    // or
                alu_out = a | b;
                wreg    = 1; end
            i_xor: begin                                   // xor
                alu_out = a ^ b;
                wreg    = 1; end
            i_sll: begin                                   // sll
                alu_out = a << b[4:0];
                wreg    = 1; end
            i_srl: begin                                   // srl
                alu_out = a >> b[4:0];
                wreg    = 1; end
            i_sra: begin                                   // sra
                alu_out = $signed(a) >>> b[4:0];
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
                if ($signed(a) < $signed(b)) 
                  alu_out = 1; end
            i_sltu: begin                                  // sltu
                if ({1'b0,a} < {1'b0,b}) //??
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
                if (a == b) 
                  next_pc = pc + broffset; end
            i_bne: begin                                   // bne
                if (a != b) 
                  next_pc = pc + broffset; end
            i_blt: begin                                   // blt
                if ($signed(a) < $signed(b)) 
                  next_pc = pc + broffset; end
            i_bge: begin                                   // bge
                if ($signed(a) >= $signed(b)) 
                  next_pc = pc + broffset; end
            i_bltu: begin                                  // bltu
                if ({1'b0,a} < {1'b0,b}) 
                  next_pc = pc + broffset; end
            i_bgeu: begin                                  // bgeu
                if ({1'b0,a} >= {1'b0,b}) 
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
              wreg = 1; end
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
            
            i_subbytes: begin
              alu_out = aes_c;
              wreg = 1; end
            i_invsubbytes: begin
              alu_out = aes_c;
              wreg = 1; end
            i_mixcolumns: begin
              alu_out = aes_c;
              wreg = 1; end
            i_invmixcolumns: begin
              alu_out = aes_c;
              wreg = 1; end
            default: ;
        endcase
    end
endmodule
