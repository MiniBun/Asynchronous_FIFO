`include "./src/ram.v"
`include "./src/read_ctrl.v"
`include "./src/write_ctrl.v"
`include "./src/sync.v"

module asynFIFO #(
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
    output [data_size-1:0] read_data,
    output fifo_empty,
    output fifo_full
);

wire [addr_size-1:0] write_ptr_binary;
wire [addr_size-1:0] read_ptr_binary;

wire [addr_size:0] write_ptr_gray;
wire [addr_size:0] read_ptr_gray;

wire [addr_size:0] write_ptr_gray_sync;
wire [addr_size:0] read_ptr_gray_sync;

ram #(
    .data_size(data_size),
    .addr_size(addr_size)
) ram_1(
    .write_clk(write_clk),
    .read_clk(read_clk),
    .write_rst_n(write_rst_n),
    .read_rst_n(read_rst_n),
    .write_en(write_en),
    .read_en(read_en),
    .write_data(write_data),
    .write_ptr_binary(write_ptr_binary),
    .read_ptr_binary(read_ptr_binary),
    .fifo_full(fifo_full),
    .fifo_empty(fifo_empty),
    .read_data(read_data)
);

write_ctrl #(
    .addr_size(addr_size)
) write_ctrl_1(
    .write_clk(write_clk),
    .write_rst_n(write_rst_n),
    .write_en(write_en),
    .read_ptr_gray_sync(read_ptr_gray_sync),
    .write_ptr_binary(write_ptr_binary),
    .write_ptr_gray(write_ptr_gray),
    .fifo_full(fifo_full)
);

read_ctrl #(
    .addr_size(addr_size)
) read_ctrl_1(
    .read_clk(read_clk),
    .read_rst_n(read_rst_n),
    .read_en(read_en),
    .write_ptr_gray_sync(write_ptr_gray_sync),
    .fifo_empty(fifo_empty),
    .read_ptr_binary(read_ptr_binary),
    .read_ptr_gray(read_ptr_gray)
);

sync #(
    .addr_size(addr_size)
) sync_1 (
    .clk(write_clk),
    .rst_n(write_rst_n),
    .data_in(read_ptr_gray),
    .data_out(read_ptr_gray_sync)
);

sync #(
    .addr_size(addr_size)
) sync_2 (
    .clk(read_clk),
    .rst_n(read_rst_n),
    .data_in(write_ptr_gray),
    .data_out(write_ptr_gray_sync)
);

endmodule 