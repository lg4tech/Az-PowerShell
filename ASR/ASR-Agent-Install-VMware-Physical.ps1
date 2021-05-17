<#
.NOTES
Author  - Lou Garramone
Date    - 5/17/21
Version - 1.0

Prerequisites
    1. Share C:\ProgramData\ASR\home\svsystems\pushinstallsvc\repository folder from ASR Config Server
    2. Gather and store the config server IP and passphrase below.

#>

# https://gist.github.com/ctigeek/bd637eeaeeb71c5b17f4
function Start-Sleep($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}

########## START USER DEFINED VARIABLES #############
$AsrCfgSvr = '<IP_HERE>'
$AsrPassphrase = '<PASSPHRASE_HERE>'
$PassphrasePath = 'D:\tmp\Passphrase.txt'
########### END USER DEFINED VARIABLES ##############

# Create tmp directory on data drive D.
New-Item -Path D:\ -Name 'tmp' -ItemType "Directory"

# Create a txt file and store the passphrase entered in $AsrPassPhrase.
New-Item "$PassphrasePath" -ItemType File -Value "$AsrPassPhrase"

# Copy the agent installer from the ASR Configuration Server and store/rename it in the tmp directory on drive D.
Copy-Item -Path "\\$AsrCfgSvr\repository\Microsoft-ASR_UA*Windows*release.exe" -Destination "D:\tmp\ASRAgentInstaller.exe"

# Extract files from ASRAgentInstaller and store them in tmp.
Start-Process -FilePath "D:\tmp\ASRAgentInstaller.exe" -ArgumentList "/q /x:D:\tmp\" -NoNewWindow

# Sleep for 5 seconds to allow extraction to finish. (This will be automated by process later)
Start-Sleep 5

# Silent install the mobility agent as VMware/Physical platform.
Start-Process -FilePath "D:\tmp\UnifiedAgent.exe" -ArgumentList "/Role `"MS`" /Platform `"VmWare`" /Silent" -NoNewWindow

# Sleep for 60 seconds to allow extraction to finish. (This will be automated by process later)
Start-Sleep 60

# Run the agent configuration (hostconfigwxcommon) and register the vault by IP and passphrase.
Start-Process -FilePath "C:\Program Files (x86)\Microsoft Azure Site Recovery\agent\UnifiedAgentConfigurator.exe" -ArgumentList "/CSEndPoint $AsrCfgSvr /PassphraseFilePath $PassphrasePath" -NoNewWindow