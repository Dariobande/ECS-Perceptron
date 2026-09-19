library IEEE;
use IEEE.std_logic_1164.all;
use work.myPackage.all;

entity Products is 
    port (
        inputs  : in  inputs;
        weights : in  weights;
        outputs : out inputsAdder
    );
end entity;

architecture structural of Products is 

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

begin 

    g_M: for i in 0 to Nin - 1 generate 

            PM_i: ParallelMultiplier 
            generic map (
                Nbit => bx,
                Mbit => bw
            )
            port map (
                a => inputs(i),
                b => weights(i),
                c => outputs(i)
            );

    end generate;

end architecture;

