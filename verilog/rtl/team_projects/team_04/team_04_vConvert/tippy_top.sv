//CURRENT VERSION OF TIPPY_TOP, 1ST ITERATION
//INCLUDES REQUEST HANDLER


module tippy_top (
    input logic clk, nRst, button,

    input logic mem_busy, 
    input logic [31:0] data_from_mem,
    output logic mem_read, mem_write,
    output logic [31:0] adr_to_mem, data_to_mem,
    output logic [3:0] sel_to_mem,

    input logic Rx,

    output logic h_out, v_out, pixel_data,

    input [31:0] memory_size

    
);

    logic [31:0] CPU_instructions;
    logic [31:0] mem_data_to_CPU;
    logic [31:0] CPU_adr_to_mem;
    logic [31:0] CPU_data_to_mem;
    logic [31:0] CPU_instr_adr;
    logic CPU_read;
    logic CPU_write;
    logic [3:0] CPU_sel;
    logic CPU_enable;
    
    logic [31:0] VGA_request_address;
    logic [31:0] mem_data_to_VGA;
    logic [9:0] h_count;
    logic [8:0] v_count;
    logic [1:0] VGA_state;
    logic data_en;
    logic VGA_read;
    logic [31:0] data_to_VGA;
    logic [31:0] VGA_adr;

    logic VGA_enable;
    

    CPU cpu(
        .instruction(CPU_instructions),

        .clk(clk),
        .nrst(nRst),
        
        .data_from_mem(mem_data_to_CPU),

        .alu_result(), //ignore
        .reg_window(), //ignore
        .err_flag(), //ignore
        
        .addr_to_mem(CPU_adr_to_mem),
        .data_to_mem(CPU_data_to_mem),

        .nextInstruction(CPU_instr_adr),
        .MemWrite(CPU_write),
        .MemRead(CPU_read),
        .select(CPU_sel),

        .enable(CPU_enable)
    );

    
    VGA_data_controller VGA_data_control(
        .clk(clk),
        .nrst(nRst),
        .VGA_request_address(VGA_request_address),
        .data_from_SRAM(mem_data_to_VGA),
        .h_count(h_count),
        .v_count(v_count),
        .VGA_state(VGA_state),
        .byte_select_out(), //ignore
        .read(VGA_read),
        .data_to_VGA(data_to_VGA),
        .SRAM_address(VGA_adr)
    );


    
    VGA_out vga(
        .SRAM_data_in(data_to_VGA),
        //.SRAM_data_in({4{uart_out}}), 
        //.SRAM_data_in({32{1'b1}}), 
        .SRAM_busy(1'b0),
        
        .clk(clk),
        .nrst(nRst),

        .data_en(data_en),
        .h_out(h_out), //VGA Connect
        .v_out(v_out),  //VGA Connect
        .pixel_data(pixel_data), //VGA Connect
        .word_address_dest(VGA_request_address),
        .byte_select(), //ignore, redundant
        .VGA_state(VGA_state),

        .h_count(h_count),
        .v_count(v_count), //ignore
        .h_state(), //ignore
        .v_state() //ignore
    );


    logic [7:0] uart_out;
    logic uart_data_ready; // flags that the UART data is ready to be received

    UART_Receiver uart(
        .nRst(nRst), .clk(clk), .enable(1), .Rx(Rx),

        .data_out(uart_out),
        .data_ready(uart_data_ready), //flag is set to false only if data is being loaded into it, might be useless in hindsight

        .working_data(), //Ignore 
        .bits_received(), //Ignore
        .receiving(), //Ignore


        //SET HERE FOR TESTBENCH SAKE//////////////////////////////////
        .BAUD_counter(), //Ignore
        .parity_error() // ignore
    );

    request_handler reqhand
    (
        .clk(clk),
        .nRst(nRst),

        .mem_busy(mem_busy),
        // .VGA_state(2'b0), 
        .VGA_state(VGA_state),
        .CPU_enable(CPU_enable),
        .VGA_enable(VGA_enable),

        .VGA_read(VGA_read),
        // .VGA_adr(VGA_adr),
        .VGA_adr(memory_size - 32'd1536 + VGA_adr*4),
        // .data_to_VGA(VGA_adr),
        .data_to_VGA(mem_data_to_VGA),
        
        .data_from_UART({24'b0, uart_out}),

        .CPU_instr_adr(CPU_instr_adr),
        .CPU_data_adr(CPU_adr_to_mem),
        .CPU_read(CPU_read),
        .CPU_write(CPU_write),
        .data_from_CPU(CPU_data_to_mem),
        .CPU_sel(CPU_sel),
        .instr_data_to_CPU(CPU_instructions),
        .data_to_CPU(mem_data_to_CPU),

        .data_from_mem(data_from_mem),
        .mem_read(mem_read),
        // .mem_write(),
        .mem_write(mem_write),
        .adr_to_mem(adr_to_mem),
        // .data_to_mem(),
        .data_to_mem(data_to_mem),
        .sel_to_mem(sel_to_mem),

        .uart_address(memory_size - 32'd1532)
    );
    // assign mem_write = 1'b0;
    // assign data_to_mem = 32'h0;
    // //create mem
    // reg [31:0] instrMem [99:0];
    // initial begin
    //     $readmemh("instrList.txt", instrMem);
    // end

    always @(posedge mem_write) begin
        #(10) $display("@ %t: Writing %h %h", $time, adr_to_mem, data_to_mem);
    end

    always @(posedge mem_read) begin
        #(10) $display("@ %t: Reading %h %h", $time, adr_to_mem, data_to_mem);
    end

endmodule






typedef enum logic [3:0] {
    ADD=0, SUB=1, SLL=2, SLT=3, SLTU=4, XOR=5, SRL=6, SRA=7,OR=8, AND=9,
    BEQ=10, BNE=11, BLT=12, BGE=13, BLTU=14, BGEU=15, ERR = 4'bxxxx
    } operation_t;

module CPU (
    input logic [31:0] instruction, //instruction to CPU
    input logic clk, nrst, //timing & reset signals
    input logic [31:0] data_from_mem,
    output logic [31:0] alu_result,  //numerical/logical output of ALU
    output reg [31:0] [31:0] reg_window,
    // output logic ctrl_err, //error flag indicating invalid instruction (not w/in RISC-V 32I), from alu control
    output logic err_flag, //ALU flag invalid operation, from ALU
    output logic [31:0] addr_to_mem, data_to_mem,//signals from memory handler to mem
    output logic [31:0] nextInstruction, //next instruction address from PC

    output logic MemWrite, MemRead,
    output logic [3:0] select,

    input logic enable
    
);

    //wires name
    //from decoder
    logic [4:0] rs1, rs2, rd; 
    logic [6:0] opcode, func7;
    logic [2:0] func3;

    //from imm_gen
    logic [31:0] imm;

    //from control_unit
    logic [1:0] RegWriteSrc;
    logic ALUSrc, RegWrite, Jump, Branch, Error;

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

    //from PC
    logic [31:0]  PCData;
    // nextInstruction,;

    //instantiation of modules

    //decode data and addresses withing instruction
    decode decoder (
        .instruction(instruction), //32-bit instruction
        .rs1(rs1), //address of source register 1
        .rs2(rs2), //address of source register 2
        .rd(rd), //address of destination register
        .opcode(opcode), //7-bit Opcode (decoded from intrsuction)
        .ALUOp(func3), //3-bit function code (decoded from intrsuction)
        .func7(func7) //7-bit function code (decoded from intrsuction)
    );

    //genrate immediate value based on instruction format and values
    imm_gen make_imm (
        .instruction(instruction), //32-bit instruction
        .imm(imm), //32-bit genrated immediate value (signed)
        .flag() //error flag (ignore, used for tb)
        );

    //generate control signals based on Opcode
    control_unit cntrl (
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
    aluop_mux ALUOpB(
        .regB(regB), //value from register
        .imm(imm), //immediate value
        .alu_src(ALUSrc), //control signal
        .opB(opB) //resulting second operand
    ); 

    //perform arithmetic and logical operation
    alu ALU (
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
    reg_write_mux reg_write_control (
        .immData(imm), //immediate value
        .ALUData(alu_result_wire), //ALU result value
        .MemData(MemData), //memory value
        .PCData(PCData), //program counter value
        .DataWrite(DataWrite), //chosen value
        .RegWriteSrc(RegWriteSrc) //control signal
        );

    //read to and write from registers
    register_file regs (
        .read_addr_1(rs1), //read addresses
        .read_addr_2(rs2), 
        .write_addr(rd), //write address
        .reg_enable_write(RegWrite), //control signal enabling write
        .read_data_1(regA), //read values
        .read_data_2(regB), 
        .write_data(DataWrite), //value tobe written
        .clk(clk), 
        .nrst(nrst), 
        .reg_file(reg_window), //testbenching array
        .enable(enable)
        );

    memory_handler mem (
        .addr(alu_result_wire), //alu result, used as address
        .read_data_2(regB), 
        .data_from_mem(data_from_mem), //requested data from memory
        .en_read(MemRead), 
        .en_write(MemWrite), 
        .size(func3), 
        .select(select),//fixme to wishbone/request unit
        .data_to_reg(MemData),
        .addr_to_mem(addr_to_mem),
        .data_to_mem(data_to_mem),
        .mem_read(), //fixme
        .mem_write() //fixme
        );


    program_counter PC (
        .nRst(nrst),
        .enable(enable), //global enable from busy signal of wishbone fixme
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
module decode (
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
module imm_gen (
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
module control_unit (
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

    `default_nettype none

    //this module will be integrated in the top or regfile module
    module aluop_mux (
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

`default_nettype none

// typedef enum logic [3:0] {
//     ADD=0, SUB=1, SLL=2, SLT=3, SLTU=4, XOR=5, SRL=6, SRA=7,OR=8, AND=9, 
//     BEQ=10, BNE=11, BLT=12, BGE=13, BLTU=14, BGEU=15, ERR=4'b
//     } operation_t;

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
        alu_control_unit ex1 (.opcode(opcode), 
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

`default_nettype none

//FIXME: comment following typedef when using tb_alu
// typedef enum logic [3:0] {
    // ADD=0, SUB=1, SLL=2, SLT=3, SLTU=4, XOR=5, SRL=6, SRA=7,OR=8, AND=9,
    // BEQ=10, BNE=11, BLT=12, BGE=13, BLTU=14, BGEU=15, ERR = 4'bxxxx
    // } operation_t;

module alu_control_unit(
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


`default_nettype none

//this module will be integrated in the top or regfile module
module reg_write_mux (
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

module register_file(
    input logic [4:0] read_addr_1, read_addr_2, write_addr,
    input logic clk, nrst, reg_enable_write,
    input logic [31:0] write_data,
    output logic [31:0]  read_data_1, read_data_2,
    output reg [31:0]  [31:0] reg_file,
    input enable
);
    // logic [4:0] i;

    //assign reg_file[0] = 0;


    always_ff @(posedge clk, negedge nrst) begin
        if (~nrst) begin 
            for (integer i = 0; i < 32; i++) begin //
                reg_file[i] <= 32'b0;
            end
        end else if (write_addr != 5'd0 && reg_enable_write && enable) begin //ensure x0 never written to (maintain value of 0)
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


module memory_handler(
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
            data_to_mem = 0;
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
            data_to_mem = 0;
            data_to_reg = 0;
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
            mem_read = 0;
            mem_write = 0;
            select = 0;
            data_to_mem = 0;
            data_to_reg = 0;
            addr_to_mem = 0;
        end
    end

endmodule

module program_counter (
  input logic nRst, enable, clk,
  input logic [31:0] immJumpValue, regJumpValue,
  input logic doForceJump, doCondJump, condJumpValue, doRegJump,
  output logic [31:0] instructionAddress, linkAddress

);
  
  always_ff @( posedge clk, negedge nRst ) begin
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


module VGA_out(
    input logic [31:0] SRAM_data_in, // These are 32 bits that the VGA receives from memory that gets sent as pixel_data
    input logic SRAM_busy,          // SRAM busy flag, acts as an enable to send pixel_data
    input logic clk, nrst,
    output logic data_en, // Can be used for the read signal sent to the wishbone
    output logic h_out, v_out, pixel_data,   // outputs to the VGA plug in
    output logic [31:0] word_address_dest, // 32 bit address line that points to memory, VGA will only ever use 12 bits
    output logic [3:0] byte_select, // directly tied to the data_en output, says that it wants 4 bytes of data
    output logic [1:0] VGA_state, // 0 = inactive, 1 = about to be active, 2 = active

    //OUTPUTS ONLY FOR TEST BENCHING
    output logic [9:0] h_count,
    output logic [8:0] v_count,
    
    output logic [1:0] h_state, // can be eliminated after test benching
    output logic [1:0] v_state // can be eliminated after tesbenching
);
    logic [31:0] word_address_base; // A set value for the base address of the VGA memory information. 
    logic [8:0] word_address_offset; // points to the address range of 0x000 to 0x180
    logic change_state_h, change_state_v, v_count_toggle; 
    
    logic [9:0] h_next_count; // 0 to 640 // FOR TESTBENCHING ONLY /////////////////////////////////////////////
    logic [8:0] v_next_count; // 0 to 480 // FOR TESTBENCHING ONLY /////////////////////////////////////////////
   
//    logic [9:0] h_count, h_next_count; // 0 to 640 // FOR ACTUAL USE /////////////////////////////////////////
//    logic [8:0] v_count, v_next_count; // 0 to 480 // FOR ACTUAL USE /////////////////////////////////////////
    logic [8:0] h_offset; // h count math for appropriate word address offset
    logic [8:0] v_offset; // v count math for appropriate word address offset
    logic [4:0] x_coord; // address for the 32 bit of information received from SRAM
    logic [31:0] current_word, next_word; // used for calling the next line of info from SRAM and having it on standby
    
    //assign word_address_base = 32'h3E80; // Word address base for the actual SRAM
    assign word_address_base = 32'h0; // Word address base for test benching purposes

    // Enum for H_STATES
    typedef enum logic [1:0] {
            h_sync = 2'b00,
            h_backporch =  2'b01,
            h_active = 2'b10,
            h_frontporch = 2'b11
    } h_mode; 

    // Enum for STATES
    typedef enum logic [1:0] {
            v_sync = 2'b00,
            v_backporch =  2'b01,
            v_active = 2'b10,
            v_frontporch = 2'b11
    } v_mode; 


    h_mode h_current_state, h_next_state;
    // HSYNC Counter
    always_ff @(posedge clk, negedge nrst) begin
        if (~nrst) begin
            h_current_state <= h_sync;
            h_count <= 0;
        end else begin
            h_current_state <= h_next_state;
            h_count <= h_next_count;
        end

    end

        v_mode v_current_state, v_next_state;
    // VSYNC Counter
    always_ff @(posedge clk, negedge nrst) begin
        if (~nrst) begin
            v_current_state <= v_sync;
            v_count <= 0;
        end else begin
            v_current_state <= v_next_state;
            v_count <= v_next_count;
        end
    end


        // Changes the VGA_State signal to notify 'Request Handler' the current active state of the VGA
    always_comb begin
        if ((v_current_state == v_active) & (v_count < 384)) begin
            VGA_state = 2'b10;
        end else if ((v_current_state == v_backporch) & (v_count > 9'd31)) begin
            VGA_state = 2'b01;
        end else begin
            VGA_state = 2'b00;
        end
    end


    // HSYNC State Machine
    always_comb begin
        h_next_count = h_count;
        case (h_current_state) 
            h_sync: begin
                h_state = 2'b00; // can be eliminated after tesbenching
                v_count_toggle = 0;
                if (h_count < 37) begin //10 MHz // 12 MHz = 45
                    h_next_count = h_next_count + 1'b1;
                    h_out = 0;
                    h_next_state = h_sync;
                end else begin
                    h_next_count = 0;
                    h_out = 1;
                    h_next_state = h_backporch;
                end
            end
            

            h_backporch: begin
                h_state = 2'b01; // can be eliminated after tesbenching
                h_out = 1;
                v_count_toggle = 0;
                if (h_count < 18) begin //10 MHz // 12 MHz = 22
                    h_next_count = h_next_count + 1'b1;
                    h_next_state = h_backporch;
                end else begin
                    h_next_count = 0;
                    h_next_state = h_active;
                end
            end

            h_active: begin
                h_state = 2'b10; // can be eliminated after tesbenching
                h_out = 1;
                v_count_toggle = 0;
                if (h_count < 256) begin //10 MHz // 12 MHz = 304
                    h_next_count = h_next_count + 1'b1;
                    h_next_state = h_active;
                end else begin
                    h_next_count = 0;
                    h_next_state = h_frontporch;
                end

            end

            h_frontporch: begin
                h_state = 2'b11; // can be eliminated after tesbenching
                h_out = 1;
                if (h_count < 5) begin //10 MHz // 12 MHz = 6
                    h_next_count = h_next_count + 1'b1;
                    h_next_state = h_frontporch;
                    v_count_toggle = 0;
                end else begin
                    h_next_count = 0;
                    h_next_state = h_sync;
                    v_count_toggle = 1;
                end
            end
        endcase
    end



    // VSYNC State Machine
    always_comb begin
        v_next_count = v_count;
        if (v_count_toggle) begin
            v_next_count = v_next_count + 1'b1;
        end
        case (v_current_state) 
            v_sync: begin
                v_state = 2'b00; // can be eliminated after tesbenching
                if (v_count < 2) begin 
                    v_out = 0;
                    v_next_state = v_sync;
                end else begin
                    v_next_count = 0;
                    v_out = 1;
                    v_next_state = v_backporch;
                end
            end
            

            v_backporch: begin
                v_state = 2'b01; // can be eliminated after tesbenching
                v_out = 1;
                if (v_count < 33) begin
                    v_next_state = v_backporch;
                end else begin
                    v_next_count = 0;
                    v_next_state = v_active;
                end
            end

            v_active: begin
                v_state = 2'b10;// can be eliminated after tesbenching
                v_out = 1;
                if (v_count < 480) begin
                    v_next_state = v_active;
                end else begin
                    v_next_count = 0;
                    v_next_state = v_frontporch;
                end

            end

            v_frontporch: begin
                v_state = 2'b11;// can be eliminated after tesbenching
                v_out = 1;
                if (v_count < 10) begin
                    v_next_state = v_frontporch;
                end else begin
                    v_next_count = 0;
                    v_next_state = v_sync;
                end
            end
        endcase
    end


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // WE CAN WORRY ABOUT HOW WE ARE GOING TO WORK WITH OUR TIMING TO MAKE SURE THAT OUR DATA BIT COMES WHEN WE WANT IT TO //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Correct Pixel data only sends if enable and ~busy flag are toggled
    always_comb begin
        if (~SRAM_busy & data_en) begin
            pixel_data = SRAM_data_in[x_coord];
        end else begin
            pixel_data = 0;
        end
    end

    // IF BOTH STATES ARE ACTIVE AND THE COUNT IS WITHIN OUR DISPLAY DIMENSIONS, DATA TRANSACTION IS ENABLED
    always_comb begin                                                       // 256 for 2 pixels ber pit, 384 for 5 lines before new data
        if ((h_current_state == h_active) & (v_current_state == v_active) & (h_count < 256) & (v_count < 480)) begin
            data_en = 1;
        end else begin
            data_en = 0;
        end 
    end

    // BYTE SELECT TOGGLES ALL BYTES IF DATA TRANSACTION IS ENABLED, OTHERWISE IT NEVER REQUESTS ANY BITS  
    assign byte_select = {data_en, data_en, data_en, data_en};



    always_comb begin
    ////////////////////////////////////POTENTIAL FOR ADDING AN ENABLE HERE TO OPTIMIZE/////////////////////////////////////////
        h_offset = {7'b0, h_count[7:6]};  // sets h offset to hcount up until 32
        v_offset = 7'd4 * (v_count / 9'd5);            // sets v offset to vcount * 4 // [8:2] accounts for after 4 lines we get a new offset of info
        word_address_offset = h_offset + v_offset; // sets word offset to the total of h and v offsets
    end

    assign word_address_dest = word_address_base + {23'b0, word_address_offset}; 

    // setting up X coordinate logic for reading from our SRAM Bytes
    // the first 5 bits just loop after every multiple of 32
    //assign x_coord = h_count[4:0]; // READING FROM RIGHT TO LEFT
    assign x_coord = 5'b11111 - h_count[5:1]; // READING FROM LEFT TO RIGHT, every 2 pixel, next bit


endmodule

module VGA_data_controller (
    input logic clk, nrst,
    input logic [31:0] VGA_request_address, data_from_SRAM,
    input logic [9:0] h_count,
    input logic [8:0] v_count,
    input logic [1:0] VGA_state,
    input logic mem_busy,
    output logic [3:0] byte_select_out,
    output logic read,
    output logic [31:0] data_to_VGA, SRAM_address
);

    logic [31:0] next_data, next_address, ready_data;

    always_comb begin
        if (VGA_state > 0) begin
            read = 1'b1;
            byte_select_out = 4'b1111;
        end else begin
            read = 1'b0;
            byte_select_out = 4'b0000;
        end
    end

    typedef enum logic [1:0] {
        IDLE,
        PREPARE_DATA,
        LOAD_NEW_REGISTER
    } state_type;

    state_type state, next_state;

    always_ff @(posedge clk, negedge nrst) begin
        if(~nrst) begin
            state <= IDLE;
            data_to_VGA <= 32'b0;
            SRAM_address <= 32'b0;
        end else begin
            state <= next_state;
            data_to_VGA <= next_data;
            SRAM_address <= next_address;
        end
    end

    always_comb begin
        next_data = data_to_VGA;
        next_address = SRAM_address;
        ready_data = data_from_SRAM;
            case (state)
                IDLE: begin
                    next_data = data_from_SRAM;
                    ready_data = data_from_SRAM;
                    next_state = LOAD_NEW_REGISTER;
                    next_address = SRAM_address;
                end

                LOAD_NEW_REGISTER: begin
                    next_data = ready_data;
                    next_address = SRAM_address;
                    next_state = PREPARE_DATA;
                end

                PREPARE_DATA: begin
                    if (~mem_busy) begin
                        ready_data = data_from_SRAM;
                    end
                    if ((VGA_state == 1)) begin // preparing first word 
                      //SRAM_address <= 32'h3E80; // base of SRAM storage
                        next_address = 32'h0; // TESTBENCH CASE
                        next_data = ready_data;
                        next_state = LOAD_NEW_REGISTER;
                    end
                    
                    else if (h_count[5:0] == 62) begin
                        next_state = LOAD_NEW_REGISTER;
                    end else if ((h_count[7:6] == 3) & ((v_count % 5) != 4))begin
                        next_address = VGA_request_address - 3; // preparing next word 
                        next_data = data_to_VGA;
                        
                        next_state = PREPARE_DATA;
                    end else begin
                        next_address = VGA_request_address + 1; // preparing next word 
                        next_data = data_to_VGA;
                        next_state = PREPARE_DATA;
                    end

                end

                default: next_state = IDLE;
            endcase
        end

endmodule




typedef enum logic { 
  RESET = 1'b0,
  COUNTING = 1'b1
} BAUD_counter_state_t;


module UART_Receiver #(
  parameter BAUD_RATE = 9600,
  parameter CLOCK_FREQ = 10000000,
  parameter CYCLES_PER_BIT = CLOCK_FREQ / BAUD_RATE //number of clock cycles per UART bit
) (
  input logic nRst, clk, enable, Rx,
  output logic [7:0] data_out,
  output logic data_ready, //flag is set to false only if data is being loaded into it

  output logic [8:0] working_data, //NOTE TO SELF: move back inside module    // This needs to be 9 bits long now to include 8 data bits + parity bit
  output logic [3:0] bits_received, //NOTE TO SELF: move back inside module   // 
  output logic receiving, //NOTE TO SELF: move back inside module


  //SET HERE FOR TESTBENCH SAKE//////////////////////////////////
  output logic [31:0] BAUD_counter, //NOTE TO SELF: figure out if this is an appropriate bus size
  output logic parity_error
);

  //
  //
  //  parity_error <= (^rx_shift[8:1]) != rx_shift[9]; // Parity error is high if the XOR of data_out
  //  parity error will affect data_ready and not allow data to be sent
  //  
  //
  
  //logic [6:0] working_data;
  //logic receiving;
  //logic [2:0] bits_received;
  // logic push_working_data;
  BAUD_counter_state_t BAUD_counter_state;
  //logic [15:0] BAUD_counter, //NOTE TO SELF: figure out if this is an appropriate bus size
  //logic parity_error                          ADDED TO TOPSET OUTPUT FOR TESTBENCH SAKE, REMOVE COMMENT TOGGLE WHEN ACTUAL IS UPON US

  

  always_ff @( posedge clk, negedge nRst ) begin //BAUD counter
    if (~nRst) begin
      BAUD_counter <= 0;
    end else begin
      if(BAUD_counter_state == RESET | BAUD_counter == CYCLES_PER_BIT) begin //NOTE TO SELF: this may have an extra cycle per bit, but it should be fine i think
        BAUD_counter <= 0;
      end else begin
        BAUD_counter <= BAUD_counter+1;
      end
    end
  end

  assign parity_error = 0; // May not work idk, we will see when we try and run it. However, this is the accurate logic info for parity error

  always_ff @( posedge clk, negedge nRst ) begin //data loader
    if (~nRst) begin //reset
      data_out <= 8'b0;
      working_data <= 9'b0;
      receiving <= 1'b0;
      bits_received <= 4'b0;
      data_ready <= 1'b0;
      BAUD_counter_state <= RESET;

    end else begin

      if(enable) begin

        if (receiving) begin
          BAUD_counter_state <= COUNTING; 
          
          if(BAUD_counter == CYCLES_PER_BIT) begin //wait till clock cycle sync up with BAUD rate 

            if (bits_received == 4'd9) begin //last bit received, send data out
              
              if (~parity_error) begin
                data_out <= working_data[8:1]; // CHANGED TO THIS IN ORDER TO SEND OUT OUR 8 BITS OF USABLE DATA
                working_data <= working_data;  // I HAVE MY CONCERNS ON WHETHER OR NOT THIS IS PLAUSIBLE, CONSIDERING DATA_OUT IS ALSO BEING SET TO WORKING_DATA
                                       // I suggest leaving it as is and letting the reset state have its way with the working data
                receiving <= 1'b0;
                bits_received <= 4'b0;
                data_ready <= 1'b1; // Flags that data is ready to transfer
                BAUD_counter_state <= RESET; 

              end else begin
                data_out <= data_out; // CHANGED TO THIS IN ORDER TO SEND OUT OUR 8 BITS OF USABLE DATA
                working_data <= 9'b0;
                receiving <= 1'b0;
                bits_received <= 4'b0;
                data_ready <= 1'b0;
                BAUD_counter_state <= RESET; 
              end


            end else begin //not enough bits received 
              
              data_out <= data_out;
              working_data <= {Rx, working_data[8:1]};
              receiving <= 1'b1;
              bits_received <= (bits_received + 1);
              data_ready <= 1'b0;
              BAUD_counter_state <= COUNTING;
            end

          end else if ((BAUD_counter == (CYCLES_PER_BIT/2)) & (bits_received == 0))begin
            data_out <= data_out;
            working_data <= working_data;
            receiving <= 1'b1;
            bits_received <= bits_received + 1;
            data_ready <= 1'b0;
            BAUD_counter_state <= RESET;
          end

        end else begin //not receiving any information

          if(Rx == 1'b0) begin //start bit received

            data_out <= data_out;
            working_data <= 9'b0;
            receiving <= 1'b1;
            bits_received <= 4'b0;
            data_ready <= 1'b0;
            BAUD_counter_state <= COUNTING;

          end else begin //no start bit, keep waiting
            
            data_out <= data_out;
            working_data <= 9'b0;
            receiving <= 1'b0;
            bits_received <= 4'b0;
            data_ready <= 1'b0;
            BAUD_counter_state <= RESET;

          end

        end
        
      end else begin //if disabled, reset all values
        data_out <= 8'b0; // MAYBE WANT TO KEEP DATA OUT AS IS, THAT WAY THE REGISTER INFORMATION ISNT CHANGED BEFORE A NEW INPUT IS GIVEN
        working_data <= 9'b0;
        receiving <= 1'b0;
        bits_received <= 4'b0;
        data_ready <= 1'b0;
        BAUD_counter_state <= RESET;
      end

    end
  end

endmodule

typedef enum logic [1:0] {
    INACTIVE = 2'd0,
    READY = 2'd1,
    ACTIVE = 2'd2
} VGA_state_t;

typedef enum logic [1:0] {
    STANDBY = 2'd0,
    VGA = 2'd1,
    CPU_INSTR = 2'd2,
    CPU_DATA = 2'd3
} client_t;

module request_handler (
    input logic clk,
    input logic nRst,

    //signals for controlling inputs/outputs
    input logic mem_busy,
    input VGA_state_t VGA_state,
    output logic CPU_enable,
    output logic VGA_enable,

    //signals to/from VGA
    input logic VGA_read,
    input logic [31:0] VGA_adr,
    output logic [31:0] data_to_VGA,

    //signals to/from UART
    input logic [31:0] data_from_UART,

    //signals to/from CPU
    input logic [31:0] CPU_instr_adr,
    input logic [31:0] CPU_data_adr,
    input logic CPU_read,
    input logic CPU_write,
    input logic [31:0] data_from_CPU,
    input logic [3:0] CPU_sel,
    output logic [31:0] instr_data_to_CPU,
    output logic [31:0] data_to_CPU,

    //signals to/from memory/Wishbone
    input logic [31:0] data_from_mem,
    output logic mem_read,
    output logic mem_write,
    output logic [31:0] adr_to_mem,
    output logic [31:0] data_to_mem,
    output logic [3:0] sel_to_mem,

    input logic [31:0] uart_address

);

    logic prev_busy, busy_edge;
    // handler_state_t handler_state, next_handler_state;
    client_t current_client, next_client;//, next_client_next;
    logic [31:0] instruction, next_instruction;
    always_ff @( posedge clk, negedge nRst ) begin
        if(~nRst) begin
            // handler_state <= WAITING;

            current_client <= STANDBY;
            //next_client <= STANDBY;

            instruction <= 32'b0;
        end else begin
            // handler_state <= next_handler_state;

            current_client <= next_client;
            //next_client <= next_client_next;

            instruction <= next_instruction;  
            
        end
    end

    // assign next_client = next_client;

    always_ff @(posedge clk, negedge nRst ) begin
        if (!nRst) begin
            prev_busy <= 1'b0;
        end else begin
            prev_busy <= mem_busy;
        end
    end
    
    assign busy_edge = (prev_busy && !mem_busy);

    always_comb begin
        next_client = current_client;
        if (!mem_busy) begin
            if (current_client == STANDBY) begin
                next_client = CPU_INSTR;
            end else if (current_client == VGA) begin
                if (VGA_state == ACTIVE | VGA_state == READY) begin
                    next_client = VGA;
                end else begin
                    next_client = CPU_INSTR;
                end
            end else if (current_client == CPU_INSTR) begin
                next_client = CPU_DATA;
            end else begin //current_client == CPU_DATA
                if (VGA_state == INACTIVE) begin
                    next_client = CPU_INSTR;
                end else begin
                    next_client = VGA;
                end
            end
        end
        
        //logic for sending data to mem
        if (mem_busy || (next_client == STANDBY)) begin
            mem_read =      1'b0;
            mem_write =     1'b0;
            adr_to_mem =    32'b0;
            data_to_mem =   32'b0;
            sel_to_mem =    4'b0;

            if(current_client == VGA) begin
                adr_to_mem =    VGA_adr;
            end else if (current_client == CPU_INSTR) begin
                adr_to_mem =    CPU_instr_adr;
            end else begin
                if(CPU_data_adr == uart_address) begin
                    adr_to_mem =    32'h0;
                end else begin
                    adr_to_mem =    CPU_data_adr;
                    data_to_mem =   data_from_CPU;
                    sel_to_mem =    CPU_sel;
                    mem_write = CPU_write; //added
                    mem_read = CPU_read; //added
                end
            end
        end else begin
            if (next_client == VGA) begin
                mem_read =      VGA_read;
                mem_write =     1'b0;
                adr_to_mem =    VGA_adr;
                data_to_mem =   32'b0;
                sel_to_mem =    4'b1111;
            end else if (next_client == CPU_INSTR) begin
                mem_read =      1'b1;
                mem_write =     1'b0;
                if(current_client == CPU_DATA) begin
                    adr_to_mem =    CPU_instr_adr + 32'd4;
                end else begin
                    adr_to_mem =    CPU_instr_adr;
                end
                data_to_mem =   32'b0;
                sel_to_mem =    4'b1111;
            end else begin // next_client == CPU_DATA
                if (CPU_data_adr == uart_address) begin
                    mem_read =      1'b0;
                    mem_write =     1'b0;
                    adr_to_mem =    32'h0;
                    data_to_mem =   32'h0;
                    sel_to_mem =    4'b0;
                end else begin
                    if(~mem_busy) begin
                        mem_write =     CPU_write;    
                    end else begin
                        mem_write = 1'b0;
                    end
                    mem_read =      CPU_read;
                    
                    adr_to_mem =    CPU_data_adr;
                    data_to_mem =   data_from_CPU;
                    sel_to_mem =    CPU_sel;
                end
            end    
        end
        
        

        //logic for sending data to other parts (VGA,CPU)
        if(~mem_busy && next_client == CPU_DATA) begin
            instr_data_to_CPU = data_from_mem;
        end else begin
            instr_data_to_CPU = instruction;    
        end

        
        if (mem_busy | current_client == STANDBY) begin
            data_to_VGA =       32'b0;
            next_instruction =  instruction;
            data_to_CPU =       32'b0;
        end else begin
            if (current_client == VGA) begin
                data_to_VGA =       data_from_mem;
                next_instruction =  32'b0;
                data_to_CPU =       32'b0;
            end else if (current_client == CPU_INSTR) begin
                data_to_VGA =       32'b0;
                next_instruction =  data_from_mem;
                data_to_CPU =       32'b0;
            end else begin // current_client == CPU_DATA
                data_to_VGA =       32'b0;
                next_instruction =  instruction;
                if (CPU_data_adr == uart_address) begin
                    data_to_CPU = data_from_UART;
                end else begin
                    data_to_CPU = data_from_mem;
                end
            end    
        end


        //logic for controlling enable signals
        if(~mem_busy & current_client == CPU_DATA) begin
            CPU_enable = 1'b1;
        end else begin
            CPU_enable = 1'b0;
        end
        if(~mem_busy & current_client == VGA) begin
            VGA_enable = 1'b1;
        end else begin
            VGA_enable = 1'b0;
        end
        
    end



endmodule



// module ram (
//     input logic clk, rst,
//     input logic [31:0] data_address, // alu result to be read or written
//     input logic [31:0] instruction_address, // no brainer, it is the insturction address
//     input logic dm_read_en, dm_write_en, // enable ports for the read and enable
//     input logic [31:0] data_to_write, // data to be written into memory
//     output logic [31:0] instruction_read, data_read // things we got from memory dude
// );

// logic [31:0] mem [4095:0];
// initial $readmemh("instrList.txt", mem, 0, 4095);

// always_ff @(posedge clk) begin
//     if (dm_write_en) begin
//         mem[data_address] <= data_to_write;
//     end

// end

// always_ff @(posedge clk, negedge rst) begin
//     if (!rst) begin
//         data_read <= '0;
//         instruction_read <= mem[32'b0];
//     end

//     else if (dm_read_en) begin
//         data_read <= mem[data_address];

//     end
    
//     else if (!dm_read_en) begin
//         instruction_read <= mem[instruction_address];

//     end

//     else begin
//         instruction_read <= 32'b00000000000000000000000000010011;
//         data_read <= '0;

//     end
// end



// endmodule