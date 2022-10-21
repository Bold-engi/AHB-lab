entity data_swapper is
  port(
    -- ARM Cortex M0 signals ----
    HRDATA : out std_logic_vector(31 downto o);
    -- State Machine signals ----
    HREADY : in std_logic;
    -- AHB Master records -------
    dmao   : in ahb_dma_out_type;
    );
end;
  
architecture structure of data_swapper is

begin

  comb: process(dmao)

  variable ready    := std_ulogic;
  variable hready   := std_logic;                       -- HREADY from state machine

  variable swpdata  := std_logic_vector(31 downto 0);
  variable hrdata   := std_logic_vector(31 downto 0);   -- data from ahbmst
  begin
  
  ready := '0'; ready := dmao.ready;
  hready:= '0'; hready:= HREADY;
  
  if ready = '1' then
    hrdata := dmao.rdata(31 downto 0);
  
    swpdata(7  downto 0)  <= hrdata(31 downto 24); -- Byte 3 to Byte 0
    swpdata(15 downto 8)  <= hrdata(23 downto 16); -- Byte 2 to Byte 1
    swpdata(23 downto 16) <= hrdata(15 downto 8);  -- Byte 1 to Byte 2
    swpdata(31 downto 24) <= hrdata(7  downto 0);  -- Byte 0 to Byte 3
  end if;
    
  if hready = '1' then
    HRDATA <= swpdata;
  end if;
    
  end process;
end;
