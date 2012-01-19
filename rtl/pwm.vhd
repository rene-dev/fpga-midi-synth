library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity pwm is
Generic(
   width: natural := 8;         -- Breite
   fclk : integer := 100000000; -- Taktfrequenz
   fpwm : integer := 100000     -- PWM-Frequenz;
);
Port(
   clk      : in  std_logic;
   pwmvalue : in  std_logic_vector (width-1 downto 0);
   pwmout   : out std_logic
);
end PWM;

architecture rtl of pwm is
   signal cnt : integer range 0 to 2**width-2 := 0;
   signal pre : integer range 0 to fclk/(fpwm*(2**width-2)) := 0; begin
   -- Vorteiler teilt FPGA-Takt auf PWM-Frequenz*Zählschritte
   process begin
      wait until rising_edge(clk);
      if (pre<fclk/(fpwm*(2**width))) then
         pre <= pre+1;
      else
         pre <= 0;
      end if;
   end process;

   -- PWM-Zähler
   process begin
      wait until rising_edge(clk);
      if (pre=0) then
         if (cnt<2**width-2) then
            cnt <= cnt+1;
         else
            cnt <= 0;
         end if;
      end if;
   end process;
   -- Vergleicher, registriert für Ausgabe auf IO-Pin ohne Glitches
   process begin
      wait until rising_edge(clk);
      if (cnt >= to_integer(unsigned(pwmvalue))) then
         pwmout <= '0';
      else
         pwmout <= '1';
      end if;
   end process;
end rtl;

