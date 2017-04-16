----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:30:37 12/10/2013 
-- Design Name: 
-- Module Name:    container - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use Std.TextIO.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity container is
  Port ( CLK_IN : STD_LOGIC;         
         btnCpuReset : in  STD_LOGIC;
--         irq : in  STD_LOGIC;
--         nmi : in  STD_LOGIC;
         
         ----------------------------------------------------------------------
         -- CIA1 ports for keyboard/joystick 
         ----------------------------------------------------------------------
         porta_pins : inout  std_logic_vector(7 downto 0);
         portb_pins : inout  std_logic_vector(7 downto 0);
         
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
         eth_rxer : in std_logic;
         eth_txen : out std_logic;
         eth_rxdv : in std_logic;
         eth_interrupt : in std_logic;
         eth_clock : out std_logic;
         
         -------------------------------------------------------------------------
         -- Lines for the SDcard interface itself
         -------------------------------------------------------------------------
         sdReset : out std_logic := '0';  -- must be 0 to power SD controller (cs_bo)
         sdClock : out std_logic;       -- (sclk_o)
         sdMOSI : out std_logic;      
         sdMISO : in  std_logic;
         sdCardDetect : in std_logic;

         ---------------------------------------------------------------------------
         -- Lines for other devices that we handle here
         ---------------------------------------------------------------------------
         aclMISO : in std_logic;
         aclMOSI : out std_logic;
         aclSS : out std_logic;
         aclSCK : out std_logic;
         aclInt1 : in std_logic;
         aclInt2 : in std_logic;
    
         micData : in std_logic;
         micClk : out std_logic;
         micLRSel : out std_logic;

         ampPWM : out std_logic;
         ampSD : out std_logic;

         tmpSDA : out std_logic;
         tmpSCL : out std_logic;
         tmpInt : in std_logic;
         tmpCT : in std_logic;
         
         ----------------------------------------------------------------------
         -- PS/2 keyboard interface
         ----------------------------------------------------------------------
         ps2clk : in std_logic;
         ps2data : in std_logic;

         ----------------------------------------------------------------------
         -- PMOD B for input PCB
         ----------------------------------------------------------------------
         jblo : inout std_logic_vector(4 downto 1) := (others => 'Z');
         jbhi : inout std_logic_vector(10 downto 7) := (others => 'Z');
         
         ----------------------------------------------------------------------
         -- PMOD A for general IO while debugging and testing
         ----------------------------------------------------------------------
         jalo : inout std_logic_vector(4 downto 1) := (others => 'Z');
         jahi : inout std_logic_vector(10 downto 7) := (others => 'Z');
         jclo : inout std_logic_vector(4 downto 1) := (others => 'Z');
         
         ----------------------------------------------------------------------
         -- Flash RAM for holding config
         ----------------------------------------------------------------------
--         QspiSCK : out std_logic;
         QspiDB : inout std_logic_vector(3 downto 0);
         QspiCSn : out std_logic;
         
         ----------------------------------------------------------------------
         -- Cellular RAM interface for Slow RAM
         ----------------------------------------------------------------------
         --RamCLK : out std_logic;
         --RamADVn : out std_logic;
         --RamCEn : out std_logic;
         --RamCRE : out std_logic;
         --RamOEn : out std_logic;
         --RamWEn : out std_logic;
         --RamUBn : out std_logic;
         --RamLBn : out std_logic;
         --RamWait : in std_logic;
         --MemDB : inout std_logic_vector(15 downto 0);
         --MemAdr : inout std_logic_vector(22 downto 0);
--         ddr2_addr      : out   std_logic_vector(12 downto 0);
--         ddr2_ba        : out   std_logic_vector(2 downto 0);
--         ddr2_ras_n     : out   std_logic;
--         ddr2_cas_n     : out   std_logic;
--         ddr2_we_n      : out   std_logic;
--         ddr2_ck_p      : out   std_logic_vector(0 downto 0);
--         ddr2_ck_n      : out   std_logic_vector(0 downto 0);
--         ddr2_cke       : out   std_logic_vector(0 downto 0);
--         ddr2_cs_n      : out   std_logic_vector(0 downto 0);
--         ddr2_dm        : out   std_logic_vector(1 downto 0);
--         ddr2_odt       : out   std_logic_vector(0 downto 0);
--         ddr2_dq        : inout std_logic_vector(15 downto 0);
--         ddr2_dqs_p     : inout std_logic_vector(1 downto 0);
--         ddr2_dqs_n     : inout std_logic_vector(1 downto 0);
         
         ----------------------------------------------------------------------
         -- Debug interfaces on Nexys4 board
         ----------------------------------------------------------------------
         led : out std_logic_vector(15 downto 0);
         sw : in std_logic_vector(15 downto 0);
         btn : in std_logic_vector(4 downto 0);

         UART_TXD : out std_logic;
         RsRx : in std_logic;
         
         sseg_ca : out std_logic_vector(7 downto 0);
         sseg_an : out std_logic_vector(7 downto 0)
         );
end container;

architecture Behavioral of container is
  
  signal irq : std_logic := '1';
  signal nmi : std_logic := '1';
  
  signal pixelclock : std_logic;
  signal pixelclock2x : std_logic;
  signal cpuclock : std_logic;
--  signal ioclock : std_logic;
  
  signal segled_counter : unsigned(31 downto 0) := (others => '0');

  signal clock100mhz : std_logic := '0';
  signal clock50mhz : std_logic := '0';

  signal slowram_addr :    std_logic_vector(26 downto 0);
  signal slowram_addr_reflect :    std_logic_vector(26 downto 0);
  signal slowram_we :      std_logic;
  signal slowram_request_toggle :      std_logic;
  signal slowram_done_toggle :      std_logic;
  signal slowram_datain :  std_logic_vector(7 downto 0);
  signal slowram_datain_reflect : std_logic_vector(7 downto 0);
  signal cache_address : std_logic_vector(8 downto 0);
  signal cache_read_data : std_logic_vector(150 downto 0);
  signal ddr_state : unsigned(7 downto 0);
  signal ddr_counter : unsigned(7 downto 0);

  signal vgaredignore : unsigned(3 downto 0);
  signal vgagreenignore : unsigned(3 downto 0);
  signal vgablueignore : unsigned(3 downto 0);
  
  -- XXX We should read the real temperature and feed this to the DDR controller
  -- so that it can update timing whenever the temperature changes too much.
  signal fpga_temperature : std_logic_vector(11 downto 0) := (others => '0');
  
begin
  
  dotclock1: entity work.dotclock
    port map ( clk_in1 => CLK_IN,
               clk_out1 => clock100mhz,
               -- CLK_OUT2 is good for 1920x1200@60Hz, CLK_OUT3___160
               -- for 1600x1200@60Hz
               -- 60Hz works fine, but 50Hz is not well supported by monitors. 
               -- so I guess we will go with an NTSC-style 60Hz display.       
               -- For C64 mode it would be nice to have PAL or NTSC selectable.                    -- Perhaps consider a different video mode for that, or buffering
               -- the generated frames somewhere?
               clk_out2 => pixelclock,
               clk_out3 => cpuclock, -- 48MHz
               PIX2CLOCK => pixelclock2x
--               clk_out3 => ioclock -- also 48MHz
               );

  fpgatemp0: entity work.fpgatemp
    generic map (DELAY_CYCLES => 480)
    port map (
      rst => '0',
      clk => cpuclock,
      temp => fpga_temperature);
  
  ddrwrapper0: entity work.ddrwrapper
    port map (
      -- Common
      cpuclock => cpuclock,
      clk_200MHz_i => pixelclock,
      rst_i => '0',
      device_temp_i => fpga_temperature,
      ddr_state => ddr_state,
      ddr_counter => ddr_counter,
      
      -- RAM interface
      ram_address           => slowram_addr,
      ram_write_data        => slowram_datain,
      ram_address_reflect   => slowram_addr_reflect,
      ram_write_reflect     => slowram_datain_reflect,
      ram_write_enable      => slowram_we,
      ram_request_toggle => slowram_request_toggle,
      ram_done_toggle    => slowram_done_toggle,
      cache_address => cache_address,
      cache_read_data => cache_read_data
      
      -- DDR2 interface
--      ddr2_addr => ddr2_addr,
--      ddr2_ba => ddr2_ba,
--      ddr2_ras_n => ddr2_ras_n,
--      ddr2_cas_n => ddr2_cas_n,
--      ddr2_we_n  => ddr2_we_n ,
--      ddr2_ck_p  => ddr2_ck_p ,
--      ddr2_ck_n  => ddr2_ck_n ,
--      ddr2_cke   => ddr2_cke  ,
--      ddr2_cs_n  => ddr2_cs_n ,
--      ddr2_dm    => ddr2_dm   ,
--      ddr2_odt   => ddr2_odt  ,
--      ddr2_dq    => ddr2_dq   ,
--      ddr2_dqs_p => ddr2_dqs_p,
--      ddr2_dqs_n => ddr2_dqs_n
   );
  
  machine0: entity work.machine
    port map (
      pixelclock      => pixelclock,
      pixelclock2x      => pixelclock2x,
      cpuclock        => cpuclock,
      clock50mhz      => clock50mhz,
--      ioclock         => ioclock, -- 32MHz
--      uartclock         => ioclock, -- must be 32MHz
      uartclock         => cpuclock, -- Match CPU clock (48MHz)
      ioclock         => cpuclock, -- Match CPU clock
      btncpureset => btncpureset,
      irq => irq,
      nmi => nmi,

      no_kickstart => '0',
      ddr_counter => ddr_counter,
      ddr_state => ddr_state,
      
      vsync           => vsync,
      hsync           => hsync,
      vgared(7 downto 4)          => vgared(3 downto 0),
      vgared(3 downto 0) => vgaredignore(3 downto 0),
      vgagreen(7 downto 4)        => vgagreen(3 downto 0),
      vgagreen(3 downto 0) => vgagreenignore(3 downto 0),
      vgablue(7 downto 4)         => vgablue(3 downto 0),
      vgablue(3 downto 0) => vgablueignore(3 downto 0),

      porta_pins => porta_pins,
      portb_pins => portb_pins,
      
      ---------------------------------------------------------------------------
      -- IO lines to the ethernet controller
      ---------------------------------------------------------------------------
      eth_mdio => eth_mdio,
      eth_mdc => eth_mdc,
      eth_reset => eth_reset,
      eth_rxd => eth_rxd,
      eth_txd => eth_txd,
      eth_txen => eth_txen,
      eth_rxer => eth_rxer,
      eth_rxdv => eth_rxdv,
      eth_interrupt => eth_interrupt,
      
      -------------------------------------------------------------------------
      -- Lines for the SDcard interface itself
      -------------------------------------------------------------------------
      cs_bo => sdReset,
      sclk_o => sdClock,
      mosi_o => sdMOSI,
      miso_i => sdMISO,
      card_present => sdCardDetect,
      card_write_prot => '0',

      aclMISO => aclMISO,
      aclMOSI => aclMOSI,
      aclSS => aclSS,
      aclSCK => aclSCK,
      aclInt1 => aclInt1,
      aclInt2 => aclInt2,
    
      micData => micData,
      micClk => micClk,
      micLRSel => micLRSel,

      ampPWM => ampPWM,
      ampSD => ampSD,
    
      tmpSDA => tmpSDA,
      tmpSCL => tmpSCL,
      tmpInt => tmpInt,
      tmpCT => tmpCT,
      
      ps2data =>      ps2data,
      ps2clock =>     ps2clk,

      pmod_clock => jblo(1),
      pmod_start_of_sequence => jblo(2),
      pmod_data_in(1 downto 0) => jblo(4 downto 3),
      pmod_data_in(3 downto 2) => jbhi(8 downto 7),
      pmod_data_out => jbhi(10 downto 9),
      pmoda(3 downto 0) => jalo(4 downto 1),
      pmoda(7 downto 4) => jahi(10 downto 7),

      uart_rx => jclo(1),
      uart_tx => jclo(2),
      
      slowram_we => slowram_we,
      slowram_request_toggle => slowram_request_toggle,
      slowram_done_toggle => slowram_done_toggle,
      slowram_datain => slowram_datain,
      slowram_addr => slowram_addr,
      slowram_addr_reflect => slowram_addr_reflect,
      slowram_datain_reflect => slowram_datain_reflect,
      cache_read_data => cache_read_data,
      cache_address => cache_address,

--      QspiSCK => QspiSCK,
      QspiDB => QspiDB,
      QspiCSn => QspiCSn,

      fpga_temperature => fpga_temperature,
      
      led => led,
      sw => sw,
      btn => btn,

      UART_TXD => UART_TXD,
      RsRx => RsRx,
         
      sseg_ca => sseg_ca,
      sseg_an => sseg_an
      );

  
  -- Hardware buttons for triggering IRQ & NMI
  irq <= not btn(0);
  nmi <= not btn(4);

  -- Generate 50MHz clock for ethernet
  process (clock100mhz) is
  begin
    if rising_edge(clock100mhz) then
      report "50MHz tick";
      clock50mhz <= not clock50mhz;
      eth_clock <= not clock50mhz;
    end if;
  end process;
  
end Behavioral;