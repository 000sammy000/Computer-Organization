//110550142
//Subject:     CO project 2 - Simple Single CPU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:110550142      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Simple_Single_CPU(
        clk_i,
		rst_i
		);
		
//I/O port
input         clk_i;
input         rst_i;

//Internal Signles
wire RegWrite,branch,branch_sl,ALU_zero,ALUSrc,MemRead,MemWrite;
wire [1:0] ALUOp,Jump,branchType,MemToReg,RegDst;
wire [3:0] ALUCtrl;
wire [4:0] RDaddr;
wire [31:0] PC_i,PC_o,Add1_o,Add2_o,Add2_i,IM_o,RDdata,RTdata,RSdata,SE_o,ALU_src2;
wire [31:0] ALU_o,DM_o,shft1_o,shft2_o,branch_o;

//Greate componentes
ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i (rst_i),     
	    .pc_in_i(PC_i) ,   
	    .pc_out_o(PC_o) 
	    );
	
Adder Adder1(
        .src1_i(32'd4),     
	    .src2_i(PC_o),     
	    .sum_o(Add1_o)    
	    );
	
Instr_Memory IM(
        .pc_addr_i(PC_o),  
	    .instr_o(IM_o)    
	    );

MUX_4to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(IM_o[20:16]),
        .data1_i(IM_o[15:11]),
        .data2_i(5'd31),//jal
        .data3_i(5'd0), //不會用到
        .select_i(RegDst),
        .data_o(RDaddr)
        );	
        
MUX_4to1 #(.size(32))Mux_MemtoReg(
        .data0_i(ALU_o),
        .data1_i(DM_o),
        .data2_i(SE_o),
        .data3_i(Add1_o), 
        .select_i(MemToReg),
        .data_o(RDdata)

);
		
Reg_File Registers(
        .clk_i(clk_i),      
	    .rst_i(rst_i) ,     
        .RSaddr_i(IM_o[25:21]) ,  
        .RTaddr_i(IM_o[20:16]) ,  
        .RDaddr_i(RDaddr) ,  
        .RDdata_i(RDdata)  , 
        .RegWrite_i (RegWrite),
        .RSdata_o(RSdata) ,  
        .RTdata_o(RTdata)   
        );
	
Decoder Decoder(
        .instr_op_i(IM_o[31:26]), 
        .funct_i(IM_o[5:0]),
	    .RegWrite_o(RegWrite), 
	    .ALU_op_o(ALUOp),   
	    .ALUSrc_o(ALUSrc),   
	    .RegDst_o(RegDst),   
		.Branch_o(branch),
		.BranchType_o(branchType),
		.Jump_o(Jump),
		.MemtoReg_o(MemToReg),
		.MemRead_o(MemRead),
		.MemWrite_o(MemWrite)
		   
	    );

ALU_Ctrl AC(
        .funct_i(IM_o[5:0]),   
        .ALUOp_i(ALUOp),   
        .ALUCtrl_o(ALUCtrl) 
        );
	
Sign_Extend SE(
        .data_i(IM_o[15:0]),
        .data_o(SE_o)
        );

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(RTdata),
        .data1_i(SE_o),
        .select_i(ALUSrc),
        .data_o(ALU_src2)
        );	
		
ALU ALU(
        .src1_i(RSdata),
	    .src2_i(ALU_src2),
	    .ctrl_i(ALUCtrl),
	    .result_o(ALU_o),
		.zero_o(ALU_zero)
	    );
	
Data_Memory Data_Memory(
	.clk_i(clk_i),
	.addr_i(ALU_o),
	.data_i(RTdata),
	.MemRead_i(MemRead),
	.MemWrite_i(MemWrite),
	.data_o(DM_o)
	);
	
Adder Adder2(
        .src1_i(Add1_o),     
	    .src2_i(shft2_o),     
	    .sum_o(Add2_o)      
	    );
Shift_Left_Two_32 Shifter1(
        .data_i(IM_o),
        .data_o(shft1_o)
        ); 			
Shift_Left_Two_32 Shifter2(
        .data_i(SE_o),
        .data_o(shft2_o)
        ); 		
MUX_4to1 #(.size(1)) Mux_Branch(
        .data0_i(ALU_zero),
        .data1_i(~(ALU_o[31]|ALU_zero)),
        .data2_i(~ALU_o[31]),
        .data3_i(~ALU_zero),
        .select_i(branchType),
        .data_o(branch_sl)
        );	
        		
MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(Add1_o),
        .data1_i(Add2_o),
        .select_i(branch&branch_sl),
        .data_o(branch_o)
        );	
        
        
MUX_4to1 #(.size(32)) Mux_PC_Jump(
        .data0_i({Add1_o[31:28],shft1_o[27:0]}),
        .data1_i(branch_o),
        .data2_i(RSdata),
        .data3_i(32'b0),//不會用到
        .select_i(Jump),
        .data_o(PC_i)
        );	

endmodule