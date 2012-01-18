library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

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

component midi_incomp is
port( 
   clock 	: in  std_logic;
   midi_in   : in  std_logic;
   midi_new	: out std_logic;
   midi_ch   : out  std_logic_vector(3 downto 0);
   midi_note : out std_logic_vector(6 downto 0);
   midi_velo : out std_logic_vector(6 downto 0);
   raw       : out std_logic_vector(7 downto 0)
);
end component;

component RS232 is
    Generic ( Quarz_Taktfrequenz : integer   := 100000000;  -- Hertz 
              Baudrate           : integer   :=  31250      -- Bits/Sec
             );
    Port ( RXD      : in   STD_LOGIC;
           RX_Data  : out  STD_LOGIC_VECTOR (7 downto 0);
           RX_Busy  : out  STD_LOGIC;
           TXD      : out  STD_LOGIC;
           TX_Data  : in   STD_LOGIC_VECTOR (7 downto 0);
           TX_Start : in   STD_LOGIC;
           TX_Busy  : out  STD_LOGIC;
           CLK      : in   STD_LOGIC
           );
end component;

component SinusPWM is
Port (
   clk       : in std_logic;
   pwmoutput : out std_logic; 
   akku      : in std_logic_vector(17 downto 0)
);
end component;

component pwm is
Generic(
   width : natural := 8; -- Breite
   fclk  : integer := 100000000; -- Taktfrequenz
   fpwm  : integer := 50000 -- PWM-Frequenz;
);
Port(
   clk      : in std_logic;
   pwmvalue : in std_logic_vector (width-1 downto 0);
   pwmout   : out std_logic
);
end component;

component playnote
port(
   clk   : in  std_logic;
   note  : in  integer;
   audio : out  std_logic
);
end component;

signal midi_new  : std_logic := '0';
signal midi_ch   : std_logic_vector(3 downto 0);
signal midi_note : std_logic_vector(6 downto 0);
signal midi_velo : std_logic_vector(6 downto 0) := "0000000";
signal note : integer := 255;
signal ddfsnote : std_logic_vector(17 downto 0);
signal l : std_logic;
signal r : std_logic;

signal midi_data : std_logic_vector(7 downto 0);
signal midi_busy : std_logic;
signal byte_done : std_logic;
type MIDI_BYTE_STATE is (channel, notev, velocity);
signal midi_byte: MIDI_BYTE_STATE := channel;

type ddfstype is array (0 to 127) of std_logic_vector (19 downto 0);
signal midi2ddfs : ddfstype := (x"00057", x"0005d", x"00062", x"00068", x"0006e", x"00075", x"0007c", x"00083", x"0008b", x"00093", x"0009c", x"000a5", x"000af", x"000ba", x"000c5", x"000d0", x"000dd", x"000ea", x"000f8", x"00107", x"00116", x"00127", x"00138", x"0014b", x"0015f", x"00174", x"0018a", x"001a1", x"001ba", x"001d4", x"001f0", x"0020e", x"0022d", x"0024e", x"00271", x"00296", x"002be", x"002e8", x"00314", x"00343", x"00374", x"003a9", x"003e1", x"0041c", x"0045a", x"0049d", x"004e3", x"0052d", x"0057c", x"005d0", x"00628", x"00686", x"006e9", x"00752", x"007c2", x"00838", x"008b5", x"0093a", x"009c6", x"00a5b", x"00af9", x"00ba0", x"00c51", x"00d0c", x"00dd3", x"00ea5", x"00f84", x"01071", x"0116b", x"01274", x"0138d", x"014b7", x"015f2", x"01740", x"018a2", x"01a19", x"01ba6", x"01d4b", x"01f09", x"020e2", x"022d6", x"024e8", x"0271a", x"0296e", x"02be4", x"02e80", x"03144", x"03432", x"0374d", x"03a97", x"03e13", x"041c4", x"045ad", x"049d1", x"04e35", x"052dc", x"057c9", x"05d01", x"06289", x"06865", x"06e9a", x"0752e", x"07c26", x"08388", x"08b5a", x"093a3", x"09c6b", x"0a5b8", x"0af92", x"0ba03", x"0c513", x"0d0cb", x"0dd35", x"0ea5c", x"0f84c", x"10710", x"116b4", x"12747", x"138d6", x"14b70", x"15f25", x"17407", x"18a26", x"1a196", x"1ba6b", x"1d4b9", x"1f099", x"20e20");
begin
--midi_incomp1:midi_incomp port map(clk, midi_in, midi_new, midi_ch, midi_note, midi_velo,open);
sin1:sinuspwm port map(clk,r,ddfsnote);
SoundGen_l: PlayNote port map (clk,note,l);
--SoundGen_r: PlayNote port map (clk,note,r);
uart1: RS232 port map(midi_in,midi_data,midi_busy,open,"00000000",'0',open,clk);
AudioL <= l and sw(0);
AudioR <= r and sw(1);

process begin
wait until rising_edge(clk);
if(midi_busy = '0') then
--Led <= midi_data;
midi_new <= '0';
if(midi_data = x"FE" and midi_byte = channel) then--ignore active sense signal
  midi_byte <= channel;
  byte_done <= '1';
elsif(midi_data(7 downto 4) = "1000" and midi_byte = channel and byte_done = '0') then --note off first bit of status byte is always 1
  midi_ch(3 downto 0) <= midi_data(3 downto 0);
  midi_byte <= channel;
  midi_velo <= "0000000";
  midi_new <= '1';
  byte_done <= '1';
--led <= midi_data;
elsif(midi_data(7 downto 4) = "1001"  and midi_byte = channel and byte_done = '0') then --note on first bit of status byte is always 1
  midi_ch(3 downto 0) <= midi_data(3 downto 0);
  midi_byte <= notev;
  byte_done <= '1';
elsif(midi_data(7) = '0' and midi_byte = notev and byte_done = '0') then --frist bit of data byte is always 0
  midi_note(6 downto 0) <= midi_data(6 downto 0);
  midi_byte <= velocity;
  byte_done <= '1';
elsif(midi_data(7) = '0' and midi_byte = velocity and byte_done = '0') then
  midi_velo(6 downto 0) <= midi_data(6 downto 0);
  midi_new <= '1';
  midi_byte <= channel;
  byte_done <= '1';
elsif(midi_data(7) = '0' and midi_byte = velocity and byte_done = '0') then
  midi_velo(6 downto 0) <= midi_data(6 downto 0);
  midi_new <= '1';
  midi_byte <= channel;
  byte_done <= '1';

elsif(byte_done = '0') then
  midi_byte <= channel;
  byte_done <= '1';
end if;
else
byte_done <= '0';
end if;
end process;

process begin
wait until rising_edge(clk);
if(midi_new = '1') then
      --led(7 downto 1) <= midi_velo;
      if(midi_velo = "0000000") then
         Led(7 downto 1) <= "0000000";
         note <= 255;
         ddfsnote <= (others => '0');
         --ddfsnote <= midi2ddfs(conv_integer(midi_note))(17 downto 0);
      else
         Led(7 downto 1) <= midi_note(6 downto 0);
         --led(1) <= clk;
         --mit led <= clk geht es.
         --wenn man ddfs statt midi_note auf den leds ausgibt brummt es nurnoch.
         note <= conv_integer(midi_note);
         --ddfsnote <= (others => '0');
         ddfsnote <= midi2ddfs(conv_integer(midi_note))(17 downto 0);
      end if;
end if;
end process;
Led(0) <= not midi_in;
midi_out <= not midi_in;
end rtl;
