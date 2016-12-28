library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    port(
        clk: in std_logic;
        data: in std_logic_vector(7 downto 0);
        tx_request: in std_logic;
        tx_done: out std_logic;
        tx: out std_logic
    );
end;

architecture rtl of uart_tx is
    type register_type is record
        tx_buffer: std_logic_vector(8 downto 0); -- data word plus start bit
        tx_active: std_logic;
        oversample_counter: unsigned(2 downto 0);
        bit_counter: unsigned(3 downto 0);
    end record;

    constant regs_init: register_type := (
        tx_buffer => (others => '1'),
        tx_active => '0',
        oversample_counter => (others => '0'),
        bit_counter => (others => '0')
    );

    signal regs: register_type := regs_init;
    signal regs_next: register_type;

    constant CLK_PER_BIT: integer := 8;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            regs <= regs_next;
        end if;
    end process;

    process(all)
        variable next_v: register_type;
    begin
        next_v := regs;
        tx_done <= '0';

        if regs.tx_active = '0' then
            -- idle
            if tx_request = '1' then
                -- latch input with start bit appended
                next_v.tx_buffer := data & '0';
                next_v.tx_active := '1';
                next_v.bit_counter := (others => '0');
            end if;
        else
            next_v.oversample_counter := regs.oversample_counter + 1;
            if regs.oversample_counter = CLK_PER_BIT - 1 then
                if regs.bit_counter = 9 -- start + data + stop transmitted
                then
                    -- done transmitting
                    next_v.tx_active := '0';
                    tx_done <= '1';
                else
                    -- shift out the next bit
                    next_v.tx_buffer := '1' & regs.tx_buffer(8 downto 1);
                    next_v.bit_counter := regs.bit_counter + 1;
                end if;
            end if;
        end if;

        regs_next <= next_v;
    end process;

    tx <= regs.tx_buffer(0);
end;