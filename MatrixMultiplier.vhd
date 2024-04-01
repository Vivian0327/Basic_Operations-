--------------------------------------------------------------------
-- Design description: Matrix multiolier
-- Author            : Weiwei Wang
-- Create Date       : 03/01/2024
--------------------------------------------------------------------
LIBRARY ieee; 
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL; 
USE ieee.std_logic_signed.ALL;
USE ieee.std_logic_unsigned.ALL;

Package Mul is
	 CONSTANT M: INTEGER:= 4;
	 type vector_type is array(0 to M-1) of integer range 0 to 255;
	 type matrix_type is array(0 to M-1) of vector_type;
end Mul;

library work; use work.Mul.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MatrixMultiplier is
    generic (
        N : INTEGER := 4  -- Size of the matrices (N x N)
    );
    port (
        matrix_a : in  matrix_type;
        matrix_b : in  matrix_type;
        result   : out matrix_type
    );
end entity MatrixMultiplier;

architecture Behavioral of MatrixMultiplier is
    
begin

    process (matrix_a, matrix_b)
        variable temp : matrix_type;
    begin
        -- Perform matrix multiplication
        for i in 0 to N-1 loop
            for j in 0 to N-1 loop
                temp(i)(j) := 0; -- Initialize the temporary matrix element
                for k in 0 to N-1 loop
                    temp(i)(j) := temp(i)(j) + matrix_a(i)(k) * matrix_b(k)(j);
                end loop;
            end loop;
        end loop;

        -- Assign the result to the output port
        result <= temp;

    end process;

end architecture Behavioral;
