library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
library work;
use work.all;

entity synth_top is port(
   clk     : in  std_logic;
   midi_in : in  std_logic;
   midi_out: out  std_logic;
   AudioR  : out  std_logic;
   AudioL  : out  std_logic;
   sw      : in  std_logic_vector(7 downto 0);
   Led     : out std_logic_vector(7 downto 0)
   );
end synth_top;

architecture rtl of synth_top is

component pwm is
Generic(
   width: natural := 8; -- Breite
   fclk : integer := 100000000; -- Taktfrequenz
   fpwm : integer := 500000 -- PWM-Frequenz;
);
Port(
   clk      : in  std_logic;
   pwmvalue : in  std_logic_vector (width-1 downto 0);
   pwmout   : out std_logic
);
end component;

signal midi_new  : std_logic := '0';
signal midi_ch   : std_logic_vector(3 downto 0);
signal midi_note : std_logic_vector(6 downto 0);
signal midi_velo : std_logic_vector(6 downto 0);
signal master    : std_logic_vector(7 downto 0);
--signal ddfsnote : std_logic_vector(17 downto 0) := (others => '0');
signal pwmaudio : std_logic;

type note_on_type is array (integer range 0 to 15) of std_logic;
signal note_on : note_on_type;

type note_in_type is array (integer range 0 to 15) of std_logic_vector(6 downto 0);
signal note_in : note_in_type;

type velocity_type is array (integer range 0 to 15) of std_logic_vector(6 downto 0);
signal velocity : velocity_type;

type volume_type is array (integer range 0 to 15) of std_logic_vector(6 downto 0);
signal volume : volume_type;

type audio_type is array (integer range 0 to 15) of std_logic_vector(7 downto 0);
signal audio_ch : audio_type;

type ddfstype is array (0 to 127) of std_logic_vector (19 downto 0);
signal midi2ddfs : ddfstype := (x"00057", x"0005d", x"00062", x"00068", x"0006e", x"00075", x"0007c", x"00083", x"0008b", x"00093", x"0009c", x"000a5", x"000af", x"000ba", x"000c5", x"000d0", x"000dd", x"000ea", x"000f8", x"00107", x"00116", x"00127", x"00138", x"0014b", x"0015f", x"00174", x"0018a", x"001a1", x"001ba", x"001d4", x"001f0", x"0020e", x"0022d", x"0024e", x"00271", x"00296", x"002be", x"002e8", x"00314", x"00343", x"00374", x"003a9", x"003e1", x"0041c", x"0045a", x"0049d", x"004e3", x"0052d", x"0057c", x"005d0", x"00628", x"00686", x"006e9", x"00752", x"007c2", x"00838", x"008b5", x"0093a", x"009c6", x"00a5b", x"00af9", x"00ba0", x"00c51", x"00d0c", x"00dd3", x"00ea5", x"00f84", x"01071", x"0116b", x"01274", x"0138d", x"014b7", x"015f2", x"01740", x"018a2", x"01a19", x"01ba6", x"01d4b", x"01f09", x"020e2", x"022d6", x"024e8", x"0271a", x"0296e", x"02be4", x"02e80", x"03144", x"03432", x"0374d", x"03a97", x"03e13", x"041c4", x"045ad", x"049d1", x"04e35", x"052dc", x"057c9", x"05d01", x"06289", x"06865", x"06e9a", x"0752e", x"07c26", x"08388", x"08b5a", x"093a3", x"09c6b", x"0a5b8", x"0af92", x"0ba03", x"0c513", x"0d0cb", x"0dd35", x"0ea5c", x"0f84c", x"10710", x"116b4", x"12747", x"138d6", x"14b70", x"15f25", x"17407", x"18a26", x"1a196", x"1ba6b", x"1d4b9", x"1f099", x"20e20");

begin

--sin1:entity work.sinuspwm port map(clk,r,ddfsnote);
--SoundGen_l:entity work.PlayNote port map(clk,note,l);
pwm1:component pwm port map(clk,master,pwmaudio);

midi:entity work.midi port map(clk,midi_in,midi_new,midi_ch,midi_note,midi_velo);

channel0 :entity work.channel port map(clk,note_on( 0),note_in( 0),velocity( 0),volume( 0),audio_ch( 0));
channel1 :entity work.channel port map(clk,note_on( 1),note_in( 1),velocity( 1),volume( 1),audio_ch( 1));
channel2 :entity work.channel port map(clk,note_on( 2),note_in( 2),velocity( 2),volume( 2),audio_ch( 2));
channel3 :entity work.channel port map(clk,note_on( 3),note_in( 3),velocity( 3),volume( 3),audio_ch( 3));
channel4 :entity work.channel port map(clk,note_on( 4),note_in( 4),velocity( 4),volume( 4),audio_ch( 4));
channel5 :entity work.channel port map(clk,note_on( 5),note_in( 5),velocity( 5),volume( 5),audio_ch( 5));
channel6 :entity work.channel port map(clk,note_on( 6),note_in( 6),velocity( 6),volume( 6),audio_ch( 6));
channel7 :entity work.channel port map(clk,note_on( 7),note_in( 7),velocity( 7),volume( 7),audio_ch( 7));
channel8 :entity work.channel port map(clk,note_on( 8),note_in( 8),velocity( 8),volume( 8),audio_ch( 8));
channel9 :entity work.channel port map(clk,note_on( 9),note_in( 9),velocity( 9),volume( 9),audio_ch( 9));
channel10:entity work.channel port map(clk,note_on(10),note_in(10),velocity(10),volume(10),audio_ch(10));
channel11:entity work.channel port map(clk,note_on(11),note_in(11),velocity(11),volume(11),audio_ch(11));
channel12:entity work.channel port map(clk,note_on(12),note_in(12),velocity(12),volume(12),audio_ch(12));
channel13:entity work.channel port map(clk,note_on(13),note_in(13),velocity(13),volume(13),audio_ch(13));
channel14:entity work.channel port map(clk,note_on(14),note_in(14),velocity(14),volume(14),audio_ch(14));
channel15:entity work.channel port map(clk,note_on(15),note_in(15),velocity(15),volume(15),audio_ch(15));

master <= std_logic_vector(unsigned(audio_ch( 0)) +
                           unsigned(audio_ch( 1)) +
                           unsigned(audio_ch( 2)) +
                           unsigned(audio_ch( 3)) +
                           unsigned(audio_ch( 4)) +
                           unsigned(audio_ch( 5)) +
                           unsigned(audio_ch( 6)) +
                           unsigned(audio_ch( 7)) +
                           unsigned(audio_ch( 8)) +
                           unsigned(audio_ch( 9)) +
                           unsigned(audio_ch(10)) +
                           unsigned(audio_ch(11)) +
                           unsigned(audio_ch(12)) +
                           unsigned(audio_ch(13)) +
                           unsigned(audio_ch(14)) +
                           unsigned(audio_ch(15))
                           );

AudioL <= pwmaudio;
AudioR <= pwmaudio;

process begin
wait until rising_edge(clk);
if(midi_new = '1') then
   note_on (to_integer(unsigned(midi_ch))) <= '1';
   note_in (to_integer(unsigned(midi_ch))) <= midi_note;
   velocity(to_integer(unsigned(midi_ch))) <= midi_velo;
   volume  (to_integer(unsigned(midi_ch))) <= "0010000";
   else
   note_on (to_integer(unsigned(midi_ch))) <= '0';
end if;
end process;

--Led(0) <= not midi_in;
Led(0) <= midi_new;
Led(7 downto 1) <= "0000000";
midi_out <= not midi_in;
end rtl;
