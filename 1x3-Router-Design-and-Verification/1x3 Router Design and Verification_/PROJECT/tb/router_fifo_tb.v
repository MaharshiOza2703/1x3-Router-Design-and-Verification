/***************************************************************************************************

NAME        :  Maharshi Oza 
FILENAME    :  router_fifo_tb.v
DATE        :  27/04/2024
DESCRIPTION :  ROUTER - FIFO TB

****************************************************************************************************/

module router_fifo_tb();
// Inputs as reg
reg clock, resetn, soft_reset, write_enb, read_enb,lfd_state;
reg [7:0] data_in;
// Outputs as wire
wire full, empty;
wire [7:0] data_out;

parameter period=10;
reg[7:0] header, parity;	// we are not including lfd_state.

reg[1:0] addr;	// This address is LSB->2 bits {represents the destination ID or location}

integer i;
router_fifo DUT (clock, resetn, soft_reset, write_enb, read_enb, lfd_state, data_in, full,  empty, data_out);

//------Clock Generation-------//
initial
begin
  clock=1'b0;
  forever #(period/2) clock = ~clock;
end

//-----------------------------Reset Task Block--------------------------------------

task rst();
  begin
    @(negedge clock)
    resetn=1'b0;
    @(negedge clock)
    resetn=1'b1;
  end
endtask

task soft_rst();
  begin
      @(negedge clock)
      soft_reset=1'b1;
      @(negedge clock)
      soft_reset=1'b0;
  end
endtask


//--------Init------------//
//----------------------------Initialization Task Block------------------------------- 

task initialize();
  begin
    write_enb=1'b0;
    soft_reset=1'b0;
    read_enb=1'b0;
    data_in=0;
    lfd_state=1'b0;
  end
endtask

//-------------------------------Read & Write Block--------------------------//

task pkt_gen;
	reg [7:0] payload_data;	// 8 bits of 1-PL (Payload Data)
	reg [5:0] payload_len;	//Reason for it to be 6 bits --> 6 bits [7:2] of PL_len + 2 bits [1:0] of DESTINATION_ADD
	begin
		@(negedge clock);
			payload_len = 6'd14;	// As per simple specification we are assuming 14(PL) + 1(Header) + 1(Parity) = 16 Total Packet.	// My doubt can we have TPL < 16?
			addr = 2'b01;	// As per our Specification we have 3 location [00, 01,10]
			header = {payload_len, addr};
			data_in = header;
			
			// Adding lfd_state also
			lfd_state = 1'b01;
			write_enb = 1;
			
// Now working for Payload Data.

			for(i=0; i<payload_len; i=i+1)
				begin
					@(negedge clock);
					lfd_state = 0;
					payload_data = {$random}%256;
					data_in = payload_data;
				end
// Now working for parity				
			@(negedge clock);
			parity = {$random}%256;
			data_in = parity;
	end
	
endtask

// Providing Stimulus Now.

initial	
	begin
		
		rst();
		initialize;
		soft_rst;
		pkt_gen;
		
		//repeat(2)
		@(negedge clock);
		read_enb = 1;
		write_enb = 0;
		@(negedge clock)
		wait(empty);	// line suggests that the code is inside a process or an always block. Here, empty seems to be some condition or signal. This line indicates that the process will wait until the condition empty becomes true before executing further.
		@(negedge clock)
		read_enb = 0;
		
		#1000 $finish;
	end

endmodule		
		