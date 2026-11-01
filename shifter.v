// -----------------------------------------------------------------------------
// shifter_unit.v : SLL, SRL, SRA for the baseline 32-bit ALU
// Shift amount = B[4:0] (as in RV32I). Upper bits of B are ignored.
// Purely combinational. Invalid opcodes produce zero.
// -----------------------------------------------------------------------------
module shifter_unit (
    input      [31:0] A,
    input      [31:0] B,
    input      [3:0]  ALU_Control,
    output reg [31:0] Result
);
 
    // ALU control encoding (shared by every file in the project)
    localparam [3:0] OP_SLL = 4'b1000;
    localparam [3:0] OP_SRL = 4'b1001;
    localparam [3:0] OP_SRA = 4'b1010;
 
    wire [4:0] shamt = B[4:0];
 
    // SRA needs a signed left operand, otherwise >>> behaves like >> (zero fill).
    // Declaring a signed copy of A keeps the intent explicit and avoids relying on
    // $signed() inside an expression context.
    wire signed [31:0] A_signed = A;
    wire signed [31:0] sra_result = A_signed >>> shamt;
 
    always @(*) begin
        Result = 32'd0;                          // default: no latch, invalid -> 0
        case (ALU_Control)
            OP_SLL:  Result = A << shamt;
            OP_SRL:  Result = A >> shamt;        // zero fill
            OP_SRA:  Result = sra_result;        // sign extension
            default: Result = 32'd0;
        endcase
    end
 
endmodule
