//Subject:     CO project 2 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer  110550142¶Àªé¬X
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
`timescale 1ns/1ps
module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o
          );
          
//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;    
     
//Internal Signals
reg        [4-1:0] ALUCtrl_o;

//Parameter

       
//Select exact operation
//

always@(funct_i,  ALUOp_i)begin     

    case (ALUOp_i)

		3'b000: case (funct_i)
			6'b100000: ALUCtrl_o <= 4'h2;  
			6'b100010: ALUCtrl_o <= 4'h6;  
			6'b100100: ALUCtrl_o <= 4'h0;  
			6'b100101: ALUCtrl_o <= 4'h1;  
			6'b101010: ALUCtrl_o <= 4'h7;  
			default:   ALUCtrl_o <= 4'h6;
		endcase
		3'b100: ALUCtrl_o <= 4'h2; 
		3'b101: ALUCtrl_o <= 4'h7;  
		3'b010: ALUCtrl_o <= 4'h6;
	endcase
 
   
 end
endmodule          
