#Download Latest Version of Future

$FutureInstallPath = 'C:\FPOS-INSTALL\FUTURE\'
$FutureFileName = 'Future-6.0.7.28'
$FutureZipName = 'Future-6.0.7.28.zip'
$FutureOutPath = $FutureInstallPath + $FutureZipName
$FutureUnzippedPath = $FutureInstallPath + $FutureFileName
$FutureDownloadURL = 'https://s3.amazonaws.com/ces-web-files/-2/Future-6.0.7.28.zip'

#Install Dotnet prereq
winget install -e --id Microsoft.dotNetFramework -v 3.5 SP1

Write-Host "`nDownloading Latest FPOS Version.`n"
try{
    Invoke-WebRequest -Uri $FutureDownloadURL -OutFile $FutureOutPath 
    Write-Host "Successfully Downloaded FPOS.`n"
}catch{
    Write-Warning "Failed to Download FPOS.`n"
    $StatusCode = $_.Exception.Response.StatusCode.value__
}

Write-Host -NoNewLine "Press Any Button to Continue..."
[void][System.Console]::ReadKey($true)
Write-Host "`n"

Write-Host "Extracting FPOS.`n"
#Extract Zip file
Expand-Archive -LiteralPath $FutureOutPath  -DestinationPath ($FutureUnzippedPath)

#Run FPOS Installer 
Write-Host "Installing FPOS.`n"
Start-Process ($FutureUnzippedPath) -ArgumentList "/s"

Write-Host "`nDownloading Latest UTG Version.`n"
try{
    Invoke-WebRequest -Uri 'https://s3.amazonaws.com/ces-web-files/-2/Future-6.0.7.28.zip' -OutFile $FutureOutPath 
    Write-Host "Successfully Downloaded FPOS.`n"
}catch{
    Write-Warning "Failed to Download FPOS.`n"
    $StatusCode = $_.Exception.Response.StatusCode.value__
}



#Download latest version of UTG


