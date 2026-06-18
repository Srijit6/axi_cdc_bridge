
// Function  : AXI4-Lite Top-level Clock Domain Crossing Bridge
module axi_cdc_bridge #(
    parameter int DATA_WIDTH  = 32,
    parameter int ADDR_WIDTH  = 32,
    parameter int FIFO_DEPTH  = 4,
    parameter int SYNC_STAGES = 2
)(
    // --------------------------------------------------
    // Slave Interface (Connected to Master) - Domain 1
    // --------------------------------------------------
    input  logic s_aclk,
    input  logic s_aresetn,

    // Write Address Channel (AW)
    input  logic [ADDR_WIDTH-1:0] s_axi_awaddr,
    input  logic [2:0]            s_axi_awprot,
    input  logic                  s_axi_awvalid,
    output logic                  s_axi_awready,

    // Write Data Channel (W)
    input  logic [DATA_WIDTH-1:0] s_axi_wdata,
    input  logic [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  logic                  s_axi_wvalid,
    output logic                  s_axi_wready,

    // Write Response Channel (B)
    output logic [1:0]            s_axi_bresp,
    output logic                  s_axi_bvalid,
    input  logic                  s_axi_bready,

    // Read Address Channel (AR)
    input  logic [ADDR_WIDTH-1:0] s_axi_araddr,
    input  logic [2:0]            s_axi_arprot,
    input  logic                  s_axi_arvalid,
    output logic                  s_axi_arready,

    // Read Data Channel (R)
    output logic [DATA_WIDTH-1:0] s_axi_rdata,
    output logic [1:0]            s_axi_rresp,
    output logic                  s_axi_rvalid,
    input  logic                  s_axi_rready,

    // --------------------------------------------------
    // Master Interface (Connected to Slave) - Domain 2
    // --------------------------------------------------
    input  logic m_aclk,
    input  logic m_aresetn,

    // Write Address Channel (AW)
    output logic [ADDR_WIDTH-1:0] m_axi_awaddr,
    output logic [2:0]            m_axi_awprot,
    output logic                  m_axi_awvalid,
    input  logic                  m_axi_awready,

    // Write Data Channel (W)
    output logic [DATA_WIDTH-1:0] m_axi_wdata,
    output logic [(DATA_WIDTH/8)-1:0] m_axi_wstrb,
    output logic                  m_axi_wvalid,
    input  logic                  m_axi_wready,

    // Write Response Channel (B)
    input  logic [1:0]            m_axi_bresp,
    input  logic                  m_axi_bvalid,
    output logic                  m_axi_bready,

    // Read Address Channel (AR)
    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic [2:0]            m_axi_arprot,
    output logic                  m_axi_arvalid,
    input  logic                  m_axi_arready,

    // Read Data Channel (R)
    input  logic [DATA_WIDTH-1:0] m_axi_rdata,
    input  logic [1:0]            m_axi_rresp,
    input  logic                  m_axi_rvalid,
    output logic                  m_axi_rready
);

    // -------------------------------------------------------------------------
    // Channel 1: AW (Write Address) - Master to Slave
    // -------------------------------------------------------------------------
    localparam int AW_WIDTH = ADDR_WIDTH + 3;
    logic aw_full, aw_empty;
    logic [AW_WIDTH-1:0] aw_din, aw_dout;

    assign aw_din = {s_axi_awprot, s_axi_awaddr};
    assign {m_axi_awprot, m_axi_awaddr} = aw_dout;

    assign s_axi_awready = ~aw_full;
    assign m_axi_awvalid = ~aw_empty;

    async_fifo #(.DATA_WIDTH(AW_WIDTH), .ADDR_WIDTH(FIFO_DEPTH), .SYNC_STAGES(SYNC_STAGES)) aw_fifo (
        .wclk(s_aclk), .wrst_n(s_aresetn), .winc(s_axi_awvalid && ~aw_full), .wdata(aw_din), .wfull(aw_full),
        .rclk(m_aclk), .rrst_n(m_aresetn), .rinc(m_axi_awready && ~aw_empty), .rdata(aw_dout), .rempty(aw_empty)
    );

    // -------------------------------------------------------------------------
    // Channel 2: W (Write Data) - Master to Slave
    // -------------------------------------------------------------------------
    localparam int W_WIDTH = DATA_WIDTH + (DATA_WIDTH/8);
    logic w_full, w_empty;
    logic [W_WIDTH-1:0] w_din, w_dout;

    assign w_din = {s_axi_wstrb, s_axi_wdata};
    assign {m_axi_wstrb, m_axi_wdata} = w_dout;

    assign s_axi_wready = ~w_full;
    assign m_axi_wvalid = ~w_empty;

    async_fifo #(.DATA_WIDTH(W_WIDTH), .ADDR_WIDTH(FIFO_DEPTH), .SYNC_STAGES(SYNC_STAGES)) w_fifo (
        .wclk(s_aclk), .wrst_n(s_aresetn), .winc(s_axi_wvalid && ~w_full), .wdata(w_din), .wfull(w_full),
        .rclk(m_aclk), .rrst_n(m_aresetn), .rinc(m_axi_wready && ~w_empty), .rdata(w_dout), .rempty(w_empty)
    );

    // -------------------------------------------------------------------------
    // Channel 3: B (Write Response) - Slave to Master
    // -------------------------------------------------------------------------
    localparam int B_WIDTH = 2;
    logic b_full, b_empty;
    
    assign s_axi_bvalid = ~b_empty;
    assign m_axi_bready = ~b_full;

    async_fifo #(.DATA_WIDTH(B_WIDTH), .ADDR_WIDTH(FIFO_DEPTH), .SYNC_STAGES(SYNC_STAGES)) b_fifo (
        .wclk(m_aclk), .wrst_n(m_aresetn), .winc(m_axi_bvalid && ~b_full), .wdata(m_axi_bresp), .wfull(b_full),
        .rclk(s_aclk), .rrst_n(s_aresetn), .rinc(s_axi_bready && ~b_empty), .rdata(s_axi_bresp), .rempty(b_empty)
    );

    // -------------------------------------------------------------------------
    // Channel 4: AR (Read Address) - Master to Slave
    // -------------------------------------------------------------------------
    localparam int AR_WIDTH = ADDR_WIDTH + 3;
    logic ar_full, ar_empty;
    logic [AR_WIDTH-1:0] ar_din, ar_dout;

    assign ar_din = {s_axi_arprot, s_axi_araddr};
    assign {m_axi_arprot, m_axi_araddr} = ar_dout;

    assign s_axi_arready = ~ar_full;
    assign m_axi_arvalid = ~ar_empty;

    async_fifo #(.DATA_WIDTH(AR_WIDTH), .ADDR_WIDTH(FIFO_DEPTH), .SYNC_STAGES(SYNC_STAGES)) ar_fifo (
        .wclk(s_aclk), .wrst_n(s_aresetn), .winc(s_axi_arvalid && ~ar_full), .wdata(ar_din), .wfull(ar_full),
        .rclk(m_aclk), .rrst_n(m_aresetn), .rinc(m_axi_arready && ~ar_empty), .rdata(ar_dout), .rempty(ar_empty)
    );

    // -------------------------------------------------------------------------
    // Channel 5: R (Read Data) - Slave to Master
    // -------------------------------------------------------------------------
    localparam int R_WIDTH = DATA_WIDTH + 2;
    logic r_full, r_empty;
    logic [R_WIDTH-1:0] r_din, r_dout;

    assign r_din = {m_axi_rresp, m_axi_rdata};
    assign {s_axi_rresp, s_axi_rdata} = r_dout;

    assign s_axi_rvalid = ~r_empty;
    assign m_axi_rready = ~r_full;

    async_fifo #(.DATA_WIDTH(R_WIDTH), .ADDR_WIDTH(FIFO_DEPTH), .SYNC_STAGES(SYNC_STAGES)) r_fifo (
        .wclk(m_aclk), .wrst_n(m_aresetn), .winc(m_axi_rvalid && ~r_full), .wdata(r_din), .wfull(r_full),
        .rclk(s_aclk), .rrst_n(s_aresetn), .rinc(s_axi_rready && ~r_empty), .rdata(r_dout), .rempty(r_empty)
    );

endmodule