function Get-NameAndTicketInfo {
    return @{
        DisplayName = "Name and Ticket Label"
        Description = "Simple 2-row label for name and ticket number"
        Parameters = @(
            @{
                Name = "Name"
                DisplayName = "Name"
                DefaultValue = ""
                UseDefault = $false
            },
            @{
                Name = "TicketNumber"
                DisplayName = "Ticket Number"
                DefaultValue = ""
                UseDefault = $false
            }
        )
    }
}

function Draw-NameAndTicket {
    param(
        [System.Drawing.Graphics]$Graphics,
        [float]$Width,
        [float]$Height,
        [hashtable]$Parameters
    )
    
    $name = $Parameters["Name"]
    $ticketNumber = $Parameters["TicketNumber"]
    
    # Printer has asymmetric printable area
    $rightEdgeLoss = 25   # Increased from 2 - right edge needs more reduction
    $bottomEdgeLoss = 12 # Increased from 9 - bottom edge needs more reduction
    
    # Shift table LEFT and UP to center it
    $offsetX = 3
    $offsetY = 6
    
    $margin = 1  
    $borderThickness = 0.5
    
    # Calculate outer rectangle
    $rectX = $offsetX + $margin
    $rectY = $offsetY + $margin
    $rectWidth = $Width - $rightEdgeLoss - ($margin * 2) - $offsetX
    $rectHeight = $Height - $bottomEdgeLoss - ($margin * 2) - $offsetY
    
    # Create pens and brushes
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, $borderThickness)
    $fieldFont = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
    $valueFont = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Regular)
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    
    # Draw outer border
    $outerRect = New-Object System.Drawing.Rectangle($rectX, $rectY, $rectWidth, $rectHeight)
    $Graphics.DrawRectangle($pen, $outerRect)
    
    # String format for left-aligned text
    $leftFormat = New-Object System.Drawing.StringFormat
    $leftFormat.Alignment = [System.Drawing.StringAlignment]::Near
    $leftFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
    
    # Calculate row dimensions
    $rowHeight = $rectHeight / 2
    $fieldWidth = 110  # Width of the field label column (Name:, Ticket:)
    
    # Define rows
    $rows = @(
        @{ Label = "Name:"; Value = $name },
        @{ Label = "Ticket:"; Value = $ticketNumber }
    )
    
    # Draw each row
    $currentY = $rectY
    for ($i = 0; $i -lt $rows.Count; $i++) {
        $row = $rows[$i]
        
        # Draw field label (left column)
        $fieldRect = New-Object System.Drawing.RectangleF(($rectX + 8), $currentY, ($fieldWidth - 8), $rowHeight)
        $Graphics.DrawString($row.Label, $fieldFont, $brush, $fieldRect, $leftFormat)
        
        # Draw vertical line between field and value
        $Graphics.DrawLine($pen, ($rectX + $fieldWidth), $currentY, ($rectX + $fieldWidth), ($currentY + $rowHeight))
        
        # Draw value (right column)
        $valueRect = New-Object System.Drawing.RectangleF(($rectX + $fieldWidth + 8), $currentY, ($rectWidth - $fieldWidth - 8), $rowHeight)
        $Graphics.DrawString($row.Value, $valueFont, $brush, $valueRect, $leftFormat)
        
        # Draw horizontal line after first row
        if ($i -eq 0) {
            $currentY += $rowHeight
            $Graphics.DrawLine($pen, $rectX, $currentY, ($rectX + $rectWidth), $currentY)
        }
    }
    
    # Dispose objects
    $pen.Dispose()
    $fieldFont.Dispose()
    $valueFont.Dispose()
    $brush.Dispose()
    $leftFormat.Dispose()
}

Export-ModuleMember -Function Get-NameAndTicketInfo, Draw-NameAndTicket