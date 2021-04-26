<#
.SYNOPSIS
This script will create rules in any NSGs provided

.DESCRIPTION
This script makes use of splatting and loops. Refer to MS Docs for detailed information on each.

You can add the same rule to multiple NSGs, multiple rules in one or more NSGs, or both.

.NOTES
Author - Lou Garramone
Email - lou@lg4tech.com

#>

# Store Resource Group and IP Addresses.
$resourceGroup = "<resource_group_here>"
$IP = @("192.168.1.1,192.168.1.2")

# Store Network Security Groups (NSG).
$NSG1 = Get-AzNetworkSecurityGroup -Name "NSG1" -ResourceGroupName $resourceGroup
$NSG2 = Get-AzNetworkSecurityGroup -Name "NSG2" -ResourceGroupName $resourceGroup


# Create splat to hold reused parameter values.
$NsgRulesSplat = @{
    Description = "Deny traffic to/from IP List"
    Access = "Deny"
    Protocol = "*"
    Priority = "110"
    SourcePortRange = "*"
    DestinationPortRange = "*"
}

# Store gathered NSGs in an array for use in the following loop.
$nsgArray = $NSG1,$NSG2

# For each Array in nsgArrays variable, create inbound and outbound rules.
foreach ($nsg in $nsgArray){

    #Apply Inbound Rule.
    $nsg | Add-AzNetworkSecurityRuleConfig -Name "Deny-Traffic-IN" `
        -Direction Inbound `
        -SourceAddressPrefix $IP `
        -DestinationAddressPrefix * `
        @NsgRulesSplat | Set-AzNetworkSecurityGroup

    #Apply Outbound Rule.
    $nsg | Add-AzNetworkSecurityRuleConfig -Name "Deny-Traffic-OUT" `
        -Direction Outbound `
        -SourceAddressPrefix * `
        -DestinationAddressPrefix $IP `
        @NsgRulesSplat | Set-AzNetworkSecurityGroup
}