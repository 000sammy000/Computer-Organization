//110550142
//Subject:     CO project 2 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:     110550142 
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o
          );
          
//I/O ports 
input      [5:0] funct_i;
input      [1:0] ALUOp_i;

output     [3:0] ALUCtrl_o;    
     
//Internal Signals
reg        [3:0] ALUCtrl_o;

//Parameter

//Select exact operation
always@(*)begin
    case(ALUOp_i)
        2'b00:ALUCtrl_o<=4'b0010;
        2'b01:ALUCtrl_o<=4'b0110;
        2'b10:case(funct_i)
            6'b100000:ALUCtrl_o<=4'b0010;
            6'b100010:ALUCtrl_o<=4'b0110;
            6'b100100:ALUCtrl_o<=4'b0000; 
            6'b100101:ALUCtrl_o<=4'b0001;
            6'b101010:ALUCtrl_o<=4'b0111;
            6'b100110:ALUCtrl_o<=4'b1001;
            6'b011000:ALUCtrl_o<=4'b1000; //mult
            default:ALUCtrl_o<=4'b1111;
        endcase
        2'b11:ALUCtrl_o<=4'b0111;
     endcase   
        
        
end     

endmodule 
