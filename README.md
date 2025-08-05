# System Cleaner Tool

A powerful PowerShell-based system cleaning tool similar to CTT Tool that uses IRM (Invoke-RestMethod) and IEX (Invoke-Expression) to download and execute cleaning modules from GitHub.

## Features

- **Modular Design**: Individual cleaning modules that can be downloaded and executed dynamically
- **GitHub Integration**: Modules are hosted on GitHub and downloaded on-demand
- **Comprehensive Cleaning**: Covers temporary files, Windows updates, browser cache, system logs, and more
- **Safe Operations**: Includes backup functionality and detailed logging
- **User-Friendly Interface**: Colored output and interactive module selection
- **Administrator Support**: Some modules require elevated privileges and are handled automatically

## Cleaning Modules

### 1. TempFiles
- Cleans temporary files from various system locations
- Removes files older than 7 days
- Includes Windows Prefetch cleaning
- **Category**: System
- **Admin Required**: No

### 2. WindowsUpdate
- Cleans Windows Update download cache
- Removes old update logs
- Runs DISM cleanup for component store
- **Category**: System
- **Admin Required**: Yes

### 3. RecycleBin
- Empties Recycle Bin for all drives
- Handles both system and user Recycle Bins
- **Category**: System
- **Admin Required**: No

### 4. BrowserCache
- Cleans cache from popular browsers (Chrome, Firefox, Edge, Opera, IE)
- Flushes DNS cache
- Clears Windows Store cache
- **Category**: Applications
- **Admin Required**: No

### 5. SystemLogs
- Cleans Windows Event Logs
- Removes old error reports
- Manages System Restore Points
- Cleans application logs
- **Category**: System
- **Admin Required**: Yes

## Setup Instructions

### 1. GitHub Repository Setup

1. Create a new GitHub repository named `system-cleaner`
2. Upload all the files from this project to your repository
3. Update the GitHub URLs in the main script:

```powershell
# In SystemCleaner.ps1, update these lines:
[string]$GitHubRepo = "https://raw.githubusercontent.com/YOUR_USERNAME/system-cleaner/main",
[string]$ConfigUrl = "https://raw.githubusercontent.com/YOUR_USERNAME/system-cleaner/main/config.json"
```

4. Update the URLs in `config.json` to match your repository:

```json
{
  "modules": [
    {
      "name": "TempFiles",
      "url": "https://raw.githubusercontent.com/YOUR_USERNAME/system-cleaner/main/modules/TempFiles.ps1",
      ...
    }
  ]
}
```

### 2. Local Setup

1. Download `SystemCleaner.ps1` to your local machine
2. Open PowerShell as Administrator (recommended for full functionality)
3. Navigate to the directory containing the script
4. Run the script

## Usage

### Basic Usage

```powershell
# Run with interactive prompts
.\SystemCleaner.ps1

# Run in silent mode (no prompts)
.\SystemCleaner.ps1 -Silent

# Run with force mode (skip confirmations)
.\SystemCleaner.ps1 -Force

# Run both silent and force
.\SystemCleaner.ps1 -Silent -Force
```

### Advanced Usage

```powershell
# Use custom GitHub repository
.\SystemCleaner.ps1 -GitHubRepo "https://raw.githubusercontent.com/your-username/custom-cleaner/main"

# Use custom configuration URL
.\SystemCleaner.ps1 -ConfigUrl "https://raw.githubusercontent.com/your-username/custom-cleaner/main/config.json"

# Show help
.\SystemCleaner.ps1 -Help
```

### Module Selection

When running interactively, you can:
- Select specific modules by number (e.g., "1,3,5")
- Run all modules by typing "all"
- Skip modules by not selecting them

## File Structure

```
system-cleaner/
├── SystemCleaner.ps1          # Main script
├── config.json                # Configuration file
├── README.md                  # This file
└── modules/                   # Cleaning modules
    ├── TempFiles.ps1
    ├── WindowsUpdate.ps1
    ├── RecycleBin.ps1
    ├── BrowserCache.ps1
    └── SystemLogs.ps1
```

## Safety Features

- **Backup Creation**: Creates backup directories before cleaning
- **Detailed Logging**: All operations are logged with timestamps
- **Error Handling**: Graceful handling of errors and permission issues
- **Confirmation Prompts**: User confirmation before destructive operations
- **Size Reporting**: Shows amount of space freed by each operation

## Logging

Logs are stored in:
- **Location**: `%TEMP%\SystemCleaner_YYYYMMDD_HHMMSS.log`
- **Backup Directory**: `%TEMP%\SystemCleaner_Backup_YYYYMMDD_HHMMSS`

## Requirements

- **OS**: Windows 10/11 (Windows 8.1 may work with some limitations)
- **PowerShell**: Version 5.1 or higher
- **Permissions**: Some modules require Administrator privileges
- **Internet**: Required for downloading modules from GitHub

## Troubleshooting

### Common Issues

1. **Execution Policy Error**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Permission Denied**
   - Run PowerShell as Administrator
   - Some operations require elevated privileges

3. **Module Download Failed**
   - Check internet connection
   - Verify GitHub repository URLs
   - Ensure repository is public or accessible

4. **Some Files Not Deleted**
   - Files in use cannot be deleted
   - Some system files are protected
   - Check logs for specific error messages

### Error Codes

- **0**: Success
- **1**: General error
- **2**: Permission denied
- **3**: Network error
- **4**: Configuration error

## Contributing

To add new cleaning modules:

1. Create a new `.ps1` file in the `modules/` directory
2. Follow the existing module structure
3. Use the `Write-ColorOutput` function for consistent output
4. Add the module to `config.json`
5. Test thoroughly before submitting

## Security Considerations

- Only run scripts from trusted sources
- Review module code before execution
- The tool downloads and executes code from GitHub
- Consider hosting modules on a private repository for enterprise use

## License

This project is provided as-is for educational and personal use. Use at your own risk.

## Disclaimer

This tool performs system cleaning operations that can delete files. Always backup important data before use. The authors are not responsible for any data loss or system issues that may occur. 