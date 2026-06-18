
// Function  : Structural stub for UPF level-shifter cell insertion
module axi_level_shifter #(
    parameter int WIDTH = 1
)(
    input  logic [WIDTH-1:0] in_data,
    output logic [WIDTH-1:0] out_data
);
    // RTL feed-through. Physical design tools will replace this 
    // boundary with target library level shifters.
    assign out_data = in_data;

endmodule