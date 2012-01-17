library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL; 
 
entity GenerateNotes is 
    Port ( clk : in  STD_LOGIC;
	        note : out integer
    ); 
end GenerateNotes; 
 
architecture Behavioral of GenerateNotes is 

type melody_type is array(0 to 15)of integer;
signal melody: melody_type;

signal c : integer range 0 to 15 := 0; -- Noten C, C#, D, D#, E, ...H
signal count : integer range 0 to 199999999 := 0;

begin 
	-- C D E F G G A A A A G(2) A A A A G(2)
	-- melody <= (0, 2, 4, 5, 7, 7, 9, 9, 9, 9, 7, 9, 9, 9, 9, 7);
	melody <= (12, 10, 12, 7, 3, 7, 0, 0, 12, 10, 12, 7, 3, 7, 0, 0);
	
   process begin  
      wait until rising_edge(clk); -- warten bis zum nchsten Takt 
      if (count<25000000) then            -- 1000000000 = 1 Sekunde bei 100MHz  25000000
          count <= count+1;                -- wenn kleiner: weiterzhlen 
      else                         -- wenn Zhlerende erreicht: 
          count <= 0;                  -- Zhler zurcksetzen 
          c <= c + 1;              -- und Note hochzhlen 
      end if; 
   end process; 
   note <= melody(c);                       -- Signal x an LED ausgeben 
end Behavioral;
