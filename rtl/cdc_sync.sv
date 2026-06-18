module cdc_sync #(
    parameter int WIDTH  = 8,
    parameter int STAGES = 2
)(
    input  logic             dest_clk,
    input  logic             dest_rst_n,
    input  logic [WIDTH-1:0] src_data,
    output logic [WIDTH-1:0] dest_data
);

    (* ASYNC_REG = "TRUE" *) logic [WIDTH-1:0] sync_reg [STAGES-1:0];

    always_ff @(posedge dest_clk or negedge dest_rst_n) begin
        if (!dest_rst_n) begin
            for (int i = 0; i < STAGES; i++) begin
                sync_reg[i] <= '0;
            end
        end else begin
            sync_reg[0] <= src_data;
            for (int i = 1; i < STAGES; i++) begin
                sync_reg[i] <= sync_reg[i-1];
            end
        end
    end

    assign dest_data = sync_reg[STAGES-1];

endmodule