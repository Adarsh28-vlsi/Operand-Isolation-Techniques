// -----------------------------------------------------------------------------
// logic_unit.v : AND, OR, XOR for the baseline 32-bit ALU
// Purely combinational. Invalid opcodes produce zero.
// -----------------------------------------------------------------------------
module logic_unit (
    input      [31:0] A,
    input      [31:0] B,
    input      [3:0]  ALU_Control,
    output reg [31:0] Result
);
 
    // ALU control encoding (shared by every file in the project)
    localparam [3:0] OP_AND = 4'b0100;
    localparam [3:0] OP_OR  = 4'b0101;
    localparam [3:0] OP_XOR = 4'b0110;
 
    always @(*) begin
        Result = 32'd0;                          // default: no latch, invalid -> 0
        case (ALU_Control)
            OP_AND:  Result = A & B;
            OP_OR:   Result = A | B;
            OP_XOR:  Result = A ^ B;
            default: Result = 32'd0;
        endcase
    end
 
endmodule
