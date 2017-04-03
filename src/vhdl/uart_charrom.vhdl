library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.debugtools.all;

--
entity uart_charrom is
port (clkl : IN STD_LOGIC;
    wel : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrl : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dinl : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkr : IN STD_LOGIC;
    addrr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    doutr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
end uart_charrom;

architecture Behavioral of uart_charrom is

type ram_t is array (0 to 4095) of std_logic_vector(7 downto 0);
signal ram : ram_t := (
x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", --(space) d"32" x"20" (0)
x"18", x"18", x"18", x"18", x"00", x"00", x"18", x"00", --! 1 01
x"66", x"66", x"66", x"00", x"00", x"00", x"00", x"00", --" 2 02
x"66", x"66", x"FF", x"66", x"FF", x"66", x"66", x"00", --# 3 03
x"18", x"3E", x"60", x"3C", x"06", x"7C", x"18", x"00", --$ 4 04
x"62", x"66", x"0C", x"18", x"30", x"66", x"46", x"00", --% 5 05
x"3C", x"66", x"3C", x"38", x"67", x"66", x"3F", x"00", --& 6 06
x"06", x"0C", x"18", x"00", x"00", x"00", x"00", x"00", --' 7 07
x"0C", x"18", x"30", x"30", x"30", x"18", x"0C", x"00", --( 8 08
x"30", x"18", x"0C", x"0C", x"0C", x"18", x"30", x"00", --) 9 09
x"00", x"66", x"3C", x"FF", x"3C", x"66", x"00", x"00", --* 10 0A
x"00", x"18", x"18", x"7E", x"18", x"18", x"00", x"00", --+ 11 0B
x"00", x"00", x"00", x"00", x"00", x"18", x"18", x"30", --, 12 0C
x"00", x"00", x"00", x"7E", x"00", x"00", x"00", x"00", --- 13 0D
x"00", x"00", x"00", x"00", x"00", x"18", x"18", x"00", --. 14 0E
x"00", x"03", x"06", x"0C", x"18", x"30", x"60", x"00", --/ 15 0F
x"3C", x"66", x"6E", x"76", x"66", x"66", x"3C", x"00", --0 16 10
x"18", x"18", x"38", x"18", x"18", x"18", x"7E", x"00", --1 17 11
x"3C", x"66", x"06", x"0C", x"30", x"60", x"7E", x"00", --2 18 12
x"3C", x"66", x"06", x"1C", x"06", x"66", x"3C", x"00", --3 19 13
x"06", x"0E", x"1E", x"66", x"7F", x"06", x"06", x"00", --4 20 14
x"7E", x"60", x"7C", x"06", x"06", x"66", x"3C", x"00", --5 21 15
x"3C", x"66", x"60", x"7C", x"66", x"66", x"3C", x"00", --6 22 16
x"7E", x"66", x"0C", x"18", x"18", x"18", x"18", x"00", --7 23 17
x"3C", x"66", x"66", x"3C", x"66", x"66", x"3C", x"00", --8 24 18
x"3C", x"66", x"66", x"3E", x"06", x"66", x"3C", x"00", --9 25 19
x"00", x"00", x"18", x"00", x"00", x"18", x"00", x"00", --: 26 1A
x"00", x"00", x"18", x"00", x"00", x"18", x"18", x"30", --; 27 1B
x"0E", x"18", x"30", x"60", x"30", x"18", x"0E", x"00", --< 28 1C
x"00", x"00", x"7E", x"00", x"7E", x"00", x"00", x"00", --= 29 1D
x"70", x"18", x"0C", x"06", x"0C", x"18", x"70", x"00", --> 30 1E
x"3C", x"66", x"06", x"0C", x"18", x"00", x"18", x"00", --? 31 1F
x"3C", x"66", x"6E", x"6E", x"60", x"62", x"3C", x"00", --@ 32 20
x"18", x"3C", x"66", x"7E", x"66", x"66", x"66", x"00", --A 33
x"7C", x"66", x"66", x"7C", x"66", x"66", x"7C", x"00", --B 34
x"3C", x"66", x"60", x"60", x"60", x"66", x"3C", x"00", --C 35
x"78", x"6C", x"66", x"66", x"66", x"6C", x"78", x"00", --D 36 
x"7E", x"60", x"60", x"78", x"60", x"60", x"7E", x"00", --E 37
x"7E", x"60", x"60", x"78", x"60", x"60", x"60", x"00", --F 38
x"3C", x"66", x"60", x"6E", x"66", x"66", x"3C", x"00", --G 39
x"66", x"66", x"66", x"7E", x"66", x"66", x"66", x"00", --H 40
x"3C", x"18", x"18", x"18", x"18", x"18", x"3C", x"00", --I 41
x"1E", x"0C", x"0C", x"0C", x"0C", x"6C", x"38", x"00", --J 42
x"66", x"6C", x"78", x"70", x"78", x"6C", x"66", x"00", --K 43
x"60", x"60", x"60", x"60", x"60", x"60", x"7E", x"00", --L 44 
x"63", x"77", x"7F", x"6B", x"63", x"63", x"63", x"00", --M 45
x"66", x"76", x"7E", x"7E", x"6E", x"66", x"66", x"00", --N 46
x"3C", x"66", x"66", x"66", x"66", x"66", x"3C", x"00", --O 47
x"7C", x"66", x"66", x"7C", x"60", x"60", x"60", x"00", --P 48
x"3C", x"66", x"66", x"66", x"66", x"3C", x"0E", x"00", --Q 49
x"7C", x"66", x"66", x"7C", x"78", x"6C", x"66", x"00", --R 50
x"3C", x"66", x"60", x"3C", x"06", x"66", x"3C", x"00", --S 51
x"7E", x"18", x"18", x"18", x"18", x"18", x"18", x"00", --T 52
x"66", x"66", x"66", x"66", x"66", x"66", x"3C", x"00", --U 53
x"66", x"66", x"66", x"66", x"66", x"3C", x"18", x"00", --V 54
x"63", x"63", x"63", x"6B", x"7F", x"77", x"63", x"00", --W 55
x"66", x"66", x"3C", x"18", x"3C", x"66", x"66", x"00", --X 56
x"66", x"66", x"66", x"3C", x"18", x"18", x"18", x"00", --Y 57
x"7E", x"06", x"0C", x"18", x"30", x"60", x"7E", x"00", --Z 58
x"3C", x"30", x"30", x"30", x"30", x"30", x"3C", x"00", --{
x"00", x"40", x"60", x"30", x"18", x"0C", x"06", x"02", --\ (/ flipped) 
x"3C", x"0C", x"0C", x"0C", x"0C", x"0C", x"3C", x"00", --]
x"3C", x"66", x"06", x"0C", x"18", x"00", x"18", x"00", --^ ?
x"3C", x"66", x"06", x"0C", x"18", x"00", x"18", x"00", --_ ?
x"3C", x"66", x"06", x"0C", x"18", x"00", x"18", x"00", --` ?
x"00", x"00", x"3C", x"06", x"3E", x"66", x"3E", x"00", --a
x"00", x"60", x"60", x"7C", x"66", x"66", x"7C", x"00", --b
x"00", x"00", x"3C", x"60", x"60", x"60", x"3C", x"00", --c
x"00", x"06", x"06", x"3E", x"66", x"66", x"3E", x"00", --d
x"00", x"00", x"3C", x"66", x"7E", x"60", x"3C", x"00", --e
x"00", x"0E", x"18", x"3E", x"18", x"18", x"18", x"00", --f
x"00", x"00", x"3E", x"66", x"66", x"3E", x"06", x"7C", --g
x"00", x"60", x"60", x"7C", x"66", x"66", x"66", x"00", --h
x"00", x"18", x"00", x"38", x"18", x"18", x"3C", x"00", --i
x"00", x"06", x"00", x"06", x"06", x"06", x"06", x"3C", --j
x"00", x"60", x"60", x"6C", x"78", x"6C", x"66", x"00", --k
x"00", x"38", x"18", x"18", x"18", x"18", x"3C", x"00", --l
x"00", x"00", x"66", x"7F", x"7F", x"6B", x"63", x"00", --m
x"00", x"00", x"7C", x"66", x"66", x"66", x"66", x"00", --n
x"00", x"00", x"3C", x"66", x"66", x"66", x"3C", x"00", --o
x"00", x"00", x"7C", x"66", x"66", x"7C", x"60", x"60", --p
x"00", x"00", x"3E", x"66", x"66", x"3E", x"06", x"06", --q
x"00", x"00", x"7C", x"66", x"60", x"60", x"60", x"00", --r
x"00", x"00", x"3E", x"60", x"3C", x"06", x"7C", x"00", --s
x"00", x"18", x"7E", x"18", x"18", x"18", x"0E", x"00", --t
x"00", x"00", x"66", x"66", x"66", x"66", x"3E", x"00", --u
x"00", x"00", x"66", x"66", x"66", x"3C", x"18", x"00", --v
x"00", x"00", x"63", x"6B", x"7F", x"3E", x"36", x"00", --w
x"00", x"00", x"66", x"3C", x"18", x"3C", x"66", x"00", --x
x"00", x"00", x"66", x"66", x"66", x"3E", x"0C", x"78", --y
x"00", x"00", x"7E", x"0C", x"18", x"30", x"7E", x"00", --z
x"3C", x"66", x"06", x"0C", x"18", x"00", x"18", x"00", --{ ?
x"3C", x"66", x"06", x"0C", x"18", x"00", x"18", x"00", --| ?
x"3C", x"66", x"06", x"0C", x"18", x"00", x"18", x"00", --} ?
x"3C", x"66", x"06", x"0C", x"18", x"00", x"18", x"00",
x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", --~ ?

770=>x"21",
849=>x"21",
3890=>x"21",
3969=>x"21",
4095=>x"21",

others=>x"00"
);

begin

--process for read and write operation.
 process(clkl)
    variable theram : ram_t;
  begin
    if(rising_edge(Clkl)) then 
      if wel(0)='1' and addrl>x"300" then
        ram(to_integer(unsigned(addrl))) <= dinl;
      end if;
      doutr <= ram(to_integer(unsigned(addrr)));
    end if;
  end process;


end Behavioral;