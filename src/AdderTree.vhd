library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myPackage.all;

entity AdderTree is 
    port (
        inputs  : in  inputsAdder;
        b       : in  std_logic_vector(bw - 1 downto 0);
        output  : out std_logic_vector(bsum - 1 downto 0)
    );
end entity;

architecture structural of AdderTree is 

    -- internal signals to extend the inputs and the bias to bsum bits, in order to perform the sums properly
    signal extendedInputs  : extendedInputsAdder;
    signal extendedBias    : std_logic_vector(bsum - 1 downto 0);

    -- signals to connect the levels of the tree
    signal outputFirstLevel1 : std_logic_vector(bsum - 1 downto 0);
    signal outputFirstLevel2 : std_logic_vector(bsum - 1 downto 0);
    signal outputFirstLevel3 : std_logic_vector(bsum - 1 downto 0);
    signal outputFirstLevel4 : std_logic_vector(bsum - 1 downto 0);
    signal outputFirstLevel5 : std_logic_vector(bsum - 1 downto 0);

    signal outputSecondLevel1 : std_logic_vector(bsum - 1 downto 0);
    signal outputSecondLevel2 : std_logic_vector(bsum - 1 downto 0);
    signal outputSecondLevel3 : std_logic_vector(bsum - 1 downto 0);

    signal outputThirdLevel : std_logic_vector(bsum - 1 downto 0);

    component RippleCarryAdder is 
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

begin

    -- extension of the inputs to bsum bits
    extendedInputs(0) <= std_logic_vector(resize(signed(inputs(0)), bsum));
    extendedInputs(1) <= std_logic_vector(resize(signed(inputs(1)), bsum));
    extendedInputs(2) <= std_logic_vector(resize(signed(inputs(2)), bsum));
    extendedInputs(3) <= std_logic_vector(resize(signed(inputs(3)), bsum));
    extendedInputs(4) <= std_logic_vector(resize(signed(inputs(4)), bsum));
    extendedInputs(5) <= std_logic_vector(resize(signed(inputs(5)), bsum));
    extendedInputs(6) <= std_logic_vector(resize(signed(inputs(6)), bsum));
    extendedInputs(7) <= std_logic_vector(resize(signed(inputs(7)), bsum));
    extendedInputs(8) <= std_logic_vector(resize(signed(inputs(8)), bsum));
    extendedInputs(9) <= std_logic_vector(resize(signed(inputs(9)), bsum));

    -- extension and alignment of the bias by shifting it of 7 positions to the left (corresponds to multiply it by 2^7)
    --  and replicating 5 times the MSB
    extendedBias <= b(b'left) & b(b'left) & b(b'left) & b(b'left) & b(b'left) & b & (6 downto 0 => '0');

    -- first level of the adder tree
    RCA_1_1: RippleCarryAdder 
    generic map(
        Nbit => bsum 
    )
    port map(
        a => extendedInputs(0),
        b => extendedInputs(1),
        cin => '0', 
        s => outputFirstLevel1,
        cout => open
    );

    RCA_1_2: RippleCarryAdder 
    generic map(
        Nbit => bsum
    )
    port map(
        a => extendedInputs(2),
        b => extendedInputs(3),
        cin => '0', 
        s => outputFirstLevel2,
        cout => open
    );

    RCA_1_3: RippleCarryAdder 
    generic map(
        Nbit => bsum
    )
    port map(
        a => extendedInputs(4),
        b => extendedInputs(5),
        cin => '0', 
        s => outputFirstLevel3,
        cout => open
    );

    RCA_1_4: RippleCarryAdder 
    generic map(
        Nbit => bsum
    )
    port map(
        a => extendedInputs(6),
        b => extendedInputs(7),
        cin => '0', 
        s => outputFirstLevel4,
        cout => open
    );

    RCA_1_5: RippleCarryAdder 
    generic map(
        Nbit => bsum
    )
    port map(
        a => extendedInputs(8),
        b => extendedInputs(9),
        cin => '0', 
        s => outputFirstLevel5,
        cout => open
    );

    -- second level 
    RCA_2_1: RippleCarryAdder 
    generic map(
        Nbit => bsum
    )
    port map(
        a => outputFirstLevel1,
        b => outputFirstLevel2,
        cin => '0', 
        s => outputSecondLevel1,
        cout => open
    );

    RCA_2_2: RippleCarryAdder  
    generic map(
        Nbit => bsum
    )
    port map(
        a => outputFirstLevel3,
        b => outputFirstLevel4,
        cin => '0', 
        s => outputSecondLevel2,
        cout => open
    );

    RCA_2_3: RippleCarryAdder  
    generic map(
        Nbit => bsum
    )
    port map(
        a => outputFirstLevel5,
        b => extendedBias,
        cin => '0', 
        s => outputSecondLevel3,
        cout => open
    );

    -- third level
    RCA_3_1: RippleCarryAdder 
    generic map(
        Nbit => bsum
    )
    port map(
        a => outputSecondLevel1,
        b => outputSecondLevel2,
        cin => '0', 
        s => outputThirdLevel,
        cout => open
    );

    -- fourth (last) level 
    RCA_4_1: RippleCarryAdder  
    generic map(
        Nbit => bsum
    )
    port map(
        a => outputThirdLevel,
        b => outputSecondLevel3,
        cin => '0', 
        s => output,
        cout => open
    );

end architecture;