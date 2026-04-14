library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pong is
    port (
        CLK               : in  std_logic;
        rst               : in  std_logic;
        KEY               : in  std_logic_vector(1 downto 0);
        LEDR              : out std_logic_vector(9 downto 0);
        score_left_pulse  : out std_logic;
        score_right_pulse : out std_logic
    );
end pong;

architecture rtl of pong is
    type direction is (LEFT, RIGHT);

    signal dir_tracker         : direction := LEFT;
    signal led_pwm             : std_logic_vector(2 downto 0);
    signal light_pos           : natural range 0 to 9 := 1;
    signal score_left_pulse_i  : std_logic := '0';
    signal score_right_pulse_i : std_logic := '0';
	 constant one: std_logic_vector(7 downto 0) := (0 => '1', others => '0');
begin
    score_left_pulse  <= score_left_pulse_i;
    score_right_pulse <= score_right_pulse_i;

    LEDR(0) <= not KEY(0);
    LEDR(9) <= not KEY(1);

    LIGHT_POS_PROC : process(CLK, rst, key)
    begin
        if rst = '1' then
            light_pos           <= 1;
            dir_tracker         <= LEFT;
            score_left_pulse_i  <= '0';
            score_right_pulse_i <= '0';
        elsif rising_edge(CLK) then
            score_left_pulse_i  <= '0';
            score_right_pulse_i <= '0';

            case dir_tracker is
                when LEFT =>
                    if light_pos < 9 then
                        light_pos <= light_pos + 1;
                    elsif KEY(1) = '0' then
                        dir_tracker <= RIGHT;
                        light_pos   <= 8;
                    else
                        dir_tracker         <= RIGHT;
                        light_pos           <= 8;
                        score_right_pulse_i <= '1';
                    end if;

                when RIGHT =>
                    if light_pos > 0 then
                        light_pos <= light_pos - 1;
                    elsif KEY(0) = '0' then
                        dir_tracker <= LEFT;
                        light_pos   <= 1;
                    else
                        dir_tracker        <= LEFT;
                        light_pos          <= 1;
                        score_left_pulse_i <= '1';
                    end if;
            end case;
        end if;
    end process;
	
    bright_pwm : entity work.pwm
        generic map (
            pwm_bits    => 10,
            clk_cnt_len => 1000
        )
        port map (
            clk        => CLK,
            rst        => rst,
            duty_cycle => to_unsigned(768, 10),
            pwm_out    => led_pwm(0)
        );

    dimmer_pwm : entity work.pwm
        generic map (
            pwm_bits    => 10,
            clk_cnt_len => 1000
        )
        port map (
            clk        => CLK,
            rst        => rst,
            duty_cycle => to_unsigned(512, 10),
            pwm_out    => led_pwm(1)
        );

    dimmest_pwm : entity work.pwm
        generic map (
            pwm_bits    => 10,
            clk_cnt_len => 1000
        )
        port map (
            clk        => CLK,
            rst        => rst,
            duty_cycle => to_unsigned(256, 10),
            pwm_out    => led_pwm(2)
        );
		  

    PROC_PONG_LED_PROC : process(CLK, rst)
    begin
        if rst = '1' then
            LEDR(8 downto 1) <= (others => '0');
        elsif rising_edge(CLK) then
		  
		  /*
				if light_pos < 9 and light_pos > 0 then
					LEDR(8 downto 1) <= std_logic_vector(shift_left(unsigned(one), light_pos));
				else 
					LEDR(8 downto 1) <= (others => '0');
				end if;
				*/
				
		  
            case dir_tracker is
                when LEFT =>
                    case light_pos is
                        when 0 =>
                            LEDR(8 downto 1) <= (others => '0');
                        when 1 =>
                            LEDR(8 downto 1) <= (1 => led_pwm(0), 2 => led_pwm(1), 3 => led_pwm(2), others => '0');
                        when 2 =>
                            LEDR(8 downto 1) <= (2 => led_pwm(0), 3 => led_pwm(1), 4 => led_pwm(2), others => '0');
                        when 3 =>
                            LEDR(8 downto 1) <= (3 => led_pwm(0), 4 => led_pwm(1), 5 => led_pwm(2), others => '0');
                        when 4 =>
                            LEDR(8 downto 1) <= (4 => led_pwm(0), 5 => led_pwm(1), 6 => led_pwm(2), others => '0');
                        when 5 =>
                            LEDR(8 downto 1) <= (5 => led_pwm(0), 6 => led_pwm(1), 7 => led_pwm(2), others => '0');
                        when 6 =>
                            LEDR(8 downto 1) <= (6 => led_pwm(0), 7 => led_pwm(1), 8 => led_pwm(2), others => '0');
                        when 7 =>
                            LEDR(8 downto 1) <= (7 => led_pwm(0), 8 => led_pwm(1), others => '0');
                        when 8 =>
                            LEDR(8 downto 1) <= (8 => led_pwm(0), others => '0');
                        when others =>
                            LEDR(8 downto 1) <= (others => '0');
                    end case;

                when RIGHT =>
                    case light_pos is
                        when 0 =>
                            LEDR(8 downto 1) <= (others => '0');
                        when 1 =>
                            LEDR(8 downto 1) <= (1 => led_pwm(0), others => '0');
                        when 2 =>
                            LEDR(8 downto 1) <= (2 => led_pwm(0), 1 => led_pwm(1), others => '0');
                        when 3 =>
                            LEDR(8 downto 1) <= (3 => led_pwm(0), 2 => led_pwm(1), 1 => led_pwm(2), others => '0');
                        when 4 =>
                            LEDR(8 downto 1) <= (4 => led_pwm(0), 3 => led_pwm(1), 2 => led_pwm(2), others => '0');
                        when 5 =>
                            LEDR(8 downto 1) <= (5 => led_pwm(0), 4 => led_pwm(1), 3 => led_pwm(2), others => '0');
                        when 6 =>
                            LEDR(8 downto 1) <= (6 => led_pwm(0), 5 => led_pwm(1), 4 => led_pwm(2), others => '0');
                        when 7 =>
                            LEDR(8 downto 1) <= (7 => led_pwm(0), 6 => led_pwm(1), 5 => led_pwm(2), others => '0');
                        when 8 =>
                            LEDR(8 downto 1) <= (8 => led_pwm(0), 7 => led_pwm(1), 6 => led_pwm(2), others => '0');
                        when others =>
                            LEDR(8 downto 1) <= (others => '0');
                    end case;
            end case;
				
        end if;
		  
    end process;

end rtl;
