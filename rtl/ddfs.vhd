library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
Entity DDFS is
Port(
CLK : in std_logic;
Freq_Data : in std_logic_vector (17 downto 0);
Dout : out std_logic_vector (7 downto 0)
);
end DDFS;
architecture rtl of ddfs is
signal Result : signed (7 downto 0);
signal Accum : unsigned (29 downto 0) := (others=>'0');
signal Address : integer range 0 to 63;
signal RomAddr : integer range 0 to 63;
signal Quadrant : std_logic;
signal Sign : std_logic;
type Rom64x8 is array (0 to 63) of signed (7 downto 0);
constant Sinus_Rom : Rom64x8 := (x"00", x"03", x"06", x"09", x"0c", x"0f", x"12", x"15", x"18", x"1b", x"1e", x"21", x"24", x"27", x"2a", x"2d", x"30", x"33", x"36", x"39", x"3b", x"3e", x"41", x"43", x"46", x"49", x"4b", x"4e", x"50", x"52", x"55", x"57", x"59", x"5b", x"5e", x"60", x"62", x"64", x"66", x"67", x"69", x"6b", x"6c", x"6e", x"70", x"71", x"72", x"74", x"75", x"76", x"77", x"78", x"79", x"7a", x"7b", x"7b", x"7c", x"7d", x"7d", x"7e", x"7e", x"7e", x"7f", x"7f");

begin

-- Phasenakkumulator
process begin
   wait until rising_edge(CLK);
   Accum <= Accum + unsigned(Freq_Data);
end process;

-- BROM
process begin
   wait until rising_edge(CLK);
   RomAddr <= Address; -- getaktete Adresse --> BRAM
end process;

Result <= signed(Sinus_Rom(RomAddr));
Quadrant <= Accum(Accum'left-1);
Address <= to_integer(Accum(Accum'high-2 downto Accum'high-7)) when (Quadrant='0') 
else 63-to_integer(Accum(Accum'high-2 downto Accum'high-7));

process begin
   wait until rising_edge(CLK);
   Sign <= Accum(Accum'left);
end process;
Dout <= std_logic_vector(Result) when (Sign='1') else std_logic_vector(0-Result);
end RTL;

