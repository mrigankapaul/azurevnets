# Set values 
$rgName="Module1-RG2"
$locName="canadacentral"
$saName="module1rg27176"
$vmName="plaz-vm-3"
$pubName="MicrosoftWindowsServer"
$offerName="WindowsServer"
$skuName="2012-R2-Datacenter"
$vmSize="Standard_A1"
$vnetName="VNet-2"
$subnetIndex=1
$nicName="plaz-VM-3-Nic1"
$domName="plaz-vm-3"
$diskName="plazOS"

#Assign virtual network
$vnet=Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
# $vnet=az network vnet show -g $rg#Name  -n $vnetName
$subNetName=$(az network vnet show -g $rgName  -n $vnetName --query subnets[1].id -o tsv)

# Create NIC
$pip=New-AzureRmPublicIpAddress -Name $nicName -ResourceGroupName $rgName -DomainNameLabel $domName -Location $locName -AllocationMethod Dynamic
az network public-ip create -n $nicName -g $rgName --dns-name $domName -l $locName --allocation-method Dynamic
$pipObj=$($pip | ConvertFrom-Json).publicIp.id
$nic=New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[$subnetIndex].Id -PublicIpAddressId $pip.Id
$nic = az network nic create -n $nicName -g $rgName -l $locName --subnet $subNetName --public-ip-address $pipObj

# Specify the local administrator account and VM information

$cred=Get-Credential -Message "Type the name and password of the local administrator account."
$vm=New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
$vm=Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm=Set-AzureRmVMSourceImage -VM $vm -PublisherName $pubName -Offer $offerName -Skus $skuName -Version "latest"
$vm=Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

# Create the VM

$storageAcc=Get-AzureRmStorageAccount -ResourceGroupName $rgName -Name $saName
$osDiskUri=$storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $vmName + $diskName  + ".vhd"
$vm=Set-AzureRmVMOSDisk -VM $vm -Name $diskName -VhdUri $osDiskUri -CreateOption fromImage
New-AzureRmVM -ResourceGroupName $rgName -Location $locName -VM $vm

#Create VM by attaching existing managed disks as OS
az vm create `
-n $vmName `
--resource-group $rgName `
--attach-os-disk $managedDiskId `
--os-type $osType

#Provide the subscription Id
subscriptionId=6492b1f7-f219-446b-b509-314e17e1efb0

#Provide the name of your resource group
resourceGroupName=myResourceGroupName

#Provide the name of the Managed Disk
managedDiskName=Plaz-VM-2_OsDisk_1_80314d696c41455caba6bf1ce2886a07

#Provide the OS type
osType=linux

#Provide the name of the virtual machine
virtualMachineName=myVirtualMachineName123

#Set the context to the subscription Id where Managed Disk exists and where VM will be created
az account set --subscription $subscriptionId

#Get the resource Id of the managed disk
managedDiskId=$(az disk show --name $managedDiskName --resource-group $rgName --query [id] -o tsv)

az vm create `
    -n $vmName `
    -g $rgName `
    -l $locName `
    --admin-password xxx `
    --admin-username mriganka `
    --enable-agent true `
    --enable-auto-update true `
    --image MicrosoftWindowsServer:WindowsServer:2012-r2-datacenter-gensecond:latest `
    --nics $($nic | ConvertFrom-Json).NewNIC.id `
    --os-disk-caching ReadWrite `
    --os-disk-name $diskName `
    --os-disk-size-gb 127 `
    --size Standard_B1s 

    

     `
