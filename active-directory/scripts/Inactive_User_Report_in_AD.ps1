# Get the current date
$presentDate = Get-Date

# Get inactive users whose last logon date is more than 90 days ago
$inactiveUsers = Get-ADUser -Filter {LastLogonDate -lt $presentDate.AddDays(-90)} -Properties Name |
             Select-Object -ExpandProperty Name

# Export the list of inactive users to a CSV file
$inactiveUsers | Export-Csv -Path "C:\inactiveusers.csv" -NoTypeInformation

# Print the list of inactive users
Write-Host "The following users are inactive:" -ForegroundColor DarkYellow
$inactiveUsers