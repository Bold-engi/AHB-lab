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

-- Define the ports of state_machine -----
entity state_machine is
  port(
    -- Clock and Reset -----------------
    clkm : in std_logic;
    rstn : in std_logic;
    -- AHB DMA records -----------------
    dmai : out ahb_dma_in_type;
    dmao : in ahb_dma_out_type;
    -- ARM Cortex-M0 AHB-Lite signals --
    HADDR : in std_logic_vector (31 downto 0); -- AHB transaction address
    HSIZE : in std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
    HTRANS : in std_logic_vector (1 downto 0); -- AHB transfer: non-sequential only
    HWDATA : in std_logic_vector (31 downto 0); -- AHB write-data
    HWRITE : in std_logic; -- AHB write control
    HREADY : out std_logic -- AHB stall signal
    );
end;
  
architecture structural of state_machine is
    type state_type is (IDLE,INSTR_FETCH);
    signal curr_st,next_st: state_type;

begin
-------------------------------
--Finite State Machine
-------------------------------

    -- tranfer logic
    process(clkm,rstn)begin
        if(clkm'event and clkm='1')then  -- state transfer when clock is on rising edge 
            if(rstn='0')then             -- reset the state machine
                curr_st <= IDLE;
            else
                curr_st <= next_st;
    	    end if;
    	end if;
    end process;

    -- next logic
    process(curr_st,HTRANS,dmao.ready)begin
        case curr_st is
        -- Different states of FSM -----
        when IDLE =>
                if(htrans="10")then
                next_st <= INSTR_FETCH;
                else
                next_st <= IDLE;
                end if;
        when INSTR_FETCH =>
                if(dmao.ready='1')then
                next_st <= IDLE;
                else
                next_st <= INSTR_FETCH;
                end if;
        when OTHERS  =>
                next_st <= IDLE;
        end case;
    end process;

    -- output logic
    process(curr_st,next_st)begin
        if(curr_st=IDLE and next_st=INSTR_FETCH)then
            dmai.start <= '1';
        else 
            dmai.start <= '0';
        end if;
        if(curr_st=INSTR_FETCH and next_st=INSTR_FETCH)then
            HREADY <= '0';
        else 
            HREADY <= '1';
        end if;
    end process;

    -- connect logic
    process(HADDR)begin
        dmai.address <= HADDR;
    end process;
    
    process(HSIZE)begin
        dmai.size <= HSIZE;
    end process;
    
    process(HWDATA)begin
        dmai.wdata <= HWDATA;
    end process;

    process(HWRITE)begin
        dmai.write <= HWRITE;
    end process;

    dmai.burst <= '0';
    dmai.busy  <= '0';
    dmai.irq   <= '0';

end structural;


