library ieee;
use ieee.std_logic_1164.all;

-- Xilinx device primitives
library unisim;
use unisim.vcomponents.all;

entity sync is
    generic(
        init: bit := '0'
    );
    port(
        clk: in std_logic;
        i: in std_logic; -- asynchronous input
        o: out std_logic -- synchronous output
    );
end;

architecture structural of sync is
    signal async_input: std_logic;
    signal metastable: std_logic;
    signal sync_output: std_logic;

    -- Force Vivado to place both registers in the same logic slice
    -- (for minimum routing delay)
    attribute async_reg: string;
    attribute async_reg of ff1: label is "true";
    attribute async_reg of ff2: label is "true";
begin
    async_input <= i;

    -- Instantiate a chain of two D flip flops
    -- The first FF samples the asynchronous signal
    ff1: FD
        generic map( INIT => init )
        port map(
            C => clk,
            D => async_input,
            Q => metastable
        );

    -- Second FF allows time for metastability resolution
    ff2: FD
        generic map( INIT => init )
        port map(
            C => clk,
            D => metastable,
            Q => sync_output
        );

    o <= sync_output;
end;