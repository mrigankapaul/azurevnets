#Create a Network Security Group 
2 New-AzureNetworkSecurityGroup -Name "DMZ_NSG" -Location Southeast Asia -Label "DMZ NSG SEVNET" 
3 
 
4 #Add, Update Rules to a NSG 
5 Get-AzureNetworkSecurityGroup -Name "DMZ_NSG" | Set-AzureNetworkSecurityRule -Name RDPInternet-DMZ -Type Inbound -Priority 347 -Action Allow -SourceAddressPrefix 'INTERNET'  -SourcePortRange '63389' -DestinationAddressPrefix '10.0.2.0/25' -DestinationPortRange '63389' -Protocol TCP 
6 
 
7 #Delete a rule from NSG 
8 Get-AzureNetworkSecurityGroup -Name "DMZ_NSG" | Remove-AzureNetworkSecurityRule -Name RDPInternet-DMZ 
9 
 
10 #Associate a NSG to a Virtual machine 
11 Get-AzureVM -ServiceName "Proxy01" -Name "azproxy01" | Set-AzureNetworkSecurityGroupConfig -NetworkSecurityGroupName "DMZ_NSG" 
12 
 
13 #Remove a NSG from a VM 
14 Get-AzureVM -ServiceName "Proxy01" -Name "azproxy01" | Remove-AzureNetworkSecurityGroupConfig -NetworkSecurityGroupName "DMZ_NSG" 
15 
 
16 #Associate a NSG to a subnet 
17 Get-AzureNetworkSecurityGroup -Name "DMZ_NSG" | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName 'SEVNET' -SubnetName 'Azure DMZ Subnet' 
18 
 
19 #Remove a NSG from the subnet 
20 Get-AzureNetworkSecurityGroup -Name "DMZ_NSG" | Remove-AzureNetworkSecurityGroupFromSubnet -VirtualNetworkName 'SEVNET' -SubnetName 'Azure DMZ Subnet' 
21 
 
22 #Delete a NSG 
23 Remove-AzureNetworkSecurityGroup -Name "DMZ_NSG" 
24 
 
25 #Get Details of Network Secuirty group along with rules 
26 Get-AzureNetworkSecurityGroup -Name "DMZ_NSG" -Detailed 
