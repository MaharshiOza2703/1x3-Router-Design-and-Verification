
/***************************************************************************************************

NAME        :  Maharshi M Oza
FILENAME    :  router_fifo.v
DATE        :  27/04/2024
DESCRIPTION :  ROUTER - FIFO design - RTL Logic

****************************************************************************************************/

module router_fifo (clock, resetn, soft_reset, write_enb, read_enb, lfd_state, data_in, full,  empty, data_out);

// Declaring input ports.

	input clock, resetn, soft_reset;
	input write_enb, read_enb, lfd_state;
	input [7:0] data_in;	// 8bits or 1 byte as input.
	
// Declaring the output ports as registers.

	output reg [7:0] data_out;
	output full, empty; // should we put this in reg or not? DOUBT
	
// Declaring the write and read pointer for FIFO.
	
	reg [4:0] rd_pointer, wr_pointer;	// Note that we will mostly use [3:0] of these two pointers
	reg [6:0] count;	// Generally we are counting till 30. Adding bit more to count more than 30.
	
// Declaring the MEMORY for FIFO.
	
	reg [8:0] mem [15:0];	// It has 9 Columns --> 8 bits + 1 lfd_state
							// It has 16 Rows --> 16 Address locations.
							
// temp variable for for loop count & LFD State.
	
	integer i;
	reg lfd_state_t;

  always@(posedge clock)
    begin
      if(!resetn)	// resetn is Active low resetn --> which means that it gets triggered when resetn = 0
        lfd_state_t <= 0;	// resetn temp var.
      else
        lfd_state_t <= lfd_state;
    end 
	
//-------------READ-OPERATION----------//

always@(posedge clock)
	begin
		if(!resetn)
			begin
				data_out <= 8'b0;
				rd_pointer <= 5'b0;		// You can change it to 3'b0.
			end
		else if(soft_reset)
			begin
				data_out <= 8'bz;
				rd_pointer <= 5'b0;		// You can change it to 3'b0.
			end
		else if((read_enb) && (!empty))
			begin
				data_out <= mem[rd_pointer[3:0]][7:0];	// We are capturing the memory location @ rd_pointer{ranging from 0-15}, entire byte {No lfd_state}}
				rd_pointer <= rd_pointer + 5'b1;	// Incrementing the rd_pointer.// getting error here need to debug.
			end
		else if(count == 0)
			data_out <= 8'bz;
	end


//------------WRITE-OPERATION----------//

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
			mem[wr_pointer[3:0]][8:0] <= {lfd_state_t, data_in};		// Concatinating {lfd_state + data_in}
			wr_pointer <= wr_pointer + 5'b1;		//Incrementing the write pointer.
		end
		
	end
	
//-------------------------------------------------Implementing the READ-WRITE Pointer Logic.------------------------------------------------------//

//always@(posedge clock) // Tried with this logic cause i got error
//	begin
//		if(!resetn) //|| soft_reset)
//			wr_pointer <= 0;
//		else if ((write_enb) && (~full))
//			wr_pointer <= wr_pointer + 1;
//	end		
//always@(posedge clock)
//	begin
//		if(!resetn )//|| soft_reset)
//			rd_pointer <= 0;
//		else if ((read_enb) && (~empty))
//			rd_pointer <= rd_pointer + 1;
//	end
			
//-----Counter-Down block while reading to Output------
// Reason  for this is that we need to know total length of data Packet (including Header and Parity byte).
  always@(posedge clock)
    begin
      if(read_enb && !empty)
        begin
          if((mem[rd_pointer[3:0]][8])==1'b1)		// If lfd_state is high then capture only the no. of No of Packet {we can get it from [7:2]mem[rd_pointer]}
            count <= mem[rd_pointer[3:0]][7:2] + 1'b1;	//Note that we added +1 to also include the parity byte.
          else if(count != 0)
            count <= count - 1'b1;
        end
    end
	
//----------Full and Empty Condition-----------//

assign full = (wr_pointer == 5'b10000 && rd_pointer == 5'b0) ? 1'b1 : 1'b0;
assign empty = (wr_pointer == rd_pointer) ? 1'b1 : 1'b0;

endmodule
