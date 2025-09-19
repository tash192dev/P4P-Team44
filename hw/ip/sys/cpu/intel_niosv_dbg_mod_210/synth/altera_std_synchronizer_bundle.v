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


// $Id: //acds/rel/24.1/ip/iconnect/pd_components/altera_std_synchronizer/altera_std_synchronizer_bundle.v#1 $
// $Revision: #1 $
// $Date: 2024/02/01 $
//----------------------------------------------------------------
//
// File: altera_std_synchronizer_bundle.v
//
// Abstract: Bundle of bit synchronizers. 
//           WARNING: only use this to synchronize a bundle of 
//           *independent* single bit signals or a Gray encoded 
//           bus of signals. Also remember that pulses entering 
//           the synchronizer will be swallowed upon a metastable
//           condition if the pulse width is shorter than twice
//           the synchronizing clock period.
//
// Copyright (C) Altera Corporation 2008, All Rights Reserved
//----------------------------------------------------------------

module altera_std_synchronizer_bundle(
				     clk,
				     reset_n,
				     din,
				     dout
				     );
   parameter width = 1;
   parameter depth = 3;   
   
   input clk;
   input reset_n;
   input [width-1:0] din;
   output [width-1:0] dout;
   
   generate
      genvar i;
      for (i=0; i<width; i=i+1)
	begin : sync
	   altera_std_synchronizer #(.depth(depth))
                                   u (
				      .clk(clk), 
				      .reset_n(reset_n), 
				      .din(din[i]), 
				      .dout(dout[i])
				      );
	end
   endgenerate
   
endmodule 

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "OE3ZZ2F5vO0gBFwhyZnSxaJX0u2JzRJq89pHAgyeohXu3kefSyovfmATuVHMt2FYguEKkq/T2TiXb3DDHCQOoggNmLVIznaXDcjEXRTLdiT3kpk+BSxCB3fD7scpaV5IF7x1AtCMgMZI8fQD5Qf8x1jK5A0Zfp2DFYohNfb40GaM8QF3vs9RlNN6YZ5V3i/5YrcdXkzVPqONWmJzZH5lohJJZ2G09mrw92Ad8N6tUC54Bop9d8RGkg5NWE4V9a4yh8FEe1EQKLjvKboAAo5NJ9e+urWCt5zTqUnfPHDBfmQguMv+SmCq/sJ1CoKMAAThK/hICGMFjS9jJ6a6gKgvtffjTzuC6Ur+kitYfK1X9vLL/6mfr2z/RI3VU2ea5+siGQXCmylTC8NEvUXecAnc7lG9EFcaqDYW3DXcxwc+ig/cTCUkHhMJorx0BimaeN9uE/8GfRlcjrOMXhstasjGGgGKAq4eLGV0U1Q1h8V//U+coOdQ6Z0wXaQqyrbxlEzEWd6SB5hrSKfdg0wOoQvCsyITbTJyCLh6DAsz8XZaiWfPG4M13FOyTajTeKpGF8RKL1xU7xb2zB2VXmh9x+D4aLwjyGV+y2Kfj2sy6o1LEztPUr/1HVNxSzrMTVd94yEyS5pYA+cjJ/H9KY8F2xISTnzZOppl2XWyY3dVJJc9BUU36Rb9HZM7vRBWFiekwHrOdiKqPTNh3jEBsTaAWZW5TuAcw6BmN8njIlfq0zhBbm6cKHdk7upTlimeQtpfCdtNHzHQnxE2DyOPsdgkhfwJ60hawEcPxAyHC09d9z2/MIzaHU3LQ6nWnthNrvM6oVU7cDiVapqPyFFn3wIkO1ke0QSBrZlKhnslHDqMJxqy6itn/rNmMx6tHssw6JXwHqMZcSv5GEK8pgkCcKnxb1Ed2A2+Ws1MZpI/7+OcDynFsw5za8eWeTmyDU2fpcuOoSvfbFWCNw20Kw72sJPTl8n8dOdeKA/Ht29aQvEaIvnLaXp2PbgkRDS3o9hw09OMZOvM"
`endif