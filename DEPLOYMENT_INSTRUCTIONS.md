# Deployment Instructions

## 1. Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: system-cleaner
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
- https://raw.githubusercontent.com/AinzAmour/system-cleaner/main/config.json
- https://raw.githubusercontent.com/AinzAmour/system-cleaner/main/modules/TempFiles.ps1

## 4. Test the Tool

Run the tool locally to test:
`powershell
.\SystemCleaner.ps1 -Help
`

## 5. Share

Share the SystemCleaner.ps1 file with others. They can run it directly:
`powershell
.\SystemCleaner.ps1
`

The tool will automatically download modules from your GitHub repository.
