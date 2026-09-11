# ============================================================
# Windows 11 - Set Lid, Power Button & Sleep Button
# to "Do Nothing"
# Automatically requests Administrator permission
# ============================================================

# Check for Administrator privileges
$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)

if (-not $Principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)) {

    Write-Host "Administrator permission is required." -ForegroundColor Yellow
    Write-Host "Requesting Administrator access..." -ForegroundColor Yellow

    # Relaunch this script as Administrator
    Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs

    exit
}

Write-Host ""
Write-Host "Running with Administrator privileges." -ForegroundColor Green
Write-Host ""

# ============================================================
# Get Active Power Scheme
# ============================================================

$ActiveScheme = (powercfg /getactivescheme) -replace `
    '.*GUID:\s*([a-fA-F0-9-]+).*', '$1'

if ($ActiveScheme -notmatch '^[a-fA-F0-9-]{36}$') {

    Write-Host "ERROR: Could not detect active power scheme." `
        -ForegroundColor Red

    pause
    exit 1
}

Write-Host "Active Power Scheme: $ActiveScheme"
Write-Host ""

# ============================================================
# Set all controls to DO NOTHING
#
# 0 = Do Nothing
# 1 = Sleep
# 2 = Hibernate
# 3 = Shut Down
# 4 = Turn Off Display
# ============================================================

Write-Host "Setting Power Button..." -ForegroundColor Cyan

# Power Button - AC
powercfg /setacvalueindex `
    $ActiveScheme SUB_BUTTONS PBUTTONACTION 0

# Power Button - Battery
powercfg /setdcvalueindex `
    $ActiveScheme SUB_BUTTONS PBUTTONACTION 0


Write-Host "Setting Sleep Button..." -ForegroundColor Cyan

# Sleep Button - AC
powercfg /setacvalueindex `
    $ActiveScheme SUB_BUTTONS SBUTTONACTION 0

# Sleep Button - Battery
powercfg /setdcvalueindex `
    $ActiveScheme SUB_BUTTONS SBUTTONACTION 0


Write-Host "Setting Lid Close..." -ForegroundColor Cyan

# Lid Close - AC
powercfg /setacvalueindex `
    $ActiveScheme SUB_BUTTONS LIDACTION 0

# Lid Close - Battery
powercfg /setdcvalueindex `
    $ActiveScheme SUB_BUTTONS LIDACTION 0


# ============================================================
# Apply Settings
# ============================================================

powercfg /S $ActiveScheme


# ============================================================
# Verification
# ============================================================

Write-Host ""
Write-Host "Verifying settings..." -ForegroundColor Cyan
Write-Host ""

$PowerSettings = powercfg /query $ActiveScheme SUB_BUTTONS

$PowerSettings | Select-String `
    "Power Button Action|Sleep Button Action|Lid close action|Current AC Power Setting Index|Current DC Power Setting Index"


Write-Host ""
Write-Host "============================================" `
    -ForegroundColor Green

Write-Host "        CONFIGURATION COMPLETED" `
    -ForegroundColor Green

Write-Host "============================================" `
    -ForegroundColor Green

Write-Host ""
Write-Host "Power Button : DO NOTHING"
Write-Host "Sleep Button : DO NOTHING"
Write-Host "Lid Close    : DO NOTHING"
Write-Host ""
Write-Host "Battery      : DO NOTHING"
Write-Host "Plugged In   : DO NOTHING"
Write-Host ""

pause