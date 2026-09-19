library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RippleCarryAdder_tb is
end entity;

architecture beh of RippleCarryAdder_tb is
  
    constant clk_period : time     := 100 ns;
    constant N          : positive := 8;

    component RippleCarryAdder
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

    signal clk      : std_logic := '0';
    signal a_ext    : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal b_ext    : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal cin_ext  : std_logic := '0';
    signal s_ext    : std_logic_vector(N - 1 downto 0);
    signal cout_ext : std_logic;
    signal testing  : boolean := true;

begin
    
    clk <= not clk after clk_period/2 when testing else '0';

    RCA: RippleCarryAdder
    generic map (
        Nbit => N
    )
    port map (
        a    => a_ext,
        b    => b_ext,
        cin  => cin_ext,
        s    => s_ext,
        cout => cout_ext
    );

    p_STIMULUS: process begin

        a_ext   <= (others => '0');
        b_ext   <= (others => '0');
        cin_ext <= '0';

        wait for 200 ns;

        a_ext   <= "00000110"; -- 6
        b_ext   <= "00100110"; -- 38
        cin_ext <= '0';

        wait until rising_edge(clk);

        a_ext   <= "01100110"; -- 102
        b_ext   <= "10010100"; -- -108
        cin_ext <= '1';

        wait until rising_edge(clk);

        a_ext   <= (others => '0');
        b_ext   <= (others => '0');
        cin_ext <= '0';

        wait for 1000 ns;

        a_ext   <= "11111111"; -- -1
        b_ext   <= "11111111"; -- -1
        cin_ext <= '0';

        wait for 500 ns;
        testing <= false;
        wait until rising_edge(clk);
        
    end process;
 end architecture;