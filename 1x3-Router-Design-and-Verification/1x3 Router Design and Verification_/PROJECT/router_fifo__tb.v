/***************************************************************************************************

NAME        :  Maharshi Oza 
FILENAME    :  router_fifo_tb.v
DATE        :  27/04/2024
DESCRIPTION :  ROUTER - FIFO TB

****************************************************************************************************/

module router_fifo_tb();
reg clock, resetn, soft_reset, write_enb, read_enb,lfd_state;
reg [7:0] data_in;
wire full, empty;
wire [7:0] data_out;

parameter period=10;
reg[7:0] header, parity;	

reg[1:0] addr;	

integer i;
router_fifo DUT (clock, resetn, soft_reset, write_enb, read_enb, lfd_state, data_in, full,  empty, data_out);
initial
begin
  clock=1'b0;
  forever #(period/2) clock = ~clock;
end
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

task initialize();
  begin
    write_enb=1'b0;
    soft_reset=1'b0;
    read_enb=1'b0;
    data_in=0;
    lfd_state=1'b0;
  end
endtask

task pkt_gen;
	reg [7:0] payload_data;	
	reg [5:0] payload_len;	
	begin
		@(negedge clock);
			payload_len = 6'd14;	// As per simple specification we are assuming 14(PL) + 1(Header) + 1(Parity) = 16 Total Packet.	// My doubt can we have TPL < 16?
			addr = 2'b01;	
			header = {payload_len, addr};
			data_in = header;
			lfd_state = 1'b01;
			write_enb = 1;
			for(i=0; i<payload_len; i=i+1)
				begin
					@(negedge clock);
					lfd_state = 0;
					payload_data = {$random}%256;
					data_in = payload_data;
				end			
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
		@(negedge clock);
		read_enb = 1;
		write_enb = 0;
		@(negedge clock)
		wait(empty);	
		@(negedge clock)
		read_enb = 0;
		#1000 $finish;
	end

endmodule		
		