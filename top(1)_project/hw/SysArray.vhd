library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity SysArray is
  generic(
    N : integer := 4
  );
  port(
    Sys_Clk : in std_logic;
    Sys_Wm : in std_logic;

    Sys_I : in std_logic_vector((N*8)-1 downto 0);
    Sys_B : in std_logic_vector((N*8)-1 downto 0);
    Sys_W : in std_logic_vector((N*8)-1 downto 0);
    Sys_O : out std_logic_vector((N*8)-1 downto 0)
  );
end SysArray;

architecture rtl of SysArray is

  component PE 
    port(
      clock : in std_logic;

      W_shift : in std_logic;
      W_in : in signed(7 downto 0);
      w_out : out signed(7 downto 0);

      I_in : in signed(7 downto 0);
      I_out : out signed (7 downto 0);
      
      O_in : in signed(7 downto 0);
      O_out : out signed (7 downto 0)
    );
  end component;
  
  type VecSize is array(0 to N-1) of signed(7 downto 0);
  type SysSize is array(0 to N-1, 0 to N) of signed(7 downto 0);
  type MatSize is array(0 to N-1, 0 to N-1) of signed(7 downto 0);
  type WeightSize is array(0 to N, 0 to N-1) of signed(7 downto 0);

  signal Weight : WeightSize;
  signal Carry  : SysSize; 
  signal Sum    : SysSize;

  signal Weight_shift : std_logic := '0';

  signal SI     : VecSize;
  signal SO     : VecSize;
  signal SB     : VecSize;
  signal SW     : VecSize;

  -- Test benching signals
  signal clock: std_logic := '0';
begin

  RowGen: for row in 0 to N-1 generate
    ColGen: for col in 0 to N-1 generate
      PE_X: PE port map(
        clock => clock,
        W_shift => Weight_Shift,
        W_in => Weight(row, Col),
        W_out => Weight(row + 1, (col + 1) Mod N),
        I_in => Carry(row, col),
        I_out => Carry(row, col + 1),
        O_in => Sum(row, col),
        O_out => Sum((row + 1) mod N, col + 1)
      );
    end generate ColGen;

  Weight(0, row) <= SW(row);
  Carry(row, 0) <= SI(row);
  Sum(row, 0) <= SB(row);
  SO(N-row-1) <= Sum((row + 1) mod N, N);
  
  end generate RowGen;

  IO_MAP: for A in 0 to N-1 generate
    -- There should be a better way to do IO with generics

    SI(A) <= Signed(Sys_I(((A+1)*8)-1 downto A*8));
    SB(A) <= Signed(Sys_B(((A+1)*8)-1 downto A*8));
    SW(A) <= Signed(Sys_W(((A+1)*8)-1 downto A*8));
    Sys_O(((A+1)*8)-1 downto A*8) <= std_logic_vector(SO(A));
  end generate IO_MAP;

end architecture;