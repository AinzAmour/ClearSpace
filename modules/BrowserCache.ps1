# BrowserCache Cleaning Module
# Cleans cache from popular web browsers

Write-ColorOutput "Starting BrowserCache cleaning module..." -Color "Blue"

$cleanedSize = 0

# Define browser cache locations
$browserPaths = @(
    @{
        Name = "Chrome"
        Paths = @(
            "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
            "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
            "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\GPUCache",
            "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Service Worker\CacheStorage",
            "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Session Storage"
        )
    },
    @{
        Name = "Firefox"
        Paths = @(
            "$env:APPDATA\Mozilla\Firefox\Profiles\*\cache2",
            "$env:APPDATA\Mozilla\Firefox\Profiles\*\cache",
            "$env:APPDATA\Mozilla\Firefox\Profiles\*\startupCache",
            "$env:APPDATA\Mozilla\Firefox\Profiles\*\thumbnails"
        )
    },
    @{
        Name = "Edge"
        Paths = @(
            "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
            "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
            "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\GPUCache",
            "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Service Worker\CacheStorage",
            "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Session Storage"
        )
    },
    @{
        Name = "Opera"
        Paths = @(
            "$env:APPDATA\Opera Software\Opera Stable\Cache",
            "$env:APPDATA\Opera Software\Opera Stable\Code Cache",
            "$env:APPDATA\Opera Software\Opera Stable\GPUCache"
        )
    },
    @{
        Name = "Internet Explorer"
        Paths = @(
            "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
            "$env:LOCALAPPDATA\Microsoft\Windows\WebCache"
        )
    }
)

foreach ($browser in $browserPaths) {
    Write-ColorOutput "Cleaning: $($browser.Name)" -Color "White"
    $browserCleanedSize = 0
    
    foreach ($path in $browser.Paths) {
        # Handle wildcards in paths (like Firefox profiles)
        $resolvedPaths = Resolve-Path -Path $path -ErrorAction SilentlyContinue
        
        if ($resolvedPaths) {
            foreach ($resolvedPath in $resolvedPaths) {
                if (Test-Path $resolvedPath) {
                    try {
                        $beforeSize = (Get-ChildItem -Path $resolvedPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
                        if (-not $beforeSize) { $beforeSize = 0 }
                        
                        # Remove cache files
                        Get-ChildItem -Path $resolvedPath -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                        
                        $afterSize = (Get-ChildItem -Path $resolvedPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
                        if (-not $afterSize) { $afterSize = 0 }
                        
                        $freedSpace = $beforeSize - $afterSize
                        $browserCleanedSize += $freedSpace
                    }
                    catch {
                        # Skip files that can't be removed
                    }
                }
            }
        }
    }
    
    if ($browserCleanedSize -gt 0) {
        Write-ColorOutput "  Freed: $([math]::Round($browserCleanedSize / 1MB, 2)) MB" -Color "Green"
        $cleanedSize += $browserCleanedSize
    } else {
        Write-ColorOutput "  No cache found or already clean" -Color "Gray"
    }
}

# Clean Windows DNS cache
Write-ColorOutput "Cleaning: Windows DNS Cache" -Color "White"
try {
    ipconfig /flushdns | Out-Null
    Write-ColorOutput "  DNS cache flushed successfully" -Color "Green"
}
catch {
    Write-ColorOutput "  Error flushing DNS cache: $($_.Exception.Message)" -Color "Red"
}

# Clean Windows Store cache
Write-ColorOutput "Cleaning: Windows Store Cache" -Color "White"
try {
    $wsresetPath = "$env:SystemRoot\System32\wsreset.exe"
    if (Test-Path $wsresetPath) {
        Start-Process -FilePath $wsresetPath -ArgumentList "/s" -Wait -WindowStyle Hidden
        Write-ColorOutput "  Windows Store cache cleared" -Color "Green"
    }
}
catch {
    Write-ColorOutput "  Error clearing Windows Store cache: $($_.Exception.Message)" -Color "Red"
}

Write-ColorOutput "BrowserCache cleaning completed. Total freed: $([math]::Round($cleanedSize / 1MB, 2)) MB" -Color "Green" 
