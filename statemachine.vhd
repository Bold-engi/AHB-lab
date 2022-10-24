library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
		dmai : out ahd_dma_in_type;
		dmao : in ahd_dma_out_type
	);
end;

architecture structural of state_machine is

	type M_state is (idle, insr_fetch);
	signal current_state, next_state : M_state;	

begin
	comb : process(current_state, HTRANS, dmao.ready) 

	begin 
		
		next_state <= current_state;
		case current_state is
			when idle =>
				HREADY <= '1',
				dmai.start <= '0';
			if HTRANS = '10' then
				dmai.start <= '1';
				next_state <= insr_fetch;
			end if; 
			when instr_fetch =>
				HREADY <= '0',
				dmai.start <= '0';
			if dmao.ready = '1' then
				HREADY <= '1';
				next_state <= idle;
			end if;
		end case;
	end process comb;
	
	seq : process (rstn, clkm) 
	
	begin
		
		if rstn = '1' then
			current_state <= idle;
		elsif falling_edge(clkm) then
			current_state <= next_state;
		end if;
	end process seq;
end architecture structural;
