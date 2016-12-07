library ieee;
use ieee.std_logic_1164.all;

Library unisim;
use unisim.vcomponents.all;

entity clocking is
    port(
        clk_12mhz: in std_logic;
        clk_96mhz: out std_logic;
        locked: out std_logic
    );
end;

architecture structural of clocking is
    signal mmcm_out: std_logic;
    signal clock_feedback: std_logic;
begin
    -- instantiate MMCM with local feedback
    -- input clock: 12 MHz
    -- output clock: 96 MHz
    clock_manager: MMCME2_BASE
        generic map(
            CLKIN1_PERIOD => 83.33,
            CLKFBOUT_MULT_F => 64.000,
            CLKOUT0_DIVIDE_F => 8.000
        )
        port map(
            CLKIN1 => clk_12mhz,
            CLKFBOUT => clock_feedback,
            CLKFBIN => clock_feedback,
            CLKOUT0 => mmcm_out,
            LOCKED => locked,

            RST => '0',
            PWRDWN => '0'
        );

    clock_buffer: BUFG
        port map(
            I => mmcm_out,
            O => clk_96mhz
        );
end;