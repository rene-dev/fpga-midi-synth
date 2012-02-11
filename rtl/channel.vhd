library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
library work;
use work.all;

entity channel is port(
   clk      : in  std_logic;
   note_on  : in  std_logic;
   note_in  : in  std_logic_vector(6 downto 0);
   velocity : in  std_logic_vector(6 downto 0);
   volume   : in  std_logic_vector(6 downto 0);
   audio_out: out std_logic_vector(7 downto 0)
   );
end channel;

architecture rtl of channel is

type poly_type is array (integer range 0 to 7) of integer range 0 to 127;
signal poly : poly_type;

type audio_type is array (integer range 0 to 7) of std_logic;
signal audio_ch : audio_type;

signal note : integer := 255;
signal sound : std_logic := '0';
--signal ddfsnote : std_logic_vector(17 downto 0) := (others => '0');

--type ddfstype is array (0 to 127) of std_logic_vector (19 downto 0);
--signal midi2ddfs : ddfstype := (x"00057", x"0005d", x"00062", x"00068", x"0006e", x"00075", x"0007c", x"00083", x"0008b", x"00093", x"0009c", x"000a5", x"000af", x"000ba", x"000c5", x"000d0", x"000dd", x"000ea", x"000f8", x"00107", x"00116", x"00127", x"00138", x"0014b", x"0015f", x"00174", x"0018a", x"001a1", x"001ba", x"001d4", x"001f0", x"0020e", x"0022d", x"0024e", x"00271", x"00296", x"002be", x"002e8", x"00314", x"00343", x"00374", x"003a9", x"003e1", x"0041c", x"0045a", x"0049d", x"004e3", x"0052d", x"0057c", x"005d0", x"00628", x"00686", x"006e9", x"00752", x"007c2", x"00838", x"008b5", x"0093a", x"009c6", x"00a5b", x"00af9", x"00ba0", x"00c51", x"00d0c", x"00dd3", x"00ea5", x"00f84", x"01071", x"0116b", x"01274", x"0138d", x"014b7", x"015f2", x"01740", x"018a2", x"01a19", x"01ba6", x"01d4b", x"01f09", x"020e2", x"022d6", x"024e8", x"0271a", x"0296e", x"02be4", x"02e80", x"03144", x"03432", x"0374d", x"03a97", x"03e13", x"041c4", x"045ad", x"049d1", x"04e35", x"052dc", x"057c9", x"05d01", x"06289", x"06865", x"06e9a", x"0752e", x"07c26", x"08388", x"08b5a", x"093a3", x"09c6b", x"0a5b8", x"0af92", x"0ba03", x"0c513", x"0d0cb", x"0dd35", x"0ea5c", x"0f84c", x"10710", x"116b4", x"12747", x"138d6", x"14b70", x"15f25", x"17407", x"18a26", x"1a196", x"1ba6b", x"1d4b9", x"1f099", x"20e20");
begin

--sin1:entity work.sinuspwm port map(clk,r,ddfsnote);
soundgen:for i in 0 to 7 generate
   soundi:entity work.PlayNote port map(clk,poly(i),audio_ch(i));
end generate;

process begin
wait until rising_edge(clk);
if(note_on = '1') then
      if(velocity = "0000000") then
         note <= 255;
         audio_out <= "00000000";
         --ddfsnote <= (others => '0');
      else
         note <= to_integer(unsigned(note_in));
         if(sound = '1') then
            --audio_out <= std_logic_vector(unsigned('0'&velocity) + unsigned('0'&volume));
            audio_out <= '0'&volume;
         else
            audio_out <= "00000000";
         end if;
         --ddfsnote <= midi2ddfs(conv_integer(midi_note))(17 downto 0);
      end if;
end if;
end process;
end rtl;

