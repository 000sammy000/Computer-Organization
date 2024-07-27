//110550142
module Forwarding_Unit(
            RegWrite_mem,
            RegWrite_wb,
            RSaddr_ex,
            RTaddr_ex,
            RDaddr_mem,
            RDaddr_wb,
            forwarda,
            forwardb
);

input       RegWrite_mem,RegWrite_wb;
input [4:0] RSaddr_ex,RTaddr_ex,RDaddr_mem,RDaddr_wb;
output [1:0] forwarda;
output [1:0] forwardb;
reg [1:0] forwarda;
reg [1:0] forwardb;

always@(*) begin
    if(RegWrite_mem==1'b1&&RDaddr_mem!=5'd0&&RDaddr_mem==RSaddr_ex)
        forwarda<=2'b10;
    else if(RegWrite_wb==1'b1&&RDaddr_wb!=5'd0&&RDaddr_wb==RSaddr_ex)
        forwarda<=2'b01;
    else
        forwarda<=2'b00;
        
    if(RegWrite_mem==1'b1&&RDaddr_mem!=5'd0&&RDaddr_mem==RTaddr_ex)
        forwardb<=2'b10;
    else if(RegWrite_wb==1'b1&&RDaddr_wb!=5'd0&&RDaddr_wb==RTaddr_ex)
        forwardb<=2'b01;
    else
        forwardb<=2'b00;
end
endmodule
