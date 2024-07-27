`timescale 1ns/1ps
// 110550142
module alu(
    /* input */
    clk,            // system clock
    rst_n,          // negative reset
    src1,           // 32 bits, source 1
    src2,           // 32 bits, source 2
    ALU_control,    // 4 bits, ALU control input
    /* output */
    result,         // 32 bits, result
    zero,           // 1 bit, set to 1 when the output is 0
    cout,           // 1 bit, carry out
    overflow        // 1 bit, overflow
);

/*==================================================================*/
/*                          input & output                          */
/*==================================================================*/

input clk;
input rst_n;
input [31:0] src1;
input [31:0] src2;
input [3:0] ALU_control;

output [32-1:0] result;
output zero;
output cout;
output overflow;

/*==================================================================*/
/*                            reg & wire                            */
/*==================================================================*/

reg [32-1:0] result;
reg zero, cout, overflow;
wire [31:0] w_result;
wire [31:0] carry_out;
wire cin;

/*==================================================================*/
/*                              design                              */
/*==================================================================*/
assign cin=(ALU_control==4'b0110||ALU_control==4'b0111)?1'b1:1'b0;

alu_top ALU00(.src1(src1[0]), .src2(src2[0]), .less(1'b0), .A_invert(ALU_control[3]), .B_invert(ALU_control[2]), .cin(cin), .operation(ALU_control[1:0]), .result(w_result[0]), .cout(carry_out[0]));
genvar i;
generate for(i=1;i<32;i=i+1)begin
    alu_top ALU01(.src1(src1[i]), .src2(src2[i]), .less(w_result[i-1]), .A_invert(ALU_control[3]), .B_invert(ALU_control[2]), .cin(carry_out[i-1]), .operation(ALU_control[1:0]), .result(w_result[i]), .cout(carry_out[i]));
    end
endgenerate
/*alu_top ALU02(.src1(src1[2]), .src2(src2[2]), .less(w_result[1]), .A_invert(~src1[2]), .B_invert(~src2[2]), .cin(carry_out), .operation(ALU_control), .result(w_result[2]), .cout(carry_out));
alu_top ALU03(.src1(src1[3]), .src2(src2[3]), .less(w_result[2]), .A_invert(~src1[3]), .B_invert(~src2[3]), .cin(carry_out), .operation(ALU_control), .result(w_result[3]), .cout(carry_out));
alu_top ALU04(.src1(src1[4]), .src2(src2[4]), .less(w_result[3]), .A_invert(~src1[4]), .B_invert(~src2[4]), .cin(carry_out), .operation(ALU_control), .result(w_result[4]), .cout(carry_out));
alu_top ALU05(.src1(src1[5]), .src2(src2[5]), .less(w_result[4]), .A_invert(~src1[5]), .B_invert(~src2[5]), .cin(carry_out), .operation(ALU_control), .result(w_result[5]), .cout(carry_out));
alu_top ALU06(.src1(src1[6]), .src2(src2[6]), .less(w_result[5]), .A_invert(~src1[6]), .B_invert(~src2[6]), .cin(carry_out), .operation(ALU_control), .result(w_result[6]), .cout(carry_out));
alu_top ALU07(.src1(src1[7]), .src2(src2[7]), .less(w_result[6]), .A_invert(~src1[7]), .B_invert(~src2[7]), .cin(carry_out), .operation(ALU_control), .result(w_result[7]), .cout(carry_out));
alu_top ALU08(.src1(src1[8]), .src2(src2[8]), .less(w_result[7]), .A_invert(~src1[8]), .B_invert(~src2[8]), .cin(carry_out), .operation(ALU_control), .result(w_result[8]), .cout(carry_out));
alu_top ALU09(.src1(src1[9]), .src2(src2[9]), .less(w_result[8]), .A_invert(~src1[9]), .B_invert(~src2[9]), .cin(carry_out), .operation(ALU_control), .result(w_result[9]), .cout(carry_out));
alu_top ALU10(.src1(src1[10]), .src2(src2[10]), .less(w_result[9]), .A_invert(~src1[10]), .B_invert(~src2[10]), .cin(carry_out), .operation(ALU_control), .result(w_result[10]), .cout(carry_out));
alu_top ALU11(.src1(src1[11]), .src2(src2[11]), .less(w_result[10]), .A_invert(~src1[11]), .B_invert(~src2[11]), .cin(carry_out), .operation(ALU_control), .result(w_result[11]), .cout(carry_out));
alu_top ALU12(.src1(src1[12]), .src2(src2[12]), .less(w_result[11]), .A_invert(~src1[12]), .B_invert(~src2[12]), .cin(carry_out), .operation(ALU_control), .result(w_result[12]), .cout(carry_out));
alu_top ALU13(.src1(src1[13]), .src2(src2[13]), .less(w_result[12]), .A_invert(~src1[13]), .B_invert(~src2[13]), .cin(carry_out), .operation(ALU_control), .result(w_result[13]), .cout(carry_out));
alu_top ALU14(.src1(src1[14]), .src2(src2[14]), .less(w_result[13]), .A_invert(~src1[14]), .B_invert(~src2[14]), .cin(carry_out), .operation(ALU_control), .result(w_result[14]), .cout(carry_out));
alu_top ALU15(.src1(src1[15]), .src2(src2[15]), .less(w_result[14]), .A_invert(~src1[15]), .B_invert(~src2[15]), .cin(carry_out), .operation(ALU_control), .result(w_result[15]), .cout(carry_out));
alu_top ALU16(.src1(src1[16]), .src2(src2[16]), .less(w_result[15]), .A_invert(~src1[16]), .B_invert(~src2[16]), .cin(carry_out), .operation(ALU_control), .result(w_result[16]), .cout(carry_out));
alu_top ALU17(.src1(src1[17]), .src2(src2[17]), .less(w_result[16]), .A_invert(~src1[17]), .B_invert(~src2[17]), .cin(carry_out), .operation(ALU_control), .result(w_result[17]), .cout(carry_out));
alu_top ALU18(.src1(src1[18]), .src2(src2[18]), .less(w_result[17]), .A_invert(~src1[18]), .B_invert(~src2[18]), .cin(carry_out), .operation(ALU_control), .result(w_result[18]), .cout(carry_out));
alu_top ALU19(.src1(src1[19]), .src2(src2[19]), .less(w_result[18]), .A_invert(~src1[19]), .B_invert(~src2[19]), .cin(carry_out), .operation(ALU_control), .result(w_result[19]), .cout(carry_out));
alu_top ALU20(.src1(src1[20]), .src2(src2[20]), .less(w_result[19]), .A_invert(~src1[20]), .B_invert(~src2[20]), .cin(carry_out), .operation(ALU_control), .result(w_result[20]), .cout(carry_out));
alu_top ALU21(.src1(src1[21]), .src2(src2[21]), .less(w_result[20]), .A_invert(~src1[21]), .B_invert(~src2[21]), .cin(carry_out), .operation(ALU_control), .result(w_result[21]), .cout(carry_out));
alu_top ALU22(.src1(src1[22]), .src2(src2[22]), .less(w_result[21]), .A_invert(~src1[22]), .B_invert(~src2[22]), .cin(carry_out), .operation(ALU_control), .result(w_result[22]), .cout(carry_out));
alu_top ALU23(.src1(src1[23]), .src2(src2[23]), .less(w_result[22]), .A_invert(~src1[23]), .B_invert(~src2[23]), .cin(carry_out), .operation(ALU_control), .result(w_result[23]), .cout(carry_out));
alu_top ALU24(.src1(src1[24]), .src2(src2[24]), .less(w_result[23]), .A_invert(~src1[24]), .B_invert(~src2[24]), .cin(carry_out), .operation(ALU_control), .result(w_result[24]), .cout(carry_out));
alu_top ALU25(.src1(src1[25]), .src2(src2[25]), .less(w_result[24]), .A_invert(~src1[25]), .B_invert(~src2[25]), .cin(carry_out), .operation(ALU_control), .result(w_result[25]), .cout(carry_out));
alu_top ALU26(.src1(src1[26]), .src2(src2[26]), .less(w_result[25]), .A_invert(~src1[26]), .B_invert(~src2[26]), .cin(carry_out), .operation(ALU_control), .result(w_result[26]), .cout(carry_out));
alu_top ALU27(.src1(src1[27]), .src2(src2[27]), .less(w_result[26]), .A_invert(~src1[27]), .B_invert(~src2[27]), .cin(carry_out), .operation(ALU_control), .result(w_result[27]), .cout(carry_out));
alu_top ALU28(.src1(src1[28]), .src2(src2[28]), .less(w_result[27]), .A_invert(~src1[28]), .B_invert(~src2[28]), .cin(carry_out), .operation(ALU_control), .result(w_result[28]), .cout(carry_out));
alu_top ALU29(.src1(src1[29]), .src2(src2[29]), .less(w_result[28]), .A_invert(~src1[29]), .B_invert(~src2[29]), .cin(carry_out), .operation(ALU_control), .result(w_result[29]), .cout(carry_out));
alu_top ALU30(.src1(src1[30]), .src2(src2[30]), .less(w_result[29]), .A_invert(~src1[30]), .B_invert(~src2[30]), .cin(carry_out), .operation(ALU_control), .result(w_result[30]), .cout(carry_out));
alu_top ALU31(.src1(src1[31]), .src2(src2[31]), .less(w_result[30]), .A_invert(~src1[31]), .B_invert(~src2[31]), .cin(carry_out), .operation(ALU_control), .result(w_result[31]), .cout(carry_out));
*/


always@(posedge clk or negedge rst_n) 
begin
	if(!rst_n) begin
       result<=32'b0;
       cout<=1'b0;
       overflow<=1'b0;
	end
	else begin 
	    if(ALU_control==4'b0111)begin
            
            if(src1[31]^src2[31])
                result[0]<=src1[31];
            else 
                result[0]<=~carry_out[31];
                
            result[31:1]<=31'b0;
        end
        else 
            result<=w_result; 
            
        cout=1'b0;    
        overflow<=0;
        if(ALU_control[1:0]==2'b10)
            cout<=carry_out[31]; 
            if(src1[31]^src2[31]^ALU_control[2]==0)
                overflow=(src1[31]^result[31]);
                
	end
	
	
end

/* HINT: You may use alu_top as submodule.*/
// 32-bit ALU



 always @(*) begin
   
    zero=(result==32'd0)?1:0;
            
end 
endmodule
