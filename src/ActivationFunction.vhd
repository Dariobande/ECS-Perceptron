library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.myPackage.all;

entity ActivationFunction is 
    port (
        x : in  std_logic_vector(bsum - 1 downto 0);
        y : out std_logic_vector(bsum - 1 downto 0)
    );
end entity;

architecture rtl of ActivationFunction is 

    -- signal to convert x to integer in order to make comparisons
    signal x_int : integer;
    -- signal to perform the arithmetic shift
    signal shifted_signal : std_logic_vector(bsum - 1 downto 0);
    -- signal to store the result of the sum
    signal sum_signal : std_logic_vector(bsum - 1 downto 0);
    -- signal to store the second addendum of the sum
    signal b_signal : std_logic_vector(bsum - 1 downto 0);

    component RippleCarryAdder is 
        generic (
            Nbit : positive
        );

        port (
            a    : in  std_logic_vector(Nbit - 1 downto 0);
            b    : in  std_logic_vector(Nbit - 1 downto 0);
            cin  : in  std_logic;
            s    : out std_logic_vector(Nbit - 1 downto 0);
            cout : out std_logic
        );
    end component; 

begin

    -- the activation function is the following:
    -- y = 1/4 * x + 1/2  if -2 <= x <= 2   --->   y = x / 2^2 + 1/2
    -- y = 0              if x <= -2
    -- y = 1              if x >= 2

    x_int <= to_integer(signed(x));

    -- multiplexer
    y <=  std_logic_vector(to_signed(int_1, bsum)) when x_int > int_2  else 
          std_logic_vector(to_signed(0, bsum)) when x_int < int_minus2 else
          sum_signal;

    -- shifting x (with sign) of 2 positions to the right, which corresponds to divide it by 4       
    shifted_signal <= x(x'left) & x(x'left) & x(bsum - 1 downto 2);

    -- storing the value of the second addendum (1/2)
    b_signal <= std_logic_vector(to_signed(int_oneHalf, bsum));

    -- rippleCarryAdder to perform the sum between the shifted_signal and 1/2
    RCA: RippleCarryAdder
    generic map (
        Nbit => bsum
    )
    port map (
        a => shifted_signal,
        b => b_signal,
        cin => '0',
        s => sum_signal,
        cout => open
    );

end architecture;        