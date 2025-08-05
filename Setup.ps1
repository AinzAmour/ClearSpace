# System Cleaner Setup Script
# Helps configure the tool for your GitHub repository

param(
    [string]$GitHubUsername,
    [string]$RepositoryName = "system-cleaner",
    [string]$Branch = "main"
)

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Header {
    param([string]$Title)
    Write-ColorOutput "`n" -Color "Cyan"
    Write-ColorOutput "=" * 60 -Color "Cyan"
    Write-ColorOutput " $Title" -Color "Cyan"
    Write-ColorOutput "=" * 60 -Color "Cyan"
    Write-ColorOutput "`n" -Color "Cyan"
}

Write-Header "System Cleaner Setup"

if (-not $GitHubUsername) {
    Write-ColorOutput "Please provide your GitHub username:" -Color "Yellow"
    $GitHubUsername = Read-Host "GitHub Username"
}

if (-not $GitHubUsername) {
    Write-ColorOutput "Error: GitHub username is required." -Color "Red"
    exit 1
}

Write-ColorOutput "Setting up System Cleaner for GitHub user: $GitHubUsername" -Color "Green"
Write-ColorOutput "Repository: $RepositoryName" -Color "Green"
Write-ColorOutput "Branch: $Branch" -Color "Green"

# Base URLs
$baseUrl = "https://raw.githubusercontent.com/$GitHubUsername/$RepositoryName/$Branch"
$configUrl = "$baseUrl/config.json"

Write-ColorOutput "`nUpdating SystemCleaner.ps1..." -Color "Blue"

# Read the main script
$scriptContent = Get-Content -Path "SystemCleaner.ps1" -Raw

# Update the GitHub repository URLs
$scriptContent = $scriptContent -replace 'https://raw\.githubusercontent\.com/your-username/system-cleaner/main', $baseUrl

# Write the updated script
Set-Content -Path "SystemCleaner.ps1" -Value $scriptContent -Encoding UTF8

Write-ColorOutput "Updated SystemCleaner.ps1" -Color "Green"

Write-ColorOutput "`nUpdating config.json..." -Color "Blue"

# Read the config file
$configContent = Get-Content -Path "config.json" -Raw

# Update all module URLs
$configContent = $configContent -replace 'https://raw\.githubusercontent\.com/your-username/system-cleaner/main', $baseUrl

# Write the updated config
Set-Content -Path "config.json" -Value $configContent -Encoding UTF8

Write-ColorOutput "Updated config.json" -Color "Green"

Write-ColorOutput "`nCreating deployment instructions..." -Color "Blue"

# Create deployment instructions
$deploymentInstructions = @"
# Deployment Instructions

## 1. Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: $RepositoryName
3. Make it Public (or Private if you prefer)
4. Click "Create repository"

## 2. Upload Files

Upload the following files to your repository:

### Root Directory:
- SystemCleaner.ps1
- config.json
- README.md
- RunSystemCleaner.bat
- Setup.ps1

### modules/ Directory:
- modules/TempFiles.ps1
- modules/WindowsUpdate.ps1
- modules/RecycleBin.ps1
- modules/BrowserCache.ps1
- modules/SystemLogs.ps1

## 3. Verify URLs

After uploading, verify these URLs work:
- $configUrl
- $baseUrl/modules/TempFiles.ps1

## 4. Test the Tool

Run the tool locally to test:
```powershell
.\SystemCleaner.ps1 -Help
```

## 5. Share

Share the SystemCleaner.ps1 file with others. They can run it directly:
```powershell
.\SystemCleaner.ps1
```

The tool will automatically download modules from your GitHub repository.
"@

Set-Content -Path "DEPLOYMENT_INSTRUCTIONS.md" -Value $deploymentInstructions -Encoding UTF8

Write-ColorOutput "Created DEPLOYMENT_INSTRUCTIONS.md" -Color "Green"

Write-ColorOutput "`nSetup completed successfully!" -Color "Green"
Write-ColorOutput "`nNext steps:" -Color "Yellow"
Write-ColorOutput "1. Create a GitHub repository named '$RepositoryName'" -Color "White"
Write-ColorOutput "2. Upload all files to the repository" -Color "White"
Write-ColorOutput "3. Test the tool with: .\SystemCleaner.ps1 -Help" -Color "White"
Write-ColorOutput "4. Check DEPLOYMENT_INSTRUCTIONS.md for detailed steps" -Color "White"

Write-ColorOutput "`nConfiguration Summary:" -Color "Cyan"
Write-ColorOutput "GitHub Username: $GitHubUsername" -Color "White"
Write-ColorOutput "Repository: $RepositoryName" -Color "White"
Write-ColorOutput "Branch: $Branch" -Color "White"
Write-ColorOutput "Base URL: $baseUrl" -Color "White"
Write-ColorOutput "Config URL: $configUrl" -Color "White" 