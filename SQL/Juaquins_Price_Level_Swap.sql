BEGIN TRAN

DECLARE @l3l2 TABLE(id uniqueidentifier, name nvarchar(32))
DECLARE @l4l2 TABLE(id uniqueidentifier, name nvarchar(32)) 

INSERT INTO @l3l2
SELECT ItemID, ItemName FROM JMR.dbo.Item 
WHERE ItemName LIKE 'CTR-%' OR ItemName LIKE 'LIQ-%' OR ItemName LIKE 'WIN-%' OR ItemName LIKE 'MAR-%' OR ItemName LIKE 'TEQ-%' OR ItemName LIKE 'TRP-%'

INSERT INTO @l4l2
SELECT ItemID, ItemName FROM JMR.dbo.Item 
WHERE ItemName NOT LIKE 'CTR-%' AND ItemName NOT LIKE 'LIQ-%' AND ItemName NOT LIKE 'WIN-%' AND ItemName NOT LIKE 'MAR-%' AND ItemName NOT LIKE 'TEQ-%' AND ItemName NOT LIKE 'TRP-%'

UPDATE JMR.dbo.ItemPrice
SET Level2Price = Level3Price
FROM JMR.dbo.ItemPrice as ip
INNER JOIN @l3l2 as l
ON l.id = ip.ItemID
WHERE ScheduleIndex = 0;

UPDATE JMR.dbo.ItemPrice
SET Level2Price = Level4Price
FROM JMR.dbo.ItemPrice as ip
INNER JOIN @l4l2 as l
ON l.id = ip.ItemID
WHERE ScheduleIndex = 0;

SELECT id,name,Level3Price,Level2Price FROM JMR.dbo.ItemPrice as ip
INNER JOIN @l3l2 as l
ON l.id = ip.ItemID
WHERE ScheduleIndex = 0;

SELECT id,name,Level4Price,Level2Price FROM JMR.dbo.ItemPrice as ip
INNER JOIN @l4l2 as l
ON l.id = ip.ItemID
WHERE ScheduleIndex = 0;

ROLLBACK