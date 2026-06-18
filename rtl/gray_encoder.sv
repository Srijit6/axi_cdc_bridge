
//Binary-to-Gray and Gray-to-Binary converters
module bin2gray #(
    parameter int WIDTH = 4
)(
    input  logic [WIDTH-1:0] bin,
    output logic [WIDTH-1:0] gray
);
    assign gray = bin ^ (bin >> 1);
endmodule

module gray2bin #(
    parameter int WIDTH = 4
)(
    input  logic [WIDTH-1:0] gray,
    output logic [WIDTH-1:0] bin
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin : gen_g2b
            assign bin[i] = ^(gray >> i);
        end
    endgenerate
endmodule