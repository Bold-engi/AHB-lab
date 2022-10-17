entity data_swapper is
  port(
    dmao : in ahb_dma_out_type;
    HRDATA : out std_logic_vector (31 downto 0);
  );
end;
  
architecture sturcture of data_swapper is
  
  
