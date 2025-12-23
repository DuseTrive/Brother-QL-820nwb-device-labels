function Get-QuarantinedDeviceInfo {
    return @{
        DisplayName = "Quarantined Device"
        Description = "Label for devices placed in quarantine"
        Parameters = @(
            @{
                Name = "LastUser"
                DisplayName = "Last User"
                DefaultValue = ""
                UseDefault = $false
            },
            @{
                Name = "TicketNumber"
                DisplayName = "Ticket Number"
                DefaultValue = ""
                UseDefault = $false
            },
            @{
                Name = "QuarantineEndDate"
                DisplayName = "Quarantine End Date"
                DefaultValue = (Get-Date).AddDays(5).ToString("dd/MM/yyyy")
                UseDefault = $true
            },
            @{
                Name = "ORG"
                DisplayName = "Organization"
                DefaultValue = ""
                UseDefault = $false
            }
        )
    }
}

function Draw-QuarantinedDevice {
    param(
        [System.Drawing.Graphics]$Graphics,
        [float]$Width,
        [float]$Height,
        [hashtable]$Parameters
    )
    
    $lastUser = $Parameters["LastUser"]
    $ticketNumber = $Parameters["TicketNumber"]
    $quarantineEndDate = $Parameters["QuarantineEndDate"]
    $org = $Parameters["ORG"]
    
    # Printer has asymmetric printable area - using discovered values
    $rightEdgeLoss = 25   # Increased from 2 - right edge needs more reduction
    $bottomEdgeLoss = 12 # Increased from 9 - bottom edge needs more reduction
    
    # Shift table LEFT and UP to center it
    $offsetX = 7
    $offsetY = 6
    
    $margin = 0.5
    $borderThickness = 0.5
    
    # Calculate outer rectangle
    $rectX = $offsetX + $margin
    $rectY = $offsetY + $margin
    $rectWidth = $Width - $rightEdgeLoss - ($margin * 2) - $offsetX
    $rectHeight = $Height - $bottomEdgeLoss - ($margin * 2) - $offsetY
    
    # Create pens and brushes
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, $borderThickness)
    $headerFont = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
    $fieldFont = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
    $valueFont = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Regular)
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    
    # Draw outer border
    $outerRect = New-Object System.Drawing.Rectangle($rectX, $rectY, $rectWidth, $rectHeight)
    $Graphics.DrawRectangle($pen, $outerRect)
    
    # String formats
    $centerFormat = New-Object System.Drawing.StringFormat
    $centerFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $centerFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
    
    $leftFormat = New-Object System.Drawing.StringFormat
    $leftFormat.Alignment = [System.Drawing.StringAlignment]::Near
    $leftFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
    
    # HEADER SECTION
    $headerHeight = 24
    $headerRect = New-Object System.Drawing.RectangleF($rectX, $rectY, $rectWidth, $headerHeight)
    $Graphics.DrawString("Quarantined Device", $headerFont, $brush, $headerRect, $centerFormat)
    
    # Line after header
    $currentY = $rectY + $headerHeight
    $Graphics.DrawLine($pen, $rectX, $currentY, ($rectX + $rectWidth), $currentY)
    
    # Calculate row height for 4 rows
    $bodyHeight = $rectHeight - $headerHeight
    $rowHeight = $bodyHeight / 4
    $fieldWidth = 140
    
    # Define rows
    $rows = @(
        @{ Label = "Last User:"; Value = $lastUser },
        @{ Label = "Ticket Number:"; Value = $ticketNumber },
        @{ Label = "Quarantine End Date:"; Value = $quarantineEndDate },
        @{ Label = "ORG:"; Value = $org }
    )
    
    # Draw each row
    for ($i = 0; $i -lt $rows.Count; $i++) {
        $row = $rows[$i]
        $rowY = $currentY
        
        # Draw field label (left column)
        $fieldRect = New-Object System.Drawing.RectangleF(($rectX + 6), $rowY, ($fieldWidth - 6), $rowHeight)
        $Graphics.DrawString($row.Label, $fieldFont, $brush, $fieldRect, $leftFormat)
        
        # Draw vertical line between field and value
        $Graphics.DrawLine($pen, ($rectX + $fieldWidth), $rowY, ($rectX + $fieldWidth), ($rowY + $rowHeight))
        
        # Draw value (right column)
        $valueRect = New-Object System.Drawing.RectangleF(($rectX + $fieldWidth + 6), $rowY, ($rectWidth - $fieldWidth - 6), $rowHeight)
        $Graphics.DrawString($row.Value, $valueFont, $brush, $valueRect, $leftFormat)
        
        # Draw horizontal line after row (except last row)
        if ($i -lt $rows.Count - 1) {
            $currentY += $rowHeight
            $Graphics.DrawLine($pen, $rectX, $currentY, ($rectX + $rectWidth), $currentY)
        }
    }
    
    # Dispose objects
    $pen.Dispose()
    $headerFont.Dispose()
    $fieldFont.Dispose()
    $valueFont.Dispose()
    $brush.Dispose()
    $centerFormat.Dispose()
    $leftFormat.Dispose()
}

Export-ModuleMember -Function Get-QuarantinedDeviceInfo, Draw-QuarantinedDevice