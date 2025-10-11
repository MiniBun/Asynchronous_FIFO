module sync #(
    parameter addr_size = 3
) (
    input clk,
    input rst_n,
    input [addr_size:0] data_in,
    output reg [addr_size:0] data_out
);

    reg [addr_size:0] data_r;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_r <= {addr_size{1'b0}};
            data_out <= {addr_size{1'b0}};
        end
        else begin
            data_r <= data_in;
            data_out <= data_r;
        end
    end

endmodule