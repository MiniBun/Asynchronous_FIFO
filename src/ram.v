module ram #(
    parameter data_size = 8,
    parameter addr_size = 3
)(
    input write_clk,
    input read_clk,
    input write_rst_n,
    input read_rst_n,
    input write_en,
    input read_en,
    input [data_size-1:0] write_data,
    input [addr_size-1:0] write_ptr_binary,
    input [addr_size-1:0] read_ptr_binary,
    input fifo_full,
    input fifo_empty,
    output reg [data_size-1:0] read_data
);

    reg [data_size-1:0] mem [{addr_size{1'b1}}:0];
    integer i;

    always @(posedge write_clk or negedge write_rst_n) begin
        if(!write_rst_n) begin
            for(i=0;i<={addr_size{1'b1}};i=i+1) begin
                mem[i] <= {data_size{1'b0}};
            end
        end
        else if(write_en&&!fifo_full) begin
            mem[write_ptr_binary] <= write_data;
        end
    end

    always @(posedge read_clk or negedge read_rst_n) begin
        if(!read_rst_n) begin
            read_data <= {data_size{1'b0}};
        end
        else if(read_en&&!fifo_empty) begin
            read_data <= mem[read_ptr_binary];
        end 
    end

endmodule