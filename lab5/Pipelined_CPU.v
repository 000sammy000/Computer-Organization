//110550142
`timescale 1ns / 1ps
// TA
module Pipe_CPU_1(
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

wire PC_w;
wire [1:0]ForwardA,ForwardB;
wire ifid_flush, ifid_write, idex_flush, exmem_flush;
/**** IF stage ****/
wire [31:0] IM_o,Add1_o,PC_i,PC_o,Branch_o;
wire Branch_sl;
/**** ID stage ****/
wire [31:0] IM_o_id,Add1_o_id,SE_o,RSdata,RTdata;
wire [4:0] RSaddr,RTaddr;
wire [1:0] ALUOp,RegDst,MemToReg,BranchType,Jump;
//wire [1:0] ALUOp_id,RegDst_id,MemToReg_id,BranchType_id,Jump_id;
wire ALUSrc,MemRead,MemWrite,RegWrite,Branch;
wire ALUSrc_id,MemRead_id,MemWrite_id,RegWrite_id,Branch_id;
wire Flush;
/**** EX stage ****/
wire [31:0] IM_o_ex,SE_o_ex,RDdata,RSdata_ex,RTdata_ex,Add1_o_ex,ALUSrc2,ALU_o,shft1_o,shft2_o,Add2_o;
wire [31:0] ALU_src1,ALU_src2;
wire [4:0]  RDaddr;
wire [4:0] RSaddr_ex,RTaddr_ex;
wire [3:0] ALUCtrl;
wire [1:0] ALUOp_ex,RegDst_ex,MemToReg_ex,BranchType_ex;
wire    ALUSrc_ex,MemRead_ex,MemWrite_ex,RegWrite_ex,Branch_ex,ALU_zero;

/**** MEM stage ****/
wire [31:0] RTdata_mem,ALU_o_mem,Add1_o_mem,Add2_o_mem,DM_o,SE_o_mem;
wire [31:0] ALU_src2_mem;
wire [4:0] RDaddr_mem;
wire [4:0] RSaddr_mem,RTaddr_mem;
wire [1:0] MemToReg_mem,BranchType_mem;
wire MemRead_mem,MemWrite_mem,RegWrite_mem,Branch_mem,ALU_zero_mem;

/**** WB stage ****/
wire [31:0] ALU_o_wb,DM_o_wb,RDdata_wb,SE_o_wb,Add1_o_wb;
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
        .select_i(Branch_mem & Branch_sl),
        .data_o(PC_i)
);


ProgramCounter PC(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .pc_write(PC_w),
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
        .flush(ifid_flush),
        .write(ifid_write),
        .data_i({IM_o,Add1_o}), //IM_o=32,Add1_o=32
        .data_o ({IM_o_id,Add1_o_id})
);
		




//Instantiate the components in ID stage
Hazard_Detection HD(
        .MemRead(MemRead_ex),
        .addr_id(IM_o_id[25:16]),
        .RTaddr_ex(IM_o_ex[20:16]),
        .branchTake(Branch_mem & Branch_sl),
        .pcwrite(PC_w),
        .write_ifid(ifid_write),
        .flush_ifid(ifid_flush),
        .flush_idex(idex_flush),
        .flush_exmem(exmem_flush)
);


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



Pipe_Reg #(.size(32*5+1*5+2*4)) ID_EX( // Modify N, which is the total length of input/output
        .clk_i(clk_i),
        .rst_i(rst_i),
        .flush(idex_flush),
        .write(1'b1),
        .data_i({IM_o_id,RSdata, RTdata,Add1_o_id,SE_o,ALUSrc,Branch
                    ,MemRead,MemWrite,RegWrite,ALUOp,MemToReg,RegDst,BranchType}),

        .data_o({IM_o_ex,RSdata_ex, RTdata_ex,Add1_o_ex,SE_o_ex,ALUSrc_ex,Branch_ex,MemRead_ex,MemWrite_ex,RegWrite_ex
                ,ALUOp_ex,MemToReg_ex,RegDst_ex,BranchType_ex})
);




//Instantiate the components in EX stage

MUX_4to1 #(.size(32)) Mux8( // Modify N, which is the total length of input/output
        .data0_i(RSdata_ex),
        .data1_i(RDdata),
        .data2_i(ALU_o_mem),
        .data3_i(ALU_o_mem),
        .select_i(ForwardA),
        .data_o(ALU_src1)    
);

Shift_Left_Two_32 Shifter(
        .data_i(SE_o_ex),
        .data_o(shft2_o)
);
ALU ALU(
        .src1_i(ALU_src1),
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


MUX_4to1 #(.size(32)) Mux9( // Modify N, which is the total length of input/output
        .data0_i(RTdata_ex),
        .data1_i(RDdata),
        .data2_i(ALU_o_mem),
        .data3_i(ALU_o_mem),
        .select_i(ForwardB),
        .data_o(ALU_src2)    
);


MUX_2to1 #(.size(32)) Mux1( // Modify N, which is the total length of input/output
        .data0_i(ALU_src2),
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
        .src2_i(shft2_o),
        .sum_o(Add2_o)
    
);

Forwarding_Unit FU(
        .RegWrite_mem(RegWrite_mem),
        .RegWrite_wb(RegWrite_wb),
        .RSaddr_ex(IM_o_ex[25:21]),
        .RTaddr_ex(IM_o_ex[20:16]),
        .RDaddr_mem(RDaddr_mem),
        .RDaddr_wb(RDaddr_wb),
        .forwarda(ForwardA),
        .forwardb(ForwardB)
);


Pipe_Reg #(.size(110)) EX_MEM(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.flush(exmem_flush),
    .write(1'b1),
    .data_i({ALU_o, Add2_o, RDaddr, ALU_src2, 
     RegWrite_ex, Branch_ex, MemRead_ex, MemWrite_ex, MemToReg_ex, ALU_zero, BranchType_ex}),
    .data_o({ALU_o_mem, Add2_o_mem, RDaddr_mem, ALU_src2_mem, 
     RegWrite_mem, Branch_mem, MemRead_mem, MemWrite_mem, MemToReg_mem, ALU_zero_mem, BranchType_mem})
);




//Instantiate the components in MEM stage
MUX_4to1 #(.size(1)) Mux4(
         .data0_i(ALU_zero_mem),
         .data1_i(~(ALU_o_mem[31]|ALU_zero_mem)),
         .data2_i(~ALU_o_mem[31]),
         .data3_i(~ALU_zero_mem),
         .select_i(BranchType_mem),
         .data_o(Branch_sl)
);

Data_Memory DM(
        .clk_i(clk_i),
        .addr_i(ALU_o_mem),
        .data_i(ALU_src2_mem),//
        .MemRead_i(MemRead_mem),
        .MemWrite_i(MemWrite_mem),
        .data_o(DM_o)
);

Pipe_Reg #(.size(72)) MEM_WB(
	.clk_i(clk_i),
    .rst_i(rst_i),
	.flush(1'b0),
    .write(1'b1),
	.data_i({DM_o, ALU_o_mem, RDaddr_mem, MemToReg_mem, RegWrite_mem}),
    	.data_o({DM_o_wb, ALU_o_wb, RDaddr_wb, MemToReg_wb, RegWrite_wb})
);


//Instantiate the components in WB stage

MUX_2to1 #(.size(32)) Mux3( // Modify N, which is the total length of input/output
        .data0_i(ALU_o_wb),
        .data1_i(DM_o_wb),
        .select_i(MemToReg_wb[0]),
        .data_o(RDdata)
);


endmodule