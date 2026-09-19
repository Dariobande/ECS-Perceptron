library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.myPackage.all;

entity Perceptron_tb is
end entity;

architecture beh of Perceptron_tb is 
  
    constant clk_period : time := 100 ns;

    component PerceptronWrapper is 
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            xn    : in  inputs;
            wn    : in  weights; 
            b     : in  std_logic_vector(bw - 1 downto 0);
            y     : out std_logic_vector(bout - 1 downto 0)
        );
    end component;

    signal clk_ext   : std_logic := '0';
    signal reset_ext : std_logic := '0';
    signal xn_ext    : inputs := (others => "00000000");
    signal wn_ext    : weights := (others => "000000000");
    signal b_ext     : std_logic_vector(bw - 1 downto 0) := (others => '0');
    signal y_ext     : std_logic_vector(bout - 1 downto 0);
    signal testing   : boolean := true;

begin

    clk_ext <= not clk_ext after clk_period/2 when testing else '0';

    Perc: PerceptronWrapper
    port map (
        clk => clk_ext, 
        reset => reset_ext,
        xn => xn_ext,
        wn => wn_ext,
        b => b_ext,
        y => y_ext
    );

    -- the objective of this tb is to test all the regions of the activation function
    p_STIMULUS: process begin 

        -- resetting the memory of the registers
        reset_ext <= '0';
        wait until rising_edge(clk_ext);

        reset_ext <= '1';
        wait for 500 ns;

        -- TEST 1:
        xn_ext <= (others => "01100000"); -- corresponds to 0.75
        wn_ext <= (others => "010000000"); -- corresponds to 0.5
        b_ext <= ("011000000"); -- corresponds to 0.75
        -- the expected input of the activation function is (0.75 * 0.5) * 10 + 0.75 = 4.5
        -- the expected output before the truncation is 1
        -- the expected output after the truncation is still 1

        wait for 500 ns;

        -- TEST 2:
        xn_ext <= (others => "01100000"); -- corresponds to 0.75
        wn_ext <= (others => "110000000"); -- corresponds to -0.5
        b_ext <= ("011000000"); -- corresponds to 0.75
        -- the expected input of the activation function is (0.75 * (-0.5)) * 10 + 0.75 = -3
        -- the expected output before the truncation is 0
        -- the expected output after the truncation is still 0

        wait for 500 ns;

        -- TEST 3 (linear region):
        xn_ext <= (others => "00100000"); -- corresponds to 0.25
        wn_ext <= (others => "001000000"); -- corresponds to 0.25
        b_ext <= ("000000000"); -- corresponds to 0
        -- the expected input of the activation function is (0.25 * 0.25) * 10 = 0.625
        -- the expected output before the truncation is 0.625 / 4 + 0.5 = 0.65625
        -- the expected output after the truncation is still 0.65625

        wait for 500 ns;
        testing <= false;
        wait until rising_edge(clk_ext);  

    end process;    
end architecture; 