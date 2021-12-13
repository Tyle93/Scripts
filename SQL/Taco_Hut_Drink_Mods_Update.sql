DECLARE @items TABLE (id uniqueidentifier, name nvarchar(32))
begin transaction

insert into @items
select ItemID,ItemName FROM [Taco Hut].dbo.Item
WHERE (ItemName LIKE 'BEV-% MOD'  OR ItemName LIKE 'Bev-% BAR') AND ItemName NOT LIKE 'BEV-KID%'

UPDATE [Taco Hut].dbo.ItemPrice
SET DefaultPrice = 0
FROM [Taco Hut].dbo.ItemPrice as ip
INNER JOIN @items as i
ON ip.ItemID = i.id AND ip.ScheduleIndex = 0

select i.name,DefaultPrice FROM [Taco Hut].dbo.ItemPrice as ip, @items as i
where i.id = ip.ItemID AND ip.ScheduleIndex = 0;

commit