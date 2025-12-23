# Brother Label Printer - Main Script

param(
    [Parameter(Mandatory=$false)]
    [string]$PrinterName = "Printer - Brother QL-820NWB (P-touch Label)"
)

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# Check if modules folder exists
$modulesPath = Join-Path $PSScriptRoot "modules"
if (-not (Test-Path $modulesPath)) {
    Write-Host "ERROR: Modules folder not found!" -ForegroundColor Red
    Write-Host "Looking for: $modulesPath" -ForegroundColor Yellow
    exit
}

# Load all module files
$moduleFiles = Get-ChildItem -Path $modulesPath -Filter "*.psm1"
if ($moduleFiles.Count -eq 0) {
    Write-Host "ERROR: No .psm1 files found in modules folder!" -ForegroundColor Red
    Write-Host "Path checked: $modulesPath" -ForegroundColor Yellow
    exit
}

Write-Host "Found $($moduleFiles.Count) module file(s)" -ForegroundColor Gray

# Load modules and get their info
$modules = @()
foreach ($file in $moduleFiles) {
    Write-Host "Loading module: $($file.Name)..." -ForegroundColor Gray
    try {
        # Import module using full path
        Import-Module $file.FullName -Force -Global
        
        $moduleName = $file.BaseName
        $infoFunctionName = "Get-${moduleName}Info"
        
        Write-Host "  Looking for function: $infoFunctionName" -ForegroundColor Gray
        
        # Check if function exists
        if (Get-Command $infoFunctionName -ErrorAction SilentlyContinue) {
            Write-Host "  ✓ Function found!" -ForegroundColor Green
            $info = & $infoFunctionName
            $modules += [PSCustomObject]@{
                Name = $moduleName
                DisplayName = $info.DisplayName
                Description = $info.Description
                Parameters = $info.Parameters
                DrawFunction = "Draw-${moduleName}"
            }
        }
        else {
            Write-Host "  ✗ Function $infoFunctionName not found" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "  ✗ Error: $_" -ForegroundColor Red
    }
}

if ($modules.Count -eq 0) {
    Write-Host ""
    Write-Host "ERROR: No valid template modules loaded!" -ForegroundColor Red
    exit
}

# Display header
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Brother Label Printer System          ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# If only one module, auto-select it
if ($modules.Count -eq 1) {
    $selectedModule = $modules[0]
    Write-Host "Using template: " -NoNewline -ForegroundColor Green
    Write-Host $selectedModule.DisplayName -ForegroundColor White
    Write-Host ""
}
else {
    # Display available templates
    Write-Host "Available Label Templates:" -ForegroundColor Green
    Write-Host ""
    for ($i = 0; $i -lt $modules.Count; $i++) {
        Write-Host "  [$($i + 1)] " -NoNewline -ForegroundColor Yellow
        Write-Host "$($modules[$i].DisplayName)" -ForegroundColor White
        Write-Host "      $($modules[$i].Description)" -ForegroundColor Gray
    }
    Write-Host ""

    # Select template
    do {
        $selection = Read-Host "Select template number (1-$($modules.Count))"
        if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $modules.Count) {
            $selectedModule = $modules[[int]$selection - 1]
            break
        }
        Write-Host "Please enter a valid number between 1 and $($modules.Count)" -ForegroundColor Red
    } while ($true)

    Write-Host ""
    Write-Host "Selected: " -NoNewline -ForegroundColor Green
    Write-Host $selectedModule.DisplayName -ForegroundColor White
    Write-Host ""
}

# Collect parameters for the template
$templateParams = @{}
foreach ($param in $selectedModule.Parameters) {
    if ($param.UseDefault) {
        $value = $param.DefaultValue
        Write-Host "$($param.DisplayName): " -NoNewline -ForegroundColor Yellow
        Write-Host $value -ForegroundColor Gray
    }
    else {
        $prompt = $param.DisplayName
        if ($param.DefaultValue) {
            $prompt += " (default: $($param.DefaultValue))"
        }
        $value = Read-Host $prompt
        
        if ([string]::IsNullOrWhiteSpace($value) -and $param.DefaultValue) {
            $value = $param.DefaultValue
        }
    }
    $templateParams[$param.Name] = $value
}

Write-Host ""

# Ask for number of copies
do {
    $copies = Read-Host "How many labels to print?"
    if ($copies -match '^\d+$' -and [int]$copies -gt 0) { 
        If ($copies -gt 5) {
            Write-Host "WARNING: Printing more than 5 labels at once not permitted!" -ForegroundColor Yellow
            break
        }
        $copies = [int]$copies
        break 
    }
    Write-Host "Enter a valid number!" -ForegroundColor Red
} while ($true)

Write-Host ""
Write-Host "Preparing to print $copies label(s)..." -ForegroundColor Green

# Check if printer exists
$printerExists = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue
if (-not $printerExists) {
    Write-Host "ERROR: Printer '$PrinterName' not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available printers:" -ForegroundColor Yellow
    Get-Printer | Select-Object Name | Format-Table -AutoSize
    exit
}

# Convert mm to inches and round to hundredths
$labelWidthInches = 90 / 25.4
$labelHeightInches = 29 / 25.4

# Convert to hundredths of inch for PaperSize (rounded, not truncated)
$paperWidthHundredths = [Math]::Round($labelWidthInches * 100)
$paperHeightHundredths = [Math]::Round($labelHeightInches * 100)

# Create PrintDocument
$printDoc = New-Object System.Drawing.Printing.PrintDocument
$printDoc.PrinterSettings.PrinterName = $PrinterName
$printDoc.DefaultPageSettings.Landscape = $true

# Set paper size using rounded values
$paperSize = New-Object System.Drawing.Printing.PaperSize("Custom", $paperWidthHundredths, $paperHeightHundredths)
$printDoc.DefaultPageSettings.PaperSize = $paperSize
$printDoc.DefaultPageSettings.Margins = New-Object System.Drawing.Printing.Margins(0, 0, 0, 0)

# Calculate actual drawing dimensions from the paper size (in pixels at 100 DPI)
$dpi = 100
$labelWidth = ($paperWidthHundredths / 100.0) * $dpi
$labelHeight = ($paperHeightHundredths / 100.0) * $dpi

Write-Host "Paper size set to: $paperWidthHundredths x $paperHeightHundredths hundredths of inch" -ForegroundColor Gray
Write-Host "Drawing area: $labelWidth x $labelHeight pixels" -ForegroundColor Gray
Write-Host ""

# Counter for copies
$script:currentCopy = 0

# Print event handler
$printPage = {
    param($sender, $ev)
    
    $graphics = $ev.Graphics
    
    # Call the selected module's draw function with consistent dimensions
    & $selectedModule.DrawFunction -Graphics $graphics -Width $labelWidth -Height $labelHeight -Parameters $templateParams
    
    $script:currentCopy++
    
    if ($script:currentCopy -lt $copies) {
        $ev.HasMorePages = $true
    } else {
        $ev.HasMorePages = $false
    }
}

# Add event handler
$printDoc.add_PrintPage($printPage)

# Print
try {
    Write-Host "Sending to printer: $PrinterName" -ForegroundColor Cyan
    $printDoc.Print()
    
    Start-Sleep -Seconds 2
    
    Write-Host ""
    Write-Host "✓ Successfully sent $copies label(s) to printer!" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    $printDoc.Dispose()
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green