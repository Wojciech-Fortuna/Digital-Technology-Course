library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity light_effect is
    port (
        clk       : in std_logic;
        speed_btn : in std_logic;
        dir_btn   : in std_logic;
        segments1 : out std_logic_vector(6 downto 0);
        segments2 : out std_logic_vector(6 downto 0)
    );
end light_effect;

architecture behavioral of light_effect is
    signal segment_pattern : std_logic_vector(13 downto 0); -- 2 x 7-segmentowe wyœwietlacze
    signal current_pos     : integer range 0 to 7 := 0; -- pozycja efektu œwietlnego
    signal direction       : std_logic := '1'; -- '1' w prawo, '0' w lewo
    signal speed           : std_logic := '0'; -- '0' wolniej, '1' szybciej
    signal speed_btn_last, dir_btn_last : std_logic := '1'; -- wartoœci zmiennych w poprzednim cyklu

    -- przesuwaj¹ce siê rejestry - u¿yte do debouncing-u
    signal speed_btn_shift : std_logic_vector(7 downto 0) := (others => '1');
	signal dir_btn_shift   : std_logic_vector(7 downto 0) := (others => '1');
begin

    -- obs³uga lewego przycisku (steruj¹cego prêdkoœci¹)
    process(clk)
    begin
        if rising_edge(clk) then
            speed_btn_shift <= speed_btn_shift(6 downto 0) & speed_btn;
            if speed_btn_shift = "00000000" and speed_btn_last = '1' then
                speed <= not speed; -- jeœli przycisk jest wciœniêty zmieñ wartoœæ na przeciwn¹ 
                speed_btn_last <= '0';
            end if;
            if speed_btn_shift = "11111111" then
				speed_btn_last <= '1';
			end if;
        end if;
    end process;

    --- obs³uga prawego przycisku (steruj¹cego kierunkiem)
    process(clk)
    begin
        if rising_edge(clk) then
            dir_btn_shift <= dir_btn_shift(6 downto 0) & dir_btn;
            if dir_btn_shift = "00000000" and dir_btn_last = '1' then
                direction <= not direction; -- jeœli przycisk jest wciœniêty zmieñ kierunek
                dir_btn_last <= '0';
            end if;
            if dir_btn_shift = "11111111" then
				dir_btn_last <= '1';
			end if;
        end if;
    end process;

    -- Obs³uga przemieszczania siê efektu œwietlnego
    process(clk)
    variable counter : integer range 0 to 30_000_000;
    begin
        if rising_edge(clk) then
            counter := counter + 1;
            if (speed = '0' and counter >= 25_000_000) or (speed = '1' and counter >= 5_000_000) then
                counter := 0;
                if direction = '1' then
                    if current_pos < 7 then
                        current_pos <= current_pos + 1;
                    else
                        current_pos <= 0;
                    end if;
                else
                    if current_pos > 0 then
                        current_pos <= current_pos - 1;
                    else
                        current_pos <= 7;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Ustawianie odpowiednich wartoœci wyœwietlaczy 7-segmentowych
    process(current_pos)
    begin
        case current_pos is
        when 0 => segment_pattern <= "11111101111110"; -- A1 A2
        when 1 => segment_pattern <= "11111111111100"; -- A2 B2
        when 2 => segment_pattern <= "11111111111001"; -- B2 C2
        when 3 => segment_pattern <= "11111111110011"; -- C2 D2
        when 4 => segment_pattern <= "11101111110111"; -- D1 D2
        when 5 => segment_pattern <= "11001111111111"; -- D1 E1
        when 6 => segment_pattern <= "10011111111111"; -- E1 F1
        when 7 => segment_pattern <= "10111101111111"; -- A1 F1
        when others => segment_pattern <= (others => 'Z');
        end case;
    end process;

    segments1 <= segment_pattern(13 downto 7);
    segments2 <= segment_pattern(6 downto 0);

end behavioral;
