/***************************************************************************************************

NAME        :  Maharshi Oza
FILENAME    :  router_fsm_tb.v
DATE        :  06/05/2024
DESCRIPTION :  ROUTER FSM - Test Bench

****************************************************************************************************/

module router_fsm_tb();

reg clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid;
reg [1:0] data_in;
wire write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;

parameter cycle=10;

router_fsm DUT(clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
  
  parameter DECODE_ADDRESS       = 3'b000,
            LOAD_FIRST_DATA 	 = 3'b001,
            LOAD_DATA 		     = 3'b010,
            WAIT_TILL_EMPTY 	 = 3'b011,
            CHECK_PARITY_ERROR   = 3'b100,
            LOAD_PARITY 		 = 3'b101,
            FIFO_FULL_STATE 	 = 3'b110,
            LOAD_AFTER_FULL 	 = 3'b111;
    
  
   initial
   begin
    clock=1'b1;
    forever #cycle clock = ~clock;
   end

   task initialize;
   begin
   {pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,fifo_full,parity_done,low_packet_valid}=0;
   end
   endtask

   task rst;
   begin
   @(negedge clock)
    resetn=1'b0;
   @(negedge clock)
    resetn=1'b1;
   end
   endtask

   task t1;	//DA- LFD - LD - LP - CPE - DA.
   begin
   @(negedge clock)  // LFD
   begin
   pkt_valid<=1;
   data_in[1:0]<=0;
   fifo_empty_0<=1;
   end              
   @(negedge clock) //LD
   @(negedge clock) //LP
   begin
   fifo_full<=0;
   pkt_valid<=0;
   end
   @(negedge clock) // CPE
   @(negedge clock) // DA
   fifo_full<=0;
   end
   endtask

   task t2;
   begin
   @(negedge clock)//LFD
   begin
   pkt_valid<=1;
   data_in[1:0]<=0;
   fifo_empty_0<=1;
   end
   @(negedge clock)//LD		// How do we know if all the PL is completed? for that is 1 clock cycle enough?
   @(negedge clock)//FFS
   fifo_full<=1;
   @(negedge clock)//LAF
   fifo_full<=0;
   @(negedge clock)//LP
   begin
   parity_done<=0;
   low_packet_valid<=1;
   end
   @(negedge clock)//CPE
   @(negedge clock)//DA
   fifo_full<=0;
   end
   endtask

   task t3;
   begin
   @(negedge clock) //LFD
   begin
   pkt_valid<=1;
   data_in[1:0]<=0;
   fifo_empty_0<=1;
   end
   @(negedge clock) //LD
   @(negedge clock) // FFS
   fifo_full<=1;
   @(negedge clock) // LAF
   fifo_full<=0;
   @(negedge clock)  // LD
   begin
      low_packet_valid<=0;
	parity_done<=0;

   end  // LP
   @(negedge clock)
   begin
   fifo_full<=0;
   pkt_valid<=0;
   end
   @(negedge clock) // CPE
   @(negedge clock) // DA
   fifo_full<=0;
   end
   endtask
   
   task t4;
   begin
   @(negedge clock)  // LFD
   begin
   pkt_valid<=1;
   data_in[1:0]<=0;
   fifo_empty_0<=1;
   end        
   @(negedge clock)   // LD
   @(negedge clock)   // LP
   begin
   fifo_full<=0;
   pkt_valid<=0;
   end
   @(negedge clock)   // CPE 
   @(negedge clock)   // FFS
   fifo_full<=1;
   @(negedge clock)   // LAF
   fifo_full<=0;
  @(negedge clock)    // DA
   parity_done=1;
   end
   endtask


   initial
   begin
   rst;
   initialize;
  
    t1;
	rst;
	#30
    t2;
	rst;
	#30
	t3;
	rst;
	#30
    t4;
	rst;
   

   #1000 $finish;
   end
   endmodule 
