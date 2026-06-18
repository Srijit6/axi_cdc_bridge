// -----------------------------------------------------------------------------
// Project ID: 24BVD1046
// File      : tb_axi_cdc_bridge.sv
// Function  : Directed and constrained-random TB for AXI CDC Bridge
// Note      : Refactored to native wire/logic mapping for Icarus Verilog compatibility
// -----------------------------------------------------------------------------
module tb_axi_cdc_bridge;

    // Parameters
    localparam int DATA_WIDTH = 32;
    localparam int ADDR_WIDTH = 32;
    localparam int FIFO_DEPTH = 4;
    
    // Clock & Reset variables
    logic clk_m = 0;
    logic clk_s = 0;
    logic rst_n = 0;

    int clk_m_period = 10;
    int clk_s_period = 10;

    always #(clk_m_period/2.0) clk_m = ~clk_m;
    always #(clk_s_period/2.0) clk_s = ~clk_s;

    // -------------------------------------------------------------------------
    // Master Domain Signals (Driven by TB, read by DUT)
    // -------------------------------------------------------------------------
    logic [ADDR_WIDTH-1:0] s_axi_awaddr = 0;
    logic [2:0]            s_axi_awprot = 0;
    logic                  s_axi_awvalid = 0;
    wire                   s_axi_awready;

    logic [DATA_WIDTH-1:0] s_axi_wdata = 0;
    logic [(DATA_WIDTH/8)-1:0] s_axi_wstrb = 0;
    logic                  s_axi_wvalid = 0;
    wire                   s_axi_wready;

    wire  [1:0]            s_axi_bresp;
    wire                   s_axi_bvalid;
    logic                  s_axi_bready = 0;

    logic [ADDR_WIDTH-1:0] s_axi_araddr = 0;
    logic [2:0]            s_axi_arprot = 0;
    logic                  s_axi_arvalid = 0;
    wire                   s_axi_arready;

    wire  [DATA_WIDTH-1:0] s_axi_rdata;
    wire  [1:0]            s_axi_rresp;
    wire                   s_axi_rvalid;
    logic                  s_axi_rready = 0;

    // -------------------------------------------------------------------------
    // Slave Domain Signals (Driven by DUT, read by TB)
    // -------------------------------------------------------------------------
    wire  [ADDR_WIDTH-1:0] m_axi_awaddr;
    wire  [2:0]            m_axi_awprot;
    wire                   m_axi_awvalid;
    logic                  m_axi_awready = 0;

    wire  [DATA_WIDTH-1:0] m_axi_wdata;
    wire  [(DATA_WIDTH/8)-1:0] m_axi_wstrb;
    wire                   m_axi_wvalid;
    logic                  m_axi_wready = 0;

    logic [1:0]            m_axi_bresp = 0;
    logic                  m_axi_bvalid = 0;
    wire                   m_axi_bready;

    wire  [ADDR_WIDTH-1:0] m_axi_araddr;
    wire  [2:0]            m_axi_arprot;
    wire                   m_axi_arvalid;
    logic                  m_axi_arready = 0;

    logic [DATA_WIDTH-1:0] m_axi_rdata = 0;
    logic [1:0]            m_axi_rresp = 0;
    logic                  m_axi_rvalid = 0;
    wire                   m_axi_rready;

    // -------------------------------------------------------------------------
    // Device Under Test (DUT)
    // -------------------------------------------------------------------------
    axi_cdc_bridge #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .SYNC_STAGES(2)
    ) dut (
        .s_aclk(clk_m), .s_aresetn(rst_n),
        .s_axi_awaddr(s_axi_awaddr), .s_axi_awprot(s_axi_awprot), .s_axi_awvalid(s_axi_awvalid), .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),   .s_axi_wstrb(s_axi_wstrb),   .s_axi_wvalid(s_axi_wvalid),   .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),   .s_axi_bvalid(s_axi_bvalid), .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr), .s_axi_arprot(s_axi_arprot), .s_axi_arvalid(s_axi_arvalid), .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),   .s_axi_rresp(s_axi_rresp),   .s_axi_rvalid(s_axi_rvalid),   .s_axi_rready(s_axi_rready),

        .m_aclk(clk_s), .m_aresetn(rst_n),
        .m_axi_awaddr(m_axi_awaddr), .m_axi_awprot(m_axi_awprot), .m_axi_awvalid(m_axi_awvalid), .m_axi_awready(m_axi_awready),
        .m_axi_wdata(m_axi_wdata),   .m_axi_wstrb(m_axi_wstrb),   .m_axi_wvalid(m_axi_wvalid),   .m_axi_wready(m_axi_wready),
        .m_axi_bresp(m_axi_bresp),   .m_axi_bvalid(m_axi_bvalid), .m_axi_bready(m_axi_bready),
        .m_axi_araddr(m_axi_araddr), .m_axi_arprot(m_axi_arprot), .m_axi_arvalid(m_axi_arvalid), .m_axi_arready(m_axi_arready),
        .m_axi_rdata(m_axi_rdata),   .m_axi_rresp(m_axi_rresp),   .m_axi_rvalid(m_axi_rvalid),   .m_axi_rready(m_axi_rready)
    );

    // -------------------------------------------------------------------------
    // BFM Tasks
    // -------------------------------------------------------------------------
    task automatic master_write(
        input  logic [ADDR_WIDTH-1:0] addr,
        input  logic [DATA_WIDTH-1:0] data,
        output logic [1:0]            resp
    );
        @(posedge clk_m);
        s_axi_awaddr  <= addr;
        s_axi_awprot  <= 3'b000;
        s_axi_awvalid <= 1'b1;
        
        s_axi_wdata   <= data;
        s_axi_wstrb   <= {(DATA_WIDTH/8){1'b1}};
        s_axi_wvalid  <= 1'b1;
        s_axi_bready  <= 1'b1;

        fork
            begin
                wait(s_axi_awvalid && s_axi_awready);
                @(posedge clk_m);
                s_axi_awvalid <= 1'b0;
            end
            begin
                wait(s_axi_wvalid && s_axi_wready);
                @(posedge clk_m);
                s_axi_wvalid <= 1'b0;
            end
        join

        wait(s_axi_bvalid && s_axi_bready);
        resp = s_axi_bresp;
        @(posedge clk_m);
        s_axi_bready <= 1'b0;
    endtask

    task automatic master_read(
        input  logic [ADDR_WIDTH-1:0] addr,
        output logic [DATA_WIDTH-1:0] data,
        output logic [1:0]            resp
    );
        @(posedge clk_m);
        s_axi_araddr  <= addr;
        s_axi_arprot  <= 3'b000;
        s_axi_arvalid <= 1'b1;
        s_axi_rready  <= 1'b1;

        wait(s_axi_arvalid && s_axi_arready);
        @(posedge clk_m);
        s_axi_arvalid <= 1'b0;

        wait(s_axi_rvalid && s_axi_rready);
        data = s_axi_rdata;
        resp = s_axi_rresp;
        @(posedge clk_m);
        s_axi_rready <= 1'b0;
    endtask

    // -------------------------------------------------------------------------
    // Slave Responder Logic
    // -------------------------------------------------------------------------
    logic [DATA_WIDTH-1:0] mem [0:255]; // Fixed size memory for Icarus

    initial begin
        // Initialize memory
        for (int i=0; i<256; i++) mem[i] = 0;
        
        forever begin
            @(posedge clk_s);
            
            // Write
            if (m_axi_awvalid && m_axi_wvalid && !m_axi_bvalid) begin
                m_axi_awready <= 1'b1;
                m_axi_wready  <= 1'b1;
                @(posedge clk_s);
                mem[m_axi_awaddr[7:0]] = m_axi_wdata;
                m_axi_awready <= 1'b0;
                m_axi_wready  <= 1'b0;
                
                m_axi_bresp   <= 2'b00;
                m_axi_bvalid  <= 1'b1;
                wait(m_axi_bready);
                @(posedge clk_s);
                m_axi_bvalid  <= 1'b0;
            end

            // Read
            if (m_axi_arvalid && !m_axi_rvalid) begin
                m_axi_arready <= 1'b1;
                @(posedge clk_s);
                m_axi_arready <= 1'b0;
                
                m_axi_rdata   <= mem[m_axi_araddr[7:0]];
                m_axi_rresp   <= 2'b00;
                m_axi_rvalid  <= 1'b1;
                wait(m_axi_rready);
                @(posedge clk_s);
                m_axi_rvalid  <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Test Execution
    // -------------------------------------------------------------------------
    initial begin
        logic [1:0] resp;
        logic [DATA_WIDTH-1:0] rdata;
        int err_count = 0;

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_axi_cdc_bridge);

        $display("--- [TB] Asserting Reset ---");
        rst_n = 0;
        #(100);
        rst_n = 1;
        #(100);

        $display("--- [TB] Test 1: Backpressure (Fast Master, Slow Slave) ---");
        clk_m_period = 10;
        clk_s_period = 50;
        #(100);
        
        for (int i = 0; i < 6; i++) begin
            master_write(32'h0000 + (i*4), $urandom(), resp);
            $display("[T=%0t] Wrote Burst %0d", $time, i);
        end

        $display("--- [TB] Test 2: Simultaneous Read/Write ---");
        clk_m_period = 20;
        clk_s_period = 20;
        #(100);

        fork
            begin
                master_write(32'h0020, 32'hDEADBEEF, resp);
                $display("[T=%0t] Simultaneous Write Complete", $time);
            end
            begin
                master_read(32'h0000, rdata, resp);
                $display("[T=%0t] Simultaneous Read Complete. Data: %h", $time, rdata);
            end
        join

        $display("--- [TB] Test 3: Clock Ratio Sweep ---");
        
        // 1:3
        clk_m_period = 30; clk_s_period = 10;
        #(100);
        master_write(32'h0030, 32'h11112222, resp);
        master_read(32'h0030, rdata, resp);
        if(rdata !== 32'h11112222) err_count++;

        // 5:1
        clk_m_period = 10; clk_s_period = 50;
        #(100);
        master_write(32'h0040, 32'h33334444, resp);
        master_read(32'h0040, rdata, resp);
        if(rdata !== 32'h33334444) err_count++;

        // 2:3
        clk_m_period = 20; clk_s_period = 30;
        #(100);
        master_write(32'h0050, 32'h55556666, resp);
        master_read(32'h0050, rdata, resp);
        if(rdata !== 32'h55556666) err_count++;

        #(200);
        if (err_count == 0)
            $display("--- [TB] STATUS: PASSED ---");
        else
            $display("--- [TB] STATUS: FAILED (%0d Errors) ---", err_count);
            
        $finish;
    end
endmodule