
#Get FPOS and UTG Install Directories from registry entries.
try{
    $FPOSDirectory= (Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\"Future P.O.S."\Directories).GetValue("FPOS Directory")
    $Shift4Directory = (Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\"Shift4 Corporation").GetValue("Installation Path")
}catch{
    Write-Error $Error[0] -ErrorAction Stop
}

#Append exe paths to install path.
$FPOSPath = "$FPOSDirectory\Bin\Fpos.exe"
$UTGPath = "$Shift4Directory\UTG2\Utg2.exe"
$BackOfficePath = "$FPOSDirectory\Bin\FPOSMenu.exe"

#Check if full path exists.
Write-Host "`nConfirming FPOS Installation Path."
if(Test-Path -Path $FPOSPath){
    Write-Host "FPOS Installation Path Found.`n"
}else{
    Write-Error "No FPOS Install Directory Found. Will now exit.`n" -ErrorAction Stop
}

#Check if full path exists.
Write-Host "`nConfirming UTG Installation Path."
if(Test-Path -Path $UTGVersion){
    Write-Host "UTG Installation Path Found.`n"
}else{
    Write-Error "No UTG Install Directory Found. Will now exit.`n" -ErrorAction Stop
}

#Define the minimum versions for offline CC.
[System.Version]$MinumumFuture5Version = [System.Version]::Parse("5.0.106")
[System.Version]$MinimumFuture6Version = [System.Version]::Parse("6.0.7.26")
[System.Version]$MinumumUTGVersion = [System.Version]::Parse("5.0.0.3080")

#Create Version objects from the exe's version property.
try{
    [System.Version]$FPOSVersion = [System.Version]::Parse((Get-Item $FPOSPath).VersionInfo.FileVersion)
    [System.Version]$UTGVersion = [System.Version]::Parse((Get-Item $UTGPath).VersionInfo.FileVersion)
}catch{
    Write-Error $Error[0] -ErrorAction Stop
}

Write-Host "FPOS VERSION: $FPOSVersion"
Write-Host "UTG VERSION: $UTGVersion`n"

Write-Host "MINIMUM FPOS5 VERSION REQUIRED: $MinumumFuture5Version"
Write-Host "MINIMUM FPOS6 VERSION REQUIRED: $MinimumFuture6Version"
Write-Host "MINIMUM UTG VERSION REQUIRED: $MinumumUTGVersion`n"

#Check Major Version and compare against the appropriate minimum version.
if($FPOSVersion.Major -eq 5){
    $ComparisonResult = $FPOSVersion -ge $MinimumFuture5Version
}elseif($FPOSVersion.Major -eq 6){
    $ComparisonResult = $FPOSVersion -ge $MinimumFuture6Version
}else{
    $ComparisonResult = $false
}

#Terminate if minimum FPOS version not met.
if($ComparisonResult -ne $true){
    Write-Error "Version $FPOSVersion of FPOS does not meet the Minimum requirements for Offline CC. Now Exiting`n" -ErrorAction Stop 
}else{
    Write-Host "Minimum FPOS Version Requirements Met."
}

#Terminate if minimum UTG version not met.
if($UTGVersion -lt $MinumumUTGVersion){
    Write-Error "Version $UTGVersion of UTG does not meet the minimum requirements for Offline CC. Now Exiting" -ErrorAction Stop
}else{
    Write-Host "Minimum UTG Version Requirements Met.`n"
}

Write-Host -NoNewLine "Press Any Button to Continue..."
[void][System.Console]::ReadKey($true)
Write-Host "`n"

#Kill all UTG and Future Processes
Write-Host "Closing FPOS and UTG.`n"
Get-process | ?{$_.Name -Like "*utg*" -OR $_.Name -eq "fpos"} | %{Stop-Process -Name $_.Name -force} 

#Start UTG Tune-Up
Write-Host "Attempting to start UTG Tune-Up."
try{
    Start-Process -FilePath $UTGPath -ArgumentList "-t"
    Write-Host "Successfully Initiaed UTG Tune-Up Startup.`n"
}
catch{
    Write-Warning $Error[0]
    Write-Warning "Failed to Start UTG Tune-Up.`n"
}

#Start Back Office
Write-Host "Attempting to start Back Office."
try{
    Start-Process -FilePath $BackOfficePath
    Write-Host "Successfully Initiaed Back Office Startup.`n"
}
catch{
    Write-Warning $Error[0]
    Write-Warning "Failed to Start Back Office.`n"
}

Write-Host -NoNewLine "Press Any Button to Continue..."
[void][System.Console]::ReadKey($true)
Write-Host "`n"

#Kill all UTG and Future Processes
Write-Host "Closing FPOS and UTG.`n"
Get-process | ?{$_.Name -Like "*utg*" -OR $_.Name -eq "fpos"} | %{Stop-Process -Name $_.Name -force} 

#Attempt to Start UTG
Write-Host "Attempting to Start UTG"
try{
	Start-Process -FilePath $UTGPath
	Write-Host "Successfully Initiated UTG Startup.`n"
}
catch{
	Write-Warning $Error[0]
    Write-Warning "Failed to Start UTG.`n"
}

Write-Host -NoNewLine "Press Any Button to Continue..."
[void][System.Console]::ReadKey($true)
Write-Host "`n"

#Attempt to Start FPOS
Write-Host "Attempting to Start FPOS."
try{
	Start-Process -FilePath $FPOSPath
	Write-Host "Successfully Initiated FPOS Startup.`n"
}
catch{
	Write-Warning $Error[0]
    Write-Warning "Failed to Start FPOS.`n"
}

Set-ExecutionPolicy -ExecutionPolicy Restricted -Force



