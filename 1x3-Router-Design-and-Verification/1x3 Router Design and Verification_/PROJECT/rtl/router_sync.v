/***************************************************************************************************

NAME        :  Maharshi Oza
FILENAME    :  router_sync.v
DATE        :  28/04/2024
DESCRIPTION :  ROUTER - SYNCHRONIZER design

****************************************************************************************************/

module router_sync(clock,resetn,data_in,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2);

input clock, resetn, detect_add, full_0, full_1, full_2, empty_0, empty_1, empty_2, write_enb_reg, read_enb_0, read_enb_1, read_enb_2;

input [1:0] data_in;	// For Synchronizer we only need 2 bits for address, thus, [1:0]

output reg [2:0] write_enb;	// Write enable is the main output of the Synchronizer which is of 3 bits following ONE-HOT-ENCODING.// THis is for which FIFO will be active using ONE HOT ENCODING.

output reg fifo_full, soft_reset_0, soft_reset_1, soft_reset_2;

output vld_out_0, vld_out_1, vld_out_2;	// IF u loog at top module val_out_ are going towards the destination bit.

reg [1:0] data_in_tmp;
reg [4:0] count0, count1, count2;	

always@(posedge clock)
begin
	if(~resetn)
		data_in_tmp <= 0;
	else if (detect_add)
		data_in_tmp <= data_in;
end

//---------------Address decoding & FIFO empty------------------//

always@(*)
begin
	
	case(data_in_tmp)
	
	2'b00		:		begin
						fifo_full <= full_0;	// connecting out(FIFO) == in(SYNC) --> out(SYNC)	
						// This indicates if FIFO of this specific address is full or not.
						
						if(write_enb_reg)
							write_enb <= 3'b001;	// THis is the OHE-HOT-ENCODING I was talking about.
						else
							write_enb <= 3'b000;
							
						end
							
	2'b01		:		begin
						fifo_full <= full_1;	// connecting out(FIFO) == in(SYNC) --> out(SYNC)	
						// This indicates if FIFO of this specific address is full or not.
						
						if(write_enb_reg)
							write_enb <= 3'b010;	// THis is the OHE-HOT-ENCODING I was talking about.
						else
							write_enb <= 3'b000;
							
						end
							
	2'b10		:		begin
						fifo_full <= full_2;	// connecting out(FIFO) == in(SYNC) --> out(SYNC)	
						// This indicates if FIFO of this specific address is full or not.
						
						if(write_enb_reg)
							write_enb <= 3'b100;	// THis is the OHE-HOT-ENCODING I was talking about.
						else
							write_enb <= 3'b000;
							
						end
							
	default		:		begin
						fifo_full <= 0;
						write_enb <= 0;
						end
	endcase
end


//------------------------------------------------Valid_Out_--------------------------------//

assign vld_out_0 = (~empty_0);		// Note that this val_out_ is connected to the Destination.	// Which means when FIFO is not empty then this will get triggered.
assign vld_out_1 = (~empty_1);
assign vld_out_2 = (~empty_2);

//-----------------------------------------------------Activating SOFT RESET------------------------------------//

always@(posedge clock)			// Acts like main RESET
begin
	if(~resetn)
	begin
		count0 <= 0;
		soft_reset_0 <= 0;
	end
	
	else if (vld_out_0)		// when valid_out_ is triggered then we should start the clock. // BUT WHAT ABOUT THE ERITING PART DO WE NEED HAV COUNTER FOR THAT???
	begin
		if (~read_enb_0)
		begin
			
			if (count0 == 30)
			begin
				soft_reset_0 <= 1'b1;
				count0 <= 0;
			end
			
			else
			begin
				soft_reset_0 <= 1'b0;
				count0 <= count0 + 1'b1;
			end
		end
		
		else
			count0 <= 0;
	end
	
end



// Now this is for Second Counter

always@(posedge clock)			// Acts like main RESET
begin
	if(~resetn)
	begin
		
		count1 <= 0;
		soft_reset_1 <= 0;
	end
	
	else if (vld_out_1)		// when valid_out_ is triggered then we should start the clock. // BUT WHAT ABOUT THE ERITING PART DO WE NEED HAV COUNTER FOR THAT???
	begin
		if (~read_enb_1)
		begin
			
			if (count1 == 30)
			begin
				soft_reset_1 <= 1'b1;
				count1 <= 0;
			end
			
			else
			begin
				soft_reset_1 <= 1'b0;
				count1 <= count1 + 1'b1;
			end
		end
		
		else
			count1 <= 0;
	end
	
end


// Now this is for THIRD Counter

always@(posedge clock)			// Acts like main RESET
begin
	if(~resetn)
	begin
		
		count2 <= 0;
		soft_reset_2 <= 0;
	end
	
	else if (vld_out_2)		// when valid_out_ is triggered then we should start the clock. // BUT WHAT ABOUT THE ERITING PART DO WE NEED HAV COUNTER FOR THAT???
	begin
		if (~read_enb_2)
		begin
			
			if (count2 == 30)
			begin
				soft_reset_2 <= 1'b1;
				count2 <= 0;
			end
			
			else
			begin
				soft_reset_2 <= 1'b0;
				count2 <= count2 + 1'b1;
			end
		end
		
		else
			count2 <= 0;
	end
	
end
	
endmodule
