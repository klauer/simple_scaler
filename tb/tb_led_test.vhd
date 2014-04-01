-- vi: sw=3 ts=3
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:44:56 03/17/2014
-- Design Name:   
-- Module Name:   tb_simple_scaler.vhd
-- Project Name:  simple_scaler
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: simple_scaler
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.globals.all;
use std.env.all;

use std.textio.all;
use ieee.std_logic_textio.all;
 
ENTITY tb_simple_scaler IS
END tb_simple_scaler;
 
ARCHITECTURE behavior OF tb_simple_scaler IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT simple_scaler
   	Port ( 
			  clk : in std_logic;
			  clear : in std_logic;
			  input_a : in std_logic_vector(16 - 1 downto 0);
			  
	  		  tx : out std_logic
			  );
    END COMPONENT;
    
   --Inputs
	signal clk : std_logic := '0';

 	--Outputs
	signal clear : std_logic := '1';
   signal LEDS : std_logic_vector(7 downto 0);
	
	signal tx : std_logic;
	signal clk_en : std_logic := '1';
	signal input_a : std_logic_vector(work.globals.N_COUNTERS - 1 downto 0) := (others => '0');
	-- signal all_counters : work.globals.t_counter;
	signal new_data : std_logic;
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: simple_scaler PORT MAP (
			 clk => clk,
			 tx => tx,
			 input_a => input_a,
			 clear => clear
        );

   -- Clock process definitions
   clk_process :process
    begin
		if (clk_en = '1') then
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		end if;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		clear <= '1';
		
      wait for clk_period * 4;	
		clear <= '0';

		input_a <= (others => '0');
		
      wait for clk_period;
		
		input_a(0) <= '0';

      wait for clk_period*10;
		input_a(0) <= '1';
		input_a(1) <= '1';
		write(output, string'("pulse on 0, 1\n"));

      wait for clk_period*10;
		input_a(0) <= '0';
		input_a(1) <= '0';

      wait for clk_period*10;
		write(output, string'("pulse on 0\n"));
		
		input_a(0) <= '1';

      wait for clk_period*10;
		input_a(0) <= '0';

      wait for clk_period*10;
		input_a(0) <= '1';
		input_a(1) <= '1';
		write(output, string'("pulse on 0, 1\n"));

      wait for clk_period*10;
		input_a(0) <= '0';
		input_a(1) <= '0';

      wait for clk_period*10;
		input_a(0) <= '1';
		write(output, string'("pulse on 0\n"));

      wait for clk_period*10;
		input_a(0) <= '0';

      wait for clk_period*10;
		input_a(0) <= '0';
		input_a(1) <= '0';

		write(output, string'("waiting\n"));
      wait for clk_period*4500;
		
		write(output, string'("waiting\n"));
      wait for clk_period*4500;

		write(output, string'("waiting\n"));
      wait for clk_period*4500;

		write(output, string'("waiting\n"));
      wait for clk_period*4500;

		clear <= '1';
		
		wait for clk_period*10;
		clk_en <= '0';
      finish(0);

   end process;

END;
