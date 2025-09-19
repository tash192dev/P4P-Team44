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


// $Id: //acds/rel/24.1/ip/iconnect/pd_components/altera_std_synchronizer/altera_std_synchronizer.v#1 $
// $Revision: #1 $
// $Date: 2024/02/01 $
// $Author: psgswbuild $
//-----------------------------------------------------------------------------
//
// File: altera_std_synchronizer.v
//
// Abstract: Single bit clock domain crossing synchronizer. 
//           Composed of two or more flip flops connected in series.
//           Random metastable condition is simulated when the 
//           __ALTERA_STD__METASTABLE_SIM macro is defined.
//           Use +define+__ALTERA_STD__METASTABLE_SIM argument 
//           on the Verilog simulator compiler command line to 
//           enable this mode. In addition, dfine the macro
//           __ALTERA_STD__METASTABLE_SIM_VERBOSE to get console output 
//           with every metastable event generated in the synchronizer.
//
// Copyright (C) Altera Corporation 2009, All Rights Reserved
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_std_synchronizer (
				clk, 
				reset_n, 
				din, 
				dout
				);

   parameter depth = 3; // This value must be >= 2 !
     
   input   clk;
   input   reset_n;    
   input   din;
   output  dout;

   // QuartusII synthesis directives:
   //     1. Preserve all registers ie. do not touch them.
   //     2. Do not merge other flip-flops with synchronizer flip-flops.
   // QuartusII TimeQuest directives:
   //     1. Identify all flip-flops in this module as members of the synchronizer 
   //        to enable automatic metastability MTBF analysis.
   //     2. Cut all timing paths terminating on data input pin of the first flop din_s1.

   (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]\" "} *) reg din_s1;

   (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg [depth-2:0] dreg;    
   
   //synthesis translate_off
   initial begin
      if (depth <2) begin
	 $display("%m: Error: synchronizer length: %0d less than 2.", depth);
      end
   end

   // the first synchronizer register is either a simple D flop for synthesis
   // and non-metastable simulation or a D flop with a method to inject random
   // metastable events resulting in random delay of [0,1] cycles
   
`ifdef __ALTERA_STD__METASTABLE_SIM

   reg[31:0]  RANDOM_SEED = 123456;      
   wire  next_din_s1;
   wire  dout;
   reg   din_last;
   reg 	 random;
   event metastable_event; // hook for debug monitoring

   initial begin
      $display("%m: Info: Metastable event injection simulation mode enabled");
   end
   
   always @(posedge clk) begin
      if (reset_n == 0)
	random <= $random(RANDOM_SEED);
      else
	random <= $random;
   end

   assign next_din_s1 = (din_last ^ din) ? random : din;   

   always @(posedge clk or negedge reset_n) begin
       if (reset_n == 0) 
	 din_last <= 1'b0;
       else
	 din_last <= din;
   end

   always @(posedge clk or negedge reset_n) begin
       if (reset_n == 0) 
	 din_s1 <= 1'b0;
       else
	 din_s1 <= next_din_s1;
   end
   
`else 

   //synthesis translate_on   
   always @(posedge clk or negedge reset_n) begin
       if (reset_n == 0) 
	 din_s1 <= 1'b0;
       else
	 din_s1 <= din;
   end
   //synthesis translate_off      

`endif

`ifdef __ALTERA_STD__METASTABLE_SIM_VERBOSE
   always @(*) begin
      if (reset_n && (din_last != din) && (random != din)) begin
	 $display("%m: Verbose Info: metastable event @ time %t", $time);
	 ->metastable_event;
      end
   end      
`endif

   //synthesis translate_on

   // the remaining synchronizer registers form a simple shift register
   // of length depth-1
   generate
      if (depth < 3) begin
	 always @(posedge clk or negedge reset_n) begin
	    if (reset_n == 0) 
	      dreg <= {depth-1{1'b0}};	    
	    else
	      dreg <= din_s1;
	 end	 
      end else begin
	 always @(posedge clk or negedge reset_n) begin
	    if (reset_n == 0) 
	      dreg <= {depth-1{1'b0}};
	    else
	      dreg <= {dreg[depth-3:0], din_s1};
	 end
      end
   endgenerate

   assign dout = dreg[depth-2];
   
endmodule 


			
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "OE3ZZ2F5vO0gBFwhyZnSxaJX0u2JzRJq89pHAgyeohXu3kefSyovfmATuVHMt2FYguEKkq/T2TiXb3DDHCQOoggNmLVIznaXDcjEXRTLdiT3kpk+BSxCB3fD7scpaV5IF7x1AtCMgMZI8fQD5Qf8x1jK5A0Zfp2DFYohNfb40GaM8QF3vs9RlNN6YZ5V3i/5YrcdXkzVPqONWmJzZH5lohJJZ2G09mrw92Ad8N6tUC5qFaCSAxT6Jy8JEeI/BJz1IwCYTjuvZU/1YzwgAaQtdP6Dz8MegAoGlwgZ4BTPQse5Ibyli33eqbnf1/IRc75xGkj41tV6rnLQwipmfrn2qhd74znA62ddRuxsuI0OerKWEVVAyeUZtwW/xl/kq0s7dURdeX2OF7Lt2zdINYNEcNfW6arMUvKQFMyM94R3K4QeckMR8PpY7OdIZK76Nc2CVqaZnwcNhRA82xIA4Rgvp1AcTHNeUT5GzQ3gxpRAIdfs8GPhOs8yF1AhjfNSki+25/F6jWkaMDpMglLupBKS6ZdY+yDC/yecM+08zxvt04hvsBjDbbh9ptWOfzCtG9FkGuXf7sX8eV5CNPxGqVHBoAPNvc7EmmC8hr8LRyk6wokU6WDaqMft9wmSGovUTqBUyP7o/EUvRGj4rm3m82tp7H2G3aZJKRc8Bb8vrF4gi/L1gI8vPhbW6p8sekEkKxCQKyWc5Q3ofb8dHvkvCSn2e8wt5v8Bwa0PsgnhFcI8e3Hlmzr6H6YgiInGpEhP4idIiU2S1Gwi4n/YDREnE8tz9Vp/vsoMG/3zz6p3E6Crh7lzbyfMPPpzZuDtCN8TTzh8jb6m0vP0SrP3K30RlNFeHDTw5s3uifCTDfYIAtky+fopkHm9FDNflFiZdBZ341XXufvg4qouOG/nyhKVjI0CpgjQrFjkxjXHV4AVZFFiyY49+/ANfl6WzUJMZeTDS/5aJwH0nkMyQp1AgLvizMMNnB34l7J30zX6KJ545OgJ+1tWeoduu+baACl8ekVsL/+8"
`endif