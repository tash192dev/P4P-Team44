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


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module altera_avalon_sysid_qsys #(
    parameter ID_VALUE   = 1,
    parameter TIMESTAMP  = 1
)(
    // inputs:
     address,
     clock,
     reset_n,
    
    // outputs:
     readdata
)
;

  output  [ 31: 0] readdata;
  input            address;
  input            clock;
  input            reset_n;

  wire    [ 31: 0] readdata;
  //control_slave, which is an e_avalon_slave
  assign readdata = address ? TIMESTAMP : ID_VALUE;

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "CTFiBi4swn7WZO/4jzPowtlmRrERjXO8DtqBIgE0w6EEQY1jYySe95JMZHrHqqSC8mnKzS1hCX81t/cBIJnu8Tig7M2hGBa488oBLSKKqB5Kj0RjURWxmBCAPvrifL5djwCe+/1WrGKDIFxzPMF3OqNaAys0OJRhDbKTmu83goCW4aHwBloD/poyX4Z4tkXPCTUIhJomkva2M3gdzmfiqUjh1pLELfQYc1afQPI8Cp1pbYrlS05DbXxrpULnwdPN+P8RnduLbU6jq5qlaFJx5GpRpsb7hNJ/vjt8GEdVpkjGluxM/SGSBbMEwsCuN32iAlkC9mTxESqREfxfiwFsiNZo3zvVi7ONwtSjR0G7UFXHr/fw0JS08KhBgRxGq5Im5j4ygT5f1Gf4NB+xlKR2g4W47/vvqGYHxhGUhcUkaHBx8ECTM9W5b7Wca4yfti1EgNRcRzpvgmNe/gZK5qwi5I0W8yIpeFtbmou75zBPQUUgdPhgy0hX15mhRNFwO3g2Ps3st2QDPA/tU3N12ZV68y2RtJAoEzwPNHCqpkikH/1MZUbituB0R7jhXUA77zsON3M3LQjKbRYzBgeG4Y3xpp8rIS+jsIsB10nK5NgT1mdEd1o0305uEUj2EXHVLhBcQ9RMxv94ipbEXrWoSvi/FokxLRLuieepsW8uNrEyFhivUl0JMji0kWiakyls/vda8fWJUusl4L2LRf/0yThHD2n+7IfM6xPe64Tt140UAgso2n2d9L1zv3HCfja8OrTu0AepyQXHYjxEjA84yNyWYSVBm5dTLVfmyQRYEiuIg8B98krYA1mFvmOvDjQYY92tDkOe/jTPl1J8PlHzKx3TsboVk7GoVzegCsQmKAVL4fNYQtwXoVW2fIwjfsrmyQ6h4HdZl+pOtpgnybW72D7lQl+RusRZIgi5wbNeXpvBkkVYwuckfeVeUMZSyH5wrlRFvRsjpGFTjk8wWYZ74g9I8w/KwxJRAXpMqup+BadOD51x0VtPzom6lYr0wXal5qtm"
`endif