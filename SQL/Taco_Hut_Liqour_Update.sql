DECLARE @items TABLE (id uniqueidentifier, name nvarchar(32))
DECLARE @before TABLE (id uniqueidentifier, name nvarchar(32), price INT)

BEGIN TRAN  

INSERT INTO @items
SELECT ItemID,ItemName FROM [Taco Hut].dbo.Item
WHERE ItemName LIKE 'LIQ-%'

INSERT INTO @before
SELECT ip.ItemID,i.name,ip.defaultPrice FROM @items as i, [Taco Hut].dbo.ItemPrice as ip
WHERE i.id = ip.ItemID AND ip.ScheduleIndex = 0

UPDATE [Taco Hut].dbo.ItemPrice
SET DefaultPrice = DefaultPrice+100
FROM [Taco Hut].dbo.ItemPrice
INNER JOIN @items as i
ON ItemID = i.id AND ScheduleIndex = 0

SELECT  b.id,b.name,b.price as Before,ip.DefaultPrice as After FROM [Taco Hut].dbo.ItemPrice as ip, @before as b
WHERE ip.ItemID = b.id AND ip.ScheduleIndex = 0

Commit