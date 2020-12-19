$routeTableName = "BE-Thru-App"
$rgName = "Module1-RG2"
$location = "East US"
$subnetName = "BackEnd"
$vnetName = "VNet-2"

$vnet = Get-AzureRmVirtualNetwork `
    -ResourceGroupName $rgName `
    -Name $vnetName

$subnet = $vnet.Subnets | 
    Where-Object Name -eq $subnetName

$routeTable = New-AzureRmRouteTable `
    -Name $routeTableName `
    -ResourceGroupName $rgName `
    -Location $location

# Add a route to the UDR Table

$routeName = "BE-thru-App-rule"

$routeTable | 
    Add-AzureRmRouteConfig `
        -Name $routeName `
        -AddressPrefix "10.20.20.0/24" `
        -NextHopType VirtualAppliance `
        -NextHopIpAddress "10.20.40.4" | 
    Set-AzureRmRouteTable

# Assign UDR table to selected subnet

Set-AzureRmVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet `
    -Name $subnetName `
    -AddressPrefix $subnet.AddressPrefix `
    -RouteTableId $routeTable.Id |
    Set-AzureRmVirtualNetwork

# Confirm UDR table is provisioned and assigned to subnet

Get-AzureRmRouteTable `
    -ResourceGroupName $rgName `
    -Name $routeTableName
