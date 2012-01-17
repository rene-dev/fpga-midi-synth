--*************************************************************************
--* Minimal UART ip core                                                 *
--* Author: Arao Hayashida Filho        arao@medinovacao.com.br           *
--*                                                                       *
--*************************************************************************
--*                                                                       *
--* Copyright (C) 2009 Arao Hayashida Filho                               *
--*                                                                       *
--* This source file may be used and distributed without                  *
--* restriction provided that this copyright statement is not             *
--* removed from the file and that any derivative work contains           *
--* the original copyright notice and the associated disclaimer.          *
--*                                                                       *
--* This source file is free software; you can redistribute it            *
--* and/or modify it under the terms of the GNU Lesser General            *
--* Public License as published by the Free Software Foundation;          *
--* either version 2.1 of the License, or (at your option) any            *
--* later version.                                                        *
--*                                                                       *
--* This source is distributed in the hope that it will be                *
--* useful, but WITHout ANY WARRANTY; without even the implied            *
--* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR               *
--* PURPOSE.  See the GNU Lesser General Public License for more          *
--* details.                                                              *
--*                                                                       *
--* You should have received a copy of the GNU Lesser General             *
--* Public License along with this source; if not, download it            *
--* from http://www.opencores.org/lgpl.shtml                              *
--*                                                                       *
--*************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity midi_incomp is
port( 
   clock     : in  std_logic;
   midi_in   : in  std_logic;
   midi_new  : out std_logic;
   midi_ch   : out std_logic_vector(3 downto 0);
   midi_note : out std_logic_vector(6 downto 0);
   midi_velo : out std_logic_vector(6 downto 0);
   raw       : out std_logic_vector(7 downto 0)
   );
end midi_incomp;

architecture rtl of midi_incomp is

constant divider : std_logic_vector(11 downto 0) := X"C80";--100Mhz/3200 = 31250
type STATE     is (idle, S1, S2, S3, S4, S5, S6, S7, S8, S9);
type MIDI_BYTE_STATE is (channel, note, velocity);

signal CLK_SERIAL   : std_logic := '0';
signal START        : std_logic := '0';
signal EOCS         : std_logic := '0';
signal RX_CK_ENABLE : std_logic := '0';
signal RECEIVING    : std_logic := '0';
signal DATA         : std_logic_vector(7 downto 0)  := X"00";
signal count        : std_logic_vector(11 downto 0) := (others=>'0');
signal ATUAL_STATE, NEXT_STATE: STATE := idle;
signal midi_byte: MIDI_BYTE_STATE := channel; 

begin

RX_CK_ENABLE <= START OR RECEIVING;

clk_div : process (CLOCK)
begin
if (rising_edge(CLOCK)) then		
	if (count=divider) then
			count <= (others=>'0');	
			CLK_SERIAL<='1';
	elsif (RX_CK_ENABLE='1') then	
			count<=count+1;	
			CLK_SERIAL<='0';			
	else				
			CLK_SERIAL<='0';
			count <=  '0' & divider(11 downto 1);			
	end if;
end if;
end process clk_div;

START_DETECT : process(midi_in, EOCS)
begin
		if (EOCS='1') then			
				START<='0';
		elsif (falling_edge(midi_in)) then			
				START<='1';			
		end if;	   
end process START_DETECT;

RXD_STATES : process (CLK_SERIAL)
begin
	if (rising_edge(CLK_SERIAL)) then
			ATUAL_STATE<=NEXT_STATE;	
	end if;			
end process RXD_STATES;

RXD_STATE_MACHINE : process(START, ATUAL_STATE, RECEIVING)
begin
if (START='1' or RECEIVING='1') then	
	case ATUAL_STATE is
		when idle =>	
		 	EOCS<='0';						
		   if (START='1') then
				NEXT_STATE<=S1;	
				RECEIVING<='1';				
			else
				NEXT_STATE<=idle;	
				RECEIVING<='0';				
			end if;				
		when S1 =>		
			RECEIVING<='1';
			EOCS<='0';					
			NEXT_STATE<=S2;			
		when S2	=>					
			RECEIVING<='1';
			EOCS<='0';					
			NEXT_STATE<=S3;			
		when S3	=>					
			RECEIVING<='1';
			EOCS<='0';				
			NEXT_STATE<=S4;			
		when S4	=>					
			RECEIVING<='1';
			EOCS<='0';							
			NEXT_STATE<=S5;			
		when S5	=>				
			RECEIVING<='1';
			EOCS<='0';							
			NEXT_STATE<=S6;			
		when S6	=>					
			RECEIVING<='1';
			EOCS<='0';					
			NEXT_STATE<=S7;		
		when S7	=>					
			RECEIVING<='1';
			EOCS<='0';								
			NEXT_STATE<=S8;		
		when S8	=>    			
			RECEIVING<='1';
			EOCS<='0';						
			NEXT_STATE<=S9;			
		when S9	=>    			
			RECEIVING<='1';
			EOCS<='1';						
			NEXT_STATE<=idle;				
	end case;	
end if;
end process RXD_STATE_MACHINE;

RXD_SHIFT : process(CLK_SERIAL)
begin   	
	if (rising_edge(CLK_SERIAL)) then	
		if(EOCS='0') then
	 		DATA<=midi_in & DATA(7 downto 1);	 		
		end if;
	end if; 	 	
end process RXD_SHIFT;
raw <= data;
DECODE_MIDI : process(EOCS)
begin
	if (rising_edge(EOCS)) then
	    if(DATA = x"FE" and midi_byte = channel) then--ignore active sense signal
                       midi_byte <= channel;
                --_elsif(DATA = x"8C" and midi_byte = channel) then --
                --       midi_velo <= "0000000";
                --        midi_byte <= note;
		elsif(DATA(7) = '1' and midi_byte = channel) then --first bit of status byte is always 1
	 		midi_ch(3 downto 0) <= DATA(3 downto 0);
	 		midi_byte <= note;
		elsif(DATA(7) = '0' and midi_byte = note) then --frist bit of data byte is always 0
	 		midi_note(6 downto 0) <= DATA(6 downto 0);
	 		midi_byte <= velocity;
		elsif(DATA(7) = '0' and midi_byte = velocity) then
	 		midi_velo(6 downto 0) <= DATA(6 downto 0);
	 		midi_new <= '1';
	 		midi_byte <= channel;
		else
			midi_byte <= channel;
		end if;
	end if; 	 	
end process DECODE_MIDI;

end rtl;  
  
