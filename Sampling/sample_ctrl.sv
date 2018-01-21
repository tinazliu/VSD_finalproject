module sample_ctrl#(
  parameter DATAWIDTH = 32,
  parameter FRAMEADDR = 16,
  parameter SAMPLEADDR = 16,
  parameter STATESWIDTH = 3

)
(
  output logic done,
  output logic load,
  output logic store, //active_low
  output logic load_back,
  output logic store_back,
  input clk,
  input rst,
  input enable,
  input sram_full,
  input got_it
);
  typedef enum logic [STATESWIDTH - 1 : 0] {IDLE, LOAD,WAIT,STORE, DONE} State;

  State cs , ns;
//---State Transfer ---//
  always_ff @(posedge clk) begin : _state_transfer
    if(rst) cs <= IDLE;
    else cs <= ns;
    
  end : _state_transfer 
//--------------------//

  always_comb begin: _ns_logic
    case(cs)
      IDLE: begin
        if(enable) ns = WAIT;
        else ns = IDLE;
      end
      WAIT: begin
        ns = LOAD;
      end
      LOAD: begin
        if(got_it) ns = STORE;
        else       ns = WAIT;
      end
      STORE: begin
        if(sram_full) ns = DONE;
        else ns = LOAD; 
      end
      DONE: begin
        ns = IDLE;
      end
    endcase
  end: _ns_logic

 //-------------------------// 
  always_comb begin :_output_logic
    case(cs)
      IDLE: begin
        load       = 1'b0;
        store      = 1'b1;
        done       = 1'b0;
        load_back  = 1'b0;
      end
      WAIT: begin
        load       = 1'b0;
        store      = 1'b1;
        done       = 1'b0;
        load_back  = 1'b0;
 
      end
      LOAD: begin
        load       = 1'b1;
        store      = 1'b1;
        done       = 1'b0;
        load_back  = 1'b0;
      end
      STORE: begin
        load       = 1'b0;
        store      = 1'b0;
        done       = 1'b0;
        load_back  = 1'b0;
      end
      DONE: begin
        load       = 1'b0;
        store      = 1'b1;
        done       = 1'b1;
        load_back  = 1'b0;
      end
    endcase
  end :_output_logic
endmodule
