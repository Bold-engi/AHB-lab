entity data_swapper is
  port(
    -- ARM Cortex M0 signals ----
    HRDATA : out std_logic_vector (31 downto o);
    -- AHB Master records -------
    dmao : in ahb_dma_out_type;
    );
 end;
  
