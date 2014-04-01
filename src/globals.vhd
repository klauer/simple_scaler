-- vi: sw=3 ts=3
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package globals is
	constant N_MAX_BUFFER : integer := 128 - 1;
	constant N_COUNTERS : integer := 16;
	constant N_COUNTER_BITS : integer := 32;
	constant N_COUNTER_BYTES : integer := N_COUNTER_BITS / 8;

	type t_counter is array (N_COUNTERS - 1 downto 0) of unsigned (N_COUNTER_BITS - 1 downto 0);
	
	-- simulation:
	-- constant N_COUNT_CYCLES : integer := 4000;
	-- constant N_BAUD16_COUNT : integer := 1;
	
	-- 32MHz clock:
   constant N_BAUD16_COUNT : integer := 207;
	constant N_COUNT_CYCLES : integer := 31999999;
	
	-- 100MHz clock
   -- constant N_BAUD16_COUNT : integer := 650; -- 100e6 / (9600 * 16) - 1
	-- constant N_COUNT_CYCLES : integer := 100000000;
	
	-- 200MHz clock
   -- constant N_BAUD16_COUNT : integer := 1301; -- 200e6 / (9600 * 16) - 1
	-- constant N_COUNT_CYCLES : integer := 200000000;

end globals;

