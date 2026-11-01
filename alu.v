// -----------------------------------------------------------------------------
// alu.v : Baseline 32-bit combinational ALU (RV32I-inspired)
//
// BASELINE: no operand isolation, no clock gating, no sequential logic.
// All three functional units always receive the raw A and B, so every unit
// toggles on every input change even when its result is not selected.
// This wasted activity is what later stages will measure and reduce.
// -----------------------------------------------------------------------------
module alu (
    input      [31:0] A,
    input      [31:0] B,
    input      [3:0]  ALU_Control,
    output reg [31:0] ALU_Result
);
 
    // ALU control encoding (shared by every file in the project)
    localparam [3:0] OP_ADD  = 4'b0000;
    localparam [3:0] OP_SUB  = 4'b0001;
    localparam [3:0] OP_SLT  = 4'b0010;
    localparam [3:0] OP_SLTU = 4'b0011;
    localparam [3:0] OP_AND  = 4'b0100;
    localparam [3:0] OP_OR   = 4'b0101;
    localparam [3:0] OP_XOR  = 4'b0110;
    localparam [3:0] OP_SLL  = 4'b1000;
    localparam [3:0] OP_SRL  = 4'b1001;
    localparam [3:0] OP_SRA  = 4'b1010;
 
    wire [31:0] arith_result;
    wire [31:0] logic_result;
    wire [31:0] shift_result;
 
    // Each unit gets the ORIGINAL, ungated operands (intentional for the baseline).
    arithmetic_unit u_arith (
        .A           (A),
        .B           (B),
        .ALU_Control (ALU_Control),
        .Result      (arith_result)
    );
 
    logic_unit u_logic (
        .A           (A),
        .B           (B),
        .ALU_Control (ALU_Control),
        .Result      (logic_result)
    );
 
    shifter_unit u_shift (
        .A           (A),
        .B           (B),
        .ALU_Control (ALU_Control),
        .Result      (shift_result)
    );
 
    // Result-selection multiplexer
    always @(*) begin
        ALU_Result = 32'd0;                      // default: invalid control -> 0
        case (ALU_Control)
            OP_ADD, OP_SUB, OP_SLT, OP_SLTU: ALU_Result = arith_result;
            OP_AND, OP_OR,  OP_XOR:          ALU_Result = logic_result;
            OP_SLL, OP_SRL, OP_SRA:          ALU_Result = shift_result;
            default:                         ALU_Result = 32'd0;
        endcase
    end
 
endmodule
 
