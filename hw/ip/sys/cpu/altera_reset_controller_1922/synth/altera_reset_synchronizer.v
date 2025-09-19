// (C) 2001-2024 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/24.1/ip/iconnect/merlin/altera_reset_controller/altera_reset_synchronizer.v#1 $
// $Revision: #1 $
// $Date: 2024/02/01 $

// -----------------------------------------------
// Reset Synchronizer
// -----------------------------------------------
`timescale 1 ns / 1 ns

module altera_reset_synchronizer
#(
    parameter ASYNC_RESET = 1,
    parameter DEPTH       = 2
)
(
    input   reset_in /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R101" */,

    input   clk,
    output  reset_out
);

    // -----------------------------------------------
    // Synchronizer register chain. We cannot reuse the
    // standard synchronizer in this implementation 
    // because our timing constraints are different.
    //
    // Instead of cutting the timing path to the d-input 
    // on the first flop we need to cut the aclr input.
    // 
    // We omit the "preserve" attribute on the final
    // output register, so that the synthesis tool can
    // duplicate it where needed.
    // -----------------------------------------------
    (*preserve*) reg [DEPTH-1:0] altera_reset_synchronizer_int_chain;
    reg altera_reset_synchronizer_int_chain_out;

    generate if (ASYNC_RESET) begin

        // -----------------------------------------------
        // Assert asynchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk or posedge reset_in) begin
            if (reset_in) begin
                altera_reset_synchronizer_int_chain <= {DEPTH{1'b1}};
                altera_reset_synchronizer_int_chain_out <= 1'b1;
            end
            else begin
                altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
                altera_reset_synchronizer_int_chain[DEPTH-1] <= 0;
                altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
            end
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
     
    end else begin

        // -----------------------------------------------
        // Assert synchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk) begin
            altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
            altera_reset_synchronizer_int_chain[DEPTH-1] <= reset_in;
            altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
 
    end
    endgenerate

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "mGRsLYfWicheP0erJvEDz+uUwjikafKrWAUMZ+LXjX0hozU14jxkrvojuEJJnZshZZGo2XaRG5HRgCO5iCIWwfTpZ+Uw6M8QQRA65LZ0JpHnr8kbfnnsDzGUGGUPmplENoNY9CIenernnIbhp+azBqOpWfYTS/SURsEv/MOuTynLgBL/LqhPjCMaDbIqDO5UjzC6mXTHwvutaqdbK+v9swTv/oN/7R0f1O5SgKsPzBQbF/qMO8O+z5bVp4skQU2qoorBQo9MoNpmasaG//DkD/oyIQsmYQP2ndxKhFhvqE7DshHxzqV1ikLwHpjAgxbaD424Ox3AmPKg0Prqt5xZE6A26j5bcuukD+mvmat5z9a44IN/juqcAXNa6c5B8dXBGEKYw377mWIG9dsBNtzu23zz5pfF/8WVFx/OSnPyG5ROYXXFqTQYQ/aodhBIYFN6upx4PrX2MpaL+OEdtJiQjQ3QZjm4R5s3Y7AyAdUaTnOBbMYg2DTlRYtOU3l9I4VM4lfPVLHX6b2wfO2WAEsWU0g6Zmf4k1wvoLuTBJEOLBhJAZHPxa/k4ahGDKgN6pfPAMvmG+NiPBXENg7PtS8LQrQbbEOBIQmm8RMauNGKuWiMplWREAESVTBZKW0x4IzKMRefSogpdc27g57s4JXSfSWmRHgaR6TotNL+K8PmeW3PyVwmFbBZJ/3TrTHmdEZe8DemN6CfCmTf4pwIQ00vmqT29jafXJujxu9e4iC7vxoGl1TrF4cQ6uvJm6gGaKAlWqJBX8UK5Gkezf5KIErcTa85kdcXyrz/IBbojqRXlwLpn45PcmknNxi+LxTWwPe6euN9knpfwYCSienmt9MR95IYq3VkboDWpKvzRJvduRevePHGxcXXw/hFspaKlu23xUKXXxxwpfjebtwHPheJ1BDsZo6FF7zDXtoLvYkRTcFAZKdN0bRlIDzPZqdox7Y48QQdIplEtcNz311lbs5ihYDRKZ2GW+orAq4ihVNrBRkwFPxvZJ0+3OwJUnAgIUbP"
`endif