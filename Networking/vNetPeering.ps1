#------------------------------------------SCRIPT START-----------------------------------------#

# Declare resource group.
$resourceGroup = '<resource_group_name>'

#Get virtual network information and store to variable.
$EU2ASRvNet = Get-AzVirtualNetwork -Name '<vNet_name>' -ResourceGroupName $resourceGroup
$CUS1vNet = Get-AzVirtualNetwork -Name '<vNet_name>' -ResourceGroupName $resourceGroup
$CUS2vNet = Get-AzVirtualNetwork -Name '<vNet_name>' -ResourceGroupName $resourceGroup

#--------------------------------------------------#

# Create peer from EU2-VNET01-ASR to CUS-VNET01.
Add-AzVirtualNetworkPeering `
    -Name EU2-VNET01-CUS-VNET01 `
    -VirtualNetwork $EU2ASRvNet `
    -RemoteVirtualNetworkId $CUS1vNet.Id

# Create peer from CUS-VNET01 to EU2-VNET01-ASR.
Add-AzVirtualNetworkPeering `
    -Name CUS-VNET01-EU2-VNET01 `
    -VirtualNetwork $CUS1vNet `
    -RemoteVirtualNetworkId $EU2ASRvNet.Id

#--------------------------------------------------#

# Create peer from CUS-VNET01 to CUS-VNET02.
Add-AzVirtualNetworkPeering `
    -Name CUS-VNET01-CUS-VNET02 `
    -VirtualNetwork $CUS1vNet `
    -RemoteVirtualNetworkId $CUS2vNet.Id `
    -AllowGatewayTransit

# Create peer from CUS-VNET02 to CUS-VNET01.
Add-AzVirtualNetworkPeering `
    -Name CUS-VNET02-CUS-VNET01 `
    -VirtualNetwork $CUS2vNet `
    -RemoteVirtualNetworkId $CUS1vNet.Id `
    -UseRemoteGateways

#--------------------------------------------------#

# Create peer from EU2-VNET01-ASR to CUS-VNET02.
Add-AzVirtualNetworkPeering `
    -Name EU2-VNET01-CUS-VNET02 `
    -VirtualNetwork $EU2ASRvNet `
    -RemoteVirtualNetworkId $CUS2vNet.Id

# Create peer from CUS-VNET02 to EU2-VNET01-ASR.
Add-AzVirtualNetworkPeering `
    -Name CUS-VNET02-EU2-VNET01 `
    -VirtualNetwork $CUS2vNet `
    -RemoteVirtualNetworkId $EU2ASRvNet.Id

#--------------------------------------------------#

# Print status of newly created peering connections.
$EU2Status = Get-AzVirtualNetworkPeering `
    -ResourceGroupName $resourceGroup `
    -VirtualNetworkName $EU2ASRvNet.Name `
    | Select Name,PeeringState

$CUS1Status = Get-AzVirtualNetworkPeering `
    -ResourceGroupName $resourceGroup `
    -VirtualNetworkName $CUS1vNet.Name `
    | Select Name,PeeringState

$CUS2Status = Get-AzVirtualNetworkPeering `
    -ResourceGroupName $resourceGroup `
    -VirtualNetworkName $CUS2vNet.Name `
    | Select Name,PeeringState

# Print peering status for all connections.
$EU2Status,$CUS1Status,$CUS2Status

#--------------------------------------------SCRIPT END-----------------------------------------#