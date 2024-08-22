//fixme: to be uncommented when running stand-alone
// typedef enum logic [3:0] {
//     ADD=0, SUB=1, SLL=2, SLT=3, SLTU=4, XOR=5, SRL=6, SRA=7,OR=8, AND=9,
//     BEQ=10, BNE=11, BLT=12, BGE=13, BLTU=14, BGEU=15
//     } operation_t;

module t04_top_intgr (
    input logic [31:0] instruction, //instruction to CPU
    input logic clk, nrst, //timing & reset signals
    input logic [31:0] data_from_mem,
    output logic [31:0] alu_result, //numerical/logical output of ALU
    output logic  MemWrite, 
    output logic [31:0] [31:0] reg_window ,
    output logic [31:0] addr_to_mem,
                        data_to_mem,
                        nextInstruction);

//wires 
//from decoder
logic [4:0] rs1, rs2, rd; 
logic [6:0] opcode, func7;
logic [2:0] func3;

//from imm_gen
logic [31:0] imm;

//from control_unit
logic [1:0] RegWriteSrc;
logic ALUSrc, RegWrite, Jump, Branch, /*MemWrite*/ MemRead, Error;

//from ALU mux
logic [31:0] opB;

//from ALU
logic [31:0] alu_result_wire;
logic condJumpValue;

//from RegWrite mux
logic [31:0] DataWrite;


//from Regs
logic [31:0] regA, regB;

//from Mem Handler
logic [31:0] MemData;

//instantiation of modules

//decode data and addresses withing instruction
t04_decode decoder (
    .instruction(instruction), //32-bit instruction
    .rs1(rs1), //address of source register 1
    .rs2(rs2), //address of source register 2
    .rd(rd), //address of destination register
    .opcode(opcode), //7-bit Opcode (decoded from intrsuction)
    .ALUOp(func3), //3-bit function code (decoded from intrsuction)
    .func7(func7) //7-bit function code (decoded from intrsuction)
);

//genrate immediate value based on instruction format and values
t04_imm_gen make_imm (
    .instruction(instruction), //32-bit instruction
    .imm(imm), //32-bit genrated immediate value (signed)
    .flag() //error flag (ignore, used for tb)
    );

//generate control signals based on Opcode
t04_control_unit cntrl (
    .opcode(opcode), //7-bit Opcode (decoded from intrsuction)
    .RegWriteSource(RegWriteSrc), //2-bit control signal specifiying what is writing to the regs
    .ALUSrc(ALUSrc), //control signal indicating use of immediate
    .RegWrite(RegWrite), //control signal indicating writing to destination reg
    .Jump(Jump), //control signal indicating a Jump will take place
    .Branch(Branch), //control signal indicating a Branch, (conditional jump)
    .MemWrite(MemWrite), //control signal indicating Memory will be written to 
    .MemRead(MemRead), //control signal indicating memory will be read from
    .Error(Error) //testing signal indicating invalid Opcode
);

//decide whether a register value or immediate is used as the second operand in an operation
t04_aluop_mux ALUOpB(
    .regB(regB), //value from register
    .imm(imm), //immediate value
    .alu_src(ALUSrc), //control signal
    .opB(opB) //resulting second operand
); 

//perform arithmetic and logical operation
t04_alu ALU (
    .opcode(opcode), //control signals
    .alu_op(func3), 
    .func7(func7), 
    .opB(opB), //operands
    .opA(regA), 
    .alu_result(alu_result_wire), //results and flags
    .zero_flag(zero_flag), //indicate result == 0
    .err_flag(err_flag), //indicate invalid operation
    .condJumpValue(condJumpValue) //indicate branching condition is true
    );

//allow for easier display of alu result
assign alu_result = alu_result_wire;

//determine register write source
t04_reg_write_mux reg_write_control (
    .immData(imm), //immediate value
    .ALUData(alu_result_wire), //ALU result value
    .MemData(MemData), //memory value
    .PCData(32'b0), //program counter value
    .DataWrite(DataWrite), //chosen value
    .RegWriteSrc(RegWriteSrc) //control signal
    );

//read to and write from registers
t04_register_file regs (
    .read_addr_1(rs1), //read addresses
    .read_addr_2(rs2), 
    .write_addr(rd), //write address
    .reg_enable_write(RegWrite), //control signal enabling write
    .read_data_1(regA), //read values
    .read_data_2(regB), 
    .write_data(DataWrite), //value to be written
    .clk(clk), 
    .nrst(nrst), 
    .reg_file(reg_window) //testbenching array
    );

t04_memory_handler mem (
    .addr(alu_result_wire), //alu result, used as address
    .read_data_2(regB), 
    .data_from_mem(data_from_mem), 
    .en_read(MemRead), 
    .en_write(MemWrite), 
    .size(func3), 
    .select(),//fixme to wishbone/request unit
    .data_to_reg(MemData),
    .addr_to_mem(addr_to_mem),
    .data_to_mem(data_to_mem),
    .mem_read(),
    .mem_write()
    );
//decode data and addresses withing instruction
t04_decode decoder (
    .instruction(instruction), //32-bit instruction
    .rs1(rs1), //address of source register 1
    .rs2(rs2), //address of source register 2
    .rd(rd), //address of destination register
    .opcode(opcode), //7-bit Opcode (decoded from intrsuction)
    .ALUOp(func3), //3-bit function code (decoded from intrsuction)
    .func7(func7) //7-bit function code (decoded from intrsuction)
);

//genrate immediate value based on instruction format and values
t04_imm_gen make_imm (
    .instruction(instruction), //32-bit instruction
    .imm(imm), //32-bit genrated immediate value (signed)
    .flag() //error flag (ignore, used for tb)
    );

//generate control signals based on Opcode
t04_control_unit cntrl (
    .opcode(opcode), //7-bit Opcode (decoded from intrsuction)
    .RegWriteSource(RegWriteSrc), //2-bit control signal specifiying what is writing to the regs
    .ALUSrc(ALUSrc), //control signal indicating use of immediate
    .RegWrite(RegWrite), //control signal indicating writing to destination reg
    .Jump(Jump), //control signal indicating a Jump will take place
    .Branch(Branch), //control signal indicating a Branch, (conditional jump)
    .MemWrite(MemWrite), //control signal indicating Memory will be written to 
    .MemRead(MemRead), //control signal indicating memory will be read from
    .Error(Error) //testing signal indicating invalid Opcode
);

//decide whether a register value or immediate is used as the second operand in an operation
t04_aluop_mux ALUOpB(
    .regB(regB), //value from register
    .imm(imm), //immediate value
    .alu_src(ALUSrc), //control signal
    .opB(opB) //resulting second operand
); 

//perform arithmetic and logical operation
t04_alu ALU (
    .opcode(opcode), //control signals
    .alu_op(func3), 
    .func7(func7), 
    .opB(opB), //operands
    .opA(regA), 
    .alu_result(alu_result_wire), //results and flags
    .zero_flag(), //indicate result == 0
    .err_flag(err_flag), //indicate invalid operation
    .condJumpValue(condJumpValue) //indicate branching condition is true
    );

//allow for easier display of alu result
assign alu_result = alu_result_wire;

//determine register write source
t04_reg_write_mux reg_write_control (
    .immData(imm), //immediate value
    .ALUData(alu_result_wire), //ALU result value
    .MemData(MemData), //memory value
    .PCData(PCData), //program counter value
    .DataWrite(DataWrite), //chosen value
    .RegWriteSrc(RegWriteSrc) //control signal
    );

//read to and write from registers
t04_register_file regs (
    .read_addr_1(rs1), //read addresses
    .read_addr_2(rs2), 
    .write_addr(rd), //write address
    .reg_enable_write(RegWrite), //control signal enabling write
    .read_data_1(regA), //read values
    .read_data_2(regB), 
    .write_data(DataWrite), //value tobe written
    .clk(clk), 
    .nrst(nrst), 
    .reg_file(reg_window) //testbenching array
    );

t04_memory_handler mem (
    .addr(alu_result_wire), //alu result, used as address
    .read_data_2(regB), 
    .data_from_mem(32'd99), //requested data from memory
    .en_read(MemRead), 
    .en_write(MemWrite), 
    .size(func3), 
    .select(),//fixme to wishbone/request unit
    .data_to_reg(MemData),
    .addr_to_mem(addr_to_mem),
    .data_to_mem(data_to_mem),
    .mem_read(), //fixme
    .mem_write() //fixme
    );


t04_program_counter PC (
    .nRst(nrst),
    .enable(1'b1), //global enable from busy signal of wishbone fixme
    .clk(clk),
    .immJumpValue(imm),
    .regJumpValue(regA),
    .doForceJump(Jump),
    .doCondJump(Branch),
    .condJumpValue(condJumpValue),
    .doRegJump(~opcode[3]),
    .instructionAddress(nextInstruction), //to Instruction memory
    .linkAddress(PCData)

);  
endmodule


//decode instruction into register addresses and Opcode
module t04_decode (
    input logic [31:0] instruction, //32 bit instruction signal, from Program Memory
    output logic [4:0] rs1, rs2, rd, //5 bit register addresses, to registers 
    output logic [6:0] opcode, //7 bit Opcode, to Control Unit
    output logic [2:0] ALUOp, //3-bit code (func-3), used to further specify operations. to ALU, & memory handler
    output logic [6:0] func7 //7-bit code, used to further specify operations, to ALU
);

assign opcode = instruction[6:0];
assign rd = instruction[11:7];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign ALUOp = instruction[14:12];
assign func7 = instruction[31:25];

endmodule

//generate immediate value from instruction code, send whereever needed (WB, PC, ALU)
module t04_imm_gen (
    input logic [31:0] instruction,
    output logic [31:0] imm,
	output logic flag
);
    
logic [31:0] imm_raw;
logic fill;


always_comb begin
	flag = 1'b0;
	fill = instruction[31];
    case(instruction[6:0])
		7'b0110111, 7'b0010111:begin //U-Type instructions
			imm[31:12] = {instruction[31:12]};
			imm[11:0] = {12'b0};
		end

		7'b1101111:begin //J-Type
			imm[0] = 0;
			imm[20:1] = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]}; //instruction[31|19:12|20|30:21];
			imm[31:21] = {11{fill}};
		end

		7'b1100111, 7'b0000011, 7'b0010011: begin //I-Type instructions
			imm[11:0] = instruction[31:20];
			imm[31:12] = {20{fill}};
		end

		7'b0100011: begin //S-Type 
			imm[4:0] = instruction[11:7]; 
			imm[11:5] = instruction[31:25]; 
			imm[31:12] = {20{fill}};
		end

		7'b1100011: begin //B-type
			imm[0] = 0;
			imm[4:1] = instruction[11:8];
			imm[10:5] = instruction[30:25];
			imm[11] = instruction[7];
			imm[12] = instruction[31];
			imm[31:13] = {19{fill}};
		end

		default: begin
			imm = 32'b01010101010101010101010101010101;
			flag = 1'b1;
		end

	endcase
end

endmodule

//output proper control signals according to given opcode
module t04_control_unit (
    input logic [6:0] opcode, //7 bit code dictating what signals to output
    output logic [1:0] RegWriteSource,  
    // 00: The value to be written to a register comes from the ALU, 01: The value to be written to a register comes from Memory, 
    // 10: The value to be written to a register comes from an immediate, 11: The value to be written to a register comes from the Program Counter, to Registers
    output logic 
    ALUSrc, //ON: ALU operates on one register value and one immediate value. OFF: ALU operates on two register values, to ALU
    RegWrite, //ON: the destination register will be written to, to Registers
    Jump, //ON: The next instruction should be taken from the address determined by the immediate value, to PC
    Branch, //ON: The next instruction should be taken from the address determined by the immediate value if some condition is fulfilled, to PC
    MemWrite, //ON: Memory will be written to, to Data Memory
    MemRead, //ON: Memory will be read from, to Data Memory
    Error //ON: Invalid Opcode 
);
    

always_comb begin
    case (opcode)
    7'b0110111: begin //lui
	    RegWrite = 1;
	    ALUSrc = 0;
        RegWriteSource = 2'b10;
	    MemWrite = 0;
	    MemRead = 0;
        Jump = 0;
        Branch = 0;
        Error = 0;
    end

    7'b0010111: begin //(auipc)
        RegWrite = 1;
        ALUSrc = 1;
        RegWriteSource = 2'b11;
        MemWrite = 0;
        MemRead = 0;
        Jump = 0;
        Branch = 0;
        Error = 0;
    end
    
    7'b1101111: begin //(jal)
        RegWrite = 1;
        ALUSrc = 1;
        RegWriteSource = 2'b11;
        MemWrite = 0;
        MemRead = 0;
        Jump = 1;
        Branch = 0;
        Error = 0;
    end

    7'b1100111: begin //(jalr)
        
        RegWrite = 1;
        ALUSrc = 1;
        RegWriteSource = 2'b11;
        MemWrite = 0;
        MemRead = 0;
        Jump = 1;
        Branch = 0;
        Error = 0;
    end

    7'b1100011: begin //(B-Type):
        RegWrite = 0;
        ALUSrc = 0;
        RegWriteSource = 2'b00;
        MemWrite = 0;
        MemRead = 0;
        Jump = 0;
        Branch = 1;
        Error = 0;
    end

    7'b0000011: begin //(I-Type):
        RegWrite = 1;
        ALUSrc = 1;
        RegWriteSource = 2'b01;
        MemWrite = 0;
        MemRead = 1;
        Jump = 0;
        Branch = 0;
        Error = 0;
    end

    7'b0100011: begin //(S-Type):
        RegWrite = 0;
        ALUSrc = 1;
        RegWriteSource = 2'b00;
        MemWrite = 1;
        MemRead = 0;
        Jump = 0;
        Branch = 0;
        Error = 0;
    end

    7'b0010011: begin //(I-Type):
        RegWrite = 1;
        ALUSrc = 1;
        RegWriteSource = 2'b00;
        MemWrite = 0;
        MemRead = 0;
        Jump = 0;
        Branch = 0;
        Error = 0;
    end

    7'b0110011: begin //(R-Type):    
        RegWrite = 1;
        ALUSrc = 0;
        RegWriteSource = 2'b00;
        MemWrite = 0;
        MemRead = 0;
        Jump = 0;
        Branch = 0;
        Error = 0;
    end
     
    default: begin
        RegWrite = 0;
        ALUSrc = 0;
        RegWriteSource = 2'b00;
        MemWrite = 0;
        MemRead = 0;
        Jump = 0;
        Branch = 0;
        Error = 1;
    end
    endcase
end

endmodule

// `default_nettype none

//this module will be integrated in the top or regfile module
module t04_aluop_mux (
input logic [31:0] regB, //from regfile
input logic [31:0] imm, //from immgen
input logic alu_src, //from control unit
output logic [31:0] opB
);

always_comb begin
    if(alu_src == 1)
    begin
        opB = imm;
    end
    else
    begin
        opB = regB;
    end
end //always_comb

endmodule

// `default_nettype none

typedef enum logic [3:0] {
    ADD=0, SUB=1, SLL=2, SLT=3, SLTU=4, XOR=5, SRL=6, SRA=7,OR=8, AND=9, 
    BEQ=10, BNE=11, BLT=12, BGE=13, BLTU=14, BGEU=15, ERR=4'bx
    } operation_t;

module alu (
input logic [6:0] opcode,
input logic [2:0] alu_op,
input logic [6:0] func7,
input logic [31:0] opA,
input logic [31:0] opB,
output logic [31:0] alu_result,
output logic zero_flag, err_flag,     //send out condJumpValue instead
output logic condJumpValue  //send out condJumpValue instead of less_flag and eq_flag
);

logic signed [31:0] opA_signed;
logic signed [31:0] opB_signed;

assign opA_signed = opA;
assign opB_signed = opB;

operation_t alu_control_input;

logic ctrl_err;
//INSTANTING alu_control_unit here
    t04_alu_control_unit ex1 (.opcode(opcode), 
                         .alu_op(alu_op), 
                          .func7(func7), 
                          .ctrl_err(ctrl_err),
                         .alu_control_input(alu_control_input));

always_comb 
begin
case(alu_control_input)

    //R-type
    ADD:
    begin
         alu_result = (opA + opB); //overflow bits are discarded (RISCV ISA)
         err_flag =1'b0;
         condJumpValue = 1'b0;
    end
    SUB:
    begin
         alu_result = (opA - opB);
         err_flag =1'b0;
         condJumpValue = 1'b0;
    end
    SLL: 
    begin
         alu_result = (opA << opB[4:0]); //DEFINE opB TO BE THE LEAST SIGNIFICANT 5 BITS OF rs2
         err_flag =1'b0;  
        condJumpValue = 1'b0;      
    end
    SLT: //taking the signed integer value of opA and opB for comparision
    begin
         alu_result = ((opA_signed < opB_signed) ? 32'b1 : 32'b0); 
         err_flag =1'b0;
        condJumpValue = 1'b0;
    end
    SLTU: //taking the unsigned value of opA and opB for comparision
    begin
         alu_result = ((opA < opB) ? 32'b1 : 32'b0); 
         err_flag =1'b0; 
      condJumpValue = 1'b0;
    end
    XOR:
    begin
         alu_result = (opA ^ opB); 
         err_flag =1'b0; 
      condJumpValue = 1'b0;
    end
    SRL: 
    begin
        alu_result = (opA >> opB[4:0]); 
         err_flag =1'b0; 
      condJumpValue = 1'b0;
    end
    SRA: 
    begin

         alu_result = (opA_signed >>> opB[4:0]); 
         err_flag =1'b0; 
      condJumpValue = 1'b0;
    end
    OR:
    begin
         alu_result = (opA | opB); 
         err_flag =1'b0; 
      condJumpValue = 1'b0;
    end
    AND:
    begin
         alu_result = (opA & opB); 
         err_flag =1'b0; 
      condJumpValue = 1'b0;
    end

    //B-type
    BEQ:
    begin
         err_flag =1'b0; 
         alu_result= {32{opA==opB}};  //needed here cause alu_result is a don't care
      condJumpValue = alu_result[0];
    end
    BNE:
    begin
         err_flag =1'b0; 
         alu_result=32'b0;
        condJumpValue = (opA != opB) ? 1 : 0;
    end
    BLT:
    begin
         err_flag =1'b0; 
         alu_result=32'b0;
         condJumpValue = (opA_signed < opB_signed) ? 1 : 0;
    end
    BGE:
    begin
         err_flag =1'b0; 
         alu_result=32'b0;
      condJumpValue = (opA_signed >= opB_signed) ? 1 : 0;
    end
    BLTU:
    begin
         err_flag =1'b0; 
         alu_result=32'b0;
      condJumpValue = (opA < opB) ? 1 : 0;
    end
    BGEU:
    begin
         err_flag =1'b0;
         alu_result=32'b0; 
      condJumpValue = (opA >= opB) ? 1 : 0;
    end

    default:
    begin
        alu_result=32'b0; //(invalid/no operations);
        err_flag = 1'b1;
        zero_flag = 1'b0;
        condJumpValue = 1'b0;
    end
endcase

    zero_flag = ((|alu_result) == 'b1) ? 'b0 :'b1;  //zero_flag

end //always_comb
endmodule

// `default_nettype none

// //FIXME: comment following typedef when using tb_alu
// typedef enum logic [3:0] {
//     ADD=0, SUB=1, SLL=2, SLT=3, SLTU=4, XOR=5, SRL=6, SRA=7,OR=8, AND=9,
//     BEQ=10, BNE=11, BLT=12, BGE=13, BLTU=14, BGEU=15, ERR = 4'bxxxx
//     } operation_t;

module t04_alu_control_unit(
input logic [6:0] opcode,
input logic [2:0] alu_op,
input logic [6:0] func7,
output logic ctrl_err, 
output operation_t alu_control_input
);
always_comb begin
    alu_control_input = ERR;
    ctrl_err = 1'b0;
    if (opcode  == 7'b0110011) //R-type
    begin
        if(alu_op == 3'b000) // ADD/SUB
        begin
            if(func7 == 7'b0000000) 
            begin
                alu_control_input = ADD;
            end
            else if (func7 == 7'b0100000)
            begin
                alu_control_input = SUB;
            end
            else
            begin
                alu_control_input = ERR; //invalid operation;
                ctrl_err = 1'b1;
            end
        end //alu_op
        else if (alu_op == 3'b001)
        begin
            alu_control_input = SLL;
        end
        else if (alu_op == 3'b010)
        begin
            alu_control_input = SLT;
        end
        else if (alu_op == 3'b011)
        begin
            alu_control_input = SLTU;
        end
        else if (alu_op == 3'b100)
        begin
            alu_control_input = XOR;
        end
        else if(alu_op == 3'b101) // SRL/SRA
        begin
            if(func7 == 7'b0000000) 
            begin
                alu_control_input = SRL;
            end
            else if(func7 == 7'b0100000)
            begin
                alu_control_input = SRA;
            end
            else
            begin
                alu_control_input = ERR; //invalid operation;
                ctrl_err = 1'b1;
            end
        end //alu_op
        else if (alu_op == 3'b110)
        begin
            alu_control_input = OR;
        end
        else if (alu_op == 3'b111)
        begin
            alu_control_input = AND;
        end
        else
        begin
            alu_control_input = ERR; //invalid operation;
            ctrl_err = 1'b1;
        end
    end //opcode
    else if (opcode  == 7'b0010011) //I-type
    begin
        if (alu_op == 3'b000)
        begin
            alu_control_input = ADD; //optimizing?
        end
        else if (alu_op == 3'b010)
        begin
            alu_control_input = SLT;
        end
        else if (alu_op == 3'b011)
        begin
            alu_control_input = SLTU;
        end
        else if (alu_op == 3'b100)
        begin
            alu_control_input = XOR;
        end
        else if (alu_op == 3'b110)
        begin
            alu_control_input = OR;
        end
        else if (alu_op == 3'b111)
        begin
            alu_control_input = AND;
        end
        else if (alu_op == 3'b001)
        begin
            alu_control_input = SLL;
        end
        else if (alu_op == 3'b101) //SRA/SRL
        begin
            if(func7 == 7'b0000000) 
            begin
                alu_control_input = SRL;
            end
            else if(func7 == 7'b0100000)
            begin
                alu_control_input = SRA;
            end
            else 
            begin
                alu_control_input = ERR;//invalid operation;
                ctrl_err = 1'b1;
            end
        end //alu_op
        else 
        begin
            alu_control_input = ERR;//invalid operation;
            ctrl_err = 1'b1;
        end

    end //opcode
    else if (opcode  == 7'b1100011) //B-type
    begin
        if (alu_op == 3'b000)
        begin
            alu_control_input = BEQ;
        end
        else if (alu_op == 3'b001)
        begin
            alu_control_input = BNE;
        end
        else if (alu_op == 3'b100)
        begin
            alu_control_input = BLT;
        end
        else if (alu_op == 3'b101)
        begin
            alu_control_input = BGE;
        end
        else if (alu_op == 3'b110)
        begin
            alu_control_input =  BLTU;
        end
        else if (alu_op == 3'b111)
        begin
            alu_control_input = BGEU;
        end
        else 
        begin
            alu_control_input = ERR;//invalid operation;
            ctrl_err = 1'b1;
        end

    end //opcode
        
  else if (opcode  == 7'b0100011) //S-type(store)
    begin
        alu_control_input = ADD; //optimizing?
    end //opcode

    else if (opcode  == 7'b0000011) //I-type(load)
    begin
        alu_control_input = ADD; //optimizing?
    end

    else 
    begin
        alu_control_input = ERR;//invalid operation;
        ctrl_err = 1'b1;
    end
end //always_comb
endmodule


// `default_nettype none

//this module will be integrated in the top or regfile module
module t04_reg_write_mux (
input logic [31:0] immData, //from imm_gen
                ALUData, //from ALU
                MemData, //from Memory Handler
                PCData, //from PC
input logic [1:0] RegWriteSrc, //from control unit

output logic [31:0] DataWrite
);
    //00: The value to be written to a register comes from the ALU, 
    //01: The value to be written to a register comes from Memory, 
    //10: The value to be written to a register comes from an immediate, 
    //11: The value to be written to a register comes from the Program Counter

always_comb begin
    DataWrite = 0;

    if(RegWriteSrc == 0)
    begin
        DataWrite = ALUData;
    end else if (RegWriteSrc == 2'b01)
    begin
        DataWrite = MemData;
    end else if (RegWriteSrc == 2'b10)
    begin
        DataWrite = immData;
    end else if (RegWriteSrc == 2'b11)
    begin
        DataWrite =  PCData;
    end
end

endmodule

module t04_register_file(
    input logic [4:0] read_addr_1, read_addr_2, write_addr,
    input logic clk, nrst, reg_enable_write,
    input logic [31:0] write_data,
    output logic [31:0]  read_data_1, read_data_2,
    output reg [31:0]  [31:0] reg_file
);
    // logic [4:0] i;

    //assign reg_file[0] = 0;


    always_ff @(posedge clk, negedge nrst) begin
        if (~nrst) begin 
            for (integer i = 0; i < 32; i++) begin //
                reg_file[i] <= 32'b0;
            end
        end else if (write_addr != 5'd0 && reg_enable_write) begin //ensure x0 never written to (maintain value of 0)
            reg_file[write_addr] <= write_data;
        end
    end

    //combinational read block
    always_comb begin
        read_data_1 = reg_file[read_addr_1];
        read_data_2 = reg_file[read_addr_2];
    end
    // assign read_data_1 = reg_file[read_addr_1];
    // assign read_data_2 = reg_file[read_addr_2];
endmodule


module t04_memory_handler(
  input logic [31:0] addr, read_data_2, data_from_mem,
  input logic en_read, en_write,
  input logic [2:0] size,
  output logic [31:0] data_to_reg,
  output logic mem_write, mem_read,
  output logic [31:0] addr_to_mem, data_to_mem,
  output logic [3:0] select
);
  

always_comb begin 
    if (en_read) begin 
      mem_read = 1;
        select = 4'b1111;
        addr_to_mem = addr;
      mem_write = 0;
      case(size)
        3'b100: begin //lbu
          data_to_reg = {24'b0, data_from_mem[7:0]};
        end
        3'b000: begin //lb
          data_to_reg = {{24{data_from_mem[7]}}, data_from_mem[7:0]};
        end
        3'b101: begin //lhu
          data_to_reg = {16'b0, data_from_mem[15:0]};
        end
        3'b001: begin //lh
          data_to_reg = {{16{data_from_mem[16]}}, data_from_mem[15:0]};
        end
        3'b010: begin //lw
          data_to_reg = data_from_mem;
        end
        default:
          data_to_reg = 0;
      endcase
    end else if (en_write) begin 
      mem_read = 0;
      mem_write = 1;
      addr_to_mem = addr;
      case(size) 
        3'b000: begin //sb 
          data_to_mem[7:0] = read_data_2[7:0];
          select = 4'b0001;
        end
        3'b001: begin //sh
          data_to_mem[15:0] = read_data_2[15:0];
          select = 4'b0011;
        end
        3'b010: begin //sw
          data_to_mem = read_data_2;
          select = 4'b1111;
        end
        default: begin
          data_to_mem = 0;
          select = 0;
        end
        
      endcase  
    end else begin
      select = 0;
      data_to_mem = 0;
      data_to_reg = 0;
	addr_to_mem = 0; //mary add?
    end
end

endmodule

module t04_program_counter (
  input logic nRst, enable, clk,
  input logic [31:0] immJumpValue, regJumpValue,
  input logic doForceJump, doCondJump, condJumpValue, doRegJump,
  output logic [31:0] instructionAddress, linkAddress

);
  
  always_ff @( negedge clk, negedge nRst ) begin
    if(~nRst) begin
      instructionAddress <= 32'd0;
      linkAddress <= 32'd0;
    end else begin
      if (enable) begin


        if (doForceJump) begin
          linkAddress <= instructionAddress + 32'd4;
        end else begin
          linkAddress <= 32'd0;
        end

        if (doForceJump | (doCondJump & condJumpValue)) begin

          if (doRegJump & !doCondJump) begin
            instructionAddress <= regJumpValue + immJumpValue;
          end else begin
            instructionAddress <= instructionAddress + immJumpValue;
          end
        end else begin
          instructionAddress <= instructionAddress + 32'd4;
        end
      end else begin
        instructionAddress <= instructionAddress;
        linkAddress <= 32'd0;
      end
    end
  end


endmodule
    

