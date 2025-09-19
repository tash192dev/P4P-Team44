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
`pragma questa_oem_00 "aBtvkOB0rVavpqYSnxGbfcYBNx6OkCwAi2K9gh9Y53caqg+VfzD4if1Wx+NybTLcpY+PnuQz6pp9KScOY4ye64zeX7CBjYAFsecofqjfk4a1c+382xda6/OF2dJrJri51Uq3eJPH2tWhlL9RydkIvKPJDVVgsS6+mu9Mhzg00gJFu3PHFz80h2m0h/O4E8aAn998tC3clvatEJIWGp/WDkQ+DABTXAmgzljq9l00wHEsab08RuzsMzvSVzZqInj96LkR+lLYc3f1A/06tUL7O6+1AydTwgHb7zI4shUztiujwknpcpOiYH+dYrmSSt3Om3fckmKFPW9g7R2vy5A8ODlp3ax63CnGOnIXV2+FEkXehpdhdNgy4IGFJVgT6Fi7zImwjbcyH3PdKewqFUe/ejCBkuhYJ4aJhYOq07uTSuBur3WQuPuuxJms60sWzcvo5CDy6oemFdg0UnV/HnPCM81tc6Kh/ashPm1WuEUx8y7MSdXOfdtToFhQFxW3OBtY2rlwNIBtrk4JD///8FcZxNn0nEtiXrZxLn6qhnNCTA2zMvMIy7ILLX1ZbzNWj6fYRDgyELPlaa9ajaO2CHCpeEI7cdulKOwFoMSNIWiPlrxrnBtuIRbiO+7UI0nzGEzywQTDbg/4Pf64whCQJVJ3YThndO0YU1yBj/hS4wzDpYXZp7xlvT+qU5Ni9NQatZJ5glarSqfNXkCMINk/TsVDrnkdMIyTcIZlHji2Ze1COOt5Eq733LMaOZv96MZs3d8kPc/39LClEPOFPnJZy8+F3QB9J2rV6txWmBb+Isjz3O3h1vdariayoFfBksXUD6pHu6gr6WQaD77yf2+sgd/SkrPuOZROtfs6v5DMrtnYyxK1k6meiG73AQuQv8JhYyBU5IvFNzSHfVFOQB9LBjV1awI3kChKrL+B6b7SnbtyqCIEhMLn64uGjATX9IfADxA5VZzU2mNofuVpW7/AkvM70A/dhoEDvJjraPVIyhVJimsit/AEdfpCWkFTuyQuUhqa"
`endif