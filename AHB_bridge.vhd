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

entity AHB_bridge is
  port(
    --------------------------------------
    -- CLOCK AND RESETS ------------------
    --------------------------------------
    clkm : in std_logic;
    rstn : in std_logic;
    -------------------------------------
    -- AHB Master records ---------------
    -------------------------------------
    ahbmi : in ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    --------------------------------------------
    ----The signals of AHB Lite of Cortex-M0----
    --------------------------------------------
    HADDR : in std_logic_vector (31 downto 0);          -- AHB address of the transaction
    HSIZE : in std_logic_vector (2 downto 0);           -- AHB size : byte, half-word or word
    HTRANS : in std_logic_vector (1 downto 0);          -- AHB transfer: non-sequential only
    HWDATA : in std_logic_vector (31 downto 0);         -- AHB write-data
    HWRITE : in std_logic;                              -- AHB write control
    HRDATA : out std_logic_vector (31 downto 0);        -- AHB read-data
    HREADY : out std_logic                              -- AHB stall signal
    );
end;                                                    ----The interface corresponding to the interface in Figure 1 from the lab manual and the properties

architecture structural of AHB_bridge is
--------------------------------------------------
--declare a component for state_machine-----------
--------------------------------------------------
  component state_machine is
    port(
    ------------------------------------
    -- Clock and Reset -----------------
    ------------------------------------
    clkm : in std_logic;
    rstn : in std_logic;
    ---------------------------------
    -- AHB DMA records --------------
    ---------------------------------
    dmai : out ahb_dma_in_type;
    dmao : in ahb_dma_out_type;
    ------------------------------------
    --Cortex-M0 AHB-Lite signals -------
    ------------------------------------
    HADDR : in std_logic_vector (31 downto 0);         -- AHB transaction address
    HSIZE : in std_logic_vector (2 downto 0);          -- AHB size: byte, half-word or word
    HTRANS : in std_logic_vector (1 downto 0);         -- AHB transfer: non-sequential only
    HWDATA : in std_logic_vector (31 downto 0);        -- AHB write-data
    HWRITE : in std_logic;                             -- AHB write control
    HREADY : out std_logic                             -- AHB stall signal
    );
  end component; 

  ---------------------------------------
  --declare a component for data_swapper-
  ---------------------------------------
  component data_swapper is
    port(
    ------------------------------------  
    -- AHB Master records --------------
    ------------------------------------
    dmao : in ahb_dma_out_type;
    ------------------------------------
    -- ARM Cortex-M0 AHB-Lite signals --
    ------------------------------------
    HRDATA : out std_logic_vector (31 downto 0)        -- AHB read-data
    );
  end component; 
  
  ----------------------------------------- 
  --declare a component for ahbmst---------
  -----------------------------------------
  component ahbmst is
    port(
    ------------------------------------  
    -- Clock and Reset -----------------
    ------------------------------------
    clk : in std_logic;
    rst : in std_logic;
    ------------------------------------
    -- AHB Master records --------------
    ------------------------------------
    ahbi : in ahb_mst_in_type;
    ahbo : out ahb_mst_out_type;
    ---------------------------------
    -- AHB DMA records --------------
    ---------------------------------
    dmai : in ahb_dma_in_type;
    dmao : out ahb_dma_out_type
    );
  end component;

signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;

--------------------------------------------
--Establishing the state_machine connection-
--------------------------------------------
begin
  MODEL1: state_machine
    port map (
      clkm => clkm,
      rstn => rstn,
      dmai => dmai,
      dmao => dmao,
      HADDR => HADDR,
      HSIZE => HSIZE,
      HTRANS => HTRANS,
      HWDATA => HWDATA,
      HWRITE => HWRITE,
      HREADY => HREADY
    );
--------------------------------------------
--Establishing the data_swapper connection--
--------------------------------------------
  MODEL2: data_swapper
    port map (
      dmao => dmao,
      HRDATA => HRDATA
    );
--------------------------------------------
--Establishing the ahbmst connection--------
--------------------------------------------    
  MODEL3: ahbmst
    port map (
      clk => clkm,
      rst => rstn,
      ahbi => ahbmi,
      ahbo => ahbmo,
      dmai => dmai,
      dmao => dmao
    );
    
end structural;



    




  
  
  
  

   

