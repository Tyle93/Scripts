DECLARE @items TABLE (id uniqueidentifier, name nvarchar(32))

BEGIN TRAN  

INSERT INTO @items
SELECT ItemID,ItemName FROM [Taco Hut].dbo.Item
WHERE ItemName LIKE 'APP-%'  OR ItemName LIKE 'BRK-%' OR ItemName LIKE 'BUR-%' OR ItemName LIKE 'COMBO-%' OR ItemName LIKE 'SAL-%'

UPDATE [Taco Hut].dbo.ItemPrice
SET DefaultPrice = DefaultPrice+100
FROM [Taco Hut].dbo.ItemPrice
INNER JOIN @items as i
ON ItemID = i.id AND ScheduleIndex = 0

SELECT ip.ItemID,ip.DefaultPrice, i.name FROM [Taco Hut].dbo.ItemPrice as ip, @items as i
WHERE i.id = ip.ItemID

COMMIT