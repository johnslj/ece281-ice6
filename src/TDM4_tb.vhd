--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : TDM4_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner, Capt Dan Johnson, **Your Name**
--| CREATED       : 03/2017 Last modified on 06/24/2020
--| DESCRIPTION   : This file tests the 4 to 1 TDM.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std, unisim
--|    Files     : TDM4.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity TDM4_tb is
end TDM4_tb;

architecture test_bench of TDM4_tb is 	
  
	component TDM4 is
    generic (
        k_WIDTH : natural := 4
    );
    port (
        i_clk   : in  std_logic;
        i_reset : in  std_logic;
        i_D3    : in  std_logic_vector(k_WIDTH-1 downto 0);
        i_D2    : in  std_logic_vector(k_WIDTH-1 downto 0);
        i_D1    : in  std_logic_vector(k_WIDTH-1 downto 0);
        i_D0    : in  std_logic_vector(k_WIDTH-1 downto 0);
        o_data  : out std_logic_vector(k_WIDTH-1 downto 0);
        o_sel   : out std_logic_vector(3 downto 0)
    );
    end component TDM4;
		-- fill in from TDM4.vhd

	-- Setup test clk (20 ns --> 50 MHz) and other signals
	
	-- Constants
	constant k_IO_WIDTH : natural := 4;
	constant k_clk_period : time := 20 ns;
	-- Signals
	signal w_clk   : std_logic := '0';
	signal w_reset : std_logic := '0';
	signal w_D3    : std_logic_vector(k_IO_WIDTH-1 downto 0) := "1100";
    signal w_D2    : std_logic_vector(k_IO_WIDTH-1 downto 0) := "1001";
    signal w_D1    : std_logic_vector(k_IO_WIDTH-1 downto 0) := "0110";
    signal w_D0    : std_logic_vector(k_IO_WIDTH-1 downto 0) := "0011";
    signal f_data  : std_logic_vector(k_IO_WIDTH-1 downto 0);
    signal f_sel_n : std_logic_vector(3 downto 0);
	
begin
	-- PORT MAPS ----------------------------------------
	-- map ports for any component instances (port mapping is like wiring hardware)
	uut_inst : TDM4 
	generic map ( k_WIDTH => k_IO_WIDTH)
	port map ( 
       i_clk   => w_clk,
       i_reset => w_reset,
       i_D3    => w_D3,
       i_D2    => w_D2,
       i_D1    => w_D1,
       i_D0    => w_D0,
       o_data  => f_data,
       o_sel   => f_sel_n
	);
	-----------------------------------------------------	
	
	-- PROCESSES ----------------------------------------	
	-- Clock Process ------------------------------------
	clk_process : process
	begin
        w_clk <= '0';
        wait for k_clk_period/2;
        w_clk <= '1';
        wait for k_clk_period/2;
	end process clk_process;
	-----------------------------------------------------	
	
	-- Test Plan Process --------------------------------
	test_process : process 
	begin
		-- assign test values to data inputs
				
		-- reset the system first
		w_reset <= '1';
		wait for k_clk_period;		
		  assert f_sel_n = "1110" report "bad reset" severity failure;
		  assert f_data = "0011" report "bad reset output" severity failure;
		w_reset <= '0';
		wait for k_clk_period;
		  assert f_sel_n = "1101" report "bad release from reset" severity failure;
		  assert f_data = "0110" report "bad release from reset output" severity failure;
		wait for k_clk_period;
		  assert f_sel_n = "1011" report "bad select change to D2" severity failure;
		  assert f_data = "1001" report "bad data change to D2" severity failure;
		wait for k_clk_period;
		  assert f_sel_n = "0111" report "bad select change to D3" severity failure;
		  assert f_data = "1100" report "bad data change to D3";
		wait for k_clk_period;
		  assert f_sel_n = "1110" report "bad wraparound select to D0" severity failure;
		  assert f_data = "0011" report "bad wraparound data to D0" severity failure;
		wait for k_clk_period;
		  assert f_sel_n = "1101" report "bad wraparound select to D1" severity failure;
		  assert f_data = "0110" report "bad wraparound data to D1" severity failure;
		wait for k_clk_period;
		  assert f_sel_n = "1011" report "bad wraparound select to D2" severity failure;
		  assert f_data = "1001" report "bad wraparound data to D2" severity failure;
		wait for k_clk_period;
		  assert f_sel_n = "0111" report "bad wraparound select to D3" severity failure;
		  assert f_data = "1100" report "bad wraparound data to D3" severity failure;
		
		wait for 160 ns; -- let the TDM do its work
	end process;	
	-----------------------------------------------------	
	
end test_bench;
