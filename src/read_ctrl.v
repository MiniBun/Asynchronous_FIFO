module read_ctrl #(
    parameter addr_size = 3
) (
    input read_clk,
    input read_rst_n,
    input read_en,
    input [addr_size:0] write_ptr_gray_sync,
    output fifo_empty,
    output [addr_size-1:0] read_ptr_binary,
    output [addr_size:0] read_ptr_gray
);
    reg [addr_size:0] read_ptr_binary_extended;

    assign read_ptr_binary = read_ptr_binary_extended[addr_size-1:0];
    assign read_ptr_gray = read_ptr_binary_extended ^ (read_ptr_binary_extended>>1);
    assign fifo_empty = read_ptr_gray == write_ptr_gray_sync ? 1 : 0;

    always @(posedge read_clk or negedge read_rst_n) begin
        if(!read_rst_n) begin
            read_ptr_binary_extended <= 0;
        end
        else if(read_en&&!fifo_empty) begin
            read_ptr_binary_extended <= read_ptr_binary_extended + 1;
        end
    end

endmodule