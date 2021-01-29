LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY fsm_tb IS
END fsm_tb;

ARCHITECTURE behaviour OF fsm_tb IS

COMPONENT comments_fsm IS
PORT (clk : in std_logic;
      reset : in std_logic;
      input : in std_logic_vector(7 downto 0);
      output : out std_logic
  );
END COMPONENT;

--The input signals with their initial values
SIGNAL clk, s_reset, s_output: STD_LOGIC := '0';
SIGNAL s_input: std_logic_vector(7 downto 0) := (others => '0');

CONSTANT clk_period : time := 1 ns;
CONSTANT SLASH_CHARACTER : std_logic_vector(7 downto 0) := "00101111";
CONSTANT STAR_CHARACTER : std_logic_vector(7 downto 0) := "00101010";
CONSTANT NEW_LINE_CHARACTER : std_logic_vector(7 downto 0) := "00001010";

BEGIN
dut: comments_fsm
PORT MAP(clk, s_reset, s_input, s_output);

 --clock process
clk_process : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR clk_period/2;
	clk <= '1';
	WAIT FOR clk_period/2;
END PROCESS;
 
--TODO: Thoroughly test your FSM
stim_process: PROCESS
BEGIN    
	REPORT "Example case, reading a meaningless character";
	s_input <= "01011000";
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "When reading a meaningless character, the output should be '0'" SEVERITY ERROR;
	REPORT "_______________________";

-- ASCII of / * \n	
-- SLASH: 00101111
-- STAR: 00101010
-- NEW_LINE: 00001010
   
-- Test cases: "r" represents random character
-- Test case 1: //random character\n

	REPORT "Test case 1: //r\n";
	REPORT "Accumulated input: /";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: / | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 1: Accumulated input: //";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: // | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 1: Accumulated input: //r";	
	s_input <= "01011000";	--r
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: //r | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 1: Accumulated input: //r\n";
	s_input <= "00001010";	--\n
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: //r\n | output: 1" SEVERITY ERROR;
	REPORT "_______________________";
	
-- Test case 2: //\n

	WAIT FOR 1 * clk_period;
	REPORT "Test case 2: //\n";
	REPORT "Accumulated input: /";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: / | output: 0" SEVERITY ERROR;
	WAIT FOR 1 * clk_period;
	
	REPORT "Test case 2: Accumulated input: //";
	s_input <= "00101111";	--//
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: // | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 2: Accumulated input: //\n";
	s_input <= "00001010";	--\n
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: //\n | output: 1" SEVERITY ERROR;
	REPORT "_______________________";
	
-- Test case 3: /*random character*/

	REPORT "Test case 3: /*r*/";
	REPORT "Accumulated input: /";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: / | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 3: Accumulated input: /*";
	s_input <= "00101010";	--*
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: /* | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 3: Accumulated input: /*r";	
	s_input <= "01011000";	--r
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /*r | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 3: Accumulated input: /*r*";
	s_input <= "00101010";	--*
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /*r* | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 3: Accumulated input: /*r*/";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /*r*/ | output: 1" SEVERITY ERROR;
	REPORT "_______________________";
	
-- Test case 4: /**/

	REPORT "Test case 4: /**/";
	REPORT "Accumulated input: /";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: / | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 4: Accumulated input: /*";
	s_input <= "00101010";	--*
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: /* | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 4: Accumulated input: /**";
	s_input <= "00101010";	--*
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /** | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 4: Accumulated input: /**/";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /**/ | output: 1" SEVERITY ERROR;
	REPORT "_______________________";
	
-- Test case 5: /**random character*/

	REPORT "Test case 5: /**r*/";
	REPORT "Accumulated input: /";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: / | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 5: Accumulated input: /*";
	s_input <= "00101010";	--*
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: /* | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 5: Accumulated input: /**";
	s_input <= "00101010";	--*
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /** | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 5: Accumulated input: /**r";
	s_input <= "01011000";	--r
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /**r | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 5: Accumulated input: /**r*";
	s_input <= "00101010";	--*
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /**r* | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 5: Accumulated input: /**r*/";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /**r*/ | output: 1" SEVERITY ERROR;
	REPORT "_______________________";
	
-- Test case 6: /random character
	
	REPORT "Test case 6: /r";
	REPORT "Accumulated input: /";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: / | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 6: Accumulated input: /r";
	s_input <= "01011000";	--r
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: /r | output: 0" SEVERITY ERROR;
	REPORT "_______________________";
	
-- Test case 7: /***/

	REPORT "Test case 7: /***/";
	REPORT "Accumulated input: /";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: / | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 7: Accumulated input: /*";
	s_input <= "00101010";	--*
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: /* | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 7: Accumulated input: /**";
	s_input <= "00101010";	--*
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /** | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 7: Accumulated input: /***";
	s_input <= "00101010";	--*
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /*** | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 4: Accumulated input: /***/";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /***/ | output: 1" SEVERITY ERROR;
	REPORT "_______________________";
	
-- Test case 8: //random character\n other random characters

	REPORT "Test case 8: //r\nr";
	REPORT "Accumulated input: /";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: / | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 8: Accumulated input: //";
	s_input <= "00101111";	--//
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: // | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 8: Accumulated input: //r";	
	s_input <= "01011000";	--r
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: //r | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 8: Accumulated input: //r\n";
	s_input <= "00001010";	--\n
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: //r\n | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 8: Accumulated input: //r\nr";	
	s_input <= "01011000";	--r
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: //r\nr | output: 0" SEVERITY ERROR;
	REPORT "_______________________";
	
-- Test case 9: /*random character*/ other random characters
REPORT "Test case 9: /*r*/r";
	REPORT "Accumulated input: /";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: / | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 9: Accumulated input: /*";
	s_input <= "00101010";	--*
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: /* | output: 0" SEVERITY ERROR;
	
	REPORT "Test case 9: Accumulated input: /*r";	
	s_input <= "01011000";	--r
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /*r | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 9: Accumulated input: /*r*";
	s_input <= "00101010";	--*
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /*r* | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 9: Accumulated input: /*r*/";
	s_input <= "00101111";	--/
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "Accumulated input: /*r*/ | output: 1" SEVERITY ERROR;
	
	REPORT "Test case 9: Accumulated input: /*r*/r";	
	s_input <= "01011000";	--r
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "Accumulated input: /*r*/r | output: 0" SEVERITY ERROR;
	REPORT "_______________________";
	
	WAIT;
END PROCESS stim_process;
END;
