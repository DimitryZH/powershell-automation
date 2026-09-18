# Import the Active Directory module
Import-Module ActiveDirectory

# Disable a single user
Disable-ADAccount -Identity user1

# Disable multiple users from a CSV file
$users = Import-Csv "C:\Users.csv"

foreach ($user in $users) {
   $samAccountName = $user."samAccountName"
   
   # Check if the user exists in Active Directory
   if (Get-ADUser -Filter "samAccountName -eq '$samAccountName'") {
      Disable-ADAccount -Identity $samAccountName
   } else {
      Write-Host "User: $samAccountName is not present in AD"
   }
}
