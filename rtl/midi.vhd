library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
library work;
use work.all;

entity midi is port(
   clk       : in  std_logic;
   midi_in   : in  std_logic;
   midi_new  : out std_logic;
   midi_ch   : out std_logic_vector(3 downto 0);
   midi_note : out std_logic_vector(6 downto 0);
   midi_velo : out std_logic_vector(6 downto 0)
   );
end midi;

architecture rtl of midi is

signal uart_busy : std_logic;
signal midi_data : std_logic_vector(7 downto 0);
type midi_state_type is (status,note_off,note_on,velocity);
signal midi_state: midi_state_type := status;
signal next_midi_state: midi_state_type := status;

begin

uart1: entity work.RS232 port map(midi_in,midi_data,uart_busy,open,"00000000",'0',open,clk);

process begin
   wait until rising_edge(clk);
   if(uart_busy = '0') then
      --midi_new <= '0';
      --if(not (midi_data = "11111110" or midi_data = "11111000")) then --active sense or clock
         midi_state <= next_midi_state;
         case midi_state is
            when status =>
               midi_new <= '0';
               if(midi_data(7 downto 4) = "1000") then    --note off
                  next_midi_state <= note_off;
                  midi_ch    <= midi_data(3 downto 0);
               elsif(midi_data(7 downto 4) = "1001") then --note on
                  next_midi_state <= note_on;
                  midi_ch    <= midi_data(3 downto 0);
               end if;
            when note_on =>
               if(midi_data(7) = '0') then
                  midi_note  <= midi_data(6 downto 0);
                  next_midi_state <= velocity;
               else
                  next_midi_state <= status;
               end if;
            when note_off =>
               if(midi_data(7) = '0') then
                  midi_note  <= midi_data(6 downto 0);
                  next_midi_state <= velocity;
                  --midi_new <= '1';
               else
                  next_midi_state <= status;
               end if;
            when velocity =>
               if(midi_data(7) = '0') then
                  midi_velo  <= midi_data(6 downto 0);
                  next_midi_state <= status;
                  midi_new   <= '1'; 
               else
                  next_midi_state <= status;
               end if;
         end case;
      --end if;
   end if;
end process;
end rtl;

