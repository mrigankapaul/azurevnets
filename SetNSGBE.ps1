$rule1 = New-AzureRmNetworkSecurityRuleConfig -Name no-internet-rule -Description "Block Internet" `
    -Access Deny -Protocol * -Direction Outbound -Priority 200 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix Internet -DestinationPortRange *
    
$rule2 = New-AzureRmNetworkSecurityRuleConfig -Name allow-FE-SQL-rule -Description "Allow SQL from FE subnet" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
    -SourceAddressPrefix 10.20.20.0/24 -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 1433

$rule3 = New-AzureRmNetworkSecurityRuleConfig -Name block-FE-rule -Description "Block all from FE subnet" `
    -Access Deny -Protocol Tcp -Direction Inbound -Priority 200 `
    -SourceAddressPrefix 10.20.20.0/24 -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange *
    
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName Module1-RG2 -location eastus -Name "NSG-BE2" `
    -SecurityRules $rule1,$rule2,$rule3

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName Module1-RG2 -Name VNet-2

Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name BackEnd `
    -AddressPrefix 10.20.30.0/24 -NetworkSecurityGroup $nsg

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet


##########################

az network nsg create `
    --name NSG-BE2 `
    --resource-group Module1-RG2 `
    --location canadacentral 

az network nsg rule create `
    --name no-internet-rule `
    --description "Block Internet" `
    --access Deny `
    --protocol "*" `
    --direction Outbound `
    --source-address-prefixes '*' `
    --source-port-ranges '*' `
    --destination-address-prefixes Internet `
    --destination-port-ranges '*' `
    --nsg-name NSG-BE2 `
    --resource-group Module1-RG2 `
    --priority 200
    
    az network nsg rule create `
    --name allow-FE-SQL-rule `
    --description "Allow SQL from FE subnet" `
    --access Allow `
    --protocol Tcp `
    --direction Inbound `
    --source-address-prefixes 10.20.20.0/24  `
    --source-port-ranges '*' `
    --destination-address-prefixes Internet `
    --destination-port-ranges 1433 `
    --nsg-name NSG-BE2 `
    --resource-group Module1-RG2 `
    --priority 100

    az network nsg rule create `
    --name block-FE `
    --description "Block all from FE subnet" `
    --access Deny `
    --protocol Tcp `
    --direction Inbound `
    --source-address-prefixes 10.20.20.0/24  `
    --source-port-ranges '*' `
    --destination-address-prefixes Internet `
    --destination-port-ranges '*' `
    --nsg-name NSG-BE2 `
    --resource-group Module1-RG2 `
    --priority 200


    az network vnet subnet update `
        --name BackEnd `
        --network-security-group NSG-BE2 `
        --resource-group Module1-RG2 `
        --vnet-name VNet-2
