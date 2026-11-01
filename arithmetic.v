// -----------------------------------------------------------------------------
// arithmetic_unit.v : ADD, SUB, SLT, SLTU for the baseline 32-bit ALU
// Purely combinational. Invalid opcodes produce zero.
// -----------------------------------------------------------------------------
module arithmetic_unit (
    input      [31:0] A,
    input      [31:0] B,
  input      [3:0]  ALU_Control, //opcode
    output reg [31:0] Result
);
 
    // ALU control encoding (shared by every file in the project)
    localparam [3:0] OP_ADD  = 4'b0000;
    localparam [3:0] OP_SUB  = 4'b0001;
    localparam [3:0] OP_SLT  = 4'b0010;
    localparam [3:0] OP_SLTU = 4'b0011;
 
    // Signed views of the operands. The ports stay unsigned so that ADD/SUB/SLTU
    // behave as plain 32-bit modular/unsigned operations; only SLT uses these.
    wire signed [31:0] A_signed = A;
    wire signed [31:0] B_signed = B;
 
    always @(*) begin
        Result = 32'd0;                          // default: no latch, invalid -> 0
        case (ALU_Control)
            OP_ADD:  Result = A + B;             // wraps modulo 2^32
            OP_SUB:  Result = A - B;             // wraps modulo 2^32
            OP_SLT:  Result = (A_signed < B_signed) ? 32'd1 : 32'd0;
            OP_SLTU: Result = (A < B)               ? 32'd1 : 32'd0;
            default: Result = 32'd0;
        endcase
    end
 
endmodule
