library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_tb is
end cache_tb;

architecture behavior of cache_tb is

component cache is
generic(
    ram_size : INTEGER := 32768
);
port(
    clock : in std_logic;
    reset : in std_logic;

    -- Avalon interface --
    s_addr : in std_logic_vector (31 downto 0);
    s_read : in std_logic;
    s_readdata : out std_logic_vector (31 downto 0);
    s_write : in std_logic;
    s_writedata : in std_logic_vector (31 downto 0);
    s_waitrequest : out std_logic; 

    m_addr : out integer range 0 to ram_size-1;
    m_read : out std_logic;
    m_readdata : in std_logic_vector (7 downto 0);
    m_write : out std_logic;
    m_writedata : out std_logic_vector (7 downto 0);
    m_waitrequest : in std_logic
);
end component;

component memory is 
GENERIC(
    ram_size : INTEGER := 32768;
    mem_delay : time := 10 ns;
    clock_period : time := 1 ns
);
PORT (
    clock: IN STD_LOGIC;
    writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    address: IN INTEGER RANGE 0 TO ram_size-1;
    memwrite: IN STD_LOGIC;
    memread: IN STD_LOGIC;
    readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    waitrequest: OUT STD_LOGIC
);
end component;
	
-- test signals 
signal reset : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal s_addr : std_logic_vector (31 downto 0);
signal s_read : std_logic;
signal s_readdata : std_logic_vector (31 downto 0);
signal s_write : std_logic;
signal s_writedata : std_logic_vector (31 downto 0);
signal s_waitrequest : std_logic;

signal m_addr : integer range 0 to 2147483647;
signal m_read : std_logic;
signal m_readdata : std_logic_vector (7 downto 0);
signal m_write : std_logic;
signal m_writedata : std_logic_vector (7 downto 0);
signal m_waitrequest : std_logic; 

begin

-- Connect the components which we instantiated above to their
-- respective signals.
dut: cache 
port map(
    clock => clk,
    reset => reset,

    s_addr => s_addr,
    s_read => s_read,
    s_readdata => s_readdata,
    s_write => s_write,
    s_writedata => s_writedata,
    s_waitrequest => s_waitrequest,

    m_addr => m_addr,
    m_read => m_read,
    m_readdata => m_readdata,
    m_write => m_write,
    m_writedata => m_writedata,
    m_waitrequest => m_waitrequest
);

MEM : memory
port map (
    clock => clk,
    writedata => m_writedata,
    address => m_addr,
    memwrite => m_write,
    memread => m_read,
    readdata => m_readdata,
    waitrequest => m_waitrequest
);
				

clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process : process
begin

-- put your tests here
	
-- 1. Invalid, dirty, read, hit	(Invalid^hit==>impossible)
-- 2. Invalid, dirty, read, miss	(Invalid^dirty==>impossible)
-- 3. Invalid, dirty, write, hit	(Invalid^hit==>impossible)
-- 4. Invalid, dirty, write, miss(Invalid^dirty==>impossible)
-- 5. Invalid, clean, read, hit	(Invalid^hit==>impossible)
-- 6. Invalid, clean, read, miss
	s_addr <= "00000000000000000000000000000001";                        
	s_read <= '1';                                                       
	s_write <= '0';                                                      
	wait until rising_edge(s_waitrequest);                               
	s_read <= '0';                                                       
	s_write <= '0'; 
	wait for clk_period;

-- 7. Invalid, clean, write, hit	(Invalid^hit==>impossible)
-- 8. Invalid, clean, write, miss
	s_addr <= "00000000000000000000000000001000";
	s_read <= '0';
	s_write <= '1';
	s_writedata <= x"000000BC";
	wait until rising_edge(s_waitrequest);
	s_read <= '0';
	s_write <= '0';
	wait for clk_period;
	
-- 9. Valid, clean, read, hit
	s_addr <= "00000000000000000000111111111111";                        
	s_write <= '1';                                                      
	s_writedata <= x"000F000A";                                          
	wait until rising_edge(s_waitrequest);                               
	s_read <= '1';                                                       
	s_write <= '0';                                                      
	wait until rising_edge(s_waitrequest);                               
	s_read <= '0';                                                       
	s_write <= '0'; 
	wait for clk_period;

-- 10. Valid, clean, read, miss
	s_addr <= "00000000000000000000000000001010";	
	s_read <= '0';   
	s_writedata <= x"000D000C";
	s_write <= '1';                                                      
	wait until rising_edge(s_waitrequest);  
	s_addr <= "00000000000000000000000010001010";
	s_read <= '1';
	s_write <= '0';
	wait until rising_edge(s_waitrequest);                               
	s_read <= '0';                                                       
	s_write <= '0'; 
	wait for clk_period;
	

-- 11. Valid, clean, write, hit
	s_addr <= "00000000000000000000000000001011";	
	s_read <= '0';                         
	s_writedata <= x"000F000C";
	s_write <= '1';                                                      
	wait until rising_edge(s_waitrequest);                               
	s_write <= '1';
	s_read <= '0';
	s_writedata <= x"0000000B";
	wait until rising_edge(s_waitrequest);                               
	s_write <= '0';
	s_read <= '0';
	wait for clk_period;

-- 12. Valid, clean, write, miss
	s_addr <= "00000000000000000000000000001101";	
	s_read <= '0';                         
	s_writedata <= x"000F000C";
	s_write <= '1';                                                      
	wait until rising_edge(s_waitrequest); 
	s_addr <= "00000000000000000000100000001101";
	s_write <= '1';
	s_read <= '0';
	s_writedata <= x"0000000B";
	wait until rising_edge(s_waitrequest);                               
	s_write <= '0';
	s_read <= '0';
	wait for clk_period;

-- 13. Valid, dirty, read, hit
	s_addr <= "00000000000000000000000000001100";
	s_read <= '0';   
	s_writedata <= x"000F00BC";
	s_write <= '1'; 
	wait until rising_edge(s_waitrequest); 
	s_read <= '0';   
	s_writedata <= x"000F00BA";
	s_write <= '1'; 
	wait until rising_edge(s_waitrequest); 	-- write hit, dirty
	s_read <= '1';
	s_write <= '0';
	wait until rising_edge(s_waitrequest); 
	s_write <= '0';
	s_read <= '0';
	wait for clk_period;

-- 14. Valid, dirty, read, miss
	s_addr <= "00000000000000000000000000001110";
	s_read <= '0';   
	s_writedata <= x"000F00BF";
	s_write <= '1';
	wait until rising_edge(s_waitrequest); 
	s_read <= '0';   
	s_writedata <= x"000F00BF";
	s_write <= '1';
	wait until rising_edge(s_waitrequest); 
	s_addr <= "00000000000000000000000010001110";
	s_read <= '1';
	s_write <= '0';
	wait until rising_edge(s_waitrequest); 
	s_write <= '0';
	s_read <= '0';
	wait for clk_period;	

-- 15. Valid, dirty, write, hit
	s_addr <= "00000000000000000000000000001111";
	s_read <= '0';   
	s_writedata <= x"000000BD";
	s_write <= '1'; 
	wait until rising_edge(s_waitrequest); 
	s_read <= '0';   
	s_writedata <= x"000F00BA";
	s_write <= '1'; 
	wait until rising_edge(s_waitrequest); 	-- write hit, dirty
	s_read <= '0';
	s_writedata <= x"000000BA";	-- write hit on the dirty
	s_write <= '1';
	wait until rising_edge(s_waitrequest); 
	s_write <= '0';
	s_read <= '0';
	wait for clk_period;

-- 16. Valid, dirty, write, miss
	s_addr <= "00000000000000000000000000001111";
	s_read <= '0';   
	s_writedata <= x"000000BD";
	s_write <= '1'; 
	wait until rising_edge(s_waitrequest); 
	s_read <= '0';   
	s_writedata <= x"000F00BA";
	s_write <= '1'; 
	wait until rising_edge(s_waitrequest); 	
	s_addr <= "00000000000000000000011000001111";
	s_read <= '0';
	s_writedata <= x"000FF0BA";
	s_write <= '1'; 
	wait until rising_edge(s_waitrequest); 
	s_write <= '0';
	s_read <= '0';
	wait for clk_period;
	
end process;
	
end;