-- vi: sw=3 ts=3
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:53:02 03/17/2014 
-- Design Name: 
-- Module Name:    scaler - Behavioral 
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

-- Text output for debugging
use std.textio.all;
use ieee.std_logic_textio.all;

use work.globals.N_COUNT_CYCLES;
use work.globals.N_COUNTER_BYTES;
use work.globals.N_COUNTER_BITS;
use work.globals.N_COUNTERS;
use work.globals.N_BAUD16_COUNT;

-- unisim components for ODDR2, etc.
library unisim;
use unisim.vcomponents.all;

entity scaler is
	Port (  clk : in std_logic;
			  clear : in std_logic;
			  input_a : in std_logic_vector(16 - 1 downto 0);
			  		  
           -- LEDS : out  std_logic_vector(7 downto 0);
	  		  tx : out std_logic;
			  clk_out : out std_logic;
			  baud_out : inout std_logic
			  );
end scaler;

architecture Behavioral of scaler is
   component singleCounter is
      Port (clk : in  std_logic;
            clear : in  std_logic;
            pin_in : in  std_logic;
				reset : in std_logic;
            final_counts : out unsigned(N_COUNTER_BITS - 1 downto 0)
            );
	end component;

	component uart_tx6
		Port (data_in : in std_logic_vector(7 downto 0);
				en_16_x_baud : in std_logic;
				serial_out : out std_logic;
				buffer_write : in std_logic;
				buffer_data_present : out std_logic;
				buffer_half_full : out std_logic;
				buffer_full : out std_logic;
				buffer_reset : in std_logic;
				clk : in std_logic);
	end component;
	
	constant N_TX_BYTES : integer := (N_COUNTERS + 1) * N_COUNTER_BYTES;
	type t_buffer is array (N_TX_BYTES - 1 downto 0) of std_logic_vector (7 downto 0);
	signal tx_buffer : t_buffer;
	
	signal n_clk : std_logic := '0';
	
	signal counters : work.globals.t_counter;
	signal counter : unsigned(31 downto 0);
	signal record_counts : std_logic := '0';
	
	signal tx_count : integer range 0 to N_TX_BYTES := 0;
	signal tx_en : std_logic := '1';
	
	signal uart_tx_data_in : std_logic_vector(7 downto 0);
	signal write_to_uart_tx : std_logic;
	signal uart_tx_data_present : std_logic;
	signal uart_tx_half_full : std_logic;
	signal uart_tx_full : std_logic;
	signal baud_count : integer range 0 to N_BAUD16_COUNT := 0;
	signal en_16_x_baud : std_logic := '0';
	signal second_pulse : std_logic := '0';
	
	signal clear_out : std_logic := '0';
	signal test_signal : std_logic := '0';
	
begin
	
	-- Main process that readies the transmission buffer
	process(clk)
		variable tline : line;
	begin
		if rising_edge(clk) then
			test_signal <= input_a(0);
			if clear = '1' or counter = N_COUNT_CYCLES then
            write(tline, string'("Main reset counter="));
            hwrite(tline, std_logic_vector(counter));
            write(tline, string'(" clear="));
            write(tline, clear);
            writeline(output, tline);

				counter <= to_unsigned(0, counter'length);
				record_counts <= '1';
				tx_count <= 0;
            write_to_uart_tx <= '0';
				second_pulse <= not second_pulse;
				clear_out <= '1';
			else
				record_counts <= '0';
				counter <= counter + 1;
			
				if counter = 2 then
					tx_buffer(0) <= std_logic_vector(to_unsigned(character'pos('S'), 8));
					tx_buffer(1) <= std_logic_vector(to_unsigned(character'pos('T'), 8));
					tx_buffer(2) <= std_logic_vector(to_unsigned(character'pos('R'), 8));
					tx_buffer(3) <= std_logic_vector(to_unsigned(character'pos('T'), 8));

					for i in 1 to counters'high + 1 loop
						-- tx_buffer(N_COUNTER_BYTES * i    ) <= std_logic_vector(counters(i - 1)( 7 downto  0));
						-- tx_buffer(N_COUNTER_BYTES * i + 1) <= std_logic_vector(counters(i - 1)(15 downto  8));
						-- tx_buffer(N_COUNTER_BYTES * i + 2) <= std_logic_vector(counters(i - 1)(23 downto 16));
						-- tx_buffer(N_COUNTER_BYTES * i + 3) <= std_logic_vector(counters(i - 1)(31 downto 24));
						for j in 0 to N_COUNTER_BYTES - 1 loop
							tx_buffer(N_COUNTER_BYTES * i + j) <= std_logic_vector(counters(i - 1)(8 * (j + 1) - 1 downto 8 * j));
						end loop;
					end loop;

					tx_count <= tx_buffer'length;
					
					write(tline, string'("clk=: "));
					hwrite(tline, std_logic_vector(counter));

					write(tline, string'(" New counts: "));
					for i in 0 to counters'high loop
						hwrite(tline, std_logic_vector(counters(i)));
						write(tline, string'(" "));
					end loop;
					writeline(output, tline);
					
				elsif counter = 10 then
					clear_out <= '0';
				end if;
				
			end if;
         
         -- somehow the uart fifo buffer fills up and can be overwritten, even when
         -- checking uart_tx_full -- so added a check of baud_count meaning it
         -- should never overwrite the fifo
         if tx_count > 0 and uart_tx_full = '0' and baud_count = 1 then
				-- write(tline, string'("Transmitting byte #"));
				-- write(tline, tx_count, RIGHT, 10);
				-- write(tline, string'(" of "));
				-- write(tline, tx_buffer'high + 1, RIGHT, 10);
				-- write(tline, string'(" = "));
				-- write(tline, tx_buffer(0), RIGHT, 10);
				-- write(tline, string'(" "));
				-- writeline(output, tline);
            
            tx_count <= tx_count - 1;
            
            uart_tx_data_in <= tx_buffer(0);
            
            for i in 0 to tx_buffer'high - 1 loop
               tx_buffer(i) <= tx_buffer(i + 1);
            end loop;
            
            -- tx_buffer(tx_buffer'high) <= std_logic_vector(to_unsigned(character'pos('x'), 8)); --"00000000";
            tx_buffer(tx_buffer'high) <= (others => '0');

            write_to_uart_tx <= '1';
         else
            write_to_uart_tx <= '0';
         end if;
		end if;	
	
	end process;

	-- Communicate with the computer via USB/UART
   tx_a: uart_tx6
	port map ( data_in => uart_tx_data_in,
              en_16_x_baud => en_16_x_baud,
              serial_out => tx,
              buffer_write => write_to_uart_tx,
              buffer_data_present => uart_tx_data_present,
              -- buffer_half_full => open,
              buffer_full => uart_tx_full,
              buffer_reset => clear,
              clk => clk
             );

	-- All of the counter instances
   gen_counter:
	for i in 0 to N_COUNTERS - 1 generate
	begin
      counterInst : component singleCounter port map (
			clk => clk,
			clear => record_counts,
			pin_in => input_a(i),
			reset => '0',
			final_counts => counters(i)(N_COUNTER_BITS - 1 downto 0)
		);
	end generate gen_counter;

	-- Generate the baud rate (9600)
   baud_rate: 
   process(clk)
	begin
	 if rising_edge(clk) then
		if baud_count = N_BAUD16_COUNT then
		  baud_count <= 0;
		  en_16_x_baud <= '1';
		  baud_out <= not baud_out;
		 else
		  baud_count <= baud_count + 1;
		  en_16_x_baud <= '0';
		end if;
	 end if;
	end process baud_rate;


   -- Use an output double data rate register to put the clock on an output pin
   ODDR2_inst: ODDR2
	generic map
	(
		DDR_ALIGNMENT => "NONE",
		INIT => '0',
		SRTYPE => "SYNC"
	)
	port map
	(
		Q => clk_out, 
		C0 => clk,
		C1 => n_clk, 
		D0 => '0', 
		D1 => '1'
	);

	n_clk <= not clk;

end Behavioral;
