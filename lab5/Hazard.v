//110550142
module Hazard_Detection(
    MemRead,
    addr_id,
    RTaddr_ex,
    branchTake,
    pcwrite,
    write_ifid,
    flush_ifid,
    flush_idex,
    flush_exmem
);

input       MemRead;
input [9:0] addr_id;
input [4:0]  RTaddr_ex;
input       branchTake;
output      pcwrite;
output      write_ifid;
output      flush_ifid;
output      flush_idex;
output      flush_exmem;

reg      pcwrite;
reg     write_ifid;
reg      flush_ifid;
reg      flush_idex;
reg      flush_exmem;

always@(*) begin
    pcwrite <= 1'b1;
    write_ifid <= 1'b1;
    flush_ifid <= 1'b0;
    flush_idex <= 1'b0;
    flush_exmem <= 1'b0;
                
    if(branchTake==1'b1) begin
              pcwrite <= 1'b1;
              write_ifid <= 1'b1;
              flush_ifid <= 1'b1;
              flush_idex <= 1'b1;
              flush_exmem <= 1'b1;
     end
     else if(MemRead == 1'b1 && (RTaddr_ex==addr_id[9:5] ||  RTaddr_ex==addr_id[4:0]))begin
              pcwrite <= 1'b0;
              write_ifid <= 1'b0;
              flush_ifid <= 1'b0;
              flush_idex <= 1'b1;
              flush_exmem <= 1'b0;     
     
     end
   
    
end

endmodule

