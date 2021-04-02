#------------------------------------------SCRIPT START-----------------------------------------#

# Name of the resource group that contains the VMs (Virtual Machines).
$rgName = '<resource_group_name>'

# Choose between Standard_LRS, Premium_LRS, StandardSSD_LRS, or UltraSSD_LRS.
$storageType = 'Premium_LRS'

# Name of the VMs in the resource group.
$vmName = Get-AzVM -ResourceGroupName $rgName | Where-Object {$_.Name -notlike "<vm-name>*"}

# For each VM in the resource group, Stop the VM and change the performance tier.
foreach ($vm in $vmName)
{
	# Stop and deallocate the VM before changing the storage type.
    Stop-AzVM -ResourceGroupName $rgName -Name $vm.name -Force

    # Get all disks connected to the VM.
    $vmDisks = Get-AzDisk -ResourceGroupName $rgName 

    # For disks that belong to the selected VM, convert to selected storage type.
    foreach ($disk in $vmDisks)
    {
        if ($disk.ManagedBy -eq $vm.Id)
        {
            $disk.Sku = [Microsoft.Azure.Management.Compute.Models.DiskSku]::new($storageType)
            $disk | Update-AzDisk
        }
    }

    # Stop and deallocate the VM before changing the disk tier.
    Start-AzVM -ResourceGroupName $rgName -Name $vm.name
}

# Print the current status of the Virtual Machines after powering on.
$vmName | Format-List Name,ProvisioningState

#--------------------------------------------SCRIPT END-----------------------------------------#