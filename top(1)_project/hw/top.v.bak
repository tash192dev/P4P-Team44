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


module top(input clk);

    wire sys_reset;
    wire po_reset;
    wire issp_reset;

    altsource_probe #(
        .probe_width(0),
        .source_width(1),
        .source_initial_value("0")
    ) issp_inst (
        .source(issp_reset)
    );

    power_on_reset reset_gen(.clk(clk), .reset(po_reset));

    assign sys_reset = po_reset | issp_reset;

    sys u0(.clk_clk(clk), .reset_reset(sys_reset));

endmodule

module power_on_reset #(
    parameter POR_COUNT = 20	// MUST BE 2 or greater
) (
    input  wire  clk,
    output wire  reset
);

    wire sync_dout;
    altera_std_synchronizer #(
        .depth (POR_COUNT)
    ) power_on_reset_std_sync_inst (
        .clk     (clk),
        .reset_n (1'b1),
        .din     (1'b1),
        .dout    (sync_dout)
    );

    reg output_reg;
    initial begin
        output_reg <= 1'b0;
    end

    always @ (posedge clk) begin
        output_reg <= sync_dout;
    end

    assign reset = ~output_reg;

endmodule
