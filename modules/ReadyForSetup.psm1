function Get-ReadyForSetupInfo {
    return @{
        DisplayName = "Ready for User Setup"
        Description = "Standard device setup completion label"
        Parameters = @(
            @{
                Name = "StatusText"
                DisplayName = "Status Text"
                DefaultValue = "Wiped and ready to use"
                UseDefault = $false
            },
            @{
                Name = "Date"
                DisplayName = "Date"
                DefaultValue = (Get-Date -Format "dd/MM/yyyy")
                UseDefault = $true
            }
        )
    }
}

function Draw-ReadyForSetup {
    param(
        [System.Drawing.Graphics]$Graphics,
        [float]$Width,
        [float]$Height,
        [hashtable]$Parameters
    )
    
    $statusText = $Parameters["StatusText"]
    $date = $Parameters["Date"]
    
    # Printer has asymmetric printable area
    $rightEdgeLoss = 25   # Increased from 2 - right edge needs more reduction
    $bottomEdgeLoss = 12 # Increased from 9 - bottom edge needs more reduction
    
    # Shift table LEFT and UP more aggressively to center it
    $offsetX = 3  # Shift 3px left
    $offsetY = 6  # Shift 6px up
    
    $margin = 1
    $borderThickness = 0.5
    $headerHeight = 30
    $footerHeight = 30
    
    # Calculate rectangle position and size accounting for printable area
    $rectX = $offsetX + $margin
    $rectY = $offsetY + $margin
    $rectWidth = $Width - $rightEdgeLoss - ($margin * 2) - $offsetX
    $rectHeight = $Height - $bottomEdgeLoss - ($margin * 2) - $offsetY
    
    $contentHeight = $rectHeight - $headerHeight - $footerHeight - ($borderThickness * 4)
    
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, $borderThickness)
    $rect = New-Object System.Drawing.Rectangle($rectX, $rectY, $rectWidth, $rectHeight)
    $Graphics.DrawRectangle($pen, $rect)
    
    $headerFont = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
    $contentFont = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Regular)
    $footerFont = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
    $footerItalicFont = New-Object System.Drawing.Font("Arial", 8, [System.Drawing.FontStyle]::Italic)
    
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    
    $stringFormat = New-Object System.Drawing.StringFormat
    $stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
    
    $headerRect = New-Object System.Drawing.RectangleF(($rectX + $borderThickness), ($rectY + $borderThickness), ($rectWidth - $borderThickness * 2), $headerHeight)
    $Graphics.DrawString("Ready for User Setup", $headerFont, $brush, $headerRect, $stringFormat)
    
    $y1 = $rectY + $borderThickness + $headerHeight
    $Graphics.DrawLine($pen, ($rectX + $borderThickness), $y1, ($rectX + $rectWidth - $borderThickness), $y1)
    
    $contentRect = New-Object System.Drawing.RectangleF(($rectX + $borderThickness), $y1, ($rectWidth - $borderThickness * 2), $contentHeight)
    $Graphics.DrawString($statusText, $contentFont, $brush, $contentRect, $stringFormat)
    
    $y2 = $y1 + $contentHeight
    $Graphics.DrawLine($pen, ($rectX + $borderThickness), $y2, ($rectX + $rectWidth - $borderThickness), $y2)
    
    $footerY = $y2 + 5
    $stringFormatLeft = New-Object System.Drawing.StringFormat
    $stringFormatLeft.Alignment = [System.Drawing.StringAlignment]::Near
    $stringFormatLeft.LineAlignment = [System.Drawing.StringAlignment]::Center
    
    $stringFormatRight = New-Object System.Drawing.StringFormat
    $stringFormatRight.Alignment = [System.Drawing.StringAlignment]::Far
    $stringFormatRight.LineAlignment = [System.Drawing.StringAlignment]::Center
    
    $footerRect = New-Object System.Drawing.RectangleF(($rectX + $borderThickness + 10), $footerY, ($rectWidth - $borderThickness * 2 - 20), $footerHeight)
    
    $Graphics.DrawString("Date Prepared:", $footerItalicFont, $brush, $footerRect, $stringFormatLeft)
    $Graphics.DrawString($date, $footerFont, $brush, $footerRect, $stringFormatRight)
    
    $pen.Dispose()
    $headerFont.Dispose()
    $contentFont.Dispose()
    $footerFont.Dispose()
    $footerItalicFont.Dispose()
    $brush.Dispose()
    $stringFormat.Dispose()
    $stringFormatLeft.Dispose()
    $stringFormatRight.Dispose()
}

# Export the functions
Export-ModuleMember -Function Get-ReadyForSetupInfo, Draw-ReadyForSetup