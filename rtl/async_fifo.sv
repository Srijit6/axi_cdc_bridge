// Function  : Parameterized asynchronous FIFO with Gray-code pointers
module async_fifo #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 4,
    parameter int SYNC_STAGES = 2
)(
    // Write Domain
    input  logic                  wclk,
    input  logic                  wrst_n,
    input  logic                  winc,
    input  logic [DATA_WIDTH-1:0] wdata,
    output logic                  wfull,

    // Read Domain
    input  logic                  rclk,
    input  logic                  rrst_n,
    input  logic                  rinc,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic                  rempty
);

    localparam int DEPTH = 1 << ADDR_WIDTH;

    // Memory array
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointers
    logic [ADDR_WIDTH:0] wptr_bin, wptr_gray;
    logic [ADDR_WIDTH:0] rptr_bin, rptr_gray;
    logic [ADDR_WIDTH:0] wq2_rptr_gray, rq2_wptr_gray;

    // Write pointer logic
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr_bin <= '0;
        end else if (winc && !wfull) begin
            wptr_bin <= wptr_bin + 1'b1;
            mem[wptr_bin[ADDR_WIDTH-1:0]] <= wdata;
        end
    end

    // Read pointer logic
    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rptr_bin <= '0;
        end else if (rinc && !rempty) begin
            rptr_bin <= rptr_bin + 1'b1;
        end
    end

    assign rdata = mem[rptr_bin[ADDR_WIDTH-1:0]];

    // Binary to Gray conversion
    bin2gray #(.WIDTH(ADDR_WIDTH+1)) w_b2g (.bin(wptr_bin), .gray(wptr_gray));
    bin2gray #(.WIDTH(ADDR_WIDTH+1)) r_b2g (.bin(rptr_bin), .gray(rptr_gray));

    // Synchronize Read Pointer to Write Domain
    cdc_sync #(.WIDTH(ADDR_WIDTH+1), .STAGES(SYNC_STAGES)) sync_r2w (
        .dest_clk(wclk),
        .dest_rst_n(wrst_n),
        .src_data(rptr_gray),
        .dest_data(wq2_rptr_gray)
    );

    // Synchronize Write Pointer to Read Domain
    cdc_sync #(.WIDTH(ADDR_WIDTH+1), .STAGES(SYNC_STAGES)) sync_w2r (
        .dest_clk(rclk),
        .dest_rst_n(rrst_n),
        .src_data(wptr_gray),
        .dest_data(rq2_wptr_gray)
    );

    // Full and Empty logic
    assign rempty = (rptr_gray == rq2_wptr_gray);
    assign wfull  = (wptr_gray == {~wq2_rptr_gray[ADDR_WIDTH:ADDR_WIDTH-1], wq2_rptr_gray[ADDR_WIDTH-2:0]});

endmodule