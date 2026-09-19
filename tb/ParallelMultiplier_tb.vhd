library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ParallelMultiplier_tb is
end entity;

architecture beh of ParallelMultiplier_tb is 
  
    constant clk_period : time     := 100 ns;
    constant N          : positive := 9;
    constant M          : positive := 8;

    component ParallelMultiplier is 
        generic (
            Nbit : positive;
            Mbit : positive
        );

        port (
            a : in  std_logic_vector(Nbit - 1 downto 0);
            b : in  std_logic_vector(Mbit - 1 downto 0);
            c : out std_logic_vector(Nbit + Mbit - 1 downto 0)
        );
    end component;

    signal clk     : std_logic := '0';
    signal a_ext   : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal b_ext   : std_logic_vector(M - 1 downto 0) := (others => '0');
    signal c_ext   : std_logic_vector(N + M - 1 downto 0);
    signal testing : boolean := true;

begin

    clk <= not clk after clk_period/2 when testing else '0';

    PM: ParallelMultiplier
    generic map (
        Nbit => N,
        Mbit => M
    )
    port map (
        a => a_ext,
        b => b_ext,
        c => c_ext
    );

    p_STIMULUS: process begin

        a_ext <= (others => '0');
        b_ext <= (others => '0');

        wait until rising_edge(clk);

        a_ext <= "100000000"; -- -256
        b_ext <= "00000001";  -- 1

        wait for 200 ns;

        a_ext <= "000000001"; -- 1
        b_ext <= "10101010";  -- -86

        wait until rising_edge(clk);

        a_ext <= (others => '0');
        b_ext <= (others => '0');

        wait for 200 ns;

        a_ext <= "111100000"; -- -32
        b_ext <= "10111000";  -- -72

        wait until rising_edge(clk);

        a_ext <= "011100000"; -- 224
        b_ext <= "00111000";  -- 56

        wait for 300 ns;

        a_ext <= "111111100"; -- -4
        b_ext <= "00001000";  -- 8

        wait until rising_edge(clk);
        testing <= false;
        wait until rising_edge(clk);  
        
    end process;    
end architecture; 