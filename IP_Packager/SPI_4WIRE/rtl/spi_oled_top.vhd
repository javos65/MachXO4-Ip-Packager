-- --------------------------------------------------------------------
-- Revision History :
-- --------------------------------------------------------------------
-- Revision 1.0  JayFox 2025
--
--  ABP to 4WIRE SPI
--  ABP interface Memory MApped
--	Adress	 mapping	
--	00xx		00		IDREGISTER
--	01xx		04		STATUS REGISTER
--						[31:9]	xx
--						[18] 	ABP Write error while full
--						[17]	FIFO Wrtie error bit
--						[16]	FIFO FULL bit
--						[15:3]	xx
--						[2]	FIFO Read error bit
--						[1]	FIFO EMPTY bit
--						[1]	SPI READY bit
--	10xx		08		CONTROL REGISTER - not used
--	11xx		0C		DATA WRITE REGISTER
--						[31:9]	xx
--						[8] 	DC~
--						[7:0]	DATAIN
--
-- --------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity apb_to_spi is
   port (
      -- clk_i and rst_n_i are kept out of standard APB SLAVE I/F
      clk_i   : in  std_logic; -- PCLK
      rst_n_i : in  std_logic; -- PRESETn
	  sclk_i   : in  std_logic; -- seperate SPI-CLK
      -- clk_i and rst_n_i are kept out of standard APB SLAVE I/F
      PSEL    : in  std_logic;
      PENABLE : in  std_logic;
      PADDR   : in  std_logic_vector(7 downto 0);
      PWRITE  : in  std_logic;
      PWDATA  : in  std_logic_vector(31 downto 0);
      PRDATA  : out std_logic_vector(31 downto 0);
      PREADY  : out std_logic;
      PSLVERR : out std_logic;
	  -- spi ports
	  SCLK		: out std_logic;
	  DC		: out std_logic;
	  CS 		: out std_logic;
	  SDIN 		: out std_logic;
	  RST 		: out std_logic
   );
end apb_to_spi;

architecture rtl_apb_to_spi of apb_to_spi is

    -- APB Short address register
    signal MEM_ADDR : std_logic_vector(1 downto 0) ;  			-- Address register 2 bits = 4 32 bit locations :
    -- APB memory mapped  registers	
	signal REG0_ID : std_logic_vector(31 downto 0) ; 			-- 32 bit Memory b'00' read only : IP-ID for SPI--IP
	signal REG1_STATUS : std_logic_vector(31 downto 0) ; 	    -- 32 bit Memory b'01' read only : bit [18] = APB error , bit[17] = fifo wrtie error, bit[16]= fifo Full, bit[2] = Fifo rerror, bit[1]= Fifo empty,  bit[0]= SPI Rrady
	signal REG2_CONTROL : std_logic_vector(31 downto 0) ; 		-- 32 bit Memory b'10' read/write  - no use , just write REG3 when not full
	signal REG3_DATA0 : std_logic_vector(31 downto 0) ; 		-- 32 bit Memory b'11' read/write :[31:9]XXX [8]C/~D [7:0] FIFO data DATA in
    -- SPI control FSM registers and signals
    signal DATA_IN 	: std_logic_vector(8 downto 0) ; 	
	signal READY 	: std_logic;
	signal START 	: std_logic;
	
    -- FIFO control signals
	signal FREAD 	: std_logic;
	signal FWRITE 	: std_logic;
	signal FWDATA   : std_logic_vector(8 downto 0) ; 	
	signal FRDATA   : std_logic_vector(8 downto 0) ; 		
	signal EMPTY 	: std_logic;		
	signal FULL 	: std_logic;
	signal RERROR	: std_logic;
	signal WERROR 	: std_logic;
	
	-- declare external SPI block for oled
	component spi_oled
		port(
		dclk_i  		: in  std_logic;
		rst_n_i 		: in  std_logic;
		start_in		: in  std_logic; 			-- handshake_in
		data_in			: in  std_logic_vector(8 downto 0);
		spi_clk			: out std_logic;
		spi_dnc			: out std_logic;
		spi_ncs			: out std_logic;
		spi_data		: out std_logic;
		spi_ready  		: out std_logic	;	  		-- handshake out
		spi_rst  		: out std_logic			
		);
	end component;

  component module_fifo_regs_no_flags
	port(
		i_nrst_sync 	: IN std_logic;
		i_clk 			: IN std_logic;
		i_wr_en 		: IN std_logic;
		i_wr_data 		: IN std_logic_vector(8 downto 0);
		i_rd_en 		: IN std_logic;          
		o_full 			: OUT std_logic;
		o_rd_data 		: OUT std_logic_vector(8 downto 0);
		o_empty 		: OUT std_logic;
		o_rerror 		: OUT std_logic;		
		o_werror 		: OUT std_logic
		);
	end component;


   type fsm1_state is (IDLE_ST, SETUP_ST, WAIT_CYCLE_0_ST, WAIT_CYCLE_1_ST);
   signal apb_control_st : fsm1_state;

   type fsm2_state is (IDLE_ST, WAIT_CYCLE_ST);
   signal spi_control_st : fsm2_state;

begin
	
	MEM_ADDR <= PADDR(3 downto 2); -- split of 2 bits of the bus for decoding, bit0,1 are non 32bit aligned adresses : always zero

	SPI0_BLOCK_INST: spi_oled
		port map(
			dclk_i		=> sclk_i, 		-- Seperate clock for SPI
			rst_n_i		=> rst_n_i,
			start_in	=> START,
			data_in 	=> DATA_IN,
			spi_data	=> SDIN,		-- I/O pin
			spi_clk		=> SCLK,		-- I/O pin
			spi_dnc		=> DC,			-- I/O pin
			spi_ncs		=> CS,			-- I/O pin
			spi_ready  	=> READY,		-- Internal SPI READY signal
			spi_rst  	=> RST	
		);

	FIFO_BLOCK_INST: module_fifo_regs_no_flags 
		port map(
			i_nrst_sync => rst_n_i,
			i_clk 		=> clk_i ,
			i_wr_en 	=> FWRITE,
			i_wr_data 	=> FWDATA,
			o_full 		=> FULL,
			i_rd_en 	=> FREAD,	-- start-signal for Fifo to load next Fifo read data
			o_rd_data 	=> FRDATA,
			o_empty 	=> EMPTY,
			o_rerror 	=> RERROR,
			o_werror 	=> WERROR		
			);
	
   --------------
   -- FSM process : ABP interface
   --------------
   FSM_PROC: process(rst_n_i, clk_i)
   begin
      if (rst_n_i = '0') then
			-- reset
         apb_control_st  <= IDLE_ST;
         PREADY  <= '0';
         PSLVERR <= '0';
         PRDATA  <= (others => '0');
		 REG1_STATUS(31 downto 16) <= x"0000";    	-- clear lower word in status register = SPI core status

      elsif (clk_i = '1' and clk_i'event) then
         -- default
        -- PREADY  <= '0';
         --PSLVERR <= '0';
         --PRDATA  <= (others => '0');
		 REG1_STATUS(16) <= FULL;   		-- replicatie FULL bit status
		 REG1_STATUS(17) <= WERROR;   		-- replicatie  WERROR bit status		 
         -- default
         case apb_control_st is
            when IDLE_ST =>
               if ((PSEL = '1') and (PENABLE = '0')) then
						------------------------------
						-- SETUP state, after transfer
						------------------------------
						apb_control_st  <= SETUP_ST;

						-- WRITE
						if (PWRITE = '1') then		-- WRITE transfer - dont wait extra cycle !
							case MEM_ADDR is
								when "11" =>  		-- memory mapped write register: CONTROL input
									REG3_DATA0 <= PWDATA; 
									if( FULL = '0' )  then					-- accept only byte start when Fifo is notfull
										FWDATA <= PWDATA(8 downto 0);     -- always setup clock PW data to fifo
										FWRITE <= '1';   					-- clock data into Fifo
										REG1_STATUS(18) <= '0';   			-- clear error			
									end if;										
									if( FULL = '1' )  then 					-- accept only byte start when not Full
										REG1_STATUS(18) <= '1';   			-- set error - writing while Full
									end if;
								when others => 
									null;			
							end case	;		
							-- WRITE transfer no wait state
							PREADY  <= '1';
							PSLVERR <= '0';
						-- READ
						else
							-- READ transfer wait state due to MEM read
							PREADY  <= '0';
							PSLVERR <= '0';
						end if;
               end if;
            when SETUP_ST =>
               if ((PSEL = '1') and (PENABLE = '1')) then
						-------------------------------
						-- ACCCESS state, WRITE or READ
						-------------------------------
						-- WRITE
						if (PWRITE = '1') then
							-- WRITE transfer already done
							PREADY   <= '0';
							PSLVERR  <= '0';
							FWRITE <= '0';   	 -- clear Fifo Write 
							apb_control_st   <= IDLE_ST;
						else
							-- READ transfer, wait 1 cycle, data from MEM
							PREADY  <= '0';
							PSLVERR <= '0';
							apb_control_st  <= WAIT_CYCLE_0_ST;
						end if;
					end if;
				when WAIT_CYCLE_0_ST =>
					if ((PSEL = '1') and (PENABLE = '1') and (PWRITE = '0')) then
						-------------------
						-- WAIT state, READ
						-------------------
							case MEM_ADDR is
								when "00" =>				
									PRDATA <= x"B19B00B9";		-- Address 0x00 b'00' = ID is 0xB19B00B9 - 32 bits, hard coded				
								when "01" =>
									PRDATA <= REG1_STATUS;  	-- Address 0x04 b'01' = STATUS
								when "10" =>
									PRDATA <= REG2_CONTROL; 	-- Address 0x08 b'10' = CONTROL - not used
								when "11" =>
									PRDATA <= REG3_DATA0; 		-- Address 0x0c b'10' = DATA0							
								when others =>
									PRDATA <= x"00000000";	
							end case	;
						PREADY  <= '1';
						PSLVERR <= '0';
						apb_control_st  <= WAIT_CYCLE_1_ST;
					end if;
            when WAIT_CYCLE_1_ST =>
					if ((PSEL = '1') and (PENABLE = '1') and (PWRITE = '0')) then
						-------------------
						-- IDLE state, READ
						-------------------
						PREADY  <= '0';
						PSLVERR <= '0';
						apb_control_st  <= IDLE_ST;
					end if;
			when others =>
					apb_control_st  <= IDLE_ST;
					PREADY  <= '0';
					PSLVERR <= '0';
         end case;
      end if;
   end process FSM_PROC;

   --------------
   -- FSM process : SPI CONTROL
   --------------
  SPI_CONTROL_PROC: process(rst_n_i, clk_i)
   begin
      if (rst_n_i = '0') then
			-- reset
         START <= '0';								-- clear Start signal
		 FREAD <= '0';								-- clear Fifo read		 
		 REG1_STATUS(15 downto 0) <= x"0000";    	-- clear lower word in status register = SPI core status
         spi_control_st  <= IDLE_ST; 				-- go to wait for spi ready

      elsif (rising_edge(clk_i) ) then
         -- default
		REG1_STATUS(2) <= RERROR;   	-- replicatie Fifo RERROR bit status		 
		REG1_STATUS(1) <= EMPTY;   		-- replicatie Fifo EMPTY bit status
		REG1_STATUS(0) <= READY;   		-- replicatie READY bit status
		 -- default
         case spi_control_st is
            when IDLE_ST  =>
               if (  EMPTY = '0' and READY = '1' ) then 		-- check if FIFO is not empty, then start SPI
						 START <= '1';			-- start SPI						 
						 DATA_IN <= FRDATA;		-- clock data to SPI (Fifo read data is direct avaiable)
						 FREAD <= '1';			-- signal FIFO to read next data
						 spi_control_st  <= WAIT_CYCLE_ST; 					 
			   else
						START <= '0';				-- stop Start spi pulse (duration 2 clk cycles)
						spi_control_st  <= IDLE_ST;
               end if;
			   
			when WAIT_CYCLE_ST =>
						 FREAD <= '0';			-- stop Fifo read pulse (duration 1 clock cycle)
                        spi_control_st  <= IDLE_ST; 	

         end case;
      end if;
   end process SPI_CONTROL_PROC;

end rtl_apb_to_spi;