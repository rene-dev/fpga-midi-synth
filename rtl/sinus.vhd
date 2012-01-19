library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity SinusPWM is
Port ( 
   clk       : in  std_logic;
   pwmoutput : out std_logic;
   akku      : in  std_logic_vector(17 downto 0)
);
end SinusPWM;

architecture rtl of SinusPWM is

signal sinusplusoffset : std_logic_vector(7 downto 0);
signal sinus           : std_logic_vector(7 downto 0);

begin

I_ddfs: entity work.ddfs port map(clk,akku,sinus);
sinusplusoffset <= std_logic_vector(unsigned(sinus) +to_unsigned(128,8));
I_pwm: entity work.PWM port map(clk,sinusplusoffset,pwmoutput);

end rtl;

