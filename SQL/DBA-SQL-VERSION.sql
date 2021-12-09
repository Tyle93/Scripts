SELECT 
  SERVERPROPERTY('productversion') as 'Product Version',
  SERVERPROPERTY('productlevel') as 'Service Pack', 
  SERVERPROPERTY('edition') as 'Edition',
  SERVERPROPERTY('instancename') as 'Instance',
  SERVERPROPERTY('servername') as 'Server Name'