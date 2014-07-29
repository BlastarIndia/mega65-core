library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.all;
use work.debugtools.all;

entity cpu_test is
  
end cpu_test;

architecture behavior of cpu_test is

  signal pixelclock : std_logic := '0';
  signal cpuclock : std_logic := '0';
  signal ioclock : std_logic := '0';
  signal clock50mhz : std_logic := '0';
  signal reset : std_logic := '0';
  signal irq : std_logic := '1';
  signal nmi : std_logic := '1';

  signal vsync : std_logic;
  signal hsync : std_logic;
  signal vgared : unsigned(3 downto 0);
  signal vgagreen : unsigned(3 downto 0);
  signal vgablue : unsigned(3 downto 0);

  signal slowram_data : std_logic_vector(15 downto 0);
  
  signal led0 : std_logic;
  signal led1 : std_logic;
  signal led2 : std_logic;
  signal led3 : std_logic;
  signal sw : std_logic_vector(15 downto 0) := (others => '0');
  signal btn : std_logic_vector(4 downto 0) := (others => '0');

  signal UART_TXD : std_logic;
  signal RsRx : std_logic;
  
  signal sseg_ca : std_logic_vector(7 downto 0);
  signal sseg_an : std_logic_vector(7 downto 0);
  
  component machine is
    Port ( pixelclock : STD_LOGIC;
           cpuclock : STD_LOGIC;
           clock50mhz : in STD_LOGIC;
           ioclock : STD_LOGIC;
           uartclock : STD_LOGIC;
           btnCpuReset : in  STD_LOGIC;
           irq : in  STD_LOGIC;
           nmi : in  STD_LOGIC;

           ----------------------------------------------------------------------
           -- VGA output
           ----------------------------------------------------------------------
           vsync : out  STD_LOGIC;
           hsync : out  STD_LOGIC;
           vgared : out  UNSIGNED (3 downto 0);
           vgagreen : out  UNSIGNED (3 downto 0);
           vgablue : out  UNSIGNED (3 downto 0);

           ---------------------------------------------------------------------------
           -- IO lines to the ethernet controller
           ---------------------------------------------------------------------------
           eth_mdio : inout std_logic;
           eth_mdc : out std_logic;
           eth_reset : out std_logic;
           eth_rxd : in unsigned(1 downto 0);
           eth_txd : out unsigned(1 downto 0);
           eth_txen : out std_logic;
           eth_rxdv : in std_logic;
           eth_interrupt : in std_logic;         
           
           -------------------------------------------------------------------------
           -- Lines for the SDcard interface itself
           -------------------------------------------------------------------------
           cs_bo : out std_logic;
           sclk_o : out std_logic;
           mosi_o : out std_logic;
           miso_i : in  std_logic;

           aclMISO : in std_logic;
           aclMOSI : out std_logic;
           aclSS : out std_logic;
           aclInt1 : in std_logic;
           aclInt2 : in std_logic;
    
           ampPWM : out std_logic;
           ampSD : out std_logic;

           micData : in std_logic;
           micClk : out std_logic;
           micLRSel : out std_logic;

           tmpSDA : out std_logic;
           tmpSCL : out std_logic;
           tmpInt : in std_logic;
           tmpCT : in std_logic;

           --------------------------------------------------------------------
           -- Slow RAM interface: null for now
           --------------------------------------------------------------------
           slowram_addr : out std_logic_vector(22 downto 0);
           slowram_we : out std_logic;
           slowram_ce : out std_logic;
           slowram_oe : out std_logic;
           slowram_lb : out std_logic;
           slowram_ub : out std_logic;
           slowram_data : inout std_logic_vector(15 downto 0);
           
           ----------------------------------------------------------------------
           -- PS/2 adapted USB keyboard & joystick connector.
           -- For now we will use a keyrah adapter to connect to the keyboard.
           ----------------------------------------------------------------------
           ps2data : in std_logic;
           ps2clock : in std_logic;        
           
           ----------------------------------------------------------------------
           -- Debug interfaces on Nexys4 board
           ----------------------------------------------------------------------
           led0 : out std_logic;
           led1 : out std_logic;
           led2 : out std_logic;
           led3 : out std_logic;
           sw : in std_logic_vector(15 downto 0);
           btn : in std_logic_vector(4 downto 0);

           UART_TXD : out std_logic;
           RsRx : in std_logic;
           
           sseg_ca : out std_logic_vector(7 downto 0);
           sseg_an : out std_logic_vector(7 downto 0)
           );
  end component;

begin
  core0: machine
    port map (
      pixelclock      => pixelclock,
      cpuclock      => cpuclock,
      clock50mhz   => clock50mhz,
      ioclock      => cpuclock,
      uartclock    => ioclock,
      btnCpuReset      => reset,
      irq => '1',
      nmi => '1',

      ps2data => '1',
      ps2clock => '1',

      miso_i => '1',

      aclMISO => '1',
      aclInt1 => '0',
      aclInt2 => '0',
      micData => '0',
      tmpInt => '0',
      tmpCT => '0',      

      eth_rxd => "00",
      eth_rxdv => '0',
      eth_interrupt => '0',
      
      slowram_data => slowram_data,
      
      vsync           => vsync,
      hsync           => hsync,
      vgared          => vgared,
      vgagreen        => vgagreen,
      vgablue         => vgablue,
      
      led0            => led0,
      led1            => led1,
      led2            => led2,
      led3            => led3,
      sw              => sw,
      btn             => btn,

      uart_txd        => uart_txd,
      rsrx            => rsrx,

      sseg_ca         => sseg_ca,
      sseg_an         => sseg_an);
  
  process
  begin  -- process tb
    report "beginning simulation" severity note;
    slowram_data <= (others => 'Z');

    for i in 1 to 2000000 loop
      pixelclock <= '0'; cpuclock <= '0'; ioclock <= '0';
      wait for 5 ns;     
      pixelclock <= '1'; cpuclock <= '0'; ioclock <= '0';
      wait for 5 ns;     
      pixelclock <= '0'; cpuclock <= '0'; ioclock <= '0';
      wait for 5 ns;     
      pixelclock <= '1'; cpuclock <= '0'; ioclock <= '0';
      wait for 5 ns;     
      pixelclock <= '0'; cpuclock <= '1'; ioclock <= '1';
      wait for 5 ns;     
      pixelclock <= '1'; cpuclock <= '1'; ioclock <= '1';
      wait for 5 ns;     
      pixelclock <= '0'; cpuclock <= '1'; ioclock <= '1';
      wait for 5 ns;     
      pixelclock <= '1'; cpuclock <= '1'; ioclock <= '1';
      wait for 5 ns;     
      reset <= '1';
    end loop;  -- i
    assert false report "End of simulation" severity failure;
  end process;

  process
  begin
    for i in 1 to 20000000 loop
      clock50mhz <= '0';
      wait for 10 ns;
      clock50mhz <= '1';
      wait for 10 ns;
    end loop;
  end process;
  
end behavior;

