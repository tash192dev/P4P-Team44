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
`pragma questa_oem_00 "GdrtC8041f37ha52Ko+Jde808iDyKA+ht5m5AuKQCsm3cRPQscDvF+wBgbawWOxUtCRI9a/tnC6AChwO+BxfmEV2UK9ncMFAL//YMEMfhylNbbg+DkYNRltJ3oLac/x0CKLYUz0kP213IDPHPJdDrn2XWjqkg2d8WjL/DUsL13IJgiL6ltB1LI/UYnSBUYY+yK6OwicfHT3EuyorZ8lWql/zzL2Fl1behLT6A47M1qgFeAJ/yBHj+Sn9zmaiLg/0DvbbOz/BruIf/Q2HoctoRuThJMc2BuTJ3HC8vxqQeakYygHJGzmXnShKaYvmqkyyKd27sEJGLGuguOdXZOVwIQvBKAT1LlpdYFH+6ejeQA3nM81eO37k7867t/ts7Uv4c02bSA8YcKi53suxwJWw+mx2TyZ7gCO4GqmtL7KOG8qccyfGaOwVNC6fyNiiCZd/LW7XXVKbLWJq8AzA7JeMjju69Q9B6/+yEmYuCsqYRg+QVxYqNLHjncBwm9zE8Gq6yQwvnFqufBUWIxkGvCMX0McXtwjUXXaHemMCL1alHlBmsLA5iNghfPYdHEuTJLNq1yYrxwenvfnlhFEsksXYNkePbMleTf3urwPUb4H3Oef7ny6fCJFMo+jzDlaXY1R/BBfhh6XtOXBybFxBKol1JRSvrCxYcviT7Egr8Kn/1BU+gxx9cGfDyOI+/MU4dNpyfspTHkA6FGh2twJQaDVvMqbrxvbIxj8DZta7gNCqntgwRDsrAT79aYtXNpOZOzM+wNxB36K9FC/+AlMJXATgId5jG0V6MK3ZoGCd8q/ujgku3Wd4en8kSnIITUQGP3H1iSaB4aPpdyH/eEo4Dqg0wpjojUDAI4sAjYyjuaQflEjc9u1iimH+K9cQDONvxpNvcMcyR2LT31TOAzCs3GEsx8wuW4PsoCsyLa1cCkzC0WuTFr0l0uUiqEkjMUqC64bb0QgHE4aXT86yJhmM6f50fObpF0Q56rXCSXdwX+ug3SohqgQ2UA8uJ6LmNFa7ugjQ"
`endif