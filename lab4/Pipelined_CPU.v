//110550142
`timescale 1ns / 1ps
// TA
module Pipelined_CPU(
    clk_i,
    rst_i
);
    
/*==================================================================*/
/*                          input & output                          */
/*==================================================================*/

input clk_i;
input rst_i;

/*==================================================================*/
/*                            reg & wire                            */
/*==================================================================*/

/**** IF stage ****/
wire [31:0] IM_o,Add1_o,PC_i,PC_o;
/**** ID stage ****/
wire [31:0] IM_o_id,Add1_o_id,SE_o,RSdata,RTdata;
wire [1:0] ALUOp,RegDst,MemToReg,BranchType,Jump;
wire ALUSrc,MemRead,MemWrite,RegWrite,Branch;
/**** EX stage ****/
wire [31:0] IM_o_ex,SE_o_ex,RDdata,RSdata_ex,RTdata_ex,Add1_o_ex,ALUSrc2,ALU_o,shft1_o,Add2_o;
wire [4:0]  RDaddr;
wire [3:0] ALUCtrl;
wire [1:0] ALUOp_ex,RegDst_ex,MemToReg_ex;
wire    ALUSrc_ex,MemRead_ex,MemWrite_ex,RegWrite_ex,Branch_ex,ALU_zero;

/**** MEM stage ****/
wire [31:0] RTdata_mem,ALU_o_mem,Add2_o_mem,DM_o;
wire [4:0] RDaddr_mem;
wire [1:0] MemToReg_mem;
wire MemRead_mem,MemWrite_mem,RegWrite_mem,Branch_mem,ALU_zero_mem;

/**** WB stage ****/
wire [31:0] ALU_o_wb,DM_o_wb;
wire [4:0] RDaddr_wb;
wire [1:0] MemToReg_wb;
wire RegWrite_wb;

/*==================================================================*/
/*                              design                              */
/*==================================================================*/

//Instantiate the components in IF stage

MUX_2to1 #(.size(32)) Mux0( // Modify N, which is the total length of input/output
        .data0_i(Add1_o),
        .data1_i(Add2_o_mem),
        .select_i(Branch_mem & ALU_zero_mem),
        .data_o(PC_i)
);

ProgramCounter PC(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .pc_in_i(PC_i),
        .pc_out_o(PC_o)
);

Instruction_Memory IM(
        .addr_i(PC_o),
        .instr_o(IM_o) 
);
			
Adder Add_pc(
        .src1_i(32'd4),
        .src2_i(PC_o),
        .sum_o(Add1_o)
);
		
Pipe_Reg #(32*2) IF_ID( // Modify N, which is the total length of input/output
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i({IM_o,Add1_o}), //IM_o=32,Add1_o=32
        .data_o ({IM_o_id,Add1_o_id})
);


//Instantiate the components in ID stage

Reg_File RF(
        .clk_i(clk_i),      
	    .rst_i(rst_i) ,     
        .RSaddr_i(IM_o_id[25:21]) ,  
        .RTaddr_i(IM_o_id[20:16]) ,  
        .RDaddr_i(RDaddr_wb) ,  
        .RDdata_i(RDdata)  , 
        .RegWrite_i (RegWrite_wb),
        .RSdata_o(RSdata) ,  
        .RTdata_o(RTdata)   
    
);

Decoder Control(
        .instr_op_i(IM_o_id[31:26]),
        .funct_i(IM_o_id[5:0]),
        .RegWrite_o(RegWrite),
        .ALU_op_o(ALUOp),
        .ALUSrc_o(ALUSrc),
        .RegDst_o(RegDst),
        .Branch_o(Branch),
        .BranchType_o(BranchType),
        .Jump_o(Jump),
        .MemRead_o(MemRead),
        .MemWrite_o(MemWrite),
        .MemtoReg_o(MemToReg)
    
);

Sign_Extend SE(
        .data_i(IM_o_id[15:0]),
        .data_o(SE_o)
);

Pipe_Reg #(.size(32*5+1*5+2*3)) ID_EX( // Modify N, which is the total length of input/output
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i({IM_o_id,RSdata, RTdata,Add1_o_id,SE_o,ALUSrc,Branch,MemRead,MemWrite,RegWrite,ALUOp,MemToReg,RegDst}),
        //IM_o_id=32, RSdata=32, RTdata=32,Add1_o_id=32,SE_o=32,ALUSrc=1,Branch=1,MemRead=1,MemWrite=1,RegWrite=1,ALUOp=2, MemToReg=2,RegDst=2
        .data_o({IM_o_ex,RSdata_ex, RTdata_ex,Add1_o_ex,SE_o_ex,ALUSrc_ex,Branch_ex,MemRead_ex,MemWrite_ex,RegWrite_ex
                ,ALUOp_ex,MemToReg_ex,RegDst_ex})
);


//Instantiate the components in EX stage

Shift_Left_Two_32 Shifter(
        .data_i(SE_o_ex),
        .data_o(shft1_o)
);

ALU ALU(
        .src1_i(RSdata_ex),
        .src2_i(ALUSrc2),
        .ctrl_i(ALUCtrl),
        .result_o(ALU_o),
        .zero_o(ALU_zero)
);
		
ALU_Ctrl ALU_Control(
        .funct_i(IM_o_ex[5:0]),   
        .ALUOp_i(ALUOp_ex),   
        .ALUCtrl_o(ALUCtrl) 
    
);

MUX_2to1 #(.size(32)) Mux1( // Modify N, which is the total length of input/output
        .data0_i(RTdata_ex),
        .data1_i(SE_o_ex),
        .select_i(ALUSrc_ex),
        .data_o(ALUSrc2)
);
		
MUX_2to1 #(.size(5)) Mux2( // Modify N, which is the total length of input/output
        .data0_i(IM_o_ex[20:16]),
        .data1_i(IM_o_ex[15:11]),
        .select_i(RegDst_ex[0]),
        .data_o(RDaddr)    
);

Adder Add_pc_branch(
        .src1_i(Add1_o_ex),
        .src2_i(shft1_o),
        .sum_o(Add2_o)
    
);

Pipe_Reg #(.size(32*3+1*5+2+5)) EX_MEM( // Modify N, which is the total length of input/output
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i({RTdata_ex,Add2_o,ALU_o,Branch_ex,MemRead_ex,MemWrite_ex,RegWrite_ex,ALU_zero,MemToReg_ex,RDaddr}),
        //RTdata_ex=32, Add2_o=32, ALU_o,Branch_ex,MemRead_ex,MemWrite_ex,RegWrite_ex,ALU_zero,MemToReg_ex,RDaddr
        .data_o({RTdata_mem,Add2_o_mem,ALU_o_mem,Branch_mem,MemRead_mem,MemWrite_mem,RegWrite_mem,ALU_zero_mem,MemToReg_mem,RDaddr_mem}) 
);


//Instantiate the components in MEM stage

Data_Memory DM(
        .clk_i(clk_i),
        .addr_i(ALU_o_mem),
        .data_i(RTdata_mem),
        .MemRead_i(MemRead_mem),
        .MemWrite_i(MemWrite_mem),
        .data_o(DM_o)
);

Pipe_Reg #(.size(5+32*2+1+2)) MEM_WB( // Modify N, which is the total length of input/output
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i({RDaddr_mem,ALU_o_mem,DM_o,RegWrite_mem,MemToReg_mem}),
        .data_o({RDaddr_wb,ALU_o_wb,DM_o_wb,RegWrite_wb,MemToReg_wb}) 
);


//Instantiate the components in WB stage

MUX_2to1 #(.size(32)) Mux3( // Modify N, which is the total length of input/output
        .data0_i(ALU_o_wb),
        .data1_i(DM_o_wb),
        .select_i(MemToReg_wb[0]),
        .data_o(RDdata)
);


endmodule