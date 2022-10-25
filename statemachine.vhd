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
	signal state : M_state;

begin
  	process (rstn, clkm) 
	variable M_dmao : std_ulogic;
	variable htrans : std_logic_vector (1 downto 0);
	begin
		M_dmao := '0' ; M_dmao := dmao.ready;
		htrans := HTRANS;
		if rstn = '1' then
			state <= idle;
		elsif rising_edge(clkm) then
			case state is
				when idle =>
					if htrans = "10" then
						state <= instr_fetch;
					else
						state <= idle;
					end if;
				when instr_fetch;
					if M_dmao = '1' then
						state <= idle;
					else 
						state <= instr_fetch;
					end if;
			end case;
		end if;
	end process;
	-- output from the state--------------------------------------		
	process (state)
	variable M_dmai : std_ulogic;
	variable M_dmao : std_ulogic;
	variable hready : std_logic;
	begin
		M_dmai := '0' ; dmai.start <= M_dmai;
		M_dmao := '0' ; M_dmao := dmao.ready;
		HREADY <= hready;
		case state is
			when idle =>
				hready := '1';
				M_dmai := '0';
				if htrans = "10" then
					M_dmai := '1';
				else 
					M_dmai := '0';
				end if;
			when instr_fetch =>
				hready := '0';
				M_dmai := '0';
				if M_dmao = '1' then
					hready := '1';
				else
					hready := '0';
				end if;
		end case;
	end process;
end architecture structural;
