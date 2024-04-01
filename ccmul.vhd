--------------------------------------------------------------------------
--  Design description:
--  	 R+jI = (X + jY)*(C + jS)     
-- 	 R = (C - S) * Y + (X -Y) * C 
-- 	 I = (C + S) * X - (X -Y) * C 
-- Author             : Weiwei Wang
-- Create Date        : 03/01/2024
--------------------------------------------------------------------------
--LPM included a wide range of functions such as:
-- Basic logic gates (AND, OR, NOT, NAND, NOR, XOR, XNOR)
-- Arithmetic functions (adders, subtractors, multipliers, comparators)
-- Memory elements (registers, latches, RAM, ROM)
-- Multiplexers and demultiplexers
-- Decoders and encoders
-- Counters and shift registers
--------------------------------------------------------------------------
LIBRARY lpm;
USE lpm.lpm_components.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY ccmul IS
	GENERIC (
		W2 : INTEGER := 37;  -- Multiplier bit width
		W1 : INTEGER := 19;  -- Bit width c+s sum
		W 	: INTEGER := 18); -- Input bit width
	PORT (
		clk             : STD_LOGIC;                          -- Clock for the output register
		x_in, y_in, c_in: IN STD_LOGIC_VECTOR(W-1 DOWNTO 0);  -- Inputs
		cps_in, cms_in  : IN STD_LOGIC_VECTOR(W1-1 DOWNTO 0); -- Inputs
		r_out, i_out    : OUT STD_LOGIC_VECTOR(W-1 DOWNTO 0));-- Results
END ccmul;

ARCHITECTURE rtl OF ccmul IS
	SIGNAL x, y, c                : STD_LOGIC_VECTOR(W-1 DOWNTO 0);    -- Inputs and outputs
	SIGNAL r, i, cmsy, cpsx, xmyc : STD_LOGIC_VECTOR(W2-1 DOWNTO 0);   -- Products
	SIGNAL xmy, cps, cms, sxtx, sxty : STD_LOGIC_VECTOR(W1-1 DOWNTO 0);-- x-y etc.
BEGIN
	x 	 <= x_in; 	-- x
	y   <= y_in; 	-- j * y
	c   <= c_in; 	-- cos
	cps <= cps_in; -- cos + sin
	cms <= cms_in; -- cos - sin

	PROCESS
	BEGIN
		WAIT UNTIL clk='1';
		r_out <= r(W2-3 DOWNTO W-1); -- Scaling and FF
		i_out <= i(W2-3 DOWNTO W-1); -- for output
	END PROCESS;
	------------------- ccmul with 3 mul. and 3 add/sub -----------------------
	sxtx <= x(x'high) & x; -- Possible growth for
	sxty <= y(y'high) & y; -- sub_1 -> sign extension
	
	sub_1: lpm_add_sub -- Sub: x - y;
		GENERIC MAP ( LPM_WIDTH => W1, LPM_DIRECTION => "SUB",
						  LPM_REPRESENTATION => "SIGNED")
		PORT MAP (dataa => sxtx, datab => sxty, result => xmy);
	
	mul_1: lpm_mult -- Multiply (x-y)*c = xmyc
		GENERIC MAP ( LPM_WIDTHA => W1, LPM_WIDTHB => W,
						  LPM_WIDTHP => W2, LPM_WIDTHS => W2,
						  LPM_REPRESENTATION => "SIGNED")
		PORT MAP ( dataa => xmy, datab => c, result => xmyc);
	
	mul_2: lpm_mult -- Multiply (c-s)*y = cmsy
		GENERIC MAP ( LPM_WIDTHA => W1, LPM_WIDTHB => W,
						  LPM_WIDTHP => W2, LPM_WIDTHS => W2,
						  LPM_REPRESENTATION => "SIGNED")
		PORT MAP ( dataa => cms, datab => y, result => cmsy);
	
	mul_3: lpm_mult -- Multiply (c+s)*x = cpsx
		GENERIC MAP ( LPM_WIDTHA => W1, LPM_WIDTHB => W,
						  LPM_WIDTHP => W2, LPM_WIDTHS => W2,
						  LPM_REPRESENTATION => "SIGNED")
		PORT MAP ( dataa => cps, datab => x, result => cpsx);
	
	sub_2: lpm_add_sub -- Sub: i <= (c-s)*x - (x-y)*c;
		GENERIC MAP ( LPM_WIDTH => W2, LPM_DIRECTION => "SUB",
						  LPM_REPRESENTATION => "SIGNED")
		PORT MAP ( dataa => cpsx, datab => xmyc, result => i);
	
	add_1: lpm_add_sub -- Add: r <= (x-y)*c + (c+s)*y;
		GENERIC MAP ( LPM_WIDTH => W2, LPM_DIRECTION => "ADD",
						  LPM_REPRESENTATION => "SIGNED")
		PORT MAP ( dataa => cmsy, datab => xmyc, result => r);
END rtl;