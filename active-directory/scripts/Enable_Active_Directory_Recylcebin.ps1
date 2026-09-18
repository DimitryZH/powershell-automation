$domain = Read-Host "Provide the domain name"
$DCserver = Read-Host "Provide DC server name"

# Enable Active Directory Recycle Bin
Enable-ADOptionalFeature -Identity 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target $domain -Server $DCserver -Confirm:$false

# Delete a user
$Username = Read-Host "Enter the username of the user to delete"
Remove-ADUser -Identity $Username -Confirm:$false