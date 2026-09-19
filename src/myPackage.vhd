library IEEE;
use IEEE.std_logic_1164.all;

-- package definition, which defines all the constants and the types used in the code
package myPackage is 

    -- number of inputs
    constant Nin : positive := 10;
    -- number of bits for each input
    constant bx : positive := 8;
    -- number of bits for the weights and the bias
    constant bw : positive := 9;
    -- number of bits for the output
    constant bout : positive := 16;
    -- number of bits per the products
    constant bpro : positive := bw + bx;
    -- number of bits per the total sum 
    constant bsum : positive := bpro + 4;

    -- The following constants are some integer representations useful for the activation function implementation
    --  and they are computed by dividing the real values by LSB = LSBx * LSBw = 2^-15
    -- integer representation of 2, which is 2 * 2^15 = 2^16
    constant int_2 : integer := 65536;
    -- integer representation of -2, which is -2 * 2^15 = -2^16
    constant int_minus2 : integer := -65536;
    -- integer representation of 1, which is 1 * 2^15 = 2^15
    constant int_1 : integer := 32768;
    -- integer representation of 1/2, which is 1/2 * 2^15 = 2^14
    constant int_oneHalf : integer := 16384;

    -- array of the inputs of the system
    type inputs is array (0 to Nin - 1) of std_logic_vector(bx - 1 downto 0);
    -- array of the weigths
    type weights is array (0 to Nin - 1) of std_logic_vector(bw - 1 downto 0);
    -- array of the inputs for the adder
    type inputsAdder is array (0 to Nin - 1) of std_logic_vector(bpro - 1 downto 0);
    -- array of the extended inputs for the adder 
    type extendedInputsAdder is array (0 to Nin - 1) of std_logic_vector(bsum - 1 downto 0);

end package myPackage;