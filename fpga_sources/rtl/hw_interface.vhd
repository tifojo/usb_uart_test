library ieee;
use ieee.std_logic_1164.all;

entity hw_interface is
	port(
		sysclk: in std_logic; -- 12 MHz system clock
		led: out std_logic_vector(0 downto 0)
	);
end;

architecture structural of hw_interface is
begin
	led(0) <= sysclk;
end;