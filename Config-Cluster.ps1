[CmdletBinding()]
param ( 
[parameter(Mandatory=$true,position=1)][String]$vmOneName,
[parameter(Mandatory=$true,position=2)][String]$vmTwoName,
[parameter(Mandatory=$true,position=3)][String]$vmResourceGroupName,
[parameter(Mandatory=$true,position=4)][String]$vmClusterName,
[parameter(Mandatory=$true,position=5)][SecureString]$localAdminPassword
)


$vmOneName = $vmOneName + ".pclinc.network.ads"
$vmTwoName = $vmTwoName + ".pclinc.network.ads"
$vmOneLocalAdmin = "admin" + $vmOneName
$vmTwoLocalAdmin = "admin" + $vmTwoName
$vmOneCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $vmOneLocalAdmin, $localAdminPassword
$vmTwoCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $vmTwoLocalAdmin, $localAdminPassword
Invoke-Command -ComputerName $VmOneName -Credential $vmOneCreds -ScriptBlock {Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools -ComputerName $vmOneName} -Authentication Basic -UseSSL
Invoke-Command -ComputerName $VmTwoName -Credential $vmTwoCreds -ScriptBlock {Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools -ComputerName $vmTwoName} -Authentication Basic -UseSSL
$lbname = (Get-AzureRmResource -ResourceGroupName $vmResourceGroupName -ResourceType Microsoft.Network/loadBalancers).ResourceName
$lbIPaddress = (Get-AzureRMLoadBalancer -Name $lbName -ResourceGroup $vmResourceGroupName).FrontendIpConfigurations.PrivateIpAddress
Invoke-Command -ComputerName $vmOneName -Credential $vmOneCreds -ScriptBlock { New-Cluster -Name $vmClusterName -Node $vmOneName,$vmTwoName-StaticAddress $lbIPaddress -NoStorage } -Authentication Basic -UseSSL
Invoke-Command -ComputerName $vmOneName -Credential $vmOneCreds -ScriptBlock { Enable-ClusterS2D } -Authentication Basic -UseSSL