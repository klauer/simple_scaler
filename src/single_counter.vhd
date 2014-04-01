-- vi: sw=3 ts=3
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:57:00 03/19/2014 
-- Design Name: 
-- Module Name:    singleCounter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;
use work.globals.N_COUNTER_BITS;

use std.textio.all;
use ieee.std_logic_textio.all;

entity singleCounter is
   Port (clk : in  std_logic;
         clear : in  std_logic;
			pin_in : in  std_logic;
			reset : in  std_logic;
         final_counts : out unsigned(N_COUNTER_BITS - 1 downto 0)
         );
end singleCounter;

architecture Behavioral of singleCounter is
	signal counts : unsigned(N_COUNTER_BITS - 1 downto 0) := (others => '0');
begin

	process(pin_in, clear)
		variable tline : line;
	begin
		if clear = '1' then
			write(tline, string'("Clear"));
			writeline(output, tline);
			counts <= to_unsigned(0, counts'length);
		elsif rising_edge(pin_in) then
			write(tline, string'("Pulse counted"));
			writeline(output, tline);
			counts <= counts + 1;
		end if;
	end process;
	
	process (clear, reset)
		variable tline : line;
	begin 
		if reset = '1' then
			write(tline, string'("Reset"));
			writeline(output, tline);
			final_counts <= to_unsigned(0, final_counts'length);
		elsif rising_edge(clear) then
			write(tline, string'("Clear"));
			writeline(output, tline);
			final_counts <= counts;
		end if;
	end process;
	
end Behavioral;

