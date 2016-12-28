library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trigger_reply is
    port(
        clk: in std_logic;
        -- rx_data: in std_logic_vector(7 downto 0);
        rx_data_strobe: in std_logic;
        tx_data: out std_logic_vector(7 downto 0);
        tx_request: out std_logic;
        tx_done: in std_logic
    );
end;

architecture rtl of trigger_reply is
    signal reply_active: std_logic := '0';
    signal reply_counter: unsigned(11 downto 0) := (others => '0');
    constant BURST_LENGTH: integer := 4096;
begin
    process(clk) begin
        if rising_edge(clk) then
            if reply_active = '0' then
                -- idle
                if rx_data_strobe = '1' then
                    reply_active <= '1';
                    reply_counter <= (others => '0');
                end if;
            else
                if tx_done = '1' then
                    reply_counter <= reply_counter + 1;
                end if;
                if reply_counter = BURST_LENGTH - 1 then
                    reply_active <= '0';
                end if;
            end if;
        end if;
    end process;

    tx_request <= reply_active;
    tx_data <= std_logic_vector(reply_counter(7 downto 0));
end;