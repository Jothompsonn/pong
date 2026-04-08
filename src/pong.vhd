library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity pong is
    port(
        CLK: in std_logic; 
        KEY: in std_logic_vector(1 downto 0);
        LEDR: out std_logic_vector(9 downto 0) 
    ); 
end pong; 


architecture rtl of pong is 
    type direction is (left, right);
    signal dir_tracker: direction;
begin 
    process(CLK, KEY(1), KEY(0)) 
        variable light_pos: natural range 0 to 10 := 1;
    begin 
        if rising_edge(clk) then
            -- Pong logic 
            case dir_tracker is 
                when LEFT => 
                    if light_pos /= 0 then 
                        light_pos  := light_pos - 1;
                    elsif  KEY(0)'event and KEY(0) = '0' then
                        dir_tracker <= RIGHT;
                        light_pos := 1;
                    else 
                        dir_tracker <= RIGHT;
                        light_pos := 1;
                        -- add code here to increment the Right Players Score counter 
                    end if;
                when RIGHT => 
                    if light_pos /= 10 then 
                        light_pos := light_pos + 1;
                    elsif KEY(1)'event and KEY(1) = '0' then 
                        dir_tracker <= LEFT;
                        light_pos := 9;
                    else 
                        dir_tracker <= LEFT;
                        light_pos := 9;
                        -- add code here to increment the LEFT Players Score counter 
                        end if;
                end case;
            end if;
        LEDR <= (others => '0'); 
        LEDR(light_pos) <= '1';
    end process;
end rtl;

