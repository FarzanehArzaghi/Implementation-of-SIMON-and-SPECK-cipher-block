
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity CircularShiftRegister is

generic(
        reg_width :integer := 64

);
    Port ( input : in  std_logic_vector(reg_width -1 downto 0);
	        load  : in  std_logic;
           RL    : in  STD_LOGIC;-- 0 means rightshift 1 means leftshift
            j    : in  integer range 0 to 8; -- number of shifts
           clk   : in  std_logic;
			  output: out std_logic_vector(reg_width -1 downto 0));
end CircularShiftRegister;

architecture Behavioral of CircularShiftRegister is

signal shift_content   : std_logic_vector(reg_width -1 downto 0);
signal bit_holder      : std_logic;

begin

 output <= shift_content;
 
  
 process(clk)
 
  variable count : integer;
  
  begin
   if rising_edge (clk) then
    count := 0;
	
	 if (load = '1') then 
	  shift_content<= input;
	 end if;
	
	 case RL is
	    when '0' => 
		  
		    shift_content(reg_width -1) <= shift_content(0);
			  while (count < j) loop
            for i in 0 to reg_width -2 loop 
              shift_content(i)	<= shift_content(i+1);
            end loop;
				  count:= count+1;
           end loop;		
		    
		  
		 when '1' =>
		      
			  shift_content(0) <= shift_content(reg_width -1);
			  while (count < j) loop
            for i in 0 to reg_width -2 loop 
              shift_content(i+1)	<= shift_content(i);
            end loop;
				    count:= count+1;
           end loop;				
		  
		  
		  when others =>
		     null; 
		   
	 end case;
  end if;
 end process;
	
end Behavioral;

