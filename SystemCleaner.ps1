# System Cleaner Tool
# Similar to CTT Tool using IRM and IEX for GitHub-based execution
# Author: System Cleaner Tool
# Version: 1.0

param(
    [switch]$Silent,
    [switch]$Force,
    [string]$GitHubRepo = "https://raw.githubusercontent.com/AinzAmour/system-cleaner/main",
    [string]$ConfigUrl = "https://raw.githubusercontent.com/AinzAmour/system-cleaner/main/config.json"
)

# Set execution policy bypass for this session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Global variables
$Global:LogFile = "$env:TEMP\SystemCleaner_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$Global:BackupDir = "$env:TEMP\SystemCleaner_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$Global:SilentMode = $Silent
$Global:ForceMode = $Force

# Color functions for better UI
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    if (-not $Global:SilentMode) {
        Write-Host $Message -ForegroundColor $Color
    }
    
    # Log all messages
    Add-Content -Path $Global:LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
}

function Write-Header {
    param([string]$Title)
    
    Write-ColorOutput "`n" -Color "Cyan"
    Write-ColorOutput "=" * 60 -Color "Cyan"
    Write-ColorOutput " $Title" -Color "Cyan"
    Write-ColorOutput "=" * 60 -Color "Cyan"
    Write-ColorOutput "`n" -Color "Cyan"
}

function Write-SubHeader {
    param([string]$Title)
    
    Write-ColorOutput "`n" -Color "Yellow"
    Write-ColorOutput "-" * 40 -Color "Yellow"
    Write-ColorOutput " $Title" -Color "Yellow"
    Write-ColorOutput "-" * 40 -Color "Yellow"
    Write-ColorOutput "`n" -Color "Yellow"
}

# Initialize logging
function Initialize-Logging {
    Write-ColorOutput "Initializing System Cleaner Tool..." -Color "Green"
    Write-ColorOutput "Log file: $Global:LogFile" -Color "Gray"
    Write-ColorOutput "Backup directory: $Global:BackupDir" -Color "Gray"
    
    # Create backup directory
    if (-not (Test-Path $Global:BackupDir)) {
        New-Item -ItemType Directory -Path $Global:BackupDir -Force | Out-Null
    }
}

# Download and execute module from GitHub
function Invoke-GitHubModule {
    param(
        [string]$ModuleName,
        [string]$ModuleUrl
    )
    
    try {
        Write-ColorOutput "Downloading module: $ModuleName" -Color "Blue"
        
        # Download module content
        $moduleContent = Invoke-RestMethod -Uri $ModuleUrl -UseBasicParsing -ErrorAction Stop
        
        # Execute the module
        Write-ColorOutput "Executing module: $ModuleName" -Color "Blue"
        Invoke-Expression $moduleContent
        
        Write-ColorOutput "Module $ModuleName completed successfully" -Color "Green"
        return $true
    }
    catch {
        Write-ColorOutput "Error executing module $ModuleName : $($_.Exception.Message)" -Color "Red"
        return $false
    }
}

# Download configuration from GitHub
function Get-GitHubConfig {
    try {
        Write-ColorOutput "Downloading configuration from GitHub..." -Color "Blue"
        $config = Invoke-RestMethod -Uri $ConfigUrl -UseBasicParsing -ErrorAction Stop
        return $config
    }
    catch {
        Write-ColorOutput "Error downloading configuration: $($_.Exception.Message)" -Color "Red"
        Write-ColorOutput "Using default configuration..." -Color "Yellow"
        return Get-DefaultConfig
    }
}

# Default configuration if GitHub is unavailable
function Get-DefaultConfig {
    return @{
        modules = @(
            @{
                name = "TempFiles"
                url = "$GitHubRepo/modules/TempFiles.ps1"
                description = "Clean temporary files"
            },
            @{
                name = "WindowsUpdate"
                url = "$GitHubRepo/modules/WindowsUpdate.ps1"
                description = "Clean Windows Update cache"
            },
            @{
                name = "RecycleBin"
                url = "$GitHubRepo/modules/RecycleBin.ps1"
                description = "Empty Recycle Bin"
            },
            @{
                name = "BrowserCache"
                url = "$GitHubRepo/modules/BrowserCache.ps1"
                description = "Clean browser cache"
            },
            @{
                name = "SystemLogs"
                url = "$GitHubRepo/modules/SystemLogs.ps1"
                description = "Clean system logs"
            }
        )
    }
}

# Main cleaning function
function Start-SystemClean {
    Write-Header "System Cleaner Tool"
    
    # Check if running as administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-ColorOutput "Warning: This tool may require administrator privileges for some operations." -Color "Yellow"
    }
    
    # Initialize logging
    Initialize-Logging
    
    # Get configuration
    $config = Get-GitHubConfig
    
    # Display available modules
    Write-SubHeader "Available Cleaning Modules"
    for ($i = 0; $i -lt $config.modules.Count; $i++) {
        Write-ColorOutput "[$($i + 1)] $($config.modules[$i].name) - $($config.modules[$i].description)" -Color "White"
    }
    
    # Get user selection
    if (-not $Global:SilentMode) {
        Write-ColorOutput "`nSelect modules to run (comma-separated numbers, or 'all' for all modules):" -Color "Cyan"
        $selection = Read-Host "Enter your choice"
    } else {
        $selection = "all"
    }
    
    # Process selection
    $selectedModules = @()
    if ($selection -eq "all") {
        $selectedModules = $config.modules
    } else {
        $numbers = $selection -split "," | ForEach-Object { $_.Trim() }
        foreach ($num in $numbers) {
            $index = [int]$num - 1
            if ($index -ge 0 -and $index -lt $config.modules.Count) {
                $selectedModules += $config.modules[$index]
            }
        }
    }
    
    if ($selectedModules.Count -eq 0) {
        Write-ColorOutput "No valid modules selected. Exiting." -Color "Red"
        return
    }
    
    # Confirm before proceeding
    if (-not $Global:SilentMode -and -not $Global:ForceMode) {
        Write-ColorOutput "`nThe following modules will be executed:" -Color "Yellow"
        foreach ($module in $selectedModules) {
            Write-ColorOutput "- $($module.name)" -Color "White"
        }
        
        $confirm = Read-Host "`nDo you want to proceed? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-ColorOutput "Operation cancelled by user." -Color "Yellow"
            return
        }
    }
    
    # Execute selected modules
    Write-SubHeader "Executing Cleaning Modules"
    $successCount = 0
    $totalCount = $selectedModules.Count
    
    foreach ($module in $selectedModules) {
        Write-ColorOutput "Processing module: $($module.name)" -Color "Blue"
        
        if (Invoke-GitHubModule -ModuleName $module.name -ModuleUrl $module.url) {
            $successCount++
        }
        
        Write-ColorOutput "`n" -Color "White"
    }
    
    # Summary
    Write-SubHeader "Cleaning Summary"
    Write-ColorOutput "Total modules processed: $totalCount" -Color "White"
    Write-ColorOutput "Successful: $successCount" -Color "Green"
    Write-ColorOutput "Failed: $($totalCount - $successCount)" -Color "Red"
    Write-ColorOutput "Log file: $Global:LogFile" -Color "Gray"
    Write-ColorOutput "Backup directory: $Global:BackupDir" -Color "Gray"
    
    Write-ColorOutput "`nSystem cleaning completed!" -Color "Green"
}

# Show help
function Show-Help {
    Write-Header "System Cleaner Tool - Help"
    Write-ColorOutput "Usage:" -Color "Yellow"
    Write-ColorOutput "  .\SystemCleaner.ps1 [options]" -Color "White"
    Write-ColorOutput "`nOptions:" -Color "Yellow"
    Write-ColorOutput "  -Silent          Run in silent mode (no user prompts)" -Color "White"
    Write-ColorOutput "  -Force           Skip confirmation prompts" -Color "White"
    Write-ColorOutput "  -GitHubRepo      Custom GitHub repository URL" -Color "White"
    Write-ColorOutput "  -ConfigUrl       Custom configuration URL" -Color "White"
    Write-ColorOutput "  -Help            Show this help message" -Color "White"
    Write-ColorOutput "`nExamples:" -Color "Yellow"
    Write-ColorOutput "  .\SystemCleaner.ps1" -Color "White"
    Write-ColorOutput "  .\SystemCleaner.ps1 -Silent -Force" -Color "White"
    Write-ColorOutput "  .\SystemCleaner.ps1 -GitHubRepo 'https://raw.githubusercontent.com/user/repo/main'" -Color "White"
}

# Main execution
if ($args -contains "-Help" -or $args -contains "-h" -or $args -contains "--help") {
    Show-Help
} else {
    Start-SystemClean
} 
