library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.myPackage.all;

entity ParallelMultiplier is 
    generic (
        Nbit : positive;
        Mbit : positive
    );

    port (
        a : in  std_logic_vector(Nbit - 1 downto 0);
        b : in  std_logic_vector(Mbit - 1 downto 0);
        c : out std_logic_vector(Nbit + Mbit - 1 downto 0)
    );
end entity;

architecture structural of ParallelMultiplier is 

    -- signals to store the signs of the operands and that of the result
    signal sign_a : std_logic;
    signal sign_b : std_logic;
    signal sign_c : std_logic;

    -- signals to store the absolute values
    signal abs_a : std_logic_vector(Nbit - 1 downto 0);
    signal abs_b : std_logic_vector(Mbit - 1 downto 0);
    signal abs_c : std_logic_vector(Nbit + Mbit - 1 downto 0);

    -- signal to store all the partial products
    signal partialProducts : std_logic_vector(Nbit * Mbit - 1 downto 0);

    -- signal to store the values of the carries
    signal carry_signal : std_logic_vector(Nbit * (Mbit - 1) - 1 downto 0);

    -- signal to store the values of the partial sums
    signal sum_signal : std_logic_vector((Nbit - 1) * (Mbit - 2) - 1 downto 0);

    -- signal for the 2's complement conversion of the product
    signal converted_c: std_logic_vector(Nbit + Mbit - 1 downto 0);

    component FullAdder is 
        port (
            a    : in  std_logic;
            b    : in  std_logic;
            cin  : in  std_logic;
            s    : out std_logic;
            cout : out std_logic
        );
    end component;  

    component HalfAdder is 
        port (
            a    : in  std_logic;
            b    : in  std_logic;
            s    : out std_logic;
            cout : out std_logic
        );
    end component; 

begin

    -- signs of the operands
    sign_a <= a(a'left);
    sign_b <= b(b'left);
    -- sign of the product
    sign_c <= sign_a xor sign_b;

    -- absolute values of the operands
    abs_a <= std_logic_vector(abs(signed(a)));
    abs_b <= std_logic_vector(abs(signed(b)));

    -- unsigned multiplication between the 2 absolute values above:

    -- process to compute the partial products
    PP: process(abs_a, abs_b)
    begin 
        for i in 0 to Mbit - 1 loop
            for j in 0 to Nbit - 1 loop
                partialProducts(i * Nbit + j) <= abs_a(j) and abs_b(i);
            end loop;    
        end loop;
    end process;

    -- first bit of the product
    abs_c(0) <= partialProducts(0);

    -- generate statement for the all the blocks of the parallel multiplier architecture
    PM_ROW: for i in 1 to Mbit - 1 generate 
        PM_COLUMN: for j in 0 to Nbit - 1 generate 

                FIRST_ROW: if i = 1 generate 

                    RIGHT_HA: if j = 0 generate 
                        HA: HalfAdder
                        port map (
                            a => partialProducts(1),
                            b => partialProducts(Nbit),
                            s => abs_c(1), -- second bit of the product
                            cout => carry_signal(0)
                        );
                    end generate;
                
                    CENTRAL_FA: if j > 0 and j < Nbit - 1 generate 
                        FA: FullAdder
                        port map (
                            a => partialProducts(j + 1),
                            b => partialProducts(Nbit + j),
                            cin => carry_signal(j - 1),
                            s => sum_signal(j - 1),
                            cout => carry_signal(j)
                        );
                    end generate;
                    
                    LEFT_HA: if j = Nbit - 1 generate 
                        HA: HalfAdder
                        port map (
                            a => carry_signal(j - 1),
                            b => partialProducts(Nbit + j),
                            s => sum_signal(j - 1),
                            cout => carry_signal(j)
                        ); 
                    end generate;
                 
                end generate FIRST_ROW;

                INTERNAL_ROW: if i > 1 and i < Mbit - 1 generate 

                    RIGHT_HA: if j = 0 generate 
                        HA: HalfAdder
                        port map (
                            a => sum_signal((Nbit - 1) * (i - 2)),
                            b => partialProducts(Nbit * i),
                            s => abs_c(i), -- i-th bit of the product
                            cout => carry_signal(Nbit * (i - 1))
                        );
                    end generate;
                
                    CENTRAL_FA: if j > 0 and j < Nbit - 1 generate 
                        FA: FullAdder
                        port map (
                            a => sum_signal((Nbit - 1) * (i - 2) + j),
                            b => partialProducts(Nbit * i + j),
                            cin => carry_signal(Nbit * (i - 1) + j - 1),
                            s => sum_signal((Nbit - 1) * (i - 1) + j - 1),
                            cout => carry_signal(Nbit * (i - 1) + j)
                        );
                    end generate;
                    
                    LEFT_FA: if j = Nbit - 1 generate 
                        FA: FullAdder
                        port map (
                            a => carry_signal(Nbit * (i - 1) - 1),
                            b => partialProducts(Nbit * i + j),
                            cin => carry_signal(Nbit * (i - 1) + j - 1),
                            s => sum_signal((Nbit - 1) * (i - 1) + j - 1),
                            cout => carry_signal(Nbit * (i - 1) + j)
                        ); 
                    end generate;
                 
                end generate INTERNAL_ROW;

                LAST_ROW: if i = Mbit - 1 generate 

                    RIGHT_HA: if j = 0 generate 
                        HA: HalfAdder
                        port map (
                            a => sum_signal((Nbit - 1) * (i - 2)),
                            b => partialProducts(Nbit * i),
                            s => abs_c(i), -- the i-th bit of the product
                            cout => carry_signal(Nbit * (i - 1))
                        );
                    end generate;
                
                    CENTRAL_FA: if j > 0 and j < Nbit - 1 generate 
                        FA: FullAdder
                        port map (
                            a => sum_signal((Nbit - 1) * (i - 2) + j),
                            b => partialProducts(Nbit * i + j),
                            cin => carry_signal(Nbit * (i - 1) + j - 1),
                            s => abs_c(i + j), -- the (i+j)-th bit of the product
                            cout => carry_signal(Nbit * (i - 1) + j)
                        );
                    end generate;
                    
                    LEFT_FA: if j = Nbit - 1 generate 
                        FA: FullAdder
                        port map (
                            a => carry_signal(Nbit * (i - 1) - 1),
                            b => partialProducts(Nbit * i + j),
                            cin => carry_signal(Nbit * (i - 1) + j - 1),
                            s => abs_c(i + j), --
                            cout => abs_c(i + j + 1) -- the 2 last bits of the product
                        ); 
                    end generate;
                 
                end generate LAST_ROW;
        end generate PM_COLUMN;
    end generate PM_ROW;            

    -- if the sign of the product is negative we have to convert abs_c in 2's complement, by inverting its bits and adding 1
    --  otherwise the result is abs_c
    c <=  converted_c when sign_c = '1' else 
          abs_c;

    -- 2's complement conversion of abs_c
    converted_c <= std_logic_vector(unsigned(not abs_c) + 1);

end architecture;