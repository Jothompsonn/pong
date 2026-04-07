library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity pong is 
begin
    port(
        CLK: in std_logic; 
        KEY: in std_logic(1 downto 0);
        LEDR: out std_logic_vector(9 downto 0) 
    ); 
end final; 

architecture rtl of pong is 
    type direction is (left, right);
    signal dir_tracker: direction;
begin 
    process(CLK, KEY[1], KEY[0]) 
        variable light_pos: natural range 0 to 10 := 0;
    begin 
        if rising_edge(clk):
            case dir_tracker is 
                when LEFT => 
                    if light_pos /= 0 then 
                        light_pos 
         
    end;
end rtl;

