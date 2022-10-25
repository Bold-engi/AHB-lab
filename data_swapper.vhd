library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
library UNISIM;
use UNISIM.VComponents.all;

entity data_swapper is
  port(
    -- AHB Master records --------------
    dmao : in ahb_dma_out_type;
    -- ARM Cortex-M0 -------------------
    HRDATA : out std_logic_vector (31 downto 0)
    );
end;

architecture structural of data_swapper is

begin

  byte_swap: process(dmao)
  begin
    HRDATA( 7 downto  0) <= dmao.rdata(31 downto 24); -- Byte 3 to Byte 0
    HRDATA(15 downto  8) <= dmao.rdata(23 downto 16); -- Byte 2 to Byte 1
    HRDATA(23 downto 16) <= dmao.rdata(15 downto  8); -- Byte 1 to Byte 2
    HRDATA(31 downto 24) <= dmao.rdata( 7 downto  0); -- Byte 0 to Byte 3
  end process;

end structural;
