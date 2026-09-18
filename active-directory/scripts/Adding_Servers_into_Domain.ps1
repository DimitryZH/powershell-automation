

## For single server\machine to be added to domain. 

set-DnsClientServerAddress -InterfaceIndex 2 -ServerAddresses "Primary DNS IP address"
set-DnsClientServerAddress -InterfaceAlias Ethernet -AddressFamily IPv4 | Select-Object ServerAddresses

#Once DNS IP is updated, then execute below cmd. 
Add-Computer -ComputerName $computers -Domain "YourDomainName" -Restart

#Give your domain credentials in the credential request window. 


#**************************************************************



## For multiple server\machine to be added to domain.

set-DnsClientServerAddress -InterfaceIndex 2 -ServerAddresses "Primary DNS IP address"
set-DnsClientServerAddress -InterfaceAlias Ethernet -AddressFamily IPv4 |Select-Object ServerAddresses

#Once DNS IP is updated on machines, then execute below cmd.

$computers = Get-Content -Path c:\test\desktop\computers.txt
Add-Computer -ComputerName $computers -Domain "YourDomainName" -Restart

#Give your domain credentials in the credential request window. 