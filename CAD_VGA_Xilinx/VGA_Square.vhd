library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

entity VGA_Square is
  port ( CLK_24MHz		: in std_logic;
			RESET				: in std_logic;
			BtnUp          : in std_logic_vector(3 downto 0);  --use Key(0) to BtnUP
			end_game       : in bit;
			score          : out integer;
			lose           : out bit;
			ColorOut			: out std_logic_vector(5 downto 0); -- RED & GREEN & BLUE
			SQUAREWIDTH		: in std_logic_vector(7 downto 0);
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0)
  );
end VGA_Square;

architecture Behavioral of VGA_Square is
  
  signal ColorOutput: std_logic_vector(5 downto 0);
  signal SquareX: std_logic_vector(9 downto 0):="1111111111";  
  signal SquareY: std_logic_vector(9 downto 0):="1111111111";  
  signal SquareX_b: std_logic_vector(9 downto 0):="1111111111";  
  signal SquareY_b: std_logic_vector(9 downto 0):="1111111111";  
  signal SquareX_t: std_logic_vector(9 downto 0):="0000011111";  
  signal SquareY_t: std_logic_vector(9 downto 0):="0000000000";  
  signal SquareXMoveDir, SquareYMoveDir: std_logic := '0';
  --constant SquareWidth: std_logic_vector(4 downto 0) := "11001";
  constant BulletWidth: std_logic_vector(4 downto 0) := "01000";
  signal SquareXmin: std_logic_vector(9 downto 0); -- := "0000000001";
  signal SquareXmax: std_logic_vector(9 downto 0); -- := "1010000000"-SquareWidth;
  signal SquareYmin: std_logic_vector(9 downto 0); -- := "0000000001";
  signal SquareYmax: std_logic_vector(9 downto 0); -- := "0111100000"-SquareWidth;
  signal ColorSelect: std_logic_vector(2 downto 0) := "001";
  signal Prescaler: std_logic_vector(30 downto 0); 
  signal Prescaler_b: std_logic_vector(30 downto 0); 
  signal Prescaler_t: std_logic_vector(30 downto 0); 
--   signal Prescaler_c: std_logic_vector(30 downto 0); 
  --location of wall first
  signal wallX1: std_logic_vector(9 downto 0):="1111111111";
  signal wallY1: std_logic_vector(9 downto 0):="1111111111";
  --location of wall second
  signal wallX2: std_logic_vector(9 downto 0):="1111111111";
  signal wallY2: std_logic_vector(9 downto 0):="1111111111";
  --use in random function 
  signal pseudo_rand: std_logic_vector(31 downto 0);-- :=(others => '0');
  signal p_rand1: std_logic_vector(9 downto 0);
  signal p_rand2: std_logic_vector(9 downto 0);
  signal score_signal: integer range 0 to 10 :=0;
  signal target_reset_flag : bit  := '0';
  
begin
	 
  
		
	square: process(CLK_24MHz, RESET)
	variable lock_key: integer range 0 to 3 :=2;
    variable lock_key_2: integer range 0 to 3 :=2;
	variable timer_up_key : integer range 0 to 6 :=0;
    variable timer_up_key_2 : integer range 0 to 6 :=0;
	begin
	--initialization
		if RESET = '1' then
			Prescaler <= (others => '0');
			SquareX <= "1010000000" - Squarewidth;  
         SquareY <= "0111100000" - Squarewidth;
			lock_key := 2;
            lock_key_2 := 2;
			timer_up_key := 0;
            timer_up_key_2 := 0;
		elsif rising_edge(CLK_24MHz) then
		   if (end_game = '0') then
			Prescaler <= Prescaler + 1;	 
			if Prescaler = "0111010100110000000" then  -- Activated every 0,01 sec
			--wall moves upward when player pushes button
			if(BtnUp(1) = '0') then  
				lock_key := 1;
			end if;
            if(BtnUp(0) = '0') then  
				lock_key_2 := 1;
			end if;
			
			
			if (lock_key = 1) then
			   timer_up_key := timer_up_key + 1;
			end if;
			
			if (timer_up_key = 5) then
			   timer_up_key := 0;
			   lock_key := 0;
		   end if;

           if (lock_key_2 = 1) then
                timer_up_key_2 := timer_up_key_2 + 1;
            end if;
            
            if (timer_up_key_2 = 5) then
                timer_up_key_2 := 0;
                lock_key_2 := 0;
            end if;

				if( lock_key = 1 ) then
				   
					if SquareX > SquareXmin then
						SquareX <= SquareX - 1;
					else
                        SquareX <= SquareX;
					end if;
                end if;
				if( lock_key_2 = 1 ) then
					if SquareX < SquareXmax then
						SquareX <= SquareX + 1;
					else
				      SquareX <= SquareX;
                    end if;
                --else
                --    SquareX <= SquareX;
			   	end if;	 

                
		   --end if;		  
				Prescaler <= (others => '0');
			end if;
			end if;
		end if;

	end process square; 

	bullet: process(CLK_24MHz, RESET)
    variable flag_b : bit := '1';
	-- variable lock_key: integer range 0 to 3 :=2;
	-- variable timer_up_key : integer range 0 to 196 :=0;
	
    begin
	--initialization
		if RESET = '1' then
			Prescaler_b <= (others => '0');
			--SquareX_b <= "1010000000";  
            SquareY_b <= SquareYmax - Squarewidth;
			-- lock_key := 0;
			-- timer_up_key := 0;
		elsif rising_edge(CLK_24MHz) then
		   if (end_game = '0') then
			Prescaler_b <= Prescaler_b + 1;	 
			if Prescaler_b = "0000111010100110000" then  -- Activated every 0,01 sec
			--wall moves upward when player pushes button
			-- if(SquareY_b = "0000000000") then  
			-- 	lock_key := 1;
			-- end if;
			
            if (flag_b = '1') then
                SquareX_b <= SquareX;
                flag_b := '0';
            end if;

		-- 	if (lock_key = 1) then
		-- 	   timer_up_key := timer_up_key + 1;
		-- 	end if;
			
		-- 	if (timer_up_key = 180) then
		-- 	   timer_up_key := 0;
		-- 	   lock_key := 0;
		--    end if;
				-- if( lock_key = 0) then
					if SquareY_b > SquareYmin then
						SquareY_b <= SquareY_b - 1;
					else
				      SquareY_b <= SquareYmax - SquareWidth;
                    --   lock_key := 0;
                      flag_b := '1';
			   	    end if;	 
		--    end if;		  
                Prescaler_b <= (others => '0');
			end if;
			end if;
		end if;
	end process bullet;
	

    target: process(CLK_24MHz, RESET)
    variable flag_y : bit := '0';
    variable flag_x : bit := '1';
    variable hit_flag : bit := '0';
    -- variable flag_rand : bit := '1';
    -- variable random_x: integer := 1; -- std_logic_vector(9 downto 0) :=(others => '1');

    begin
	--initialization
		if RESET = '1' then
			Prescaler_t <= (others => '0');
            SquareX_t <= "0101000000";  
            SquareY_t <= SquareYmin;
            lose <= '0';
			

		elsif rising_edge(CLK_24MHz) then
		   if (end_game = '0') then
			Prescaler_t <= Prescaler_t + 1;	 
			if Prescaler_t = "0111010100110000000" then  -- Activated every 0,01 sec


                if (SquareX_b > SquareX_t and SquareX_b < SquareX_t + SquareWidth and SquareY_b <= SquareY_t + SquareWidth and SquareY_b >= SquareY_t) or
                    (SquareX_b + BulletWidth > SquareX_t and SquareX_b + BulletWidth < SquareX_t + SquareWidth and SquareY_b <= SquareY_t + SquareWidth and SquareY_b >= SquareY_t) then
                -- if (SquareY_b <= SquareYmin + SquareWidth) then
                --         SquareX_t <= "0101000000";  
                --         SquareY_t <= SquareYmin;
                            hit_flag := '1';
                            score_signal <= score_signal + 1;
                end if;

                if (SquareX_t > SquareX and SquareX_t < SquareX + SquareWidth and SquareY_t + SquareWidth >= SquareY) or
                    (SquareX_t + SquareWidth > SquareX and SquareX_t + SquareWidth < SquareX + SquareWidth and SquareY_t + SquareWidth >= SquareY) then
                -- if (SquareY_b <= SquareYmin + SquareWidth) then
                --         SquareX_t <= "0101000000";  
                --         SquareY_t <= SquareYmin;
                            lose <= '1';
                end if;
                -- SquareX_t <= "0101000000";  
                -- SquareY_t <= SquareYmin;

                -- if (flag_rand = '1') then
                --     random_x := CONV_INTEGER(pseudo_rand(3 downto 0));
                --     flag_rand := '0';
                -- end if;

                if (SquareY_t >= SquareYmax) then
                    flag_y := '0';
                elsif (SquareY_t <= SquareYmin) then
                    flag_y := '1';
                end if;	 
 
                if hit_flag = '1' then
                    SquareY_t <= SquareYmin;
                    hit_flag := '0';
                elsif (flag_y = '1' and SquareY_t < SquareYmax) then
                    SquareY_t <= SquareY_t + 1;
                elsif (flag_y = '0' and SquareY_t > SquareYmin) then
                    SquareY_t <= SquareY_t - 1;
                -- else
                --     SquareY_t <= SquareYmin;
                --     hit_flag := '0';
                end if;


                if (SquareX_t >= SquareXmax) then
                    flag_x := '0';
                elsif (SquareX_t <= SquareXmin) then
                    flag_x := '1';
                end if;	 
 
                if hit_flag = '1' then
                    SquareX_t <= SquareXmin;
                    hit_flag := '0';
                elsif (flag_x = '1' and SquareX_t < SquareXmax) then
                    SquareX_t <= SquareX_t + 2;
                elsif (flag_x = '0' and SquareX_t > SquareXmin) then
                    SquareX_t <= SquareX_t - 2;
                -- else
                --     SquareX_t <= SquareXmin;
                --     hit_flag := '0';
                end if;


                Prescaler_t <= (others => '0');
			end if;
			end if;
		end if;
	end process target;




    -- process( CLK_24MHz, RESET)
	-- begin
	-- if RESET = '1' then
	-- 	lose <= '0';
	-- elsif( rising_edge(CLK_24MHz))then -- conflict to first wall
	-- 	if (((wallX1 <= SquareX+ SquareWidth AND wallX1 >= SquareX) OR (wallX1+ SquareWidth >= SquareX AND wallX1 <= SquareX))
	-- 		AND (SquareY <= p_rand1 OR SquareY + squareWidth >= p_rand1 + squareWidth+ squareWidth+ squareWidth+SquareWidth )) then
	-- 		lose <= '1';
	-- 	end if;
	-- 	--conflict to second wall
	-- 	--if (((wallX2 <= SquareX+ SquareWidth AND wallX2 >= SquareX) OR (wallX2+ SquareWidth >= SquareX AND wallX2 <= SquareX))
	-- 	--	AND (SquareY <= p_rand2 OR SquareY + squareWidth >= p_rand2 + squareWidth+ squareWidth+ squareWidth+SquareWidth )) then
	-- 	--	lose <= '1';
	-- 	--end if;
	-- end if;	
	-- end process;

    -- conflict: process(CLK_24MHz, RESET)
    -- begin
	-- --initialization
	-- 	if RESET = '1' then
	-- 		Prescaler_c <= (others => '0');
    --         target_reset_flag <= '0';
	-- 	elsif rising_edge(CLK_24MHz) then
	-- 	   if (end_game = '0') then
	-- 		Prescaler_c <= Prescaler_c + 1;	 
	-- 		if Prescaler_c = "0111010100110000000" then  -- Activated every 0,01 sec

    --             if (SquareX_b > SquareX_t and SquareX_b < SquareX_t + SquareWidth and SquareY_b >= SquareX_t + SquareWidth) or
    --                (SquareX_b + BulletWidth > SquareX_t and SquareX_b + BulletWidth < SquareX_t + SquareWidth and SquareY_b >= SquareX_t + SquareWidth) then
    --                     target_reset_flag <= '1';
    --             end if;

    --             Prescaler_c <= (others => '0');
	-- 		end if;
	-- 		end if;
	-- 	end if;
	-- end process conflict;

	

    rand: process(CLK_24MHz, RESET)
    -- maximal length 32-bit xnor LFSR
        function lfsr32(x : std_logic_vector(31 downto 0)) return std_logic_vector is
        begin
            return x(30 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31));
        end function;
        begin
            if rising_edge(CLK_24MHz) then
                if RESET='0' then
                    pseudo_rand <= (others => '0');
                else
                    pseudo_rand <= lfsr32(pseudo_rand);
                end if;
            end if;
    end process rand;


    -- flag_plus : 0-> initial state, 1 -> must increment score , 2 -> scre is incremented and we are in area after wall
	-- process(CLK_24MHz, RESET)
	-- variable flag_rst : bit:= '0';
	-- variable flag_plus1 : integer range 0 to 3 := 0;
	-- variable flag_plus2 : integer range 0 to 3:= 0;
	-- begin
	-- if(RESET = '1')then
	-- 	flag_rst := '1';
	-- 	score_signal <= 0;
	-- 	flag_plus1 := 0;
	--    flag_plus2 := 0;
	-- elsif rising_edge(CLK_24MHz)then 

	-- 	if (SquareX_b > SquareX_t and SquareX_b < SquareX_t + SquareWidth and SquareY_b >= SquareX_t + SquareWidth) or
    --         (SquareX_b + BulletWidth > SquareX_t and SquareX_b + BulletWidth < SquareX_t + SquareWidth and SquareY_b >= SquareX_t + SquareWidth) then
    --         score_signal <= score_signal + 1;

	-- 	end if;
	-- end if;
	-- end process;

	score <= score_signal;

   --display: 1.square, 2.perimeter, 3.first wall, 4.second wall, 5.background
	ColorOutput <=	   "000000" when  (ScanlineX=SquareX+7 and ScanlineY=SquareY+7) or (ScanlineX=SquareX+8 and  ScanlineY=SquareY+7) or (ScanlineX=SquareX+7 and  ScanlineY=SquareY+8) or (ScanlineX=SquareX+8 and  ScanlineY=SquareY+8)
					else  "000000" when  (ScanlineX=SquareX+SquareWidth-7 and ScanlineY=SquareY+7) or (ScanlineX=SquareX+SquareWidth-8 and  ScanlineY=SquareY+7) or (ScanlineX=SquareY+SquareWidth-7 and  ScanlineX=SquareY+8) or (ScanlineX=SquareY+SquareWidth-8 and  ScanlineX=SquareY+8)
					else  "000000" when   ScanlineY=SquareY+SquareWidth-7 and (ScanlineX>SquareX+7 and ScanlineX<SquareX+SquareWidth-7)
					else  "000000" when   (ScanlineX=SquareX+7 or ScanlineX=SquareX+SquareWidth-7) and (ScanlineY>SquareY+SquareWidth-12 and ScanlineY<SquareY+SquareWidth-7)	
	                
                    else  "001100" when  (ScanlineX > SquareX AND ScanlineY > SquareY AND ScanlineX < SquareX+SquareWidth AND ScanlineY < SquareY+SquareWidth)
                    else  "110000" when  (ScanlineX > SquareX_b AND ScanlineY > SquareY_b AND ScanlineX < SquareX_b+BulletWidth AND ScanlineY < SquareY_b+BulletWidth)
                    else  "101000" when  (ScanlineX > SquareX_t AND ScanlineY > SquareY_t AND ScanlineX < SquareX_t+SquareWidth AND ScanlineY < SquareY_t+SquareWidth)


                    else  "111111" when  (ScanlineX = SquareX AND ScanlineY > SquareY AND ScanlineY < SquareY+SquareWidth) OR (ScanlineY = SquareY AND ScanlineX > SquareX AND ScanlineX < SquareX+SquareWidth)
					OR (ScanlineX = SquareX+SquareWidth AND ScanlineY > SquareY AND ScanlineY < SquareY+SquareWidth) OR (ScanlineY = SquareY+SquareWidth AND ScanlineX > SquareX AND ScanlineX < SquareX+SquareWidth)
				   else  "111000" when  ScanlineX >= wallX1  AND ScanlineX < wallX1+SquareWidth AND (ScanlineY < p_rand1 OR ScanlineY > p_rand1+SquareWidth+SquareWidth+SquareWidth+SquareWidth)
					else  "111100" when  ScanlineX >= wallX2  AND ScanlineX < wallX2+SquareWidth AND (ScanlineY < p_rand2 OR ScanlineY > p_rand2+SquareWidth+SquareWidth+SquareWidth+SquareWidth)
					else  "111111" when  (ScanlineY>"1111101" and ScanlineY<"10010110" and ScanlineX>"1100100" and ScanlineX<"10001100")
					or (ScanlineY>="10010110" and ScanlineY<="10101111"and ScanlineX>"1001011" and ScanlineX<"11001000")
					or (ScanlineY>"10101111" and ScanlineY<"11001000" and ScanlineX>"110010" and ScanlineX<"11111010")				
					or (ScanlineY> ("11001000") and ScanlineY< ("11100001") and ScanlineX>("100101100") and ScanlineX< ("101011110"))
					or (ScanlineY>=("11100001") and ScanlineY<=("11111010" )and ScanlineX>("100010011") and ScanlineX<("110010000"))
					or (ScanlineY> ("11111010") and ScanlineY< ("100010011") and ScanlineX> ("11111010") and ScanlineX<("111000010"))
					else	"000011";

	ColorOut <= ColorOutput;
	
	SquareXmax <= "1010000000"-SquareWidth; -- (640 - SquareWidth)
	SquareYmax <= "0111100000"-SquareWidth;	-- (480 - SquareWidth)
    SquareXmin <= "0000000001";
	SquareYmin <= "0000000001";
end Behavioral;
