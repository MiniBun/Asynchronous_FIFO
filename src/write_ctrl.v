module write_ctrl #(
    parameter addr_size = 3
) (
    input write_clk,
    input write_rst_n,
    input write_en,
    input [addr_size:0] read_ptr_gray_sync,
    output [addr_size-1:0] write_ptr_binary,
    output [addr_size:0] write_ptr_gray,
    output fifo_full
);

    reg [addr_size:0] write_ptr_binary_extended;
    
    assign write_ptr_binary = write_ptr_binary_extended[addr_size-1:0];
    assign write_ptr_gray = write_ptr_binary_extended ^ (write_ptr_binary_extended>>1);
    assign fifo_full = (write_ptr_gray[addr_size-2:0]==read_ptr_gray_sync[addr_size-2:0])&&(write_ptr_gray[addr_size:addr_size-1]==~read_ptr_gray_sync[addr_size:addr_size-1]);

    always @(posedge write_clk or negedge write_rst_n) begin
        if(!write_rst_n) begin
            write_ptr_binary_extended <= 0;        
        end
        else if(write_en&&!fifo_full) begin
            write_ptr_binary_extended <= write_ptr_binary_extended + 1;
        end
    end
    
endmodule