library IEEE;
use IEEE.std_logic_1164.all;
use work.myPackage.all;

entity PerceptronWrapper is 
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        xn    : in  inputs;
        wn    : in  weights; 
        b     : in  std_logic_vector(bw - 1 downto 0);
        y     : out std_logic_vector(bout - 1 downto 0)
    );
end entity;

architecture structural of PerceptronWrapper is 

    -- internal signals to connect the components
    signal inputs_signal  : inputs;
    signal weights_signal : weights;
    signal bias_signal    : std_logic_vector(bw - 1 downto 0);
    signal output_signal  : std_logic_vector(bout - 1 downto 0);

    component Perceptron is 
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        xn    : in  inputs;
        wn    : in  weights; 
        b     : in  std_logic_vector(bw - 1 downto 0);
        y     : out std_logic_vector(bout - 1 downto 0)
    );
    end component;

    component DFFN is
        generic (
            Nbit: positive
        );
    
        port (
            clk    : in  std_logic;
            resetn : in  std_logic; 
            en     : in  std_logic;
            di     : in  std_logic_vector(Nbit - 1 downto 0); 
            do     : out std_logic_vector(Nbit - 1 downto 0)
        );
    end component;

begin 

    -- generate statement for all the input barrier registers
    g_DFF: for i in 0 to Nin - 1 generate 
        -- register for the inputs xn
        DDF_x: DFFN
        generic map (
            Nbit => bx
        )
        port map (
            clk => clk,
            resetn => reset,
            en => '1',
            di => xn(i),
            do => inputs_signal(i)
        );
        -- register for the weights wn
        DDF_w: DFFN
        generic map (
            Nbit => bw
        )
        port map (
            clk => clk,
            resetn => reset,
            en => '1',
            di => wn(i),
            do => weights_signal(i)
        );
    end generate;

    -- register for the bias
    DDF_b: DFFN
    generic map (
        Nbit => bw
    )
    port map (
        clk => clk,
        resetn => reset,
        en => '1',
        di => b,
        do => bias_signal
    );

    -- Perceptron instance
    Perc: Perceptron
    port map (
        clk => clk, 
        reset => reset,
        xn => inputs_signal,
        wn => weights_signal,
        b => bias_signal,
        y => output_signal
    );

    -- register for the output
    DDF_y: DFFN
    generic map (
        Nbit => bout
    )
    port map (
        clk => clk,
        resetn => reset,
        en => '1',
        di => output_signal,
        do => y
    );

end architecture;