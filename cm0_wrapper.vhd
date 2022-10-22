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

entity cm0_wrapper is
  port(
    -- Clock and Reset --------------------------
    clkm : in std_logic;
    rstn : in std_logic;
    -- AHB Master records (signals)--------------
    ahbmi : in ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    --debug led processor interface--------------
    cm0_led : out std_logic                                                     
    );
end;

architecture structural of cm0_wrapper is
-- component detectorbus can be used to test your implementation (declare a component for cortex m0)
COMPONENT CORTEXM0DS is
	PORT(
------------------------------------
----------- a component for AHB-LITE
------------------------------------
  -- CLOCK AND RESETS ------------------
  --input  wire        HCLK,              
  -- Clock
  --input  wire        HRESETn,           
  -- Asynchronous reset
  HCLK : IN std_logic;                                   -- Clock
  HRESETn : IN std_logic;                                -- Asynchronous reset
  --------------------------------------
  -- AHB-LITE MASTER PORT --------------
  --------------------------------------
  HADDR : OUT std_logic_vector (31 downto 0);            -- AHB  transaction address(output wire [31:0] HADDR)
  HBURST : OUT std_logic_vector (2 downto 0);            -- AHB  burst: tied to single(output wire [ 2:0] HBURST)
  HMASTLOCK : OUT std_logic;                             -- AHB  locked transfer (always zero)(output wire HMASTLOCK)
  HPROT : OUT std_logic_vector (3 downto 0);             -- AHB  protection: priv; data or inst(output wire [ 3:0] HPROT)
  HSIZE : OUT std_logic_vector (2 downto 0);             -- AHB  size: byte, half-word or word(output wire [ 2:0] HSIZE)
  HTRANS : OUT std_logic_vector (1 downto 0);            -- AHB  transfer: non-sequential only(output wire [ 1:0] HTRANS)
  HWDATA : OUT std_logic_vector (31 downto 0);           -- AHB  write-data(output wire [31:0] HWDATA)
  HWRITE : OUT std_logic;                                -- AHB  write control(output wire HWRITE)
  HRDATA : IN std_logic_vector (31 downto 0);            -- AHB  read-data(input  wire [31:0] HRDATA)
  HREADY : IN std_logic;                                 -- AHB  stall signal(input wire HREADY)
  HRESP : IN std_logic;                                  -- AHB  error response(input wire HRESP)
  -- MISCELLANEOUS ---------------------
  --input  wire        NMI,               -- Non-maskable interrupt input
  --input  wire [15:0] IRQ,               -- Interrupt request inputs
  --output wire        TXEV,              -- Event output (SEV executed)
  --input  wire        RXEV,              -- Event input
  --output wire        LOCKUP,            -- Core is locked-up
  --output wire        SYSRESETREQ,       -- System reset request
  NMI : IN std_logic;                                    -- Non-maskable interrupt input
  IRQ : IN std_logic_vector (15 downto 0);               -- Interrupt request inputs
  TXEV : OUT std_logic;                                  -- Event output (SEV executed)
  RXEV : IN std_logic;                                   -- Event input
  LOCKUP : OUT std_logic;                                -- Core is locked-up
  SYSRESETREQ : OUT std_logic;                           -- System reset request

  -- POWER MANAGEMENT ------------------
                                                         --output wire SLEEPING                          
                                                         -- Core and NVIC sleeping
  SLEEPING : OUT std_logic                               -- Core and NVIC sleeping
);
END COMPONENT;                                           ---all come from cm0-dssystem file

-------------------------------------
--declare a component for DetectorBus
-------------------------------------
component DetectorBus is
    Port ( Clock : in  STD_LOGIC;
           DataBus : in  STD_LOGIC_VECTOR (31 downto 0);
           Detector : out  STD_LOGIC);
end component;                                           ---all come from cm0-dssystem file
------------------------------------
--------- a component for AHB-BRIDGE
------------------------------------
  component AHB_bridge is
  port(
    -- CLOCK AND RESETS ------------------
    clkm : in std_logic;
    rstn : in std_logic;
    -- AHB Master records --------------
    ahbmi : in ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    ----The signals of AHB Lite of Cortex-M0----
    HADDR : in std_logic_vector (31 downto 0);          -- AHB address of the transaction
    HSIZE : in std_logic_vector (2 downto 0);           -- AHB size : byte, half-word or word
    HTRANS : in std_logic_vector (1 downto 0);          -- AHB transfer: non-sequential only
    HWDATA : in std_logic_vector (31 downto 0);         -- AHB write-data
    HWRITE : in std_logic;                              -- AHB write control
    HRDATA : out std_logic_vector (31 downto 0);        -- AHB read-data
    HREADY : out std_logic                              -- AHB stall signal
    );
  end component;                                        ----The interface corresponding to the interface in Figure 1 from the lab manual and the properties

signal dummy : STD_LOGIC_VECTOR (2 downto 0);
signal HRData_1 : std_logic_vector (31 downto 0);
signal HWData_1 : std_logic_vector (31 downto 0);
signal HADDR_1 : std_logic_vector (31 downto 0);
signal HBurst_1 : std_logic_vector (2 downto 0);
signal HProt_1 : std_logic_vector (3 downto 0);
signal HSize_1 : std_logic_vector (2 downto 0);
signal HTrans_1 : std_logic_vector (1 downto 0);
signal HWrite_1 : std_logic_vector (0 downto 0);
signal Clock_1 : std_logic;
signal none_1 : std_logic_vector (1 downto 0);         ---all come from cm0-dssystem file 
----To differentiate it from the signals in the file dssystem, our group number(1) has been added to the end of each signal to show the difference.

signal led_value:std_logic;
signal Led1:std_logic;
signal Led2:std_logic;   

begin
cm0_led <= led_value;

------------------------------------------------------------
---Start the CORTEXM0DS component and establish a connection
------------------------------------------------------------
Processor : CORTEXM0DS	port map (
	-- CLOCK AND RESETS ------------------
  HCLK => Clock,                       -- Clock
  HRESETn => SyncResetPulse,           -- Asynchronous reset
----------------------------------------
-- AHB-LITE MASTER PORT ----------------
----------------------------------------
  HADDR => HADDR_1(31 downto 0),             -- AHB transaction address
  HBURST => HBurst_1(2 downto 0),            -- AHB burst: tied to single
  HMASTLOCK => dummy_1(0),                   -- AHB locked transfer (always zero)
  HPROT => HProt_1 (3 downto 0),             -- AHB protection: priv; data or inst
  HSIZE => HSize_1(2 downto 0),              -- AHB size: byte, half-word or word
  HTRANS => HTrans_1 (1 downto 0),           -- AHB transfer: non-sequential only
  HWDATA => HWData_1(31 downto 0),           -- AHB write-data
  HWRITE => HWrite_1(0),                     -- AHB write control
  HRDATA => HRData_1(31 downto 0),           -- AHB read-data
  HREADY => HREADY_1,                        -- AHB stall signal
  HRESP => '0',                              -- AHB error response
  --------------------------------------
  -- MISCELLANEOUS ---------------------
  --------------------------------------
  NMI => '0',                                -- Non-maskable interrupt input
  IRQ => "0000000000000000",                 --Interrupciones(15 downto 0), Interrupt request inputs
  TXEV => dummy(1),                          -- Event output (SEV executed)
  RXEV => '0',                               -- Event input
  LOCKUP => Led2,                            -- Core is locked-up
  SYSRESETREQ => dummy(2),                   -- System reset request

  -- POWER MANAGEMENT ------------------
  SLEEPING => Led1                           -- Core and NVIC sleeping
	);
---all come from cm0-dssystem file
----------------------------------------------------------   
--Enabling the AHB bridge component and making connections
----------------------------------------------------------
 AHB_bridge1: AHB_bridge
    port map (
      clkm => clkm,
      rstn => rstn,
      ahbmi => ahbmi,
      ahbmo => ahbmo,
      HADDR => HADDR_1,
      HSIZE => HSIZE_1,
      HTRANS => HTRANS_1,
      HWDATA => HWDATA_1,
      HWRITE => HWRITE_1(0),
      HRDATA => HRDATA_1,
      HREADY => HREADY_1                            --------The interface corresponding to the interface in Figure 1 from the lab manual and the properties.
    );
                                                    --------Detector
  Inst_Detector: DetectorBus 
    Port map ( Clock => clkm,
           DataBus => HRDATA_1,
           Detector => led_value);
           
end structural;

              

  












