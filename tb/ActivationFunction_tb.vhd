library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.myPackage.all;

entity ActivationFunction_tb is
end entity;

architecture beh of ActivationFunction_tb is 
  
    constant clk_period : time := 100 ns;

    component ActivationFunction is 
        port (
            x : in  std_logic_vector(bsum - 1 downto 0);
            y : out std_logic_vector(bsum - 1 downto 0)
        );
    end component;

    signal clk     : std_logic := '0';
    signal x_ext   : std_logic_vector(bsum - 1 downto 0) := (others => '0');
    signal y_ext   : std_logic_vector(bsum - 1 downto 0);
    signal testing : boolean := true;

begin

    clk <= not clk after clk_period/2 when testing else '0';

    AF: ActivationFunction
    port map (
        x => x_ext,
        y => y_ext
    );

    p_STIMULUS: process begin

        x_ext <= (others => '0'); -- 0 --> linear region, expected value 0.5

        wait until rising_edge(clk);

        x_ext <= "000000100000000000000"; -- 16384 which corresponds to 0.5 --> linear region, expected value 0.625

        wait for 200 ns;

        x_ext <= "000001000000000000000"; -- 32768 which corresponds to 1 --> linear region, expected value 0.75

        wait for 300 ns;

        x_ext <= "000010000000000000000"; -- 65536 which corresponds to 2 --> expected value 1

        wait until rising_edge(clk);

        x_ext <= "111100000000000000000"; -- -131072 which corresponds to -4 --> expected value 0

        wait for 200 ns;

        x_ext <= "001000000000000000000"; -- 262144 which corresponds to 8 --> expected value 1

        wait until rising_edge(clk);
        testing <= false;
        wait until rising_edge(clk);  
        
    end process;    
end architecture; 