//Subject:     CO project 2 - Simple Single CPU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      ¶Àªé¬X110550142
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
`timescale 1ns/1ps
module Simple_Single_CPU(
        clk_i,
		rst_i
		);
		
//I/O port
input         clk_i;
input         rst_i;

//Internal Signles
wire RegWrite,RegDst,branch,ALU_zero,ALUSrc;
wire [2:0] ALUOp;
wire [3:0] ALUCtrl;
wire [4:0] RDaddr;
wire [31:0] PC_in,PC_out,Add1_o,Add2_o,Add2_i,IM_out,RDdata,RTdata,RSdata,SE_out,ALU_src2;
//Greate componentes
ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i (rst_i),     
	    .pc_in_i(PC_in) ,   
	    .pc_out_o(PC_out) 
	    );
	
Adder Adder1(
        .src1_i(32'd4),     
	    .src2_i(PC_out),     
	    .sum_o(Add1_o)    
	    );
	
Instr_Memory IM(
        .pc_addr_i(PC_out),  
	    .instr_o(IM_out)    
	    );

MUX_2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(IM_out[20:16]),
        .data1_i(IM_out[15:11]),
        .select_i(RegDst),
        .data_o(RDaddr)
        );	
		
Reg_File RF(
        .clk_i(clk_i),      
	    .rst_i(rst_i) ,     
        .RSaddr_i(IM_out[25:21]) ,  
        .RTaddr_i(IM_out[20:16]) ,  
        .RDaddr_i(RDaddr) ,  
        .RDdata_i(RDdata)  , 
        .RegWrite_i (RegWrite),
        .RSdata_o(RSdata) ,  
        .RTdata_o(RTdata)   
        );
	
Decoder Decoder(
        .instr_op_i(IM_out[31:26]), 
	    .RegWrite_o(RegWrite), 
	    .ALU_op_o(ALUOp),   
	    .ALUSrc_o(ALUSrc),   
	    .RegDst_o(RegDst),   
		.Branch_o(branch)   
	    );

ALU_Ctrl AC(
        .funct_i(IM_out[5:0]),   
        .ALUOp_i(ALUOp),   
        .ALUCtrl_o(ALUCtrl) 
        );
	
Sign_Extend SE(
        .data_i(IM_out[15:0]),
        .data_o(SE_out)
        );

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(RTdata),
        .data1_i(SE_out),
        .select_i(ALUSrc),
        .data_o(ALU_src2)
        );	
		
ALU ALU(
        .src1_i(RSdata),
	    .src2_i(ALU_src2),
	    .ctrl_i(ALUCtrl),
	    .result_o(RDdata),
		.zero_o(ALU_zero)
	    );
		
Adder Adder2(
        .src1_i(Add1_o),     
	    .src2_i(Add2_i),     
	    .sum_o(Add2_o)      
	    );
		
Shift_Left_Two_32 Shifter(
        .data_i(SE_out),
        .data_o(Add2_i)
        ); 		
		
MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(Add1_o),
        .data1_i(Add2_o),
        .select_i(branch & ALU_zero),
        .data_o(PC_in)
        );	

endmodule
