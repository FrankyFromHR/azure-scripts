[CmdletBinding()]
param ( 
)

New-Item -ItemType Directory -Name Temp -Path C:\
Start-Transcript -Path C:\Temp\
Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools -Confirm
Stop-Transcript