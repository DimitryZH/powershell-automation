# Active Directory Automation

This module contains PowerShell scripts for common Active Directory administration tasks. It was migrated from the standalone `active-directory-powershell-automation` project and is now the first module in the broader [PowerShell Automation](../README.md) collection.

## Overview

The scripts are intended for system administrators and IT professionals who manage Active Directory environments. They cover user lifecycle tasks, inactive account handling, object recovery, domain join preparation, and Group Policy creation.

Review each script before running it in a live environment. Several scripts perform mutating administrative actions and require domain-level permissions, local administrative rights, or both.

## Repository Layout

```text
active-directory/
├── README.md
└── scripts/
    ├── Active_Direcory_User_Recovery.ps1
    ├── Active_Directory_User_Creation.ps1
    ├── Adding_Servers_into_Domain.ps1
    ├── Create_groupe_policy.ps1
    ├── Delete_Active_Directory_Object.ps1
    ├── Disabling_Inactive_users_in_AD.ps1
    ├── Enable_Active_Directory_Recylcebin.ps1
    └── Inactive_User_Report_in_AD.ps1
```

Script filenames are preserved from the original project to avoid unnecessary behavior or usage changes during migration.

## Scripts

| Script | Purpose |
| --- | --- |
| [Adding_Servers_into_Domain.ps1](scripts/Adding_Servers_into_Domain.ps1) | Helps join servers to a domain and configure the primary DNS IP address on the network adapter. |
| [Active_Directory_User_Creation.ps1](scripts/Active_Directory_User_Creation.ps1) | Creates new Active Directory user accounts, sets temporary passwords, and sends email confirmations. |
| [Enable_Active_Directory_Recylcebin.ps1](scripts/Enable_Active_Directory_Recylcebin.ps1) | Enables the Active Directory Recycle Bin feature when it is not already enabled. |
| [Active_Direcory_User_Recovery.ps1](scripts/Active_Direcory_User_Recovery.ps1) | Recovers deleted Active Directory users through the AD Recycle Bin feature. |
| [Inactive_User_Report_in_AD.ps1](scripts/Inactive_User_Report_in_AD.ps1) | Reports user accounts that have been inactive longer than the configured threshold. |
| [Delete_Active_Directory_Object.ps1](scripts/Delete_Active_Directory_Object.ps1) | Deletes a specified Active Directory object by distinguished name. |
| [Disabling_Inactive_users_in_AD.ps1](scripts/Disabling_Inactive_users_in_AD.ps1) | Identifies and disables inactive Active Directory user accounts. |
| [Create_groupe_policy.ps1](scripts/Create_groupe_policy.ps1) | Creates and configures a Group Policy Object and backs up Group Policy Objects. |

## Common Prerequisites

Most scripts require:

- Windows PowerShell 5.1 or later
- Active Directory module for Windows PowerShell
- RSAT where the Active Directory or Group Policy cmdlets are not already installed
- Administrative privileges appropriate to the target operation
- A test or non-production validation path before use in production

Some scripts have additional requirements, such as SMTP access for notification email, Group Policy cmdlets, or an Active Directory forest functional level that supports the Recycle Bin feature.

## Usage

From the root of this repository, navigate to this module:

```powershell
cd .\active-directory
```

Review the script you want to run:

```powershell
Get-Content .\scripts\Active_Directory_User_Creation.ps1
```

Run the selected script from an elevated PowerShell session when the prerequisites are satisfied:

```powershell
.\scripts\Active_Directory_User_Creation.ps1
```

Several scripts include environment-specific values such as domain names, DNS addresses, mail server details, distinguished names, inactivity thresholds, or organizational units. Update those values before execution.

## Script Details

### Adding Servers into Domain

Prerequisites:

- Windows PowerShell 5.1 or higher
- Active Directory module for Windows PowerShell
- Remote Server Administration Tools (RSAT) installed on the local system
- Administrative privileges on the local system

Features:

- Automates joining servers to a domain
- Configures the primary DNS IP address on the network adapter

Usage:

1. Update the script with your domain details and DNS IP address.
2. Run the script with administrative privileges.

### Active Directory User Creation

Prerequisites:

- Windows PowerShell 5.1 or higher
- Active Directory module for Windows PowerShell
- SMTP server access for sending email notifications
- Administrative privileges on the local system

Features:

- Creates new user accounts in Active Directory
- Sets a temporary password for new accounts
- Sends email confirmations for newly created accounts

Usage:

1. Update the script with your domain controller, mail server details, and placeholders marked with `YOUR_`.
2. Run the script with administrative privileges.

### Enable Active Directory Recycle Bin

Prerequisites:

- Windows PowerShell 5.1 or higher
- Active Directory module for Windows PowerShell
- Administrative privileges on the local system
- Forest functional level of Windows Server 2008 R2 or higher

Features:

- Enables the Active Directory Recycle Bin feature
- Allows recovery of deleted Active Directory objects

Usage:

1. Run the script with administrative privileges.
2. The script checks and enables the AD Recycle Bin feature if it is not already enabled.

### Active Directory User Recovery

Prerequisites:

- Windows PowerShell 5.1 or higher
- Active Directory module for Windows PowerShell
- AD Recycle Bin feature enabled
- Administrative privileges on the local system

Features:

- Recovers deleted Active Directory users
- Uses the AD Recycle Bin feature for user recovery

Usage:

1. Run the script with administrative privileges.
2. When prompted, enter the name of the deleted user to recover.

### Inactive User Report in AD

Prerequisites:

- Windows PowerShell 5.1 or higher
- Active Directory module for Windows PowerShell
- Administrative privileges on the local system

Features:

- Generates a report of inactive user accounts in Active Directory
- Helps administrators identify accounts unused beyond a specified period

Usage:

1. Update the script with the desired inactivity threshold, such as 90 days.
2. Run the script with administrative privileges.
3. Review the report output.

### Delete Active Directory Object

Prerequisites:

- Windows PowerShell 5.1 or higher
- Active Directory module for Windows PowerShell
- Administrative privileges on the local system

Features:

- Deletes specified objects from Active Directory
- Supports objects such as users, computers, and groups

Usage:

1. Run the script with administrative privileges.
2. When prompted, enter the distinguished name of the object to delete.
3. Confirm that the target object is correct before proceeding.

### Disabling Inactive Users in AD

Prerequisites:

- Windows PowerShell 5.1 or higher
- Active Directory module for Windows PowerShell
- Administrative privileges on the local system

Features:

- Identifies inactive user accounts based on a configured inactivity period
- Disables inactive accounts to reduce security exposure

Usage:

1. Update the script with the desired inactivity threshold, such as 90 days.
2. Run the script with administrative privileges.
3. Review the affected accounts before using in production.

### Create Group Policy

Prerequisites:

- Windows PowerShell 5.1 or higher
- Group Policy module for Windows PowerShell
- Administrative privileges on the local system

Features:

- Creates a Group Policy Object named `Secure_computer`
- Configures desktop background and icon restrictions
- Links the GPO to a specific Organizational Unit in Active Directory
- Backs up all Group Policy Objects

Usage:

1. Open PowerShell with administrative privileges.
2. Review and update the target Organizational Unit and policy settings.
3. Run `Create_groupe_policy.ps1`.
4. Confirm the script has the permissions required to modify Group Policy Objects and Active Directory.

## Safety Notes

- Test scripts in a lab or staging domain before production use.
- Confirm target distinguished names, OUs, domain names, DNS addresses, SMTP settings, and inactivity thresholds.
- Avoid storing credentials directly in scripts.
- Use least-privilege administrative accounts where practical.
- Keep a current backup and recovery process for directory and Group Policy changes.

## Repository Context

This module is part of the PowerShell Automation collection. For the collection overview and future modules, see the root [`README.md`](../README.md).
