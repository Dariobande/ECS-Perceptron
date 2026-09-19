library IEEE;
use IEEE.std_logic_1164.all;
use work.myPackage.all;

entity Perceptron is 
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        xn    : in  inputs;
        wn    : in  weights; 
        b     : in  std_logic_vector(bw - 1 downto 0);
        y     : out std_logic_vector(bout - 1 downto 0)
    );
end entity;

architecture structural of Perceptron is 

    -- internal signals to connect the components
    signal outputsProduct_signal : inputsAdder;
    signal inputsAdder_signal : inputsAdder;
    signal bias_signal : std_logic_vector(bw - 1 downto 0);
    signal outputAdder_signal : std_logic_vector(bsum - 1 downto 0);
    signal inputAF_signal : std_logic_vector(bsum - 1 downto 0);
    signal outputAF_signal    : std_logic_vector(bsum - 1 downto 0);

    component Products is 
        port (
            inputs  : in  inputs;
            weights : in  weights;
            outputs : out inputsAdder
        );
    end component; 
    
    component AdderTree is 
        port (
            inputs : in inputsAdder;
            b      : in std_logic_vector(bw - 1 downto 0);
            output : out std_logic_vector(bsum - 1 downto 0)
        );
    end component; 

    component ActivationFunction is 
        port (
            x : in  std_logic_vector(bsum - 1 downto 0); 
            y : out std_logic_vector(bsum - 1 downto 0)
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

    Prod: Products
    port map (
        inputs => xn,
        weights => wn,
        outputs => outputsProduct_signal
    );

    -- pipeline registers
    g_DFF: for i in 0 to Nin - 1 generate 
        PR_1: DFFN
        generic map (
            Nbit => bpro
        )
        port map (
            clk => clk,
            resetn => reset,
            en => '1',
            di => outputsProduct_signal(i),
            do => inputsAdder_signal(i)
        );
    end generate;

    PR_bias: DFFN
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

    AT: AdderTree 
    port map (
        inputs => inputsAdder_signal,
        b => bias_signal, 
        output => outputAdder_signal
    );

    -- pipeline register
    PR_2: DFFN
    generic map (
        Nbit => bsum
    )
    port map (
        clk => clk,
        resetn => reset,
        en => '1',
        di => outputAdder_signal,
        do => inputAF_signal
    );

    AF: ActivationFunction
    port map (
        x => inputAF_signal,
        y => outputAF_signal
    );

    -- truncating the least significant bits
    y <= outputAF_signal(bsum - 1 downto (bsum - bout));

end architecture;     
