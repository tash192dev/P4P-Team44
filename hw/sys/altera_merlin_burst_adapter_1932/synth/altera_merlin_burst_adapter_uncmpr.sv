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


// (C) 2001-2012 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other
// software and tools, and its AMPP partner logic functions, and any output
// files any of the foregoing (including device programming or simulation
// files), and any associated documentation or information are expressly subject
// to the terms and conditions of the Altera Program License Subscription
// Agreement, Altera MegaCore Function License Agreement, or other applicable
// license agreement, including, without limitation, that your use is for the
// sole purpose of programming logic devices manufactured by Altera and sold by
// Altera or its authorized distributors.  Please refer to the applicable
// agreement for further details.


// $Id: //acds/main/ip/merlin/altera_merlin_burst_adapter/altera_merlin_burst_adapter.sv#68 $
// $Revision: #68 $
// $Date: 2014/01/23 $

`timescale 1 ns / 1 ns

// -------------------------------------------------------
// Adapter for uncompressed transactions only. This adapter will
// typically be used to adapt burst length for non-bursting 
// wide to narrow Avalon links.
// -------------------------------------------------------
module altera_merlin_burst_adapter_uncompressed_only
#(
    parameter 
    PKT_BYTE_CNT_H  = 5,
    PKT_BYTE_CNT_L  = 0,
    PKT_BYTEEN_H    = 83,
    PKT_BYTEEN_L    = 80,
    ST_DATA_W       = 84,
    ST_CHANNEL_W    = 8
)
(
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                           sink0_valid,
    input  [ST_DATA_W-1 : 0]        sink0_data,
    input  [ST_CHANNEL_W-1 : 0]     sink0_channel,
    input                           sink0_startofpacket,
    input                           sink0_endofpacket,
    output reg                      sink0_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output reg                      source0_valid,
    output reg [ST_DATA_W-1    : 0] source0_data,
    output reg [ST_CHANNEL_W-1 : 0] source0_channel,
    output reg                      source0_startofpacket,
    output reg                      source0_endofpacket,
    input                           source0_ready
);
    localparam
        PKT_BYTE_CNT_W = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1,
        NUM_SYMBOLS    = PKT_BYTEEN_H - PKT_BYTEEN_L + 1;

    wire [PKT_BYTE_CNT_W - 1 : 0] num_symbols_sig = NUM_SYMBOLS[PKT_BYTE_CNT_W - 1 : 0];

    always_comb begin : source0_data_assignments
        source0_valid         = sink0_valid;
        source0_channel       = sink0_channel;
        source0_startofpacket = sink0_startofpacket;
        source0_endofpacket   = sink0_endofpacket;

        source0_data          = sink0_data;
        source0_data[PKT_BYTE_CNT_H : PKT_BYTE_CNT_L] = num_symbols_sig;

        sink0_ready = source0_ready;
    end

endmodule



`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "CTFiBi4swn7WZO/4jzPowtlmRrERjXO8DtqBIgE0w6EEQY1jYySe95JMZHrHqqSC8mnKzS1hCX81t/cBIJnu8Tig7M2hGBa488oBLSKKqB5Kj0RjURWxmBCAPvrifL5djwCe+/1WrGKDIFxzPMF3OqNaAys0OJRhDbKTmu83goCW4aHwBloD/poyX4Z4tkXPCTUIhJomkva2M3gdzmfiqUjh1pLELfQYc1afQPI8Cp0VtSYPycfFdSWML+8H399XgKrLkjfkHbkLda1TNsOkU87klpubInWH65XuG/vJvIsJ+L3Xe2dDcF6nAi/E0iXMI02yRS0jd3z7xIJuffJfMT8KuBIsHMKsDDaHUzPMRMs4TjFSd4A5mZ44bXQLMv3VaB6IzvJWNm7YQH9sDMISM6+Mcr5XRET+eOEJA2zt9E+9xc2kBjv3lbEOSvDLwF6p3POeoEyI5E/MGKEQYoP6wg1sIbo1Ah7X90OFlGIFZmxrReHIMO5/mZ1WN7HAgQJa2/Uaoqhx+iXdha19pw+4lSLAx6H1zQw6K+pzcUWtslrs8QR1TrGx/CEcrE2Mk0DjyZNL3Av2jNjojc1EmUSLS8zEVqRdymSt4WVmmUhmCeO2igY+z9hSq+6KKL/m0aTAmPKagJnl5Evrgk+wxLR0/5u41zTTH1eqQgdl2SjnIFnO36JX9YT+WpTvRrLB0VqTG0/rKT/d5lacSig9isfdO00tJ8UKdh/EkN+a8Utjk29hMdPhMK1/9BAQURxRFOJdUVVdOhMAikJqG84n66JlkwpliOJcVVb5jA/+Gmb2foYq6TTFj/iy+XbWBpnOW6Iq3LIZ9MJM33nfFeFopWPP6bmRb5NcHvQjbsughIA9mh+eJvtCqSC/f3G25sJ5rHsi3SgXA03NYqMUlr+rrU/WZzir7//1XfVFG0Fo+TXd6Yqm5PXIeMpzG6UFki2CHusCq8Eo9pWhzqyIJ76ylu4zpM/7ZHK4zt1kG3OPSnaHSjjNYDE33QKopisqnr2hsB+J"
`endif