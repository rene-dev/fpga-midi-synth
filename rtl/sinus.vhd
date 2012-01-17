library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity SinusPWM is
Port ( 
clk : in std_logic;
pwmoutput : out std_logic;
akku : in std_logic_vector(17 downto 0)
);
end SinusPWM;

architecture Behavioral of SinusPWM is

component DDFS is
Port (
CLK : in std_logic;
Freq_Data : in std_logic_vector (17 downto 0);
Dout : out std_logic_vector (7 downto 0)
);
end component;

component PWM is
Port (
clk : in std_logic;
pwmvalue : in std_logic_vector (7 downto 0);
pwmout : out std_logic
);
end component;
signal sinusplusoffset : std_logic_vector(7 downto 0);
signal sinus : std_logic_vector(7 downto 0);
begin
I_ddfs : DDFS port map(
CLK => clk,
Freq_Data => akku,
Dout => sinus
);
sinusplusoffset <= std_logic_vector(unsigned(sinus) +to_unsigned(128,8));
I_pwm : PWM
port map(
CLK => clk,
pwmvalue => sinusplusoffset,
pwmout => pwmoutput
);
end Behavioral;
