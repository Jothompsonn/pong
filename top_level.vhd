--top_level.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
	generic (
			DELAY_NUM: natural range 0 to 10000000 := 10000000
	);
    port(
        CLK  : in  std_logic;
        rst  : in  std_logic;
        KEY  : in  std_logic_vector(1 downto 0);

        LEDR : out std_logic_vector(9 downto 0);

        HEX0 : out std_logic_vector(6 downto 0); -- right player score
        HEX1 : out std_logic_vector(6 downto 0)  -- left player score
    );
end top_level;

architecture rtl of top_level is

    -- score registers
    signal score_left  : integer range 0 to 9 := 0;
    signal score_right : integer range 0 to 9 := 0;
	 signal clk_delay : std_logic := '0';

    -- pulses from pong
    signal score_left_pulse  : std_logic;
    signal score_right_pulse : std_logic;

  
    -- 7-Segment Decoder Function 

    function to_7seg(num: integer) return std_logic_vector is
    begin
        case num is
            when 0 => return "1000000";
            when 1 => return "1111001";
            when 2 => return "0100100";
            when 3 => return "0110000";
            when 4 => return "0011001";
            when 5 => return "0010010";
            when 6 => return "0000010";
            when 7 => return "1111000";
            when 8 => return "0000000";
            when 9 => return "0010000";
            when others => return "1111111";
        end case;
    end function;

begin
	process(clk, clk_delay)
		variable count : natural range DELAY_NUM'range := 0;
		begin 
			if rising_edge(clk) then 
				if count >= DELAY_NUM then
					count := 0; 
					clk_delay <= not clk_delay;
				else
					count := count + 1; 
				end if;
			end if;
		end process;
   
    -- instantiate pong 
    pong_inst : entity work.pong
        port map(
            CLK  => clk_delay,
            rst  => rst,
            KEY  => KEY,
            LEDR => LEDR,

            score_left_pulse  => score_left_pulse,
            score_right_pulse => score_right_pulse
        );

    -- Score Counter Logic
    process(clk_delay)
    begin
        if rising_edge(clk_delay) then
            if rst = '1' then
                score_left  <= 0;
                score_right <= 0;
            else
                -- left player scores
                if score_left_pulse = '1' then
                    if score_left < 9 then
                        score_left <= score_left + 1;
                    end if;
                end if;

                -- right player scores
                if score_right_pulse = '1' then
                    if score_right < 9 then
                        score_right <= score_right + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    
    -- drive 7-Segment Displays
    
    HEX0 <= to_7seg(score_right); -- right side
    HEX1 <= to_7seg(score_left);  -- left side

end rtl;