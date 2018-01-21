`include "sample_ctrl.sv"

module sampling #(
  parameter DATAWIDTH    = 32,
  parameter PIXWIDTH   = 16,
  parameter PIXNUMWIDTH = 11, // choose 1200 pix
  parameter ADDR    = 14

)
(
  output logic done,
  output logic load,
  output logic store,
  output logic [ADDR - 1 : 0] faddr,
  output logic [ADDR - 1 : 0] saddr,
  output logic [DATAWIDTH - 1 : 0] sdata,

  input clk,
  input rst,
  input enable,
  input [DATAWIDTH - 1 : 0] fdata,
  input [PIXWIDTH - 1 : 0] threshold
);

  logic load_back;
  logic store_back;
  logic sram_full;
  logic got_it;
  logic msb;
  logic [PIXWIDTH - 1 : 0] first_pix;
  logic [PIXWIDTH - 1 : 0] second_pix;
  logic [PIXWIDTH - 1 : 0] result1;
  logic [PIXWIDTH - 1 : 0] result2;
  logic [PIXWIDTH - 1 : 0] result;
  logic [PIXWIDTH - 1 : 0] Max;
  logic [PIXNUMWIDTH - 1 : 0] pix_num;
  logic [PIXNUMWIDTH - 1 : 0] count;
  logic [ADDR - 1 : 0] got_data;

  logic [ADDR - 1 : 0] store_faddr;


  assign pix_num = 'd1200;
  
  sample_ctrl _sample_ctrl1(
    .done(done),
    .load(load),
    .store(store),
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .load_back(load_back),
    .store_back(store_back),
    .sram_full(sram_full),
    .got_it(got_it)
  );
 always_ff @(posedge clk) begin : _load_addr
   if(rst)begin
      faddr <= 'd0;
      store_faddr <= 'd0;
    end
    else if (load) begin
      faddr <= faddr + 'd1; //?
      store_faddr <= faddr;
    end
    else begin 
      faddr <= faddr;
      store_faddr <= store_faddr;
    end
  end : _load_addr 

  always_ff @(posedge clk) begin : _store_addr
    if(rst) begin
      //saddr <= 'h3FFF;
      saddr <= 'd0;
    end
    else if (!store) begin
      saddr <= saddr + 'd1;//?
    end
    else begin 
      saddr <= saddr;
    end
  end : _store_addr 

   always_comb begin 
    if(rst) begin
      sdata = 'd0;
    end
    else begin
      sdata = {msb,17'd0,got_data};
    end
 
   end 
 
 ////////////////////////////////////////////////////////////////////
  always_comb begin : _extract_pix
    if(rst) begin
    first_pix  = 'd0;
    second_pix = 'd0;
    end
    else begin
      if(load) begin
       first_pix  = fdata[31:16];
       second_pix = fdata[15:0];
     end
     else begin
       first_pix  = first_pix;
       second_pix = second_pix;
     end
     
    end
  end:_extract_pix
//  always_comb begin:_extract_pix
//    first_pix  = fdata[31:16];
//    second_pix = fdata[15:0];
//  end:_extract_pix
/////////////////////////////////////////////////////////////////////////
//  always_comb begin:_compare_threshold
//  always_ff @(posedge clk) begin :_compare_threshold
  always_comb begin:_caculate_pix_value
    if(rst) begin
      result1 = 'd0;
      result2 = 'd0;
      Max     = 'd0;
    end
    else begin
      result1 = (first_pix-second_pix);
      result2 = (second_pix-first_pix);
      Max     = 'd30000;
    end
  end:_caculate_pix_value
    always_comb begin:_abs_
      if(rst)begin
        result = 'd0;
        msb = 'd0;
      end
      else if(result1[15]==1'd1) begin
        result = result2;
        msb = 'd0;
      end
      else if(result2[15]==1'd1)begin
        result = result1;
        msb = 'd1;
      end
      else begin
        result = 'd0;
        msb = 'd0;
      end
    end:_abs_

  ///////////////////////////////////////////////
  always_comb begin:_compare_threshold
    if(rst) begin
      got_it   = 'd0;
    end
    else begin
      if(load) begin
        if( (result>threshold) & (result< Max))begin
          got_it    = 'd1;
        end // the end of sub
        else begin
          got_it    = 'd0;
        end
      end // the end of load back
      else begin
        got_it    = 'd0;
      end
    end
  end:_compare_threshold
  always_ff@(posedge clk)begin
    if(rst) begin
      got_data = 'd0;
    end
    else begin
      if(load) begin
        if( got_it)begin
          got_data  = faddr;
        end // the end of sub
        else begin
          got_data  = got_data;
        end
      end // the end of load back
      else begin
        got_data  = got_data;
      end
    end
  end
 
  ///////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////
  always_ff@(posedge clk) begin:_sram_counter
    if(rst)
      count <= 'd0;
  	else if(sram_full)
      count <= 'd0;
    else if(!store)
      count <= count + 'd1;
    else
      count <= count;
  end:_sram_counter

  always_comb begin:_sram_full_judge
    if(rst) 
      sram_full = 'd0;
    else if (count == pix_num) 
      sram_full = 'd1;
    else 
      sram_full = 'd0;
  end: _sram_full_judge

endmodule
