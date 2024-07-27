`timescale 1ns/1ps
// 110550142
 module alu_top(
    /* input */
    src1,       //1 bit, source 1 (A)
    src2,       //1 bit, source 2 (B)
    less,       //1 bit, less
    A_invert,   //1 bit, A_invert
    B_invert,   //1 bit, B_invert
    cin,        //1 bit, carry in
 
    operation,  //2 bit, operation
    /* output */
    result,     //1 bit, result
    cout        //1 bit, carry out
);

/*==================================================================*/
/*                          input & output                          */
/*==================================================================*/

input src1;
input src2;
input less;
input A_invert;
input B_invert;
input cin;
input [1:0] operation;

output result;
output cout;

/*==================================================================*/
/*                            reg & wire                            */
/*==================================================================*/

reg result; 
reg cout;
reg a,b,c;
wire s1,s2;
assign s1=src1^A_invert;
assign s2=src2^B_invert; 
/*==================================================================*/
/*                              design                              */
/*==================================================================*/


/* HINT: You may use 'case' or 'if-else' to determine result.*/
// result
always@(*) 
begin
    case(operation)
    2'b00:
        begin
        result=s1&s2;
        cout=cin;
        end
    2'b01:
        begin
        result=s1|s2;
        cout=cin;
        end
    /*4'b0010:
        begin
        {cout,result}=src1+src2+cin;
        end*/
    2'b10:
        begin
        a=s1^s2;
        b=s1&s2;
        result=a^cin;
        c=a&cin;
        cout=b|c;
        end
    /*4'b1100:
        begin
        result= ~(src1|src2) ;
        cout=cin;
        end*/
    2'b11:
        begin
        a=s1^s2;
        b=s1&s2;
        result=a^cin;
        c=a&cin;
        cout=b|c;
        /*if(src1<src2)
            result<=1'b1;
        else if(src1==src2)
            result=less;
        else
            result=1'b0;
        cout<=cin;*/
        end   
                    
        /*default: begin
            result =src1+src2;
        end*/
    endcase
end


endmodule
