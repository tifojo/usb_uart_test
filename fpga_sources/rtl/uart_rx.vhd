library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    port(
        clk: in std_logic;
        rx: in std_logic;
        data: out std_logic_vector(7 downto 0);
        data_strobe: out std_logic
    );
end;

architecture rtl of uart_rx is
    type state_type is (idle, start_bit, data_bit, stop_bit);

    type register_type is record
        state: state_type;
        oversample_counter: unsigned(2 downto 0);
        bit_counter: unsigned(2 downto 0);
        data_shift_reg: std_logic_vector(7 downto 0);
    end record;

    constant regs_init: register_type := (
        state => idle,
        oversample_counter => (others => '0'),
        bit_counter => (others => '0'),
        data_shift_reg => (others => '0')
    );

    signal regs, regs_next: register_type;

    -- State vector gets a local synchronous reset
    signal state_machine_reset: std_logic;

    -- Synchronize rx signal
    signal rx_sync: std_logic;

    constant CLK_PER_BIT: integer := 8;
begin
    reset_sync: entity work.sync
        generic map( init => '1' )
        port map(
            clk => clk,
            i => '0',
            o => state_machine_reset
        );

    rx_synchronizer: entity work.sync
        generic map( init => '1' )
        port map(
            clk => clk,
            i => rx,
            o => rx_sync
        );

    process(clk)
    begin
        if rising_edge(clk) then
            -- Synchronous reset for state vector
            if state_machine_reset = '1' then
                regs <= regs_init;
            else
                regs <= regs_next;
            end if;
        end if;
    end process;

    process(all)
        variable next_v: register_type;
    begin
        next_v := regs;
        data_strobe <= '0';

        -- oversample_counter keeps track of position within each bit
        if regs.state /= idle then
            next_v.oversample_counter := regs.oversample_counter + 1;
        end if;

        case regs.state is
            when idle =>
                if rx_sync = '0' then
                    -- start bit received
                    next_v.state := start_bit;
                    next_v.oversample_counter := (others => '0');
                    next_v.bit_counter := (others => '0');
                end if;
            when start_bit =>
                if regs.oversample_counter = CLK_PER_BIT/2 - 1 then
                    -- centered on data eye of start bit
                    next_v.state := data_bit;
                    next_v.oversample_counter := (others => '0');
                end if;
            when data_bit =>
                if regs.oversample_counter = CLK_PER_BIT - 1 then
                    -- center of data eye, sample the bit
                    next_v.data_shift_reg := rx_sync & regs.data_shift_reg(7 downto 1);
                    if regs.bit_counter = 7 then
                        next_v.state := stop_bit;
                    else
                        next_v.bit_counter := regs.bit_counter + 1;
                    end if;
                end if;
            when stop_bit =>
                if regs.oversample_counter = CLK_PER_BIT - 1 then
                    -- could check for framing error here
                    next_v.state := idle;
                    data_strobe <= '1';
                end if;
        end case;

        regs_next <= next_v;
    end process;

    data <= regs.data_shift_reg;
end;