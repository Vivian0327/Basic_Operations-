LIBRARY lpm;
USE lpm.lpm_components.ALL;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Real_Multiplier IS
	GENERIC(
		W2 : INTEGER := 16; -- Multiplier bit width
		--W1 : INTEGER := 17;  -- Bit width c+s sum
		W 	: INTEGER := 8 -- Input bit width
	);
	PORT(clk             :   IN    std_logic; -- Clock for the output register
        X_in_re         :   IN    std_logic_vector(W-1 DOWNTO 0);  -- Inputs
        Y_in_re         :   IN    std_logic_vector(W-1 DOWNTO 0);  -- Inputs
        Z_out_re        :   OUT   std_logic_vector(W2-1 DOWNTO 0));  -- Outputs
END Real_Multiplier;


ARCHITECTURE rtl OF Real_Multiplier IS
	SIGNAL x_r, y_r  : STD_LOGIC_VECTOR(W-1 DOWNTO 0);  -- Inputs and outputs
	SIGNAL xrmyr     : STD_LOGIC_VECTOR(w2-1 DOWNTO 0); -- Products

BEGIN
	x_r <= X_in_re;
	y_r <= Y_in_re;

	
	PROCESS
		BEGIN
		WAIT UNTIL clk='1';
		Z_out_re <= xrmyr; -- Scaling and FF
	END PROCESS;
	------------------- ccmul real-valued numbers -----------------------
	mul_1: lpm_mult   --Multipliy  x_r*y_r
		GENERIC MAP(
			LPM_WIDTHA => W, LPM_WIDTHB => W,
			LPM_WIDTHP => W2, LPM_WIDTHS => W2,
			LPM_REPRESENTATION => "SIGNED")
		PORT MAP(dataa => x_r, datab => y_r, result => xrmyr);
		
	
end rtl;