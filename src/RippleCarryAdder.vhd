library IEEE;
use IEEE.std_logic_1164.all;

entity RippleCarryAdder is 
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
end entity;    

architecture structural of RippleCarryAdder is 

    signal c : std_logic_vector(Nbit - 2 downto 0);

    component FullAdder is 
    port (
        a    : in  std_logic;
        b    : in  std_logic;
        cin  : in  std_logic;
        s    : out std_logic;
        cout : out std_logic
    );
    end component;  

begin 

    g_RCA: for i in 0 to Nbit - 1 generate 
        g_FIRST: if i = 0 generate 
            FA: FullAdder
            port map (
                a => a(i),
                b => b(i),
                cin => cin,
                s => s(i),
                cout => c(i)
            );
        end generate;
        
        g_INTERNAL: if i >= 1 and i < Nbit - 1 generate 
            FA: FullAdder
            port map (
                a => a(i),
                b => b(i),
                cin => c(i-1),
                s => s(i),
                cout => c(i)
            );  
        end generate;

        g_LAST: if i = Nbit - 1 generate 
            FA: FullAdder
            port map (
                a => a(i),
                b => b(i),
                cin => c(i-1),
                s => s(i),
                cout => cout
            );
        end generate;
    end generate;    

end architecture;        