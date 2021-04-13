<#
.SYNOPSIS
	Create a hub and spoke network layout with Az Powershell.
.DESCRIPTION
	This is referencing HubAndSpokeTopology architecture diagram: https://github.com/lg4tech/Az-Architecture/blob/master/Networking/HubAndSpokeTopology.png
.NOTES
	AUTHOR: Lou Garramone
	EMAIL: lou@lg4tech.com
	DATE: 4/13/2021
#>

$resourceGroup = 'HubServices'
$location = 'East US'

# Create Resource Group.
New-AzResourceGroup -Name $resourceGroup -Location $location

#Create Virtual Networks for Hub, Spoke1 and Spoke2.
$hubVirtualNetwork = New-AzVirtualNetwork -Name 'Hub-vNet' -ResourceGroupName $resourceGroup -Location $location -AddressPrefix '172.16.0.0/24'
$spoke1VirtualNetwork = New-AzVirtualNetwork -Name 'Spoke-vNet1' -ResourceGroupName $resourceGroup -Location $location -AddressPrefix '172.17.0.0/16'
$Spoke2VirtualNetwork = New-AzVirtualNetwork -Name 'Spoke-vNet2' -ResourceGroupName $resourceGroup -Location $location -AddressPrefix '172.18.0.0/16'

#Create Subnets and associate Hub-vNet.
Add-AzVirtualNetworkSubnetConfig -Name 'HubMainSubnet' -VirtualNetwork $hubVirtualNetwork -AddressPrefix '172.16.0.0/26' | Set-AzVirtualNetwork
Add-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $hubVirtualNetwork -AddressPrefix '172.16.0.64/28' | Set-AzVirtualNetwork

#Create Subnets and associate Spoke1-vNet.
Add-AzVirtualNetworkSubnetConfig -Name 'WebSubnet' -VirtualNetwork $spoke1VirtualNetwork -AddressPrefix '172.17.0.0/24' | Set-AzVirtualNetwork
Add-AzVirtualNetworkSubnetConfig -Name 'AppSubnet' -VirtualNetwork $spoke1VirtualNetwork -AddressPrefix '172.17.1.0/24' | Set-AzVirtualNetwork
Add-AzVirtualNetworkSubnetConfig -Name 'DBSubnet' -VirtualNetwork $spoke1VirtualNetwork -AddressPrefix '172.17.2.0/24' | Set-AzVirtualNetwork

#Create Subnets and associate Spoke2-vNet.
Add-AzVirtualNetworkSubnetConfig -Name 'WebSubnet' -VirtualNetwork $Spoke2VirtualNetwork -AddressPrefix '172.18.0.0/24' | Set-AzVirtualNetwork
Add-AzVirtualNetworkSubnetConfig -Name 'AppSubnet' -VirtualNetwork $Spoke2VirtualNetwork -AddressPrefix '172.18.1.0/24' | Set-AzVirtualNetwork
Add-AzVirtualNetworkSubnetConfig -Name 'DBSubnet' -VirtualNetwork $Spoke2VirtualNetwork -AddressPrefix '172.18.2.0/24' | Set-AzVirtualNetwork

# Create peer from Hub-vNet to Spoke-vNet1.
Add-AzVirtualNetworkPeering -Name Hub-vNet-Spoke-vNet1 -VirtualNetwork $hubVirtualNetwork -RemoteVirtualNetworkId $spoke1VirtualNetwork.Id -AllowGatewayTransit

# Create peer from Spoke-vNet1 to Hub-vNet.
Add-AzVirtualNetworkPeering  -Name Spoke-vNet1-Hub-vNet -VirtualNetwork $spoke1VirtualNetwork -RemoteVirtualNetworkId $hubVirtualNetwork.Id -UseRemoteGateways

# Create peer from Hub-vNet to Spoke-vNet2.
Add-AzVirtualNetworkPeering -Name Hub-vNet-Spoke-vNet2 -VirtualNetwork $hubVirtualNetwork -RemoteVirtualNetworkId $spoke2VirtualNetwork.Id -AllowGatewayTransit

# Create peer from Spoke-vNet2 to Hub-vNet.
Add-AzVirtualNetworkPeering  -Name Spoke-vNet2-Hub-vNet -VirtualNetwork $spoke2VirtualNetwork -RemoteVirtualNetworkId $hubVirtualNetwork.Id -UseRemoteGateways