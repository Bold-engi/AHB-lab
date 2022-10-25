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

architecture structrual of state_machine is

  type M_state is (idle, instr_fetch);

  signal current_state, next_state : M_state;

  signal HTrans : std_logic_vector (1 downto 0);
  signal HReady : std_logic;

begin
   port map(
   HTRANS => HTrans;
   HREADY => HReady
   );
  
   seq : process (clkm, rstn, next_state) 
   begin
	if rstn = '1' then
		current_state <= idle;
	elsif rising_edge(clkm) then
		current_state <= next_state;
	end if;
   end process seq;
		
   comb : process()
   begin
   case current_state is
	when idle =>
	   
