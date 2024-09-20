$iasver = "1.2"
$activate = 0
$freeze = 0
$reset = 0

$PATH = "$env:SystemRoot\System32;$env:SystemRoot\System32\wbem;$env:SystemRoot\System32\WindowsPowerShell\v1.0\"
if (Test-Path "$env:SystemRoot\Sysnative\reg.exe") {
    $PATH = "$env:SystemRoot\Sysnative;$env:SystemRoot\Sysnative\wbem;$env:SystemRoot\Sysnative\WindowsPowerShell\v1.0\;$PATH"
}

$cmdf = $MyInvocation.MyCommand.Path
$args = $args -join " "
$elev = $null
$unattended = 0

if ($args) {
    $args = $args -replace '"', ''
    $args.Split(" ") | ForEach-Object {
        if ($_ -ieq "-el") { $elev = 1 }
        if ($_ -ieq "/res") { $reset = 1 }
        if ($_ -ieq "/frz") { $freeze = 1 }
        if ($_ -ieq "/act") { $activate = 1 }
    }
}

if ($activate -eq 1 -or $freeze -eq 1 -or $reset -eq 1) { $unattended = 1 }

$Red = "41;97m"
$Gray = "100;97m"
$Green = "42;97m"
$Blue = "44;97m"
$White = "40;37m"
$Green = "40;92m"
$Yellow = "40;93m"

$nceline = "echo: &echo ==== ERROR ==== &echo:"
$eline = "echo: &call :_color $Red '==== ERROR ====' &echo:"
$line = "___________________________________________________________________________________________________"
$buf = '{$W=$Host.UI.RawUI.WindowSize;$B=$Host.UI.RawUI.BufferSize;$W.Height=34;$B.Height=300;$Host.UI.RawUI.WindowSize=$W;$Host.UI.RawUI.BufferSize=$B;}'

if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "Unsupported OS version Detected."
    Write-Host "Project is supported only for Windows 7/8/8.1/10/11 and their Server equivalent."
    exit
}

if (-not (Get-Command powershell.exe -ErrorAction SilentlyContinue)) {
    Write-Host "Unable to find powershell.exe in the system."
    exit
}

$work = Split-Path -Parent $cmdf
$batf = $cmdf
$batp = $batf -replace "'", "''"

$PSarg = """$batf""" -el $args
$PSarg = $PSarg -replace "'", "''"

$appdata = $env:APPDATA
$ttemp = "$env:USERPROFILE\AppData\Local\Temp"

if ($batf -match [regex]::Escape($ttemp)) {
    if ($work -ne $ttemp) {
        Write-Host "Script is launched from the temp folder,"
        Write-Host "Most likely you are running the script directly from the archive file."
        Write-Host "Extract the archive file and launch the script from the extracted folder."
        exit
    }
}

if (-not (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property CreationClassName)) {
    Write-Host "WMI is not working. Aborting..."
    exit
}

$sid = ([System.Security.Principal.NTAccount](Get-WmiObject -Class Win32_ComputerSystem).UserName).Translate([System.Security.Principal.SecurityIdentifier]).Value

if (-not (Get-Item "HKU:\$sid\Software")) {
    $explorerProc = Get-Process -Name explorer | Where-Object { $_.SessionId -eq (Get-Process -Id $pid).SessionId } | Select-Object -First 1
    $sid = (Get-WmiObject -Query "Select * From Win32_Process Where ProcessID=$($explorerProc.Id)").GetOwnerSid().Sid
}

if (-not (Get-Item "HKU:\$sid\Software")) {
    Write-Host "User Account SID not found. Aborting..."
    exit
}

$HKCUsync = $null
Remove-Item -Path "HKCU:\IAS_TEST" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKU:\$sid\IAS_TEST" -Force -ErrorAction SilentlyContinue

New-Item -Path "HKCU:\IAS_TEST" -Force
if (Test-Path "HKU:\$sid\IAS_TEST") { $HKCUsync = 1 }

Remove-Item -Path "HKCU:\IAS_TEST" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKU:\$sid\IAS_TEST" -Force -ErrorAction SilentlyContinue

$arch = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -Name "PROCESSOR_ARCHITECTURE").PROCESSOR_ARCHITECTURE
if ($arch -ne "x86") { $arch = "x64" }

if ($arch -eq "x86") {
    $CLSID = "HKCU:\Software\Classes\CLSID"
    $CLSID2 = "HKU:\$sid\Software\Classes\CLSID"
    $HKLM = "HKLM:\Software\Internet Download Manager"
} else {
    $CLSID = "HKCU:\Software\Classes\Wow6432Node\CLSID"
    $CLSID2 = "HKU:\$sid\Software\Classes\Wow6432Node\CLSID"
    $HKLM = "HKLM:\SOFTWARE\Wow6432Node\Internet Download Manager"
}

$IDMan = (Get-ItemProperty -Path "HKU:\$sid\Software\DownloadManager" -Name "ExePath" -ErrorAction SilentlyContinue).ExePath
if (-not (Test-Path $IDMan)) {
    if ($arch -eq "x64") { $IDMan = "$env:ProgramFiles(x86)\Internet Download Manager\IDMan.exe" }
    if ($arch -eq "x86") { $IDMan = "$env:ProgramFiles\Internet Download Manager\IDMan.exe" }
}

if (-not (Test-Path "$env:SystemRoot\Temp")) { New-Item -Path "$env:SystemRoot\Temp" -ItemType Directory }

if ($reset -eq 1) { goto _reset }
if ($activate -eq 1) { $frz = 0; goto _activate }
if ($freeze -eq 1) { $frz = 1; goto _activate }

:MainMenu

cls
Write-Host "IDM Activation Script $iasver"
Write-Host "1. Activate (Currently not working)"
Write-Host "2. Freeze Trial"
Write-Host "3. Reset Activation / Trial"
Write-Host "4. Download IDM"
Write-Host "5. Help"
Write-Host "0. Exit"
$choice = Read-Host "Enter a menu option [1,2,3,4,5,0]"

switch ($choice) {
    1 { $frz = 0; goto _activate }
    2 { $frz = 1; goto _activate }
    3 { goto _reset }
    4 { Start-Process "https://www.internetdownloadmanager.com/download.html"; goto MainMenu }
    5 { Start-Process "https://github.com/zinzied/IDM-Freezer/blob/main/zied.cmd"; goto MainMenu }
    0 { exit }
    default { goto MainMenu }
}

:_reset

cls
if ($HKCUsync -ne 1) {
    $Host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(153, 35)
} else {
    $Host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(113, 35)
}

if ($unattended -eq 1) {
    $Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(300, 34)
}

Write-Host "Creating backup of CLSID registry keys in $env:SystemRoot\Temp"
reg export $CLSID "$env:SystemRoot\Temp\_Backup_HKCU_CLSID_$((Get-Date).ToString('yyyyMMdd-HHmmssfff')).reg"
if ($HKCUsync -ne 1) {
    reg export $CLSID2 "$env:SystemRoot\Temp\_Backup_HKU-$sid_CLSID_$((Get-Date).ToString('yyyyMMdd-HHmmssfff')).reg"
}

Write-Host "Deleting IDM registry keys..."
$keys = @(
    "HKCU:\Software\DownloadManager\FName",
    "HKCU:\Software\DownloadManager\LName",
    "HKCU:\Software\DownloadManager\Email",
    "HKCU:\Software\DownloadManager\Serial",
    "HKCU:\Software\DownloadManager\scansk",
    "HKCU:\Software\DownloadManager\tvfrdt",
    "HKCU:\Software\DownloadManager\radxcnt",
    "HKCU:\Software\DownloadManager\LstCheck",
    "HKCU:\Software\DownloadManager\ptrk_scdt",
    "HKCU:\Software\DownloadManager\LastCheckQU",
    $HKLM
)

foreach ($key in $keys) {
    if (Test-Path $key) {
        Remove-Item -Path $key -Force
        Write-Host "Deleted - $key"
    } else {
        Write-Host "Failed - $key"
    }
}

if ($HKCUsync -ne 1) {
    $keys = @(
        "HKU:\$sid\Software\DownloadManager\FName",
        "HKU:\$sid\Software\DownloadManager\LName",
        "HKU:\$sid\Software\DownloadManager\Email",
        "HKU:\$sid\Software\DownloadManager\Serial",
        "HKU:\$sid\Software\DownloadManager\scansk",
        "HKU:\$sid\Software\DownloadManager\tvfrdt",
        "HKU:\$sid\Software\DownloadManager\radxcnt",
        "HKU:\$sid\Software\DownloadManager\LstCheck",
        "HKU:\$sid\Software\DownloadManager\ptrk_scdt",
        "HKU:\$sid\Software\DownloadManager\LastCheckQU"
    )

    foreach ($key in $keys) {
        if (Test-Path $key) {
            Remove-Item -Path $key -Force
            Write-Host "Deleted - $key"
        } else {
            Write-Host "Failed - $key"
        }
    }
}

Write-Host "The IDM reset process has been completed."
goto done

:_activate

cls
if ($HKCUsync -ne 1) {
    $Host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(153, 35)
} else {
    $Host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(113, 35)
}

if ($unattended -eq 1) {
    $Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(300, 34)
}

if ($frz -eq 0 -and $unattended -eq 0) {
    Write-Host "Activation is not working for some users and IDM may show fake serial nag screen."
    Write-Host "Its recommended to use Freeze Trial option instead."
    $choice = Read-Host "Press 1 to go back or 9 to activate"
    if ($choice -eq 1) { goto MainMenu }
    cls
}

if (-not (Test-Path $IDMan)) {
    Write-Host "IDM [Internet Download Manager] is not Installed."
    Write-Host "You can download it from https://www.internetdownloadmanager.com/download.html"
    goto done
}

$int = Test-Connection -ComputerName internetdownloadmanager.com -Count 1 -Quiet
if (-not $int) {
    $tcpClient = New-Object Net.Sockets.TcpClient
    try {
        $tcpClient.Connect("internetdownloadmanager.com", 80)
        $int = $tcpClient.Connected
    } catch {
        $int = $false
    } finally {
        $tcpClient.Close()
    }

    if (-not $int) {
        Write-Host "Unable to connect internetdownloadmanager.com, aborting..."
        goto done
    }
    Write-Host "Ping command failed for internetdownloadmanager.com"
}

$regwinos = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName").ProductName
$regarch = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -Name "PROCESSOR_ARCHITECTURE").PROCESSOR_ARCHITECTURE
$fullbuild = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "CurrentBuild").CurrentBuild
$IDMver = (Get-ItemProperty -Path "HKU:\$sid\Software\DownloadManager" -Name "idmvers" -ErrorAction SilentlyContinue).idmvers

Write-Host "Checking Info - [$regwinos | $fullbuild | $regarch | IDM: $IDMver]"

if (Get-Process -Name idman -ErrorAction SilentlyContinue) {
    Stop-Process -Name idman -Force
}

Write-Host "Creating backup of CLSID registry keys in $env:SystemRoot\Temp"
reg export $CLSID "$env:SystemRoot\Temp\_Backup_HKCU_CLSID_$((Get-Date).ToString('yyyyMMdd-HHmmssfff')).reg"
if ($HKCUsync -ne 1) {
    reg export $CLSID2 "$
