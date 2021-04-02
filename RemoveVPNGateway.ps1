#------------------------------------------SCRIPT START-----------------------------------------#

# Declare resource group.
$resourceGroup = "<resource_group_name>"

# Get Virtual Network Gateway information and store it to a variable.
$EU2VpnGw = Get-AzVirtualNetworkGateway -Name "<VPN_Gateway_Name" -ResourceGroupName $resourceGroup

# Get Virtual Network Gateway connections list and store to a variable.
$Connections = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $resourceGroup `
| Where-Object {$_.VirtualNetworkGateway1.Id -eq $EU2VpnGw.Id}

# Remove each connection stored in $Connections.
$Connections | ForEach-Object {Remove-AzVirtualNetworkGatewayConnection -Name $_.Name -ResourceGroupName $_.ResourceGroupName}

# Remove the Virtual Network Gateway in the EU2 Region.
Remove-AzVirtualNetworkGateway -Name $EU2VpnGw.Name -ResourceGroupName $resourceGroup -Force

#--------------------------------------------SCRIPT END-----------------------------------------#