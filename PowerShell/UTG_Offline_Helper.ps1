
function Download {
    param ( 
        [Parameter(Mandatory=$true)]
        [string]
        $URL,
        [Parameter(Mandatory=$true)]
        [string]
        $OutFile
    )
    PROCESS{
        try{
            Invoke-WebRequest -Uri $URL -OutFile $OutFile 
            Write-Host "Successfully Downloaded FPOS.`n"
        }catch{
            throw
        }
    }
}
function Extract {
    param (
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [string]
        $FilePath,
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [string]
        $DestFile
    )
    PROCESS{
        try{
            Expand-Archive -LiteralPath $FilePath -DestinationPath $DestFile
        }catch{
            throw 
        }    
    }
}
function Install {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $FilePath,
        # Parameter help description
        [Parameter(Mandatory=$false)]
        [string[]]
        $Args = "/s"
    )
    PROCESS{
        try{
            Start-Process $FilePath -ArgumentList $args
        }catch{
            throw
        }
    }
}

function FutureDownload {
    param(
        [switch] $a
    )
    PROCESS{
        $FutureInstallPath = 'C:\FPOS-INSTALL\FUTURE\'
        $FutureFileName = 'Future-6.0.7.28'
        $FutureZipName = 'Future-6.0.7.28.zip'
        $FutureOutPath = $FutureInstallPath + $FutureZipName
        $FutureUnzippedPath = $FutureInstallPath + $FutureFileName
        $FutureDownloadURL = 'https://s3.amazonaws.com/ces-web-files/-2/Future-6.0.7.28.zip'
        try{
            Download($FutureDownloadURL,$FutureOutPath)
            Extract($FutureOutPath,$FutureUnzippedPath)
            Install($FutureUnzippedPath)
        }catch{
            Write-Error $_.Exception.Message -ErrorAction Stop
        }
    }

}
Write-Host -NoNewLine "Press Any Button to Continue..."
[void][System.Console]::ReadKey($true)
Write-Host "`n"

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
    Write-Warning "No FPOS Install Directory Found.`n" 
    Write-Error "Would you like to download the latest version of FPOS?(Y/n)"
    $selection = [void][System.Console]::ReadLine().ToLower();
    switch ($selection) {
        'y'{}
        'yes'{
            FutureDownload();
            break;
        } 
        'n'{}
        'no'{
            Write-Host "Closing..." 
            Exit
            break
        }
        Default {         
            Write-Host "Invalid Input."
            break
        }
    }
}

#Check if full path exists.
Write-Host "`nConfirming UTG Installation Path."
if(Test-Path -Path $UTGPath){
    Write-Host "UTG Installation Path Found.`n"
}else{
    Write-Error "No UTG Install Directory Found.`n" -ErrorAction Stop
}

#Define the minimum versions for offline CC.
[System.Version]$MinumumFuture5Version = [System.Version]::Parse("5.0.106")
[System.Version]$MinimumFuture6Version = [System.Version]::Parse("6.0.7.26")
[System.Version]$MinumumUTGVersion = [System.Version]::Parse("5.0.0.3080")

#Create Version objects from the exe's version property.
try{
    $FPOSVersion = [System.Version]::Parse((Get-Item $FPOSPath).VersionInfo.FileVersion)
    $UTGVersion = [System.Version]::Parse((Get-Item $UTGPath).VersionInfo.FileVersion)
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
    Write-Error "Version $FPOSVersion of FPOS does not meet the Minimum requirements for Offline CC.`n" -ErrorAction Stop 
}else{
    Write-Host "Minimum FPOS Version Requirements Met."
}

#Terminate if minimum UTG version not met.
if($UTGVersion -lt $MinumumUTGVersion){
    Write-Error "Version $UTGVersion of UTG does not meet the minimum requirements for Offline CC." -ErrorAction Stop
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



