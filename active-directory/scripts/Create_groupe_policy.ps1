
# Edit the registries of our client computers in the group policy:
New-GPO -Name "Secure_computer"

# Prevent changing desktop background
Set-GPRegistryValue -Name "Secure_computer" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" -ValueName "NoChangingWallPaper" -Value 1 -Type Dword

# Prevent changing desktop icons
Set-GPRegistryValue -Name "Secure_computer" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "NoDispBackgroundPage" -Value 1 -Type Dword

# Desktop Wallpaper
Set-GPRegistryValue -Name "Secure_computer" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "WallpaperStyle" -Value 0 -Type Dword
Set-GPRegistryValue -Name "Secure_computer" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "Wallpaper" -Value "\\SRV1\Share1$\wallpaper.jpg" -Type ExpandString

# Disable Remove Recycle Bin icon from desktop
Set-GPRegistryValue -Name "Secure_computer" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -ValueName "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0 -Type Binary

# By default, creating the group policy object doesn’t bind it to any part of Active Directory.
# To bind the group policy object to AD:
Get-GPO -Name "Secure_computer" | New-GPLink -Target "OU=test,OU=Sites,DC=linkedin,DC=int" -LinkEnabled Yes

# To back up group policy objects:
Get-GPO -All | Backup-GPO -Path "C:\GPOBackup\" -Comment "$(Get-Date)"