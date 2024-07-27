//110550142
//Subject:     CO project 2 - Decoder
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      110550142
//----------------------------------------------
//Date:        2010/8/16
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Decoder(
    instr_op_i,
    funct_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
	RegDst_o,
	Branch_o,
	BranchType_o,
	Jump_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o

	);
     
//I/O ports
input  [6-1:0] instr_op_i;
input  [6-1:0] funct_i;
output         RegWrite_o;
output [2-1:0] ALU_op_o;
output         ALUSrc_o;
output [2-1:0] RegDst_o;
output         Branch_o;
output [2-1:0] BranchType_o;
output [2-1:0] Jump_o;
output	       MemRead_o;
output	       MemWrite_o;
output	[1:0]  MemtoReg_o;
 
//Internal Signals
reg    [1:0]   ALU_op_o;
reg            ALUSrc_o;
reg            RegWrite_o;
reg    [1:0]   RegDst_o;
reg            Branch_o;
reg    [1:0]   BranchType_o;
reg            MemRead_o;
reg            MemWrite_o;
reg	 [1:0]     MemtoReg_o;
reg    [1:0] Jump_o;
//Parameter


//Main function
always@(instr_op_i,funct_i)begin
    Branch_o<=instr_op_i[2];
    MemRead_o<= instr_op_i == 6'b100011;//lw
    MemWrite_o<=instr_op_i == 6'b101011;//sw
    case(instr_op_i)
        6'b000100:BranchType_o<=2'b00;
        6'b000101:BranchType_o<=2'b11;
        6'b000001:BranchType_o<=2'b10;
        6'b000111:BranchType_o<=2'b10;
    endcase
    case(instr_op_i)
        6'b000100:ALU_op_o<=2'b01;//beq
        6'b001010:ALU_op_o<=2'b11;//slti
        6'b000000:ALU_op_o<=2'b10;//r-type
        default:ALU_op_o<=2'b00;
    endcase
    case(instr_op_i)
        6'b001000:ALUSrc_o<=1'b1;
        6'b001010:ALUSrc_o<=1'b1;
        6'b100011:ALUSrc_o<=1'b1;
        6'b101011:ALUSrc_o<=1'b1;
        default:ALUSrc_o<=1'b0;
    endcase
    
    case(instr_op_i)
        6'b000010:Jump_o<=2'b00;//jump
        6'b000011:Jump_o<=2'b00;//jal
        6'b000000:case(funct_i)
            6'b001000: Jump_o<=2'b10;//jump reg
            default:Jump_o<=2'b01;
        endcase
        default: Jump_o<=2'b01;
     endcase
     case(instr_op_i)
        6'b000011:MemtoReg_o <=2'b11;//jal
        6'b100011:MemtoReg_o <=2'b01;//lw
        default:MemtoReg_o <=2'b00;
     endcase
     case(instr_op_i)
        6'b000011:RegDst_o<=2'b10;
        6'b000000:RegDst_o<=2'b01;
        default:RegDst_o<=2'b00;
     endcase
      
     case(instr_op_i)
        6'b000000:RegWrite_o<=1;
        6'b001000:RegWrite_o<=1;
        6'b001010:RegWrite_o<=1;
        6'b100011:RegWrite_o<=1;
        6'b000011:RegWrite_o<=1;
        default:RegWrite_o<=0;
        
     endcase  
     
end


endmodule        