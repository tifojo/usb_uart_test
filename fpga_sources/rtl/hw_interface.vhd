library ieee;
use ieee.std_logic_1164.all;

entity hw_interface is
    port(
        sysclk: in std_logic; -- 12 MHz system clock
        led: out std_logic_vector(0 downto 0);
        uart_txd_in: in std_logic;
        ja: out std_logic_vector(0 downto 0)
    );
end;

architecture structural of hw_interface is
    signal clk_96mhz: std_logic;
begin
    clocking: entity work.clocking
        port map(
            clk_12mhz => sysclk,
            clk_96mhz => clk_96mhz,
            locked => led(0)
        );

    uart_sync: entity work.sync
        port map(
            clk => clk_96mhz,
            i => uart_txd_in,
            o => ja(0)
        );
end;