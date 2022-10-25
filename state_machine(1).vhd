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

entity state_machine is
  port(
    -- Clock and Reset -----------------
    clkm : in std_logic;
    rstn : in std_logic;
    -- AHB DMA records --------------
    dmai : out ahb_dma_in_type;
    dmao : in ahb_dma_out_type;
    -- ARM Cortex-M0 AHB-Lite signals --
    HADDR : in std_logic_vector (31 downto 0);      -- AHB transaction address
    HSIZE : in std_logic_vector (2 downto 0);       -- AHB size: byte, half-word or word
    HTRANS : in std_logic_vector (1 downto 0);      -- AHB transfer: non-sequential only
    HWDATA : in std_logic_vector (31 downto 0);     -- AHB write-data
    HWRITE : in std_logic;                          -- AHB write control
    HREADY : out std_logic                          -- AHB stall signal
    );
end;
architecture structural of state_machine is
    type type_state is (IDLE,INSTR_FETCH);
    signal current_state,next_state: type_state;

begin
  ---------three steps of FSM --------------

--------transfer logic------------------
    process(clkm,rstn)begin
        if(clkm'event and clkm='1')then
            if(rstn='0')then
                current_state <= IDLE;
            else
                current_state <= next_state;
    	    end if;
    	end if;
    end process;
       ---------next logic------------
    process(current_state,HTRANS,dmao.ready)begin
        case current_state is
        when IDLE =>
                if(htrans="10")then
                next_state <= INSTR_FETCH;
                else
                next_state <= IDLE;
                end if;
        when INSTR_FETCH =>
                if(dmao.ready='1')then
                next_state <= IDLE;
                else
                next_state <= INSTR_FETCH;
                end if;
        when OTHERS  =>
                next_state <= IDLE;
        end case;
    end process; 
       