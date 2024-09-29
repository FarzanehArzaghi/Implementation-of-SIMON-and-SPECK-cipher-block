
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity simon_key_generator is

 generic(
        reg_width :integer := 64
); 
    Port ( input_simon  : in  STD_LOGIC;
           input_shift  : in  STD_LOGIC_vector(reg_width -1 downto 0);-- shifted key
           clk : in  STD_LOGIC;
           output_shift : out STD_LOGIC_vector(reg_width -1 downto 0);
			  load_gen     : out std_logic;
			  RL_gen       : out std_logic;
			  num_shift    : out integer; 
			  output_simon : out  STD_LOGIC_vector(reg_width -1 downto 0);
			  send_bit     : out std_logic := '0'
			  );
end simon_key_generator;

architecture Behavioral of simon_key_generator is

type state_t is (s0, s1, s2, s3, s4, s5, s6, s7, s8);
signal state      : state_t := s0;
signal next_state : state_t := s0;

constant c: std_logic_vector(63 downto 0):= "1010111101110011101101001010011110100001011111111001011011001110";
signal z : std_logic_vector (65 downto 0):= "101011110111000000110100100110001010000100011111100101101100111010";

signal master_key : std_logic_vector (127 downto 0);
signal p_key : std_logic_vector (reg_width-1 downto 0);-- previous key
signal n_key : std_logic_vector (reg_width-1 downto 0);-- next key
signal n_key_out : std_logic_vector (reg_width-1 downto 0);

signal shift_holder1 : std_logic_vector (reg_width-1 downto 0);
signal shift_holder2 : std_logic_vector (reg_width-1 downto 0);
signal count : integer;


signal output_shift_int : std_logic_vector (reg_width-1 downto 0);
signal input_shift_int  : std_logic_vector (reg_width-1 downto 0);
signal load_gen_int     : std_logic;
signal RL_gen_int       : std_logic;
signal num_shift_int    : integer;


component CircularShiftRegister
         
    Port ( input : in  std_logic_vector(reg_width -1 downto 0);
	        load  : in  std_logic;
           RL    : in  STD_LOGIC;
            j    : in  integer ; 
           clk   : in  std_logic;
			  output: out std_logic_vector(reg_width -1 downto 0)
			  );
 
 
end component;

begin
output_shift <=  output_shift_int;
input_shift_int  <= input_shift;
load_gen<=  load_gen_int;
RL_gen  <=  RL_gen_int;
num_shift <= num_shift_int;



shifter:CircularShiftRegister
  port map
 
     (  input => output_shift_int,
	     load =>  load_gen_int,
	     RL => RL_gen_int,
	     j => num_shift_int,
		  clk => clk,
	     output => input_shift_int
	  
	  );
 
 process(state, input_simon)
   variable counter : integer := 1;
  begin
    case state is
      when s0 => 
	         if (input_simon = '0') then 
				    n_key <= master_key(63 downto 0);
				    p_key<= master_key(63 downto 0);
					 send_bit<= '1';
					 next_state <= s1;
			   else
				    null;
				end if;
				
		 when s1 => 
	         if (input_simon = '0') then 
				    n_key <= master_key(127 downto 64);
					 send_bit<= '1';
					 next_state <= s2;
			   else
				    null;
				end if;
				
       when s2 => 
	         if (input_simon = '0') then 
				    output_shift_int <= p_key ;
					 load_gen_int <= '1';
					 next_state <= s3;
			   else
				    null;
				end if;	

       when s3 => 
		      if (input_simon = '0') then 
				    RL_gen_int <= '0' ;
					 num_shift_int <= 3;
					 next_state <= s4;
			   else
				    null;
				end if;				
				
        when s4 => 
		      if (input_simon = '0') then 
				    shift_holder1 <= input_shift ;
					 next_state <= s5;
			   else
				    null;
				end if;	
				
        when s5 => 
		      if (input_simon = '0') then 
				    output_shift_int <= shift_holder1 ;
					 load_gen_int <= '1';
					 next_state <= s6;
			   else
				    null;
				end if;		

        when s6 => 
		      if (input_simon = '0') then 
				    RL_gen_int <= '0' ;
					 num_shift_int <= 1;
					 next_state <= s7;
			   else
				    null;
				end if;	

         when s7 => 
		      if (input_simon = '0') then 
				    shift_holder2 <= input_shift ;
					 next_state <= s8;
			   else
				    null;
				end if;	

         when s8 => 
		      if (input_simon = '0') then
                if (z(count)= '1')then				
				       n_key <= (not C) xor p_key xor shift_holder1 xor shift_holder2 ;
					 else 
					 
                   n_key <=  C xor p_key xor shift_holder1 xor shift_holder2 ;
                end if;	
					 
					 p_key <= n_key;
					 count<= count + 1;
                counter := counter + 1;					 
					 send_bit<= '1';
					 if (counter < 66)then 
					  next_state <= s2;
					 else 
					  next_state <= s0;
					 end if;
				else
				    null;
				end if;
   end case;
  end process;

process(clk)
 begin
 if rising_edge (clk) then
       state <= next_state;
 end if;  
end process	;	

output_simon <= n_key;
		
end Behavioral;

