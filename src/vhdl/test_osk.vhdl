use WORK.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.debugtools.all;

entity test_osk is
end test_osk;

architecture behavioral of test_osk is

  signal pixel_x_640 : integer := 0;
  signal ycounter_in : unsigned(11 downto 0) := (others => '0');
  signal x_start : unsigned(11 downto 0) := to_unsigned(0,12);
  signal y_start : unsigned(11 downto 0) := to_unsigned(479-290,12);
  signal pixelclock : std_logic := '1';
  signal visual_keyboard_enable : std_logic := '1';
  signal key1 : unsigned(7 downto 0) := x"0f";
  signal key2 : unsigned(7 downto 0) := x"3c";
  signal key3 : unsigned(7 downto 0) := x"01";
  signal vgared_in : unsigned (7 downto 0) := x"00";
  signal vgagreen_in : unsigned (7 downto 0) := x"FF";
  signal vgablue_in : unsigned (7 downto 0) := x"00";
  signal vgared_out : unsigned (7 downto 0);
  signal vgagreen_out : unsigned (7 downto 0);
  signal vgablue_out : unsigned (7 downto 0);
  
begin
  kc0: entity work.visual_keyboard
    port map(
      pixel_x_640_in => pixel_x_640,
      x_start => x_start,
      y_start => y_start,
      ycounter_in => ycounter_in,
      pixelclock => pixelclock,
      visual_keyboard_enable => visual_keyboard_enable,
      key1 => key1,
      key2 => key2,
      key3 => key3,
      vgared_in => vgared_in,
      vgagreen_in => vgagreen_in,
      vgablue_in => vgablue_in,
      vgared_out => vgared_out,
      vgagreen_out => vgagreen_out,
      vgablue_out => vgablue_out
    );

  process
  begin
    for i in 1 to 20000000 loop
      pixelclock <= '1';
      wait for 10 ns;
      pixelclock <= '0';
      wait for 10 ns;
      pixelclock <= '1';
      wait for 10 ns;
      pixelclock <= '0';
      wait for 10 ns;
      pixelclock <= '1';
      wait for 10 ns;
      pixelclock <= '0';
      wait for 10 ns;
      if pixel_x_640 < 650 then
        pixel_x_640 <= pixel_x_640 + 1;
      else
        pixel_x_640 <= 0;
        if ycounter_in < 480 then
          ycounter_in <= ycounter_in + 1;
        else
          ycounter_in <= to_unsigned(0,12);
        end if;
      end if;
      report "PIXEL:" & integer'image(pixel_x_640)
        & ":" & integer'image(to_integer(ycounter_in))
        & ":" & to_hstring(vgared_out)
        & ":" & to_hstring(vgagreen_out)
        & ":" & to_hstring(vgablue_out);
    end loop;  -- i
    assert false report "End of simulation" severity note;
  end process;

end behavioral;