library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity PE is
  port (
    clock : in std_logic;

    W_shift : in std_logic;
    W_in : in signed(7 downto 0);
    w_out : out signed(7 downto 0);

    I_in : in signed(7 downto 0);
    I_out : out signed (7 downto 0);
    
    O_in : in signed(31 downto 0);
    O_out : out signed(31 downto 0)
  ) ;
end PE;

-- Weight Stationary Diagonal PE
architecture int8 of PE is
  signal Weight : signed(7 downto 0) := X"00";
begin
    process(clock)
        variable temp : signed(15 downto 0);
    begin
        if rising_edge(clock) then
          if W_shift = '1' then
            Weight <= W_in; -- This is never running now and I am straight geeking out 
          end if;
          
          I_out <= I_in;
          O_out <= O_in + (I_in * Weight);

        end if;
    end process;

    W_out <= Weight;
end int8 ; --PE