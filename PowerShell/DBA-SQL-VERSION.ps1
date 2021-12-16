#Get FPOS Install Directory from the registry.
$FPOSDirectory = (Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\"Future P.O.S."\Directories).GetValue("FPOS Directory")
#Get UTG Install Directory from the registry.
$Shift4Directory = (Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\"Shift4 Corporation").GetValue("Installation Path")
#Path to UTG Executable.
$UTGPath = "$Shift4Directory\UTG2\Utg2.exe"
#Path to FPOS Executable.
$FPOSExePath = ($FPOSDirectory + "\\bin\\fpos.exe")
#Get FPOS Version from exe properties.
$FPOSVersion = [System.Version]::Parse((Get-Item ($FPOSExePath)).VersionInfo.FileVersion)
#Get UTG Version from exe properties.
$UTGVersion = [System.Version]::Parse((Get-Item ($UTGPath)).VersionInfo.FileVersion)

#SQL String to use with sqlcmd.
$queryString = "`"
                SET NOCOUNT ON
                SELECT SERVERPROPERTY('productversion') as 'Product Version',
                SERVERPROPERTY('productlevel') as 'Service Pack',
                SERVERPROPERTY('edition') as 'Edition', 
                SERVERPROPERTY('instancename') as 'Instance', 
                SERVERPROPERTY('servername') as 'Server Name'
                `""
#Check FPOS Version and get default SQL Instance name.
if($FPOSVersion.Major -eq 5){
    $InstanceName = "CESSQL"
}else{
    $InstanceName = "FPOSSQL"
}

#sqlcmd output destination
$sqlOutputFile = "C:\Users\FPOS\Desktop\sqlVersion.txt"
#default server name
$ServerName = $env:ComputerName + "\" + $InstanceName
#sqlcmd argument list
$argList = "-S $ServerName -Q $queryString -o $sqlOutputFile -W -h -1 -s `",`""
#Execute sql string
Start-Process sqlcmd -ArgumentList $argList -Wait
#Retreive output of sql query.
$sqlOutput = Get-Content -Path $sqlOutputFile
#Get Total System Memory.
$ram =  Get-CimInstance -Class CIM_PhysicalMemory -ComputerName localhost -ErrorAction Stop | Select-Object Capacity
$ramTotal = 0
foreach($stick in $ram){
    $ramTotal += ($stick.Capacity/1GB)
}
#Concatanate Version Info and System Info.
$appendString = ($FPOSVersion.toString() + "," + $UTGVersion.ToString() + "," + $ramTotal + "GB")
#Concatanate All version and System Info.
$finalOutput = "$sqlOutput,$appendString" 
#Create Headers for Final output file.
$headers = "PRODUCT VERSION, PRODUCT LEVEL, EDITION,INSTANCE NAME,SERVER NAME,FPOS VERSION,UTG VERSION,TOTAL MEMORY"
$finalOutputFile = "C:/versionInfo.csv"
#Create new file to hold final output.
New-Item -Path $finalOutputFile -Force
#Insert Headers into Final Output File.
Add-Content -Path $finalOutputFile -Value $headers
#Insert Version and System Info into Final Output File.
Add-Content -Path $finalOutputFile -Value $finalOutput
#Remove temp sql output file.
Remove-Item -Path $sqlOutputFile 
#Email Final Output to support email.
Send-MailMessage -from "Tyler <Tyler@wc-pos.com>" -to "Support <Support@wc-pos.com>" -Attachments $finalOutputFile -SmtpServer "imap.wc-pos.com"