`define CYCLE 10
`timescale 1ns/10ps
`include "sampling.sv"
`include "SRAM/SRAM/SRAM.v"

`timescale 1ns/10ps
module samplig_tb;

  logic done;
  logic load;
  logic store;
//  logic [13 : 0] faddr;
  logic [31 : 0] sdata;
  logic [13 : 0] saddr;
  logic [13 : 0] faddr;
  logic clk;
  logic rst;
  logic enable;
  logic [31 : 0] fdata;
  logic [15 : 0] threshold;
  //---S_SAMPLE---//
  logic [31:0] DOS;
  logic [31:0] DIS;
  logic [13:0] AS;
  logic WEBS;   //write_enable                                  
  logic CK;    //clk                                  
  logic CS;    //chip select                                  
  logic OES;    //output enable                                  
  /////////////////////////////////////////////
  //---S_FRAM---//
  logic [31:0] DOF;
  logic [31:0] DIF;
  logic [13:0] AF;
  logic WEBF;   //write_enable                                  
  logic OEF;    //output enable                                  
  /////////////////////////////////////////////
  logic preload_sig;
  logic [31 : 0] pre_fdata; //load_to_do_the_fdata
  logic [13 : 0] pre_sramaddr;
  logic pre_store;
  //----------------------
  logic preread_sig; 
  logic pre_read;
 
  always #(`CYCLE/2) clk = ~clk;
  always_comb begin:_store2SAMPLE
    if(rst) begin
      DIS  = 'd0;
      AS   = 'd0;
      WEBS = 'd1;
      OES  = 'd0;
    end

    else begin
      DIS  = sdata;
      AS   = saddr;
      WEBS = store;
      OES  = 'd0;
 
   end
 end:_store2SAMPLE

always_comb begin:_pre_load_to_SRAM
    if(rst) begin
      DIF  = 'd0;
      AF   = 'd0;
      WEBF = 'd1;
      OEF  = 'd0;
    end
    else begin
    if(preload_sig)begin
      DIF  = pre_fdata;
      AF   = pre_sramaddr;
      WEBF = pre_store;
      OEF  = 'd0;
    end
    else if (preread_sig) begin
      DIF  = 'd0;
      AF   = pre_sramaddr;
      WEBF = 'd1;
      OEF  = pre_read;
   end
    else begin
      DIF  = 'd0;
      AF   = faddr;
      WEBF = 'd1;
      OEF  = load;
    end
    end
 end:_pre_load_to_SRAM
always_comb begin
   CK = clk;
   CS = 1'd1;
 end



  sampling samp1(
    .done(done),
    .load(load),
    .store(store),
    .sdata(sdata),
    .saddr(saddr),
    .faddr(faddr),

    .clk(clk),
    .rst(rst),
    .enable(enable),
    .fdata(fdata),
    .threshold(threshold)
);
  
  SRAM s_frame(
    .A(AF),
    .DO(fdata),
    .DI(DIF),
    .CK(CK),
    .WEB(WEBF),
    .OE(OEF),
    .CS(CS) // to sample data
  );
  SRAM s_sample(
    .A(AS),
    .DO(DOS),
    .DI(DIS),
    .CK(CK),
    .WEB(WEBS),
    .OE(OES),
    .CS(CS) // to sample data
  );
  initial
  begin
    rst = 1; clk = 0;pre_store = 'd1;
    #(`CYCLE) 
     preload_sig  = 'd1; 
     rst       = 0;
     pre_sramaddr    = 'd0;
     pre_fdata       = 'h00410006;
     pre_store       = 'd0;
    #(`CYCLE*2) 
     pre_sramaddr    = 'd1;
     pre_fdata       = 'h00150056;
     pre_store       = 'd0;
    #(`CYCLE*2) 
     pre_sramaddr    = 'd2;
     pre_fdata       = 'h00560015;
     pre_store       = 'd0;
    #(`CYCLE*2) 
     pre_sramaddr    = 'd3;
     pre_fdata       = 'h00050006;
     pre_store       = 'd0;
    #(`CYCLE*2) 
     pre_sramaddr    = 'd4;
     pre_fdata       = 'h00350056;
     pre_store       = 'd0;
    #(`CYCLE*2) 
     pre_sramaddr    = 'd5;
     pre_fdata       = 'h00040002;
     pre_store       = 'd0;
    #(`CYCLE*2) 
     pre_sramaddr    = 'd6;
     pre_fdata       = 'h00550088;
     pre_store       = 'd0;
    #(`CYCLE*2) 
      pre_sramaddr    = 'd7;
      pre_fdata       = 'h00150056;
      pre_store       = 'd0;
    #(`CYCLE) preload_sig  = 'd0; pre_store = 'd1;
      #(`CYCLE) 
      pre_sramaddr    = 'd0;
      preread_sig     = 'd1;
      pre_read        = 'd1;
      pre_store       = 'd0;
      #(`CYCLE) 
      pre_sramaddr    = 'd1;
      preread_sig     = 'd1;
      pre_read        = 'd1;
      pre_store       = 'd0;
      #(`CYCLE) 
      pre_sramaddr    = 'd2;
      preread_sig     = 'd1;
      pre_read        = 'd1;
      pre_store       = 'd0;
     #(`CYCLE) 
      pre_sramaddr    = 'd3;
      preread_sig     = 'd1;
      pre_read        = 'd1;
      pre_store       = 'd0;
    #(`CYCLE) preread_sig  = 'd0;
    #(`CYCLE) threshold   = 'd20;
    #(`CYCLE) enable      = 1'd1;
    #(`CYCLE) enable      = 1'd0;
    #(`CYCLE*100)
   $display("Done"); 
    $finish;
  end

  initial
  begin
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0, samplig_tb);
    #900000000 $finish;
  end
  endmodule


