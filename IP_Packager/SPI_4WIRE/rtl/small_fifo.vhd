-------------------------------------------------------------------------------
-- File Downloaded from http://www.nandland.com
--
-- Description: Creates a Synchronous FIFO made out of registers.
--              Generic: g_WIDTH sets the width of the FIFO created.
--              Generic: g_DEPTH sets the depth of the FIFO created.
--
--              Total FIFO register usage will be width * depth
--              Note that this fifo should not be used to cross clock domains.
--              (Read and write clocks NEED TO BE the same clock domain)
--
--              FIFO Full Flag will assert as soon as last word is written.
--              FIFO Empty Flag will assert as soon as last word is read.
--
--              FIFO is 100% synthesizable.  It uses assert statements which do
--              not synthesize, but will cause your simulation to crash if you
--              are doing something you shouldn't be doing (reading from an
--              empty FIFO or writing to a full FIFO).
--
--              No Flags = No Almost Full (AF)/Almost Empty (AE) Flags
--              There is a separate module that has programmable AF/AE flags.
-------------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity module_fifo_regs_no_flags is
  generic (
    g_WIDTH : integer := 9;		-- word size
    g_DEPTH : integer := 8 		-- depth is  
    );
  port (
    i_nrst_sync : in std_logic;
    i_clk      : in std_logic;
 
    -- FIFO Write Interface
    i_wr_en   : in  std_logic;
    i_wr_data : in  std_logic_vector(g_WIDTH-1 downto 0);
 
    -- FIFO Read Interface
    i_rd_en   : in  std_logic;
    o_rd_data : out std_logic_vector(g_WIDTH-1 downto 0);

    -- FIFO Flags
    o_full    : out std_logic;	
    o_empty   : out std_logic;
	o_rerror   : out std_logic;
	o_werror   : out std_logic
	
    );
end module_fifo_regs_no_flags;
 
architecture rtl of module_fifo_regs_no_flags is
 
  type t_FIFO_DATA is array (0 to g_DEPTH-1) of std_logic_vector(g_WIDTH-1 downto 0);
  signal r_FIFO_DATA : t_FIFO_DATA := (others => (others => '0'));
 
  signal r_WR_INDEX   : integer range 0 to g_DEPTH-1 := 1; 	-- points to next read location
  signal r_RD_INDEX   : integer range 0 to g_DEPTH-1 := 0; 	-- points to next to write location
  signal w_FULL  : std_logic;
  signal w_EMPTY : std_logic;
  signal w_WERROR : std_logic;
  signal w_RERROR : std_logic;
   
begin

 -- Process for write
  p_CONTROLW : process (i_clk , i_nrst_sync) is
  begin
    if (i_nrst_sync = '0' ) then
			r_WR_INDEX   <= 0;
			w_WERROR <= '0';
		elsif ( rising_edge(i_clk) ) then	
        -- Track Write
        if (i_wr_en = '1' and w_FULL = '0') then
			r_FIFO_DATA(r_WR_INDEX) <= i_wr_data;					-- clock data from input
			r_WR_INDEX <= (r_WR_INDEX + 1) mod g_DEPTH; 			-- clock next index - ring buffer
			w_WERROR <= '0';										-- clear write error
		elsif (	i_wr_en = '1' and w_FULL = '1' ) then				-- check write error : full write
			w_WERROR <= '1';
		end if ;
    end if;                             							-- n_rst and rising_edge(i_clk)
	o_werror <= w_WERROR;
end process p_CONTROLW;


 -- Process for read
  p_CONTROLR : process (i_clk , i_nrst_sync) is
  begin
    if (i_nrst_sync = '0' ) then
			r_RD_INDEX  <= 0;
			w_RERROR <= '0';
	elsif ( rising_edge(i_clk) ) then
        -- Track Read
        if (i_rd_en = '1' and w_EMPTY = '0') then
			-- no clocked output, data is direct
			r_RD_INDEX <= (r_RD_INDEX + 1) mod g_DEPTH; 			-- clock next index
			w_RERROR <= '0';										-- clear read error
		elsif (	i_rd_en = '1' and w_EMPTY = '1' ) then				-- check read error : empty read
			w_RERROR <= '1';
		end if ;
    end if;    	-- n_rst and rising_edge(i_clk)

	o_rd_data <= r_FIFO_DATA((r_RD_INDEX) mod g_DEPTH);	-- direct data output : to be read data is direct avaialble !	
	o_rerror <= w_RERROR;
end process p_CONTROLR;


 -- Process for Flags
  p_CONTROLF  : process (i_clk , i_nrst_sync) is
	begin
    if (i_nrst_sync = '0' ) then
			w_FULL  <= '0';	
			w_EMPTY  <= '1';
	elsif ( falling_edge(i_clk) ) then
			if( ((r_WR_INDEX + 1) mod g_DEPTH) = r_RD_INDEX ) then		-- check full
				w_FULL  <= '1';						-- set full
			else
				w_FULL  <= '0';			
			end if; 
			
			if( r_RD_INDEX  = r_WR_INDEX)  then		-- check almost empty
				w_EMPTY  <= '1';									-- set empty
			else
				w_EMPTY  <= '0';						
			end if; 
    end if;    	-- n_rst 	
	
	o_full  <= w_FULL;
	o_empty <= w_EMPTY;	
  end process p_CONTROLF;


  -- synthesis translate_on
end rtl;