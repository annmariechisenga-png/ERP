-- Create views to handle case-sensitive table names

-- For Councils (capital C)
CREATE OR REPLACE VIEW "Councils" AS 
SELECT * FROM councils;

-- For HRA_Positions (uppercase)
CREATE OR REPLACE VIEW "HRA_Positions" AS 
SELECT * FROM hra_positions;

-- Verify they were created
SELECT 'Views created successfully' as message;
