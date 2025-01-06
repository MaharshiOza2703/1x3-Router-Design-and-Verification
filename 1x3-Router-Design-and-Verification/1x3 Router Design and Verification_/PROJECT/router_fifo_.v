
/***************************************************************************************************

NAME        :  Maharshi M Oza
FILENAME    :  router_fifo.v
DATE        :  27/04/2024
DESCRIPTION :  ROUTER - FIFO design - RTL Logic

****************************************************************************************************/

module router_fifo (clock, resetn, soft_reset, write_enb, read_enb, lfd_state, data_in, full,  empty, data_out);
	input clock, resetn, soft_reset;
	input write_enb, read_enb, lfd_state;
	input [7:0] data_in;

	output reg [7:0] data_out;
	output full, empty;
	reg [4:0] rd_pointer, wr_pointer;
	reg [6:0] count;
	reg [8:0] mem [15:0];

	integer i;
	reg lfd_state_t;
  always@(posedge clock)
    begin
      if(!resetn)	
        lfd_state_t <= 0;	
      else
        lfd_state_t <= lfd_state;
    end 
always@(posedge clock)
	begin
		if(!resetn)
			begin
				data_out <= 8'b0;
				rd_pointer <= 5'b0;		
			end
		else if(soft_reset)
			begin
				data_out <= 8'bz;
				rd_pointer <= 5'b0;		
			end
		else if((read_enb) && (!empty))
			begin
				data_out <= mem[rd_pointer[3:0]][7:0];	
				rd_pointer <= rd_pointer + 5'b1;	
			end
		else if(count == 0)
			data_out <= 8'bz;
	end
always@(posedge clock)
	begin
		if(!resetn)
		begin
		for( i=0; i<16; i=i+1)
			begin
				mem[i] <= 8'b0;
			end
		wr_pointer <= 0;
		end
		
		else if(soft_reset)
		begin
		for( i=0; i<16; i=i+1)
		begin
			mem[i] <= 8'bz;
		end
		wr_pointer <= 0;
		end
		
		else if((write_enb) && (~full))
		begin
		mem[wr_pointer[3:0]][8:0] <= {lfd_state_t, data_in};		
		wr_pointer <= wr_pointer + 5'b1;		
		end
		
	end

  always@(posedge clock)
    begin
if(read_enb && !empty)
  begin
    if((mem[rd_pointer[3:0]][8])==1'b1)		
      count <= mem[rd_pointer[3:0]][7:2] + 1'b1;	
    else if(count != 0)
      count <= count - 1'b1;
  end
    end
assign full = (wr_pointer == 5'b10000 && rd_pointer == 5'b0) ? 1'b1 : 1'b0;
assign empty = (wr_pointer == rd_pointer) ? 1'b1 : 1'b0;

endmodule
