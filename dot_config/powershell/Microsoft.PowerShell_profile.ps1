#winfetch
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\montys.omp.json" | Invoke-Expression

# Import the PSReadLine module
Import-Module PSReadLine

# Enable syntax coloring
Set-PSReadLineOption -Colors @{
    Command            = 'Magenta'
    Number             = 'DarkGray'
    Member             = 'DarkGray'
    Operator           = 'DarkGray'
    Type               = 'DarkGray'
    Variable           = 'DarkGreen'
    Parameter          = 'DarkGreen'
    ContinuationPrompt = 'DarkGray'
    Default            = 'DarkGray'
}

# Enable Predictive IntelliSense
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# Customize key bindings
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord

# Set Emacs editing mode
Set-PSReadLineOption -EditMode Emacs

# Enable Bash style completion
Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine
Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine

# Custom key binding to save current line to history without executing
Set-PSReadLineKeyHandler -Key Alt+w `
                         -BriefDescription SaveInHistory `
                         -LongDescription "Save current line in history but do not execute" `
                         -ScriptBlock {
    param($key, $arg)
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}



# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}



# PowerShell Profile

# Custom shutdown function
function shutdown {
    param (
        [switch]$Force,
        [int]$Delay = 0
    )

    if ($Force) {
        Stop-Computer -Force
    } else {
        Start-Sleep -Seconds $Delay
        Stop-Computer
    }
}

# Custom reboot function
function reboot {
    param (
        [switch]$Force,
        [int]$Delay = 0
    )

    if ($Force) {
        Restart-Computer -Force
    } else {
        Start-Sleep -Seconds $Delay
        Restart-Computer
    }
}

# You can add more functions or aliases as needed

function Invoke-Tere() {
    $result = . (Get-Command -CommandType Application tere) $args
    if ($result) {
        Set-Location $result
    }
}
Set-Alias tere Invoke-Tere



#touch functionality 

function touch {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string[]]$Path
    )

    foreach ($item in $Path) {
        if (-not (Test-Path $item)) {
            Set-Content -Path $item -Value $null -Force
        }
        else {
            (Get-ChildItem $item).LastWriteTime = Get-Date
        }
    }
}


# cp and mv functionality


function cp {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Source,
        [Parameter(Mandatory=$true,Position=1)]
        [string]$Destination
    )

    Copy-Item -Path $Source -Destination $Destination
}

function mv {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Source,
        [Parameter(Mandatory=$true,Position=1)]
        [string]$Destination
    )

    Move-Item -Path $Source -Destination $Destination
}



# rm functionality


function rm {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string[]]$Path,
        [switch]$r,
        [switch]$f,
        [switch]$i
    )

    $ConfirmPreference = 'None'
    $ErrorActionPreference = 'SilentlyContinue'

    foreach ($item in $Path) {
        if (Test-Path $item) {
            if ($i) {
                $confirm = Read-Host "Are you sure you want to delete $item? (y/n)"
                if ($confirm -ne 'y') {
                    continue
                }
            }
            Remove-Item -LiteralPath $item -Recurse:$r -Force:$f -ErrorAction SilentlyContinue
            if ($?) {
                Write-Host "$item moved to Recycle Bin" -ForegroundColor Green
            }
            else {
                Write-Host "Failed to delete $item" -ForegroundColor Red
            }
        }
        else {
            Write-Host "$item does not exist" -ForegroundColor Yellow
        }
    }
}


#folder icons 
Import-Module -Name Terminal-Icons


# Equivalent of `cat` command
function cat {
    param (
        [string]$Path
    )
    Get-Content -Path $Path
}

# Equivalent of `grep` command
function grep {
    param (
        [string]$Pattern,
        [string]$Path
    )
    Select-String -Pattern $Pattern -Path $Path
}



# Equivalent of `mkdir` command
function mkdir {
    param (
        [string]$Path
    )
    New-Item -ItemType Directory -Path $Path
}

# Equivalent of `rmdir` command
function rmdir {
    param (
        [string[]]$Path,
        [switch]$Force,
        [switch]$Recursive
    )
    Remove-Item -Path $Path -Force:$Force -Recurse:$Recursive
}


# Equivalent of `echo` command
function echo {
    param (
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Text
    )
    Write-Output ($Text -join " ")
}

# Equivalent of `head` command
function head {
    param (
        [string]$Path,
        [int]$Lines = 10
    )
    Get-Content -Path $Path -TotalCount $Lines
}

# Equivalent of `tail` command
function tail {
    param (
        [string]$Path,
        [int]$Lines = 10
    )
    Get-Content -Path $Path -Tail $Lines
}

# Equivalent of `ps` command
function ps {
    param (
        [switch]$All,
        [switch]$Full
    )
    $flags = @()
    if ($All) { $flags += "-IncludeUserName" }
    if ($Full) { $flags += "-Full" }
    Get-Process @flags
}

# Equivalent of `kill` command
function kill {
    param (
        [int[]]$Pid
    )
    Stop-Process -Id $Pid
}

# Equivalent of `df` command
function df {
    Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name="Used(GB)";Expression={[math]::round($_.Used/1GB,2)}}, @{Name="Free(GB)";Expression={[math]::round($_.Free/1GB,2)}}, @{Name="Total(GB)";Expression={[math]::round($_.Used/1GB,2)+[math]::round($_.Free/1GB,2)}}, @{Name="Used(%)";Expression={[math]::round($_.Used/($_.Used+$_.Free)*100,2)}}
}

# Equivalent of `chmod` command
function chmod {
    param (
        [string]$Mode,
        [string[]]$Path
    )
    # Simplified chmod function; PowerShell does not have a direct equivalent
    Write-Host "chmod is not natively supported in PowerShell. Consider using 'icacls' for advanced permissions management."
}

# Equivalent of `chown` command
function chown {
    param (
        [string]$User,
        [string]$Path
    )
    # Simplified chown function; PowerShell does not have a direct equivalent
    Write-Host "chown is not natively supported in PowerShell. Consider using 'icacls' for advanced ownership management."
}

# Equivalent of `find` command
function find {
    param (
        [string]$Path = ".",
        [string]$Name = "*",
        [switch]$Recurse
    )
    Get-ChildItem -Path $Path -Filter $Name -Recurse:$Recurse
}

# Equivalent of `wc` command
function wc {
    param (
        [string]$Path
    )
    $content = Get-Content -Path $Path
    $lineCount = ($content | Measure-Object -Line).Lines
    $wordCount = ($content | Measure-Object -Word).Words
    $charCount = ($content | Measure-Object -Character).Characters
    Write-Output "$lineCount $wordCount $charCount $Path"
}

# Equivalent of `history` command
function history {
    Get-History
}

# Equivalent of `alias` command
function alias {
    param (
        [string]$Name,
        [string]$Value
    )
    Set-Alias -Name $Name -Value $Value
}

# Equivalent of `clear` command
function clear {
    Clear-Host
}

# Equivalent of `man` command
function man {
    param (
        [string]$Command
    )
    Get-Help -Name $Command -Full
}

# Equivalent of `uname` command
function uname {
    param (
        [string]$Option
    )
    switch ($Option) {
        "-a" { Get-ComputerInfo | Select-Object -Property CsName, OsName, OsArchitecture, WindowsVersion, WindowsBuildLabEx }
        "-s" { (Get-ComputerInfo).OsName }
        "-r" { (Get-ComputerInfo).WindowsVersion }
        "-m" { (Get-ComputerInfo).OsArchitecture }
        "-n" { (Get-ComputerInfo).CsName }
        default { Write-Output "Invalid option" }
    }
}

# Equivalent of `top` command
function top {
    Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 10 -Property Id, ProcessName, CPU, WS
}

# Equivalent of `whoami` command
function whoami {
    Write-Output $env:USERNAME
}

# Equivalent of `ping` command
function ping {
    param (
        [string]$Target
    )
    Test-Connection -ComputerName $Target -Count 4
}

# Equivalent of `wget` command
function wget {
    param (
        [string]$Url,
        [string]$OutFile
    )
    Invoke-WebRequest -Uri $Url -OutFile $OutFile
}

# Equivalent of `curl` command
function curl {
    param (
        [string]$Url
    )
    Invoke-WebRequest -Uri $Url
}



# Equivalent of `tar` command
function tar {
    param (
        [string]$Action,
        [string]$Archive,
        [string]$Path
    )
    switch ($Action) {
        "czf" { Compress-Archive -Path $Path -DestinationPath $Archive }
        "xzf" { Expand-Archive -Path $Archive -DestinationPath $Path }
        default { Write-Host "Unsupported action. Use 'czf' for compressing and 'xzf' for extracting." }
    }
}

# Equivalent of `df` command
function df {
    Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name="Used(GB)";Expression={[math]::round($_.Used/1GB,2)}}, @{Name="Free(GB)";Expression={[math]::round($_.Free/1GB,2)}}, @{Name="Total(GB)";Expression={[math]::round($_.Used/1GB,2)+[math]::round($_.Free/1GB,2)}}, @{Name="Used(%)";Expression={[math]::round($_.Used/($_.Used+$_.Free)*100,2)}}
}

# Equivalent of `du` command
function du {
    param (
        [string]$Path = ".",
        [switch]$HumanReadable
    )
    $items = Get-ChildItem -Path $Path -Recurse | Measure-Object -Property Length -Sum
    $size = $items.Sum
    if ($HumanReadable) {
        $size = [math]::round($size / 1MB, 2)
        "$size MB"
    } else {
        "$size bytes"
    }
}

# Equivalent of `sort` command
function sort {
    param (
        [string]$Path,
        [switch]$Reverse
    )
    $content = Get-Content -Path $Path
    if ($Reverse) {
        $content | Sort-Object -Descending
    } else {
        $content | Sort-Object
    }
}

# Equivalent of `uniq` command
function uniq {
    param (
        [string]$Path
    )
    Get-Content -Path $Path | Get-Unique
}

# Equivalent of `basename` command
function basename {
    param (
        [string]$Path
    )
    [System.IO.Path]::GetFileName($Path)
}

# Equivalent of `dirname` command
function dirname {
    param (
        [string]$Path
    )
    [System.IO.Path]::GetDirectoryName($Path)
}

# Equivalent of `diff` command
function diff {
    param (
        [string]$Path1,
        [string]$Path2
    )
    Compare-Object -ReferenceObject (Get-Content -Path $Path1) -DifferenceObject (Get-Content -Path $Path2)
}

# Equivalent of `ln` command (creating symbolic link)
function ln {
    param (
        [string]$Target,
        [string]$Link
    )
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target
}

# Equivalent of `which` command
function which {
    param (
        [string]$Command
    )
    Get-Command $Command | Select-Object -ExpandProperty Definition
}

# Equivalent of `uptime` command
function uptime {
    $wmi = Get-WmiObject -Class Win32_OperatingSystem
    (Get-Date) - $wmi.LastBootUpTime
}

# Equivalent of `sleep` command
function sleep {
    param (
        [int]$Seconds
    )
    Start-Sleep -Seconds $Seconds
}

# Equivalent of `export` command
function export {
    param (
        [string]$Variable,
        [string]$Value
    )
    [System.Environment]::SetEnvironmentVariable($Variable, $Value, [System.EnvironmentVariableTarget]::Process)
}

# Equivalent of `scp` command (requires Posh-SSH module)
function scp {
    param (
        [string]$Source,
        [string]$Destination,
        [string]$Username,
        [string]$Host
    )
    $session = New-SSHSession -ComputerName $Host -Credential (Get-Credential -UserName $Username)
    if ($session) {
        Copy-Item -Path $Source -Destination $Destination -ToSession $session
        Remove-SSHSession -SessionId $session.SessionId
    }
}

# Equivalent of `locate` command
function locate {
    param (
        [string]$Pattern
    )
    Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$Pattern*" }
}

# Equivalent of `cal` command
function cal {
    Get-Date -Format "MMMM yyyy"
    [System.Globalization.CultureInfo]::CurrentCulture.DateTimeFormat.GetDayName((Get-Date).DayOfWeek)
}

# Equivalent of `date` command
function date {
    Get-Date
}


# Equivalent of `ifconfig` command
function ifconfig {
    Get-NetAdapter | Select-Object Name, Status, MacAddress, @{Name="IPv4Address";Expression={(Get-NetIPAddress -InterfaceAlias $_.Name -AddressFamily IPv4).IPAddress}}, @{Name="IPv6Address";Expression={(Get-NetIPAddress -InterfaceAlias $_.Name -AddressFamily IPv6).IPAddress}}
}


# Equivalent of `traceroute` command
function traceroute {
    param (
        [string]$Target
    )
    Test-NetConnection -ComputerName $Target -TraceRoute
}

# Equivalent of `netstat` command
function netstat {
    Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess | Format-Table
}

# Equivalent of `nslookup` command
function nslookup {
    param (
        [string]$Hostname
    )
    Resolve-DnsName -Name $Hostname
}

# Equivalent of `dig` command
function dig {
    param (
        [string]$Domain
    )
    Resolve-DnsName -Name $Domain -Type A,AAAA,MX,NS
}

# Equivalent of `curl` command
function curl {
    param (
        [string]$Url
    )
    Invoke-WebRequest -Uri $Url
}

# Equivalent of `wget` command
function wget {
    param (
        [string]$Url,
        [string]$OutFile
    )
    Invoke-WebRequest -Uri $Url -OutFile $OutFile
}

# Equivalent of `ftp` command
function ftp {
    param (
        [string]$Server,
        [string]$Username,
        [string]$Password
    )
    $ftp = "ftp://${Username}:${Password}@${Server}"
    $ftpRequest = [System.Net.FtpWebRequest]::Create($ftp)
    $ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $ftpResponse = $ftpRequest.GetResponse()
    $streamReader = New-Object System.IO.StreamReader($ftpResponse.GetResponseStream())
    $streamReader.ReadToEnd()
    $streamReader.Close()
    $ftpResponse.Close()
}

# Equivalent of `scp` command (requires Posh-SSH module)
function scp {
    param (
        [string]$Source,
        [string]$Destination,
        [string]$Username,
        [string]$Host
    )
    $session = New-SSHSession -ComputerName $Host -Credential (Get-Credential -UserName $Username)
    if ($session) {
        Copy-Item -Path $Source -Destination $Destination -ToSession $session
        Remove-SSHSession -SessionId $session.SessionId
    }
}

# Equivalent of `ssh` command (requires Posh-SSH module)
function ssh {
    param (
        [string]$Host,
        [string]$Username
    )
    New-SSHSession -ComputerName $Host -Credential (Get-Credential -UserName $Username)
}

# Equivalent of `hostname` command
function hostname {
    Write-Output $env:COMPUTERNAME
}

# Equivalent of `arp` command
function arp {
    Get-NetNeighbor -AddressFamily IPv4 | Select-Object -Property ifIndex, IPAddress, LinkLayerAddress, State
}

# Equivalent of `route` command
function route {
    Get-NetRoute | Select-Object -Property DestinationPrefix, NextHop, InterfaceAlias, RouteMetric
}

 
