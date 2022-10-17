entity data_swapper is
  port(
    -- ARM Cortex M0 signals ----
    HRDATA : out std_logic_vector(31 downto o);
    -- AHB Master records -------
    dmao   : in ahb_dma_out_type;
    );
end;
  
architecture structure of data_swapper is

begin

  seq: process(dmao)
  -- Swapper own use --------------------------
  variable Swpdata  := std_logic_vector(31 downto 0);
  
  -- Directly reads from ahbmst ---------------
  variable hrdata   := std_logic_vector(31 downto 0);
  begin
  
  hrdata := dmao.rdata(31 downto 0);
  
  Swpdata(7  downto 0)  <= hrdata(31 downto 24); -- Byte 3 to Byte 0
  Swpdata(15 downto 8)  <= hrdata(23 downto 16); -- Byte 2 to Byte 1
  Swpdata(23 downto 16) <= hrdata(15 downto 8);  -- Byte 1 to Byte 2
  Swpdata(31 downto 24) <= hrdata(7  downto 0);  -- Byte 0 to Byte 3
  
  HRDATA <= Swpdata;
  
  end process;
end;
