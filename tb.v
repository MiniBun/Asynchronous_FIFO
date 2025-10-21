`include "asynFIFO.v"
`timescale 1ns/10ps
`default_nettype none
`define WRITE_CYCLE 10.0
`define READ_CYCLE 12.0
`define RESET_DELAY 2.0
`define MAX_CYCLE 2000.0 

module tb_asynFIFO;

    parameter data_size = 8;
    parameter addr_size = 3;
    parameter depth = {addr_size{1'b1}}+1;

    reg read_clk;
    reg write_clk;

    reg read_en;
    reg write_en;

    reg read_rst_n;
    reg write_rst_n;

    reg [data_size-1:0] write_data;
    wire [data_size-1:0] read_data;

    integer tb_read_ptr, tb_write_ptr, tb_count;
    reg [data_size-1:0] tb_mem [depth-1:0];

    integer cnt;
    reg [data_size-1:0] expected_data;

    integer i;

    wire fifo_empty;
    wire fifo_full;

    task mem_push;
        input [data_size-1:0] d_in;
        begin
            if(tb_count===depth) begin
                $fatal(1,"Error! The memory is full but the full signal is not high!");
            end
            tb_count = tb_count + 1;
            tb_mem[tb_write_ptr]=d_in;
            tb_write_ptr=(tb_write_ptr+1)%(depth);
        end
    endtask

    task mem_pop;
        output [data_size-1:0] d_out;
        begin
            if(tb_count===0) begin
                $fatal(1,"Error! The memory is empty but the empty signal is not high!");
            end
            tb_count = tb_count - 1;
            d_out = tb_mem[tb_read_ptr];
            tb_read_ptr=(tb_read_ptr+1)%(depth);
        end
    endtask

    always #(`WRITE_CYCLE/2.0) write_clk=~write_clk;
    always #(`READ_CYCLE/2.0) read_clk=~read_clk;

    asynFIFO #(
        .data_size(data_size),
        .addr_size(addr_size)
    ) asynFIFO_1(
        .write_clk(write_clk),
        .read_clk(read_clk),
        .write_rst_n(write_rst_n),
        .read_rst_n(read_rst_n),
        .write_en(write_en),
        .read_en(read_en),
        .write_data(write_data),
        .read_data(read_data),
        .fifo_empty(fifo_empty),
        .fifo_full(fifo_full)
    );

    initial begin
        $dumpfile("asynFIFO.vcd");
        $dumpvars(0,tb_asynFIFO);
    end

    initial begin
        write_clk = 1'b0;
        write_rst_n = 1'b1;
        #(0.25*`WRITE_CYCLE) write_rst_n=1'b0;
        #((`RESET_DELAY-0.25)*`WRITE_CYCLE) write_rst_n=1'b1;
    end

    initial begin
        read_clk = 1'b0;
        read_rst_n = 1'b1;
        #(0.25*`READ_CYCLE) read_rst_n=1'b0;
        #((`RESET_DELAY-0.25)*`READ_CYCLE) read_rst_n=1'b1;
    end

    initial begin
        if(`WRITE_CYCLE>`READ_CYCLE) begin
            #(`MAX_CYCLE*`WRITE_CYCLE);
        end
        else begin
            #(`MAX_CYCLE*`READ_CYCLE);
        end
        $fatal(1, "Error! Time Exceeded!!");
    end

    initial begin
        read_en = 1'b0;
        write_en = 1'b0;
        write_data = {data_size{1'b0}};
        tb_read_ptr = 0;
        tb_write_ptr = 0;
        tb_count = 0;
        if(`READ_CYCLE>`WRITE_CYCLE) begin
            wait(write_rst_n===1'b0);
            wait(read_rst_n===1'b0);
        end
        else begin
            wait(read_rst_n===1'b0);
            wait(write_rst_n===1'b0);
        end
        wait(read_rst_n===1'b1&&write_rst_n===1'b1);

        if(fifo_empty===1'b0) begin
            $fatal(1,"Error! Ram must be empty after reset!");
        end

        if(fifo_full===1'b1) begin
            $fatal(1,"Error! Ram must not be full after reset!");
        end

        repeat (2) @(posedge read_clk);
        repeat (2) @(posedge write_clk);

        // Scenario 1: Write to Full
        $display("Start Scenario 1: Write to Full");
        repeat(depth) begin
            @(negedge write_clk);
            if(fifo_full===1'b1) begin
                $fatal(1,"Error! The ram must not be full!");
            end
            write_en = 1'b1;
            write_data = $urandom%{data_size{1'b1}};
            mem_push(write_data);
        end

        @(negedge write_clk);
        write_en=1'b0;
        if(fifo_full===1'b0) begin
            $fatal(1,"Error! The ram must be full!");
        end

        $display("Scenario 1 Success!");

        $display("Start Scenario 2: Read to Empty");
        cnt=0;
        while (!fifo_empty) begin
            @(negedge read_clk);
            read_en = 1'b1;
            mem_pop(expected_data);
            @(negedge read_clk);
            read_en = 1'b0;
            if(read_data!==expected_data) begin
                $fatal(1,"Error! %d is expected but %d is read.", expected_data, read_data);
            end
            else begin
                cnt=cnt+1;
            end
        end

        if(cnt!==depth) begin
            $fatal(1,"Error! %d values are expected but %d values are read.", depth, cnt);
        end

        $display("Scenario 2 Success!");

        #(2*`WRITE_CYCLE);
        $finish;

    end

endmodule