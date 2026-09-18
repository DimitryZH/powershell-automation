# Prompt the user to choose whether to delete a User or a Computer
$input = Read-Host "Enter your choice"

Switch ($input)
{
   0 { $result = 'User Deletion' }
   1 { $result = 'Computer Deletion' }
}

# If input is greater than 1, display an error message.
if ($input -gt 1)
{
   Write-Host "$input is not a valid choice" -ForegroundColor Cyan
}

# If 0 is selected, prompt for the username to be deleted.
if ($input -eq 0)
{
   $user = Read-Host "Provide the username" 
   Try {
      Remove-ADUser $user -Confirm:$false 
      Write-Host "User $user has been deleted" -ForegroundColor DarkGreen
   }
   Catch {
      Write-Host "$user is not present in Active Directory or the username is incorrect" -ForegroundColor DarkRed 
   }
}

# If 1 is selected, prompt for the computer name to be deleted.
if ($input -eq 1)
{
   $computer = Read-Host "Provide the computer name"
   Try {
      Remove-ADComputer $computer -Confirm:$false 
      Write-Host "Computer $computer has been deleted" -ForegroundColor DarkGreen
   }
   Catch {
      Write-Host "$computer is not present in Active Directory or the computer name is incorrect" -ForegroundColor DarkRed 
   }
}
