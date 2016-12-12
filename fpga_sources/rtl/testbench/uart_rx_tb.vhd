library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- testbench for uart_rx
-- based on Jasinski, Effective Coding with VHDL

entity uart_rx_tb is
end;

architecture rtl of uart_rx_tb is
    signal clk: std_logic := '0';
    constant CLK_PERIOD: time := 10.4 ns; -- 96 MHz

    -- UART interface
    signal rx: std_logic := '1';
    signal rx_data: std_logic_vector(7 downto 0);
    signal rx_strobe: std_logic;
    constant BIT_INTERVAL: time := 83.3 ns; -- 12 Mbaud

    -- test transactions
    signal transaction_data: std_logic_vector(7 downto 0);
    signal transaction_done: boolean;
begin
    clk <= not clk after CLK_PERIOD/2;

    uart_rx: entity work.uart_rx
        port map(
            clk => clk,
            rx => rx,
            data => rx_data,
            data_strobe => rx_strobe
        );

    driver: process
        variable tx_buffer: std_logic_vector(9 downto 0);
    begin
        wait on transaction_data'transaction;

        tx_buffer := '1' & transaction_data & '0';
        for i in tx_buffer'reverse_range loop
            rx <= tx_buffer(i);
            wait for BIT_INTERVAL;
        end loop;

        -- for clarity, wait a few extra bit intervals
        -- wait for 2*BIT_INTERVAL;

        transaction_done <= true;
    end process;

    stimulus: process begin
        -- allow time for state machine to come out of reset
        wait for 4*CLK_PERIOD;

        for i in 0 to 255 loop
            transaction_data <= std_logic_vector(to_unsigned(i, 8));
            wait on transaction_done'transaction;
        end loop;

        wait for BIT_INTERVAL;
        std.env.finish;
    end process;
end;