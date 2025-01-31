# ------------------------------------------
# PolicyWizard
# PowerShell Script to Set Password History and Complexity Policies to Zero
# Author: Joe Juette
# Created: January 31, 2025
# Description: This script exports the current security policy, modifies the
# PasswordHistorySize and PasswordComplexity settings to zero, and re-imports the policy.
# Additionally, it ensures cleanup of temporary files used during the process.
# ------------------------------------------

function Check-Directory {
    # Define the paths
    $PolicyFilePath = "C:\Temp\SecurityPolicy.inf"
    $SecurityDatabasePath = "C:\Windows\Security\Database\secedit.sdb"

    # Check if the temp policy path exists, if not, create it
    $PolicyDirectory = [System.IO.Path]::GetDirectoryName($PolicyFilePath)
    if (-not (Test-Path -Path $PolicyDirectory)) {
        New-Item -Path $PolicyDirectory -ItemType Directory | Out-Null
    }
}

function Clean-Directory {
    # Define the path
    $PolicyFilePath = "C:\Temp\SecurityPolicy.inf"

    # Clean up the temporary policy file
    if (Test-Path $PolicyFilePath) {
        Remove-Item $PolicyFilePath -Force
        Write-Output "Temporary policy file cleaned up."
    }
}

function Set-PasswordHistoryToZero {
    # Define the paths
    $PolicyFilePath = "C:\Temp\SecurityPolicy.inf"
    $SecurityDatabasePath = "C:\Windows\Security\Database\secedit.sdb"

    # Export the current security policy
    secedit /export /cfg $PolicyFilePath

    # Read the policy file
    $policyContent = Get-Content -Path $PolicyFilePath

    # Modify the PasswordHistorySize setting to 0
    $newPolicyContent = $policyContent -replace '(PasswordHistorySize\s*=\s*)\d+', '$10'

    # Save the modified policy back to the file
    Set-Content -Path $PolicyFilePath -Value $newPolicyContent

    # Import the modified security policy
    secedit /configure /db $SecurityDatabasePath /cfg $PolicyFilePath /overwrite

    # Refresh the security policies
    gpupdate /force

    Write-Output "Password history requirement set to zero successfully."
}

function Set-PasswordComplexityToZero {
    # Define the paths
    $PolicyFilePath = "C:\Temp\SecurityPolicy.inf"
    $SecurityDatabasePath = "C:\Windows\Security\Database\secedit.sdb"

    # Export the current security policy
    secedit /export /cfg $PolicyFilePath

    # Read the policy file
    $policyContent = Get-Content -Path $PolicyFilePath

    # Modify the PasswordComplexity setting to 0
    $newPolicyContent = $policyContent -replace '(PasswordComplexity\s*=\s*)\d+', '$10'

    # Save the modified policy back to the file
    Set-Content -Path $PolicyFilePath -Value $newPolicyContent

    # Import the modified security policy
    secedit /configure /db $SecurityDatabasePath /cfg $PolicyFilePath /overwrite

    # Refresh the security policies
    gpupdate /force

    Write-Output "Password complexity requirement set to zero successfully."
}

# First run requirement
Check-Directory

# Example usage of the functions
Set-PasswordComplexityToZero
Set-PasswordHistoryToZero

# After run requirement for security
Clean-Directory


