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
    -- Clock and Reset-----------------------
		clkm : in std_logic;
		rstn : in std_logic;
		-- ARM Cortex-M0 AHB-Lite signals -------
		HADDR : in std_logic_vector (31 downto 0);
		HSIZE : in std_logic_vector (2 downto 0);
		HTRANS : in std_logic_vector (1 downto 0);
		HWDATA : in std_logic_vector (31 downto 0);
		HWRITE : in std_logic;
		HREADY : out std_logic;
		-- AHB Master records (signals)----------
		dmai : out ahb_dma_in_type;
		dmao : in ahb_dma_out_type
	);
end;

architecture structural of state_machine is

	type M_state is (idle, instr_fetch);
	signal current_state, next_state : M_state;
	signal htrans : std_logic_vector (1 downto 0);

begin
  
 	seq : process (rstn, clkm) 
	begin
		if rstn = '1' then
			current_state <= idle;
		elsif falling_edge(clkm) then
			current_state <= next_state;
		end if;
	end process seq;
  
	comb : process(current_state, HTRANS, dmao) 
	variable M_dmai : std_ulogic;
	variable M_dmao : std_ulogic;
	variable hready : std_logic;

	begin 
		M_dmai := '0' ; dmai.start <= M_dmai;
		M_dmao := '0' ; M_dmao := dmao.ready;
		HREADY <= hready;
		htrans <= HTRANS;
		
		next_state <= current_state;
		case current_state is
			when idle =>
				hready <= '1';
				M_dmai := '0';
				if htrans = "10" then
					M_dmai := '1';
					next_state <= instr_fetch;
				end if; 
			when instr_fetch =>
				hready <= '0';
				M_dmai := '0';
				if M_dmao = '1' then
					hready <= '1';
					next_state <= idle;
				end if;
		end case;
	end process comb;
	

end architecture structural;
