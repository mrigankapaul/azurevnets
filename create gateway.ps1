$VNetName  = "VNet-3"
$FESubName = "FrontEnd"
$BESubName = "Backend"
$GWSubName = "GatewaySubnet"
$VNetPrefix = "10.30.0.0/16"
$FESubPrefix = "10.30.10.0/24"
$BESubPrefix = "10.30.20.0/24"
$GWSubPrefix = "10.30.200.0/26"
$VPNClientAddressPool = "192.168.111.0/24"
$RG = "PlazRG"
$Location = "East US"
$DNS = "8.8.8.8"
$GWName = "VNet3GW"
$GWIPName = "VNet3GWIP"
$GWIPconfName = "VNet3gwipconf"
$P2SRootCertName = "x"

New-AzureRmResourceGroup -Name $RG -Location $Location

$fesub = New-AzureRmVirtualNetworkSubnetConfig -Name $FESubName -AddressPrefix $FESubPrefix
$besub = New-AzureRmVirtualNetworkSubnetConfig -Name $BESubName -AddressPrefix $BESubPrefix
$gwsub = New-AzureRmVirtualNetworkSubnetConfig -Name $GWSubName -AddressPrefix $GWSubPrefix

New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RG -Location $Location -AddressPrefix $VNetPrefix -Subnet $fesub, $besub, $gwsub -DnsServer $DNS

$vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RG
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet

$pip = New-AzureRmPublicIpAddress -Name $GWIPName -ResourceGroupName $RG -Location $Location -AllocationMethod Dynamic
$ipconf = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPconfName -Subnet $subnet -PublicIpAddress $pip

$MyP2SRootCertPubKeyBase64 = "MIIC8DCCAdygAwIBAgIQI9l9n0JtepFB5dDFlYhTLDAJBgUrDgMCHQUAMBMxETAPBgNVBAMTCFBsYXpDZXJ0MB4XDTE2MDYwMTE1MzE0OFoXDTM5MTIzMTIzNTk1OVowEzERMA8GA1UEAxMIUGxhekNlcnQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDSqMuBSjY+mb5PpXJEDVHLoQIsKZYwRAHG7yK/O13Th3LqfJTpkteL6sKCpelSkHAHFcsw1f061K30ZV1kFBMLkDuTFmRny0L7fKxmbVPNgGCLJKFvczM6D9cXoprUx+vIunVXR1xKH8uE9YB6AWM3llUL9jOdeaFpSuQj/8nSoY82NY06KgRo5hN2l3qPWxTVMpHisijCQci2OZ8Phrq1aj37HGBI7Vn4f1xXWTo5X9Oz+ijH+0hKXwzzElOpKY/D5ic/BuMEb6kjRjFMWjCoUvmlk7bkLkloDpclyIr64CgG4+T+R4/eT5g/Yv0V9tTUA2525UE3611Z9ewwkdxBAgMBAAGjSDBGMEQGA1UdAQQ9MDuAEPE1dAXkDyS2jCca/GATQFahFTATMREwDwYDVQQDEwhQbGF6Q2VydIIQI9l9n0JtepFB5dDFlYhTLDAJBgUrDgMCHQUAA4IBAQBIgoXg9okaAdnmoFkTz5vfiDJrB6IMwSc5oUHeaotEM1Zpj/avjQJjB9ZsTod8s3/7K/71QngWzQn9o0b4JvBP/bDsTya5vEyIF8ZMXEEWg0jpiTaPmunKuednLY1m76pX5RTy1rWTAgzYhKPIZa18DGLibojYGc59TE6Qyv7FQhquYfseuGSCsF8GQD2D2Iia562r0WPyzToZUE8bf3Vz6HwdP4wEHMYRM2mJDnyUOwhZww6jXzt1d3ualaYbYH5sRd74exbnrWGi0fU1SehChqZvzQTMR5NYKP5OD9dm1mXeuQA82GuA+QYM5pwOCc/4+V8hMbLsnukcOtKOA0lH"
$p2srootcert = New-AzureRmVpnClientRootCertificate -Name $P2SRootCertName -PublicCertData $MyP2SRootCertPubKeyBase64

New-AzureRmVirtualNetworkGateway -Name $GWName -ResourceGroupName $RG -Location $Location -IpConfigurations $ipconf -GatewayType Vpn -VpnType RouteBased -EnableBgp $false -GatewaySku Standard -VpnClientAddressPool $VPNClientAddressPool -VpnClientRootCertificates $p2srootcert