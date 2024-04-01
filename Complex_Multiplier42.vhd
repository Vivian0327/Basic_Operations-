/*********************************************************************
-- Design Discreption: Complex-number multiplication using 4/2 algorithm.
-- Author            ：      Weiwei Wang.
-- Create date       : 03/01/2024

**********************************************************************/

LIBRARY lpm;
USE lpm.lpm_components.ALL;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Complex_Multiplier42 IS
	GENERIC(
		W2 : INTEGER := 16; -- Multiplier bit width
		--W1 : INTEGER := 17;  -- Bit width c+s sum
		W 	: INTEGER := 8 -- Input bit width
	);
	PORT(clk             :   IN    std_logic;                       -- Clock for the output register
        X_in_re         :   IN    std_logic_vector(W-1 DOWNTO 0);  -- Inputs
        X_in_im         :   IN    std_logic_vector(W-1 DOWNTO 0);  -- Inputs
        Y_in_re         :   IN    std_logic_vector(W-1 DOWNTO 0);  -- Inputs
        Y_in_im         :   IN    std_logic_vector(W-1 DOWNTO 0);  -- Inputs
        Z_out_re        :   OUT   std_logic_vector(W2-1 DOWNTO 0); -- Outputs
        Z_out_im        :   OUT   std_logic_vector(W2-1 DOWNTO 0)  -- Outputs
        );
END Complex_Multiplier42;


ARCHITECTURE rtl OF Complex_Multiplier42 IS
	SIGNAL x_r,x_i, y_r,y_i          : STD_LOGIC_VECTOR(W-1 DOWNTO 0);  -- Inputs and outputs
	SIGNAL xrmyr, ximyi, xrmyi, ximyr: STD_LOGIC_VECTOR(w2-1 DOWNTO 0); -- Products
	SIGNAL r,     i                  : STD_LOGIC_VECTOR(w2-1 DOWNTO 0);   --

BEGIN
	x_r <= X_in_re;
	x_i <= X_in_im;
	y_r <= Y_in_re;
	y_i <= Y_in_im;

	
	PROCESS
	BEGIN
		WAIT UNTIL clk='1';
		Z_out_re <= r; -- Scaling and FF
		Z_out_im <= i; -- for output
	END PROCESS;
	------------------- ccmul with 4 mul. and 2 add/sub -----------------------
	mul_1: lpm_mult   --Multipliy  x_r*y_r
		GENERIC MAP(
			LPM_WIDTHA => W, LPM_WIDTHB => W,
			LPM_WIDTHP => W2, LPM_WIDTHS => W2,
			LPM_REPRESENTATION => "SIGNED")
		PORT MAP(dataa => x_r, datab => y_r, result => xrmyr);
		
	mul_2: lpm_mult   --Multipliy  x_i*y_i
		GENERIC MAP(
			LPM_WIDTHA => W, LPM_WIDTHB => W,
			LPM_WIDTHP => W2, LPM_WIDTHS => W2,
			LPM_REPRESENTATION => "SIGNED")
		PORT MAP(dataa => x_i, datab => y_i, result => ximyi);

	mul_3: lpm_mult   --Multipliy  x_r*y_i
		GENERIC MAP(
			LPM_WIDTHA => W, LPM_WIDTHB => W,
			LPM_WIDTHP => W2, LPM_WIDTHS => W2,
			LPM_REPRESENTATION => "SIGNED")
		PORT MAP(dataa => x_r, datab => y_i, result => xrmyi);
		
	mul_4: lpm_mult   --Multipliy  x_i*y_r
		GENERIC MAP(
			LPM_WIDTHA => W, LPM_WIDTHB => W,
			LPM_WIDTHP => W2, LPM_WIDTHS => W2,
			LPM_REPRESENTATION => "SIGNED")
		PORT MAP(dataa => x_i, datab => y_r, result => ximyr);	
	
	sub_1: lpm_add_sub -- Sub: r <= x_r*y_r - x_i*y_i;
		GENERIC MAP ( LPM_WIDTH => W2, LPM_DIRECTION => "SUB",
						  LPM_REPRESENTATION => "SIGNED")
		PORT MAP ( dataa => xrmyr, datab => ximyi, result => r);
	
	add_1: lpm_add_sub -- Add: i <= x_r*y_i + x_i*y_r;
		GENERIC MAP ( LPM_WIDTH => W2, LPM_DIRECTION => "ADD",
						  LPM_REPRESENTATION => "SIGNED")
		PORT MAP ( dataa => xrmyi, datab => ximyr, result => i);		
	
end rtl;