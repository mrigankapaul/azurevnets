New-AzureRmResourceGroup -Name Module1-RG2 -Location canadacentral
az group create -l canadacentral -n Module1-RG2
New-AzureRmVirtualNetwork -ResourceGroupName Module1-RG2 -Name VNet-2 `
    -AddressPrefix 10.20.0.0/16 -Location EastUS   

    az network vnet create -g Module1-RG2 -n VNet-2 --address-prefix 10.20.0.0/16 -l canadacentral

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName Module1-RG2 -Name VNet-2

Add-AzureRmVirtualNetworkSubnetConfig -Name FrontEnd `
    -VirtualNetwork $vnet -AddressPrefix 10.20.20.0/24

    az network vnet subnet create -g Module1-RG2 --vnet-name VNet-2 -n FrontEnd `
    --address-prefixes 10.20.20.0/24

Add-AzureRmVirtualNetworkSubnetConfig -Name BackEnd `
    -VirtualNetwork $vnet -AddressPrefix 10.20.30.0/24

    az network vnet subnet create -g Module1-RG2 --vnet-name VNet-2 -n BackEnd `
    --address-prefixes 10.20.30.0/24

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet 
