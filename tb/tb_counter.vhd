-- vi: sw=3 ts=3
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:44:56 03/17/2014
-- Design Name:   
-- Module Name:   tb_counter.vhd
-- Project Name:  counter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: counter
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;
use std.env.all;
use work.globals.N_COUNTER_BITS;

ENTITY tb_counter IS
END tb_counter;
 
ARCHITECTURE behavior OF tb_counter IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
   component singleCounter is
		Port (clk : in  std_logic;
            clear : in  std_logic;
				pin_in : in  std_logic;
				reset : in  std_logic;
            final_counts : out unsigned(N_COUNTER_BITS - 1 downto 0)
				);
	end component;
    
   --Inputs
	signal clk : std_logic := '0';
	signal clk_en : std_logic := '1';
   signal input_a : std_logic := '0';

 	--Outputs
	signal clear : std_logic := '0';
	signal reset : std_logic := '1';
   constant clk_period : time := 5 ns;
 
   signal final_counts : unsigned(N_COUNTER_BITS - 1 downto 0) := (others => '0');

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: singleCounter PORT MAP (
      clk => clk,
      clear => clear,
		reset => reset,
      pin_in => input_a,
      final_counts => final_counts
   );

   -- Clock process definitions
   clk_process :process
    begin
		--if (clk_en = '1') then
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		--end if;
   end process;

	-- clear_delay <= clear after 1 ns;

   -- Stimulus process
   stim_proc: process
		variable tline : line;
   begin
      -- hold reset state for 100 ns.
      -- final_counts <= (others => '0');  -- <-- this was it
		reset <= '1';
      wait for clk_period * 10;
		reset <= '0';
		
		clear <= '1';
      wait for clk_period;
		clear <= '0';
		
      wait for clk_period*5;
		input_a <= '0';

      wait for clk_period;
		input_a <= '1';
		write(tline, string'("-> Pulse"));
		writeline(output, tline);

      wait for 5 ns;
		input_a <= '0';

      wait for 5 ns;
		input_a <= '1';
		write(tline, string'("-> Pulse"));
		writeline(output, tline);

      wait for 5 ns;
		input_a <= '0';

      wait for 5 ns;
		input_a <= '1';
		write(tline, string'("-> Pulse"));
		writeline(output, tline);

      wait for 5 ns;
		input_a <= '0';

      wait for 5 ns;
		input_a <= '1';
		write(tline, string'("-> Pulse"));
		writeline(output, tline);

      wait for 5 ns;
		input_a <= '0';

      wait for clk_period;
		input_a <= '0';

      wait for clk_period*10;
		
		clear <= '1';
		wait for clk_period;
		clear <= '0';
		
		wait for clk_period*10;
		
		clk_en <= '0';

      write(tline, string'("Counts: "));
      hwrite(tline, std_logic_vector(final_counts));
      writeline(output, tline);
		
      finish(0);
		
   end process;

END;
