library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- testbench for uart_tx

entity uart_tx_tb is
end;

architecture rtl of uart_tx_tb is
    signal clk: std_logic := '0';
    constant CLK_PERIOD: time := 10.4 ns; -- 96 MHz

    signal data: std_logic_vector(7 downto 0);
    signal tx_request: std_logic := '0';
    signal tx_done: std_logic;
begin
    clk <= not clk after CLK_PERIOD/2;

    uart_tx: entity work.uart_tx
        port map(
            clk => clk,
            tx => open,
            data => data,
            tx_request => tx_request,
            tx_done => tx_done
        );

    stimulus: process begin
        -- wait to see the initial state
        wait for 4*CLK_PERIOD;

        for i in 0 to 255 loop
            data <= std_logic_vector(to_unsigned(i, 8));
            tx_request <= '1';
            wait for CLK_PERIOD;
            tx_request <= '0';
            wait until falling_edge(tx_done);
        end loop;

        std.env.finish;
    end process;
end;