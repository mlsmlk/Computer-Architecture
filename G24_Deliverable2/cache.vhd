library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
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
end cache;

architecture arch of cache is
--Define states
type states is (idle,c_read,c_write,mm_write,mm_read,mm_wait,writeback);
signal state: states;

-- Define cache
type cacheType is array (0 to 31) of std_logic_vector (154 downto 0);
signal c: cacheType;

begin
process (clock, reset, s_read, s_write, m_waitrequest, state)
	
-- Define properties
	variable word : INTEGER := 0;
	variable address: std_logic_vector (14 downto 0);
	variable offset: INTEGER := 0;
	variable index: INTEGER;
begin
    if(reset = '1') then 
	state <= idle;
    elsif rising_edge(clock) then

	-- 5 bits index
	index := to_integer(unsigned(s_addr(6 downto 2)));
	-- 2 bits offset
	offset := to_integer(unsigned(s_addr(1 downto 0))) + 1;

	case state is
		when idle =>
			s_waitrequest <= '1';
			if s_read = '1' then		--If the request is read
				state <= c_read;		-- switch to cache read state
			elsif s_write = '1' then	--If the request is write
				state <= c_write;		-- switch to cache write state
			else				--If the request is else
				state <= idle;			-- stay in idle state
			end if;	
		
		when c_read =>
			if c(index)(153) = '1' then 	--If the flag is dirty
				state <= mm_write;			-- switch to meory write state
			elsif c(index)(153) = '0' then 	--If the flag is not dirty
				if c(index)(154) = '1'	then --If the flag is valid
					-- If it is a hit
					if c(index)(152 downto 128) = s_addr(31 downto 7) then
						--return the found data, set waitrequest low, switch to idle
						s_readdata <= c(index)(127 downto 0) ((offset * 32) -1 downto 32*(offset-1));
						s_waitrequest <= '0';
						state <= idle; 
					end if;
				else 			--If it is a miss
					state <= mm_read;	--read data from main memory
				end if;
			else					--Continue reading
				state <= c_read;
			end if;

		when c_write =>
			--If flag is not dirty and  flag is valid and it is hit
			if c(index)(153) = '0' and c(index)(154) = '1' and c(index)(152 downto 128) = s_addr (31 downto 7) then
				c(index)(153) <= '1'; 		--Set valid flag to 1
				c(index) (154) <= '1';		--Set dirty flag to 1 since it is modified
				c(index)(127 downto 0)((offset * 32) - 1 downto 32 * (offset - 1)) <= s_writedata; --Write data to given address of cache
				c(index)(152 downto 128) <= s_addr(31 downto 7);  --Set tag of cache to given tag
				s_waitrequest <= '0';			--Set waitrequest low
				state <= idle;				--Writing is done switch back to idle
			else
				state <= writeback;			--It is a miss , write both main memory and cache
			end if;			

		when mm_read =>
			if m_waitrequest = '1' then		--If the main memory is ready for request
				--Get address 
				m_addr <= to_integer(unsigned(s_addr (14 downto 0))) + word;
				m_read <= '1';
				m_write <= '0';
				state <= mm_wait;		--wait until reading process ends
			else
				state <= mm_read;		--wait main memory to be ready
			end if;

		when mm_write =>
			if word = 4 then			--If the word count reaches to the limit (4 word per block)
				word := 0;				--reset the word counter 
				state <= mm_read;			--return reading
			elsif word < 4 and m_waitrequest ='1' then --If the word count has not reached and main memory is ready to receving request
				address := c(index)(135 downto 128) & s_addr (6 downto 0); --Build adress for main memory and prepare necessary variables for writing the data
				m_addr <= to_integer(unsigned (address)) + word;
				m_write <= '1';
				m_read <= '0';
				m_writedata <= c(index)(127 downto 0)((word * 8) + 7 + 32*(offset - 1) downto (word*8) + 32*(offset - 1)); --Write data to main memory
				word := word + 1; --increase counter since one more word is written into main memory
				state <= mm_write; --stay in this state until word limit has reached
			else	--wait until main memory is ready for receving request
				m_write <= '0';	
				state <= mm_write;
			end if;

		when mm_wait =>
			if word < 4 and m_waitrequest = '0' then
				c(index)(127 downto 0)((word * 8) + 7 + 32*(offset - 1) downto (word*8) + 32*(offset - 1)) <= m_readdata; --Write data to main memory
				m_read <= '0';
				if word = 3 then
					word := word + 1;
					state <= mm_wait;
				else
					word := word + 1;
					state <= mm_read;
				end if;
			elsif word = 4 then
				--Write into cache
				c(index)(154) <= '1'; 		--Set valid flag to 1
				c(index) (153) <= '0';		--Set dirty flag to 0 since its modification ends
				s_readdata <= c(index)(127 downto 0)((offset * 32) - 1 downto 32 * (offset - 1)); --return data from given address of cache
				c(index)(152 downto 128) <= s_addr(31 downto 7);  --Set tag of cache to given tag
				word := 0; --reset counter
				m_read <= '0';	-- reset m_read and m_write signals
				m_write <= '0';
				s_waitrequest <= '0';
				state <= idle;		--operation ends switch to idle
			else
				state <= mm_wait; --wait until main memory is available
			end if;


		when writeback =>
			if word = 4 then			--If the word count reaches to the limit (4 word per block)
				word := 0;				--reset the word counter 
				--Write into cache
				c(index)(153) <= '1'; 		--Set valid flag to 1
				c(index) (154) <= '1';		--Set dirty flag to 1 since it is modified
				c(index)(127 downto 0)((offset * 32) - 1 downto 32 * (offset - 1)) <= s_writedata; --Write data to given address of cache
				c(index)(152 downto 128) <= s_addr(31 downto 7);  --Set tag of cache to given tag
				
				s_waitrequest <= '0';		--set waitrequest to low since the process is done
				m_write <= '0';
				state <= idle;			--return reading
			elsif word < 4 and m_waitrequest ='1' then --If the word count has not reached and main memory is ready to receving request
				address := c(index)(135 downto 128) & s_addr (6 downto 0); --Build adress for main memory and prepare necessary variables for writing the data
				m_addr <= to_integer(unsigned (address)) + word;
				m_write <= '1';
				m_read <= '0';
				m_writedata <= c(index)(127 downto 0)((word * 8) + 7 + 32*(offset - 1) downto (word*8) + 32*(offset - 1)); --Write data to main memory
				word := word + 1; --increase counter since one more word is written into main memory
				state <= writeback; --stay in this state until word limit has reached
			else	--wait until main memory is ready for receving request
				m_write <= '0';	
				state <= writeback;
			end if;
	end case;
end if;
end process;			
end arch;