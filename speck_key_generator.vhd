
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;




entity speck_key_generator is

generic(
        reg_width :integer := 64
); 
    Port ( input_speck  : in  STD_LOGIC;
           input_shift  : in  STD_LOGIC_vector(reg_width -1 downto 0);-- shifted key
           clk_s : in  STD_LOGIC;
           output_shift : out STD_LOGIC_vector(reg_width -1 downto 0);
			  load_gen     : out std_logic;
			  RL_gen       : out std_logic;
			  num_shift    : out integer; 
			  output_speck : out  STD_LOGIC_vector(reg_width -1 downto 0);
			  send_bit     : out std_logic := '0'
			  );

end speck_key_generator;

architecture Behavioral of speck_key_generator is

type state_t is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9);
signal state      : state_t := s0;
signal next_state : state_t := s0;

signal L0    : std_logic_vector(reg_width-1 downto 0);
signal k0    : std_logic_vector(reg_width-1 downto 0);
signal p_L    : std_logic_vector(reg_width-1 downto 0);
signal n_L    : std_logic_vector(reg_width-1 downto 0);
signal p_key : std_logic_vector (reg_width-1 downto 0);-- previous key
signal n_key : std_logic_vector (reg_width-1 downto 0);-- next key

signal shift_holder1 : std_logic_vector (reg_width-1 downto 0);
signal shift_holder2 : std_logic_vector (reg_width-1 downto 0);


signal output_shift_int : std_logic_vector (reg_width-1 downto 0);
signal input_shift_int  : std_logic_vector (reg_width-1 downto 0);
signal load_gen_int     : std_logic;
signal RL_gen_int       : std_logic;
signal num_shift_int    : integer;
signal A                : std_logic_vector (63 downto 0);
signal t                : integer;


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
		  clk => clk_s,
	     output => input_shift_int
	  
	  );
	  
	process(state, input_speck)
	 
	  begin
       case state is
          when s0 => 
	         if (input_speck = '0') then 
				    p_key <= k0;
					 n_key <= k0;
					 p_L <= L0;
					 send_bit<= '1';
					 next_state <= s1;
			   else
				    null;
				end if;
				
			 when s1 => 
	         if (input_speck = '0') then 
				    output_shift_int <= p_L ;
					 load_gen_int <= '1';
					 next_state <= s2;
			   else
				    null;
				end if;
 
          when s2 => 
		      if (input_speck = '0') then 
				    RL_gen_int <= '0' ;
					 num_shift_int <= 8;
					 next_state <= s3;
			   else
				    null;
				end if;	
 
          when s3 => 
		      if (input_speck = '0') then 
				    shift_holder1 <= input_shift ;
					 next_state <= s4;
			   else
				    null;
				end if;
				
         when s4 => 
		      if (input_speck = '0') then 
				    A <= std_logic_vector(to_unsigned(t, 64)) ;
					 next_state <= s5;
			   else
				    null;
				end if;				
			
         when s5 => 
		      if (input_speck = '0') then 
				    n_L <= (p_key xor shift_holder1) xor A ;
					 next_state <= s6;
			   else
				    null;
				end if;
 
         when s6 => 
		      if (input_speck = '0') then 
				    output_shift_int <= p_key ;
					 load_gen_int <= '1';
					 next_state <= s7;
			   else
				    null;
				end if;	
				
         when s7 => 
		      if (input_speck = '0') then 
				    RL_gen_int <= '1' ;
					 num_shift_int <= 3;
					 next_state <= s8;
			   else
				    null;
				end if;
         
			when s8 => 
		      if (input_speck = '0') then 
				    shift_holder2 <= input_shift ;
					 next_state <= s9;
			   else
				    null;
				end if;	

         
			when s9 => 
		      if (input_speck = '0') then
                n_key <= shift_holder2 xor n_L ;	
					 
					 p_key <= n_key;
					 p_L <= n_L;
					 t   <= t + 1;
                					 
					 send_bit<= '1';
					 if (t < 30)then 
					  next_state <= s1;
					 else 
					  next_state <= s0;
					 end if;
				else
				    null;
				end if;
   end case;
  end process;
  
 process(clk_s)
 begin
 if rising_edge (clk_s) then
       state <= next_state;
 end if;  
end process	;	

output_speck <= n_key;
		
  
end Behavioral;

