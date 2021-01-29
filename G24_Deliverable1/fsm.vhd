library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Do not modify the port map of this structure
entity comments_fsm is
port (clk : in std_logic;
      reset : in std_logic;
      input : in std_logic_vector(7 downto 0);
      output : out std_logic
  );
end comments_fsm;

architecture behavioral of comments_fsm is

-- The ASCII value for the '/', '*' and end-of-line characters
constant SLASH_CHARACTER : std_logic_vector(7 downto 0) := "00101111";
constant STAR_CHARACTER : std_logic_vector(7 downto 0) := "00101010";
constant NEW_LINE_CHARACTER : std_logic_vector(7 downto 0) := "00001010";
type STATES is (IDLE,STATE_1,STATE_2,STATE_3,STATE_4,FINAL);
signal state: STATES;

begin

-- Insert your processes here
process (clk, reset)
begin
    if(reset = '1') then 
	state <= IDLE;
    elsif rising_edge(clk) then
	case state is
		when IDLE =>
			if input = SLASH_CHARACTER then
				state <= STATE_1;
				output <= '0';
			else
				state <= IDLE;
				output <= '0';
			end if;
		when STATE_1 => 
			if input = SLASH_CHARACTER then
				state <= STATE_2;
				output <= '0';
			elsif input = STAR_CHARACTER then
				state <= STATE_3;
				output <= '0';
			else 
				state <= IDLE;
				output <= '0';
			end if;
		when STATE_2 =>
			if input = NEW_LINE_CHARACTER then
				state <= FINAL;
				output <= '1';
			else
				state <= STATE_2;
				output <= '1';
			end if;
		when STATE_3 =>
			if input = STAR_CHARACTER  then
				state <= STATE_4;
				output <= '1';
			else 
				state<= STATE_3;
				output <= '1';
			end if;
		when STATE_4 =>
			if input = SLASH_CHARACTER then 
				state <= FINAL;
				output <= '1';
			elsif input = STAR_CHARACTER  then
				state <= STATE_4;
				output <= '1';
			else
				state <= STATE_3;
				output <= '1';
			end if;
		when  FINAL =>
			state <= IDLE;
end case;

end if;

end process;

end behavioral;