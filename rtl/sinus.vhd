library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity SinusPWM is
Port ( 
   clk       : in  std_logic;
   pwmoutput : out std_logic;
   akku      : in  std_logic_vector(17 downto 0)
);
end SinusPWM;

architecture rtl of SinusPWM is

component ddfs is
Port (
   clk       : in  std_logic;
   Freq_Data : in  std_logic_vector (17 downto 0);
   Dout      : out std_logic_vector (7 downto 0)
);
end component;

component pwm is
Port (
   clk      : in  std_logic;
   pwmvalue : in  std_logic_vector (7 downto 0);
   pwmout   : out std_logic
);
end component;

signal sinusplusoffset : std_logic_vector(7 downto 0);
signal sinus           : std_logic_vector(7 downto 0);

begin

I_ddfs:DDFS port map(clk,akku,sinus);
sinusplusoffset <= std_logic_vector(unsigned(sinus) +to_unsigned(128,8));
I_pwm:PWM port map(clk,sinusplusoffset,pwmoutput);
end rtl;

