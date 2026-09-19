library IEEE;
use IEEE.std_logic_1164.all;

entity HalfAdder is 
    port (
        a    : in  std_logic;
        b    : in  std_logic;
        s    : out std_logic;
        cout : out std_logic
    );
end entity;    

architecture dataflow of HalfAdder is 
begin 

    s    <= a xor b;
    cout <= a and b;
    
end architecture;  