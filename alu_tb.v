// -----------------------------------------------------------------------------
// tb_alu.v : Self-checking testbench for the baseline 32-bit ALU
// Expected values are written as explicit unsigned hex constants, so the
// testbench does not depend on the signed/unsigned behaviour of the DUT logic.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
 
module tb_alu;
 
    // ALU control encoding (same as the RTL)
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
 
    reg  [31:0] A;
    reg  [31:0] B;
    reg  [3:0]  ALU_Control;
    wire [31:0] ALU_Result;
 
    integer total_tests;
    integer fail_count;
 
    alu dut (
        .A          (A),
        .B          (B),
        .ALU_Control(ALU_Control),
        .ALU_Result (ALU_Result)
    );
 
    // Apply one vector, wait for combinational settling, compare, report.
    task run_test;
        input [8*30-1:0] name;
        input [3:0]      ctrl;
        input [31:0]     a_in;
        input [31:0]     b_in;
        input [31:0]     expected;
        begin
            A           = a_in;
            B           = b_in;
            ALU_Control = ctrl;
            #10;
            total_tests = total_tests + 1;
            if (ALU_Result === expected) begin
                $display("[PASS] %0s | ctrl=%b A=%h B=%h expected=%h got=%h",
                         name, ctrl, a_in, b_in, expected, ALU_Result);
            end else begin
                fail_count = fail_count + 1;
                $display("[FAIL] %0s | ctrl=%b A=%h B=%h expected=%h got=%h",
                         name, ctrl, a_in, b_in, expected, ALU_Result);
            end
        end
    endtask
 
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, tb_alu);
 
        total_tests = 0;
        fail_count  = 0;
        A = 32'd0; B = 32'd0; ALU_Control = 4'b0000;
        #10;
 
        $display("==== Arithmetic ====");
        run_test("ADD 10+5",             OP_ADD,  32'd10,      32'd5,       32'd15);
        run_test("ADD 20+30",            OP_ADD,  32'd20,      32'd30,      32'd50);
        run_test("SUB 10-5",             OP_SUB,  32'd10,      32'd5,       32'd5);
        run_test("SUB 5-10 (wrap)",      OP_SUB,  32'd5,       32'd10,      32'hFFFFFFFB);
        run_test("SLT -5<3",             OP_SLT,  32'hFFFFFFFB, 32'd3,      32'd1);
        run_test("SLT 5<-3",             OP_SLT,  32'd5,       32'hFFFFFFFD, 32'd0);
        run_test("SLTU 5<10",            OP_SLTU, 32'd5,       32'd10,      32'd1);
        run_test("SLTU 10<5",            OP_SLTU, 32'd10,      32'd5,       32'd0);
        run_test("SLTU 0xFFFFFFFB<3",    OP_SLTU, 32'hFFFFFFFB, 32'd3,      32'd0);
 
        $display("==== Logic ====");
        run_test("AND pattern",          OP_AND,  32'hF0F0F0F0, 32'hFF00FF00, 32'hF000F000);
        run_test("OR pattern",           OP_OR,   32'hF0F0F0F0, 32'hFF00FF00, 32'hFFF0FFF0);
        run_test("XOR pattern",          OP_XOR,  32'hF0F0F0F0, 32'hFF00FF00, 32'h0FF00FF0);
        run_test("AND pattern 2",        OP_AND,  32'hA5A5A5A5, 32'h0FF00FF0, 32'h05A005A0);
        run_test("OR pattern 2",         OP_OR,   32'hA5A5A5A5, 32'h0FF00FF0, 32'hAFF5AFF5);
        run_test("XOR pattern 2",        OP_XOR,  32'hA5A5A5A5, 32'h0FF00FF0, 32'hAA55AA55);
 
        $display("==== Shifter ====");
        run_test("SLL by 1",             OP_SLL,  32'h00000001, 32'd1,       32'h00000002);
        run_test("SLL by 4",             OP_SLL,  32'h0000000F, 32'd4,       32'h000000F0);
        run_test("SRL by 1",             OP_SRL,  32'h80000000, 32'd1,       32'h40000000);
        run_test("SRL by 4",             OP_SRL,  32'hF0000000, 32'd4,       32'h0F000000);
        run_test("SRA positive by 4",    OP_SRA,  32'h40000000, 32'd4,       32'h04000000);
        run_test("SRA negative by 4",    OP_SRA,  32'h80000000, 32'd4,       32'hF8000000);
        run_test("SLL by 0",             OP_SLL,  32'hDEADBEEF, 32'd0,       32'hDEADBEEF);
        run_test("SRL by 0",             OP_SRL,  32'hDEADBEEF, 32'd0,       32'hDEADBEEF);
        run_test("SRA by 0",             OP_SRA,  32'hDEADBEEF, 32'd0,       32'hDEADBEEF);
        run_test("SLL by 31",            OP_SLL,  32'h00000001, 32'd31,      32'h80000000);
        run_test("SRL by 31",            OP_SRL,  32'h80000000, 32'd31,      32'h00000001);
        run_test("SRA negative by 31",   OP_SRA,  32'h80000000, 32'd31,      32'hFFFFFFFF);
        run_test("SRA positive by 31",   OP_SRA,  32'h7FFFFFFF, 32'd31,      32'h00000000);
        run_test("SLL uses only B[4:0]", OP_SLL,  32'h00000001, 32'h00000021, 32'h00000002);
 
        $display("==== Boundary cases ====");
        run_test("ADD 0+0",              OP_ADD,  32'h00000000, 32'h00000000, 32'h00000000);
        run_test("SUB 0-0",              OP_SUB,  32'h00000000, 32'h00000000, 32'h00000000);
        run_test("AND 0&0",              OP_AND,  32'h00000000, 32'h00000000, 32'h00000000);
        run_test("ADD allones+1",        OP_ADD,  32'hFFFFFFFF, 32'h00000001, 32'h00000000);
        run_test("SUB allones-allones",  OP_SUB,  32'hFFFFFFFF, 32'hFFFFFFFF, 32'h00000000);
        run_test("AND allones",          OP_AND,  32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFF);
        run_test("XOR allones",          OP_XOR,  32'hFFFFFFFF, 32'hFFFFFFFF, 32'h00000000);
        run_test("ADD maxpos+1 (ovf)",   OP_ADD,  32'h7FFFFFFF, 32'h00000001, 32'h80000000);
        run_test("SUB minneg-1 (ovf)",   OP_SUB,  32'h80000000, 32'h00000001, 32'h7FFFFFFF);
        run_test("SLT minneg<maxpos",    OP_SLT,  32'h80000000, 32'h7FFFFFFF, 32'd1);
        run_test("SLT maxpos<minneg",    OP_SLT,  32'h7FFFFFFF, 32'h80000000, 32'd0);
        run_test("SLTU minneg<maxpos",   OP_SLTU, 32'h80000000, 32'h7FFFFFFF, 32'd0);
        run_test("SLTU maxpos<minneg",   OP_SLTU, 32'h7FFFFFFF, 32'h80000000, 32'd1);
        run_test("Invalid ctrl 0111",    4'b0111, 32'h12345678, 32'h9ABCDEF0, 32'h00000000);
        run_test("Invalid ctrl 1011",    4'b1011, 32'h12345678, 32'h9ABCDEF0, 32'h00000000);
        run_test("Invalid ctrl 1111",    4'b1111, 32'hFFFFFFFF, 32'hFFFFFFFF, 32'h00000000);
 
        $display("");
        $display("==================== TEST SUMMARY ====================");
        $display("Total tests : %0d", total_tests);
        $display("Passed      : %0d", total_tests - fail_count);
        $display("Failed      : %0d", fail_count);
        if (fail_count == 0) $display("RESULT      : ALL TESTS PASSED");
        else                 $display("RESULT      : SOME TESTS FAILED");
        $display("======================================================");
 
        #10;
        $finish;
    end
 
endmodule
