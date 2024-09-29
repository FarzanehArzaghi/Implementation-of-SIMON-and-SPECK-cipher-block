
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity SIMON_TP is

 generic(
        reg_width :integer := 64
); 
    Port ( plaintext       : in std_logic_vector(127 downto 0);
	        receive_bit_tp  : in  STD_LOGIC;
           key             : in  STD_LOGIC_vector(reg_width-1 downto 0);
           input_shift_tp  : in  STD_LOGIC_vector(reg_width-1 downto 0);
			  clk             : in  STD_LOGIC;
			  output_shift_tp : out STD_LOGIC_vector(reg_width -1 downto 0);
			  load_tp         : out std_logic;
			  RL_tp           : out std_logic;
			  num_shift_tp    : out integer;
           send_bit_tp     : out  STD_LOGIC;
           cipher_text     : out  STD_LOGIC_vector(127 downto 0));
end SIMON_TP;

architecture Behavioral of SIMON_TP is



type state_topm is (s0, s1, s2, s3, s4, s5, s6, s7, s8);
signal state_tp   : state_topm := s0;
signal next_state_tp : state_topm := s0;

signal shift_holder1: STD_LOGIC_vector(reg_width-1 downto 0);
signal shift_holder2: STD_LOGIC_vector(reg_width-1 downto 0);
signal shift_holder3: STD_LOGIC_vector(reg_width-1 downto 0);
signal F            : STD_LOGIC_vector(reg_width-1 downto 0);


signal left     : std_logic_vector(127 downto 64):= plaintext(127 downto 64);
signal right    : std_logic_vector(63 downto 0):= plaintext(63 downto 0);

signal receive_bit_tp_int: std_logic;
signal send_bit_tp_int: STD_LOGIC;
signal load_tp_int: STD_LOGIC;
signal RL_tp_int: STD_LOGIC;
signal num_shift_tp_int: integer;
signal key_int: STD_LOGIC_vector(reg_width-1 downto 0);
signal output_shift_tp_int: STD_LOGIC_vector(reg_width-1 downto 0);
signal input_shift_tp_int : STD_LOGIC_vector(reg_width-1 downto 0);



 component CircularShiftRegister
         
    Port ( input : in  std_logic_vector(reg_width -1 downto 0);
	        load  : in  std_logic;
           RL    : in  STD_LOGIC;
            j    : in  integer ; 
           clk   : in  std_logic;
			  output: out std_logic_vector(reg_width -1 downto 0)
			  );

 end component;
 
 component  simon_key_generator
   Port (  input_simon  : in  STD_LOGIC;
           input_shift  : in  STD_LOGIC_vector(reg_width -1 downto 0);
           clk          : in  STD_LOGIC;
           output_shift : out STD_LOGIC_vector(reg_width -1 downto 0);
			  load_gen     : out std_logic;
			  RL_gen       : out std_logic;
			  num_shift    : out integer; 
			  output_simon : out  STD_LOGIC_vector(reg_width -1 downto 0);
			  send_bit     : out std_logic := '0'
			  );
 end component;
 
begin

output_shift_tp <= output_shift_tp_int;
load_tp <= load_tp_int;
RL_tp <= RL_tp_int;
num_shift_tp <= num_shift_tp_int;
send_bit_tp <= send_bit_tp_int;
receive_bit_tp_int <= receive_bit_tp ;
key_int <= key;
input_shift_tp_int<= input_shift_tp;



shifter:CircularShiftRegister
  port map
 
     (  input => output_shift_tp_int,
	     load =>  load_tp_int,
	     RL => RL_tp_int,
	     j => num_shift_tp_int,
		  clk => clk,
	     output => input_shift_tp_int	     
	  );
	  
generator:simon_key_generator

  port map
      ( input_simon => send_bit_tp_int,
		  clk => clk ,
		  output_simon => key_int,
		  send_bit => receive_bit_tp_int,
		  input_shift => input_shift_tp_int , 
		  output_shift => output_shift_tp_int, 
	     load_gen  => load_tp_int, 		  
        RL_gen  => RL_tp_int, 
		  num_shift  =>num_shift_tp_int
	      
			);
  
 

  process(state_tp, plaintext)
     variable counter : integer := 1;
	  variable t : integer :=1;
         begin
                    
			    
               case state_tp is
                  when s0 => 
						   if(t=1)then
		                 output_shift_tp_int <= left;
							  load_tp_int <= '1';
							  send_bit_tp_int <= '0'; -- ask key generator to generate and send key.
							  next_state_tp <= s1;
							else 
							  null; 
							end if;  
							
						
						when s1 => 
						   if(t=1)then
		                 RL_tp_int <= '1';
							  num_shift_tp_int <= 1;
							  next_state_tp <= s2;
							else 
							  null;
							end if;
							  
							
						when s2 =>
                     if(t=1)then						
						     shift_holder1<= input_shift_tp_int;
							  next_state_tp <= s3;
							else
							  null;
							end if;
		               
						when s3 => 
		               if(t=1)then
						      RL_tp_int <= '1';
							   num_shift_tp_int <= 8;
							   next_state_tp <= s4;
							else 
							   null;
						   end if;
							   
                  when s4 => 
						   if(t=1)then
						      shift_holder2<= input_shift_tp_int;
							   next_state_tp <= s5;
							else
							   null;
						   end if;
		              
                  when s5 =>
						    if(t=1)then
		                  RL_tp_int <= '1';
							   num_shift_tp_int <= 2;
							   next_state_tp <= s6;
							 else 
							    null;
							 end if;
							
					    when s6 =>
                      if(t=1)then						 
						      shift_holder3<= input_shift_tp_int;
							   next_state_tp <= s7;	
							 else 
                        null;
                      end if;								
							
                   when s7 => 
						    if(t=1)then
		                  F<= (shift_holder1 and shift_holder2) xor shift_holder3;
 							   next_state_tp <= s8;
							 else
							    null;
							  end if;
							
						 when s8 => 
                      if(t=1 and receive_bit_tp_int = '1')then						 
						      
		                  left <= right xor F xor key_int;
							   right <=left;
 							   send_bit_tp_int <= '1';
							   counter := counter + 1;
							   if (counter < 69)then 
							      next_state_tp <= s0;
						      else
                          t := 0;
                        end if;
                      else
                         null;
                      end if;								 
                 end case;
       end process;
		 
process(clk)
 begin
 if rising_edge (clk) then
       state_tp <= next_state_tp;
 end if;  
end process	;	

cipher_text <= left & right;
				 
end Behavioral;

