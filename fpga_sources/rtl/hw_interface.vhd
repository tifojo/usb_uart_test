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
    signal uart_data: std_logic_vector(7 downto 0);
    signal uart_data_strobe: std_logic;

    attribute mark_debug: string;
    attribute mark_debug of uart_data: signal is "true";
    attribute mark_debug of uart_data_strobe: signal is "true";
begin
    clocking: entity work.clocking
        port map(
            clk_12mhz => sysclk,
            clk_96mhz => clk_96mhz,
            locked => led(0)
        );

    uart_rx: entity work.uart_rx
        port map(
            clk => clk_96mhz,
            rx => uart_txd_in,
            data => uart_data,
            data_strobe => uart_data_strobe
        );

    ja(0) <= uart_data_strobe;
end;