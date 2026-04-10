library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use work.pwm;

entity pong is
    port(
        CLK, rst: in std_logic; 
        KEY: in std_logic_vector(1 downto 0);
        LEDR: out std_logic_vector(9 downto 0) 
    ); 
end pong; 


architecture rtl of pong is 
    type direction is (left, right);
    signal dir_tracker: direction := RIGHT;
    signal led_pwm: std_logic_vector(3 downto 0);
    signal light_pos: natural range 0 to 9 := 1;
begin 
    LIGHT_POS_PROC: process(CLK, rst, KEY(1), KEY(0)) 
    begin 
        if rst  = '1' then 
            light_pos <= 1;
            dir_tracker <= RIGHT;
            -- add rest score logic
        elsif rising_edge(clk) then
            -- Pong logic 
            case dir_tracker is 
                when LEFT => 
                    if light_pos /= 0 then 
                        light_pos  <= light_pos - 1;
                    elsif  KEY(0)'event and KEY(0) = '0' then
                        dir_tracker <= RIGHT;
                        light_pos <= 1;
                    else 
                        dir_tracker <= RIGHT;
                        light_pos <= 1;
                        -- add code here to increment the Right Players Score counter 
                    end if;
                when RIGHT => 
                    if light_pos /= 9 then 
                        light_pos <= light_pos + 1;
                    elsif KEY(1)'event and KEY(1) = '0' then 
                        dir_tracker <= LEFT;
                        light_pos <= 8;
                    else 
                        dir_tracker <= LEFT;
                        light_pos <= 8;
                        -- add code here to increment the LEFT Players Score counter 
                        end if;
                end case;
            end if;

            if KEY(0)'event and KEY(0) = '0' then 
                -- Turns LED on button press
                LEDR(0) <= '1';
            else 
                -- Turns LED off otherwise
                LEDR(0) <= '0';
            end if;

            if KEY(1)'event and KEY(1) = '0' then 
                -- Turns LED on button press
                LEDR(9) <= '1';
            else 
                -- Turns LED off otherwise
                LEDR(9) <= '0';
            end if;

    end process;

    -- Should produce a duty_cycle of 75%, using formula duty_cycle_per = (duty_cycle * 100)/(2^pwm_bits - 1)
    -- Frequency if clk_hz is 50MHz is ~= 50hz
    bright_pwm: entity work.pwm generic map(pwm_bits => 10, clk_cnt_len => 1000)
                                port map( clk => clk, rst => rst, duty_cycle => x"300", pwm_out => led_pwm(0));

    -- Should produce a duty_cycle of 50%, using formula duty_cycle_per = (duty_cycle * 100)/(2^pwm_bits - 1)
    -- Frequency if clk_hz is 50MHz is ~= 50hz
    dimmer_pwm: entity work.pwm generic map(pwm_bits => 10, clk_cnt_len => 1000)
                                port map( clk => clk, rst => rst, duty_cycle => x"200", pwm_out => led_pwm(1));

    -- Should produce a duty_cycle of 25%, using formula duty_cycle_per = (duty_cycle * 100)/(2^pwm_bits - 1)
    -- Frequency if clk_hz is 50MHz is ~= 50hz
    dimmest_pwm: entity work.pwm generic map(pwm_bits => 10, clk_cnt_len => 1000)
                                port map( clk => clk, rst => rst, duty_cycle => x"100", pwm_out => led_pwm(2));

    PROC_PONG_LED_PROC: process(clk, rst)
    begin
        if rising_edge(clk) then
            case dir_tracker is 
                when LEFT => 
                    -- When the ball is traveling to the left it should have a trail of leds that are dimmer than the ball
                    case light_pos is 
                        when 0 | 9  => 
                            LEDR(8 downto 1)  <= (others => '0');
                        when 1 => 
                            LEDR(8 downto 1) <= ( 1 => led_pwm(0), 2 => led_pwm(1), 3 => led_pwm(2), others => '0');
                        when 2 => 
                            LEDR(8 downto 1) <= ( 2 => led_pwm(0), 3 => led_pwm(1), 4 => led_pwm(2),  others => '0');
                        when 3 => 
                            LEDR(8 downto 1) <= ( 3 => led_pwm(0), 4 => led_pwm(1), 3 => led_pwm(2), others => '0');
                        when 4 => 
                            LEDR(8 downto 1) <= ( 4 => led_pwm(0), 5 => led_pwm(1), 6 => led_pwm(2), others => '0');
                        when 5 => 
                            LEDR(8 downto 1) <= ( 5 => led_pwm(0), 6 => led_pwm(1), 7 => led_pwm(2), others => '0');
                        when 6 => 
                            LEDR(8 downto 1) <= ( 6 => led_pwm(0), 7 => led_pwm(1), 8 => led_pwm(2), others => '0');
                        when 7 => 
                            LEDR(8 downto 1) <= ( 7 => led_pwm(0), 8 => led_pwm(1), others => '0');
                        when 8 =>
                            LEDR(8 downto 1) <= ( 8 => led_pwm(0), others => '0');
                    end case;
                when RIGHT => 
                    -- When the ball is traveling to the right it should have a trail of leds that are dimmer than the ball
                    case light_pos is 
                        when 0 | 9 => 
                            LEDR(8 downto 1)  <= (others => '0');
                        when 1 => 
                            LEDR(8 downto 1) <= ( 1 => led_pwm(0), others => '0');
                        when 2 => 
                            LEDR(8 downto 1) <= ( 2 => led_pwm(0), 1 => led_pwm(1), others => '0');
                        when 3 => 
                            LEDR(8 downto 1) <= ( 3 => led_pwm(0), 2 => led_pwm(1), 1 => led_pwm(2), others => '0');
                        when 4 => 
                            LEDR(8 downto 1) <= ( 4 => led_pwm(0), 3 => led_pwm(1), 2 => led_pwm(2), others => '0');
                        when 5 => 
                            LEDR(8 downto 1) <= ( 5 => led_pwm(0), 4 => led_pwm(1), 3 => led_pwm(2), others => '0');
                        when 6 => 
                            LEDR(8 downto 1) <= ( 6 => led_pwm(0), 5 => led_pwm(1), 4 => led_pwm(2), others => '0');
                        when 7 => 
                            LEDR(8 downto 1) <= ( 7 => led_pwm(0), 6 => led_pwm(1), 5 => led_pwm(2), others => '0');
                        when 8 =>
                            LEDR(8 downto 1) <= ( 8 => led_pwm(0), 7 => led_pwm(1), 6 => led_pwm(2), others => '0');
                    end case;
                end case;
        end if;
    end process;
end rtl;

