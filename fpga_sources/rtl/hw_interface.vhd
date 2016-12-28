library ieee;
use ieee.std_logic_1164.all;

entity hw_interface is
    port(
        sysclk: in std_logic; -- 12 MHz system clock
        led: out std_logic_vector(0 downto 0);
        uart_txd_in: in std_logic;
        uart_rxd_out: out std_logic
    );
end;

architecture structural of hw_interface is
    signal clk_96mhz: std_logic;
    signal rx_data: std_logic_vector(7 downto 0);
    signal rx_data_strobe: std_logic;
    signal tx_data: std_logic_vector(7 downto 0);
    signal tx_request: std_logic;
    signal tx_done: std_logic;

    attribute mark_debug: string;
    attribute mark_debug of rx_data: signal is "true";
    attribute mark_debug of rx_data_strobe: signal is "true";
    attribute mark_debug of tx_data: signal is "true";
    attribute mark_debug of tx_request: signal is "true";
    attribute mark_debug of tx_done: signal is "true";
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
            data => rx_data,
            data_strobe => rx_data_strobe
        );

    uart_tx: entity work.uart_tx
        port map(
            clk => clk_96mhz,
            tx => uart_rxd_out,
            data => tx_data, -- XXX temporary
            tx_request => tx_request,
            tx_done => tx_done
        );

    trigger_reply: entity work.trigger_reply
        port map(
            clk => clk_96mhz,
            rx_data_strobe => rx_data_strobe,
            tx_data => tx_data,
            tx_request => tx_request,
            tx_done => tx_done
        );
end;