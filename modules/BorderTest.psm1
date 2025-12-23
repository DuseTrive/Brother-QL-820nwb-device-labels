function Get-BorderTestInfo {
    return @{
        DisplayName = "Border Scale Test"
        Description = "Test different border margins to find perfect centering"
        Parameters = @()
    }
}

function Draw-BorderTest {
    param(
        [System.Drawing.Graphics]$Graphics,
        [float]$Width,
        [float]$Height,
        [hashtable]$Parameters
    )
    
    # Keep top-left fixed, reduce width and height by these amounts
    $reductions = @(0, 2, 4, 6, 8, 10, 12, 15, 20, 25, 30)
    
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1)
    $font = New-Object System.Drawing.Font("Arial", 6, [System.Drawing.FontStyle]::Regular)
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    
    $stringFormat = New-Object System.Drawing.StringFormat
    $stringFormat.Alignment = [System.Drawing.StringAlignment]::Near
    $stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Near
    
    # Fixed starting position (top-left corner)
    $startX = 0
    $startY = 0
    
    # Draw all test rectangles
    foreach ($reduction in $reductions) {
        $rectWidth = $Width - $reduction
        $rectHeight = $Height - $reduction
        
        $rect = New-Object System.Drawing.Rectangle($startX, $startY, $rectWidth, $rectHeight)
        $Graphics.DrawRectangle($pen, $rect)
        
        # Label at top-left of each rectangle
        $labelPoint = New-Object System.Drawing.PointF(($startX + 2), ($startY + ($reduction * 0.5) + 2))
        $Graphics.DrawString("-${reduction}px", $font, $brush, $labelPoint, $stringFormat)
    }
    
    # Draw corner markers to see physical edges
    $cornerSize = 8
    $penRed = New-Object System.Drawing.Pen([System.Drawing.Color]::Red, 2)
    
    # Top-left corner (should align perfectly)
    $Graphics.DrawLine($penRed, 0, 0, $cornerSize, 0)
    $Graphics.DrawLine($penRed, 0, 0, 0, $cornerSize)
    
    # Top-right corner (test edge)
    $Graphics.DrawLine($penRed, $Width, 0, ($Width - $cornerSize), 0)
    $Graphics.DrawLine($penRed, $Width, 0, $Width, $cornerSize)
    
    # Bottom-left corner (test edge)
    $Graphics.DrawLine($penRed, 0, $Height, $cornerSize, $Height)
    $Graphics.DrawLine($penRed, 0, $Height, 0, ($Height - $cornerSize))
    
    # Bottom-right corner (test edge)
    $Graphics.DrawLine($penRed, $Width, $Height, ($Width - $cornerSize), $Height)
    $Graphics.DrawLine($penRed, $Width, $Height, $Width, ($Height - $cornerSize))
    
    # Add info text
    $legendY = 40
    $Graphics.DrawString("Red corners = Intended edges", $font, $brush, 2, $legendY)
    $Graphics.DrawString("Numbers = Pixels reduced from right & bottom", $font, $brush, 2, ($legendY + 8))
    $Graphics.DrawString("Find the largest -Xpx rectangle that fits completely", $font, $brush, 2, ($legendY + 16))
    
    $pen.Dispose()
    $penRed.Dispose()
    $font.Dispose()
    $brush.Dispose()
    $stringFormat.Dispose()
}

# Export the functions
Export-ModuleMember -Function Get-BorderTestInfo, Draw-BorderTest