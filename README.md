# Brother QL-820NWB Device Label Printing – PowerShell (Non-GUI)

**Label Printer**  
Modular PowerShell label printing system for IT device status labels using the **Brother QL-820NWB** 🖨️

This repository provides a **script-driven (non-GUI)** PowerShell solution for printing standardized IT device labels on **29mm × 90mm** Brother DK labels.  
It is designed for **automation, scripting, and fast execution** without a graphical interface.

![GIF](https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExZmdwbmRkeDk0bGJycnJkaWI1NG51cmUzZncxenVxZ3hkMGhveTdhMiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/48nzMZpaVQoBW/giphy.gif)
---

## Features

- Script-based label printing (no GUI)
- Modular architecture for easy extension
- Built-in label templates:
  - Quarantined Device
  - Device Ready for Setup
- Runtime parameters only (no hard-coded data)
- Precision calibration for the QL-820NWB printer
- Reusable PowerShell modules
- Stateless execution (no data stored or transmitted)

---

## Requirements

### Printer & Drivers

- **Printer**: Brother QL-820NWB
- **Label Paper**: 29mm × 90mm continuous label tape (DK-11201)
- **Printer Drivers**:  
  Download and install the **Full Driver & Software Package** from Brother Support:  
  https://support.brother.com/g/b/downloadtop.aspx?c=au&lang=en&prod=lpql820nwbeas

After installation, confirm the printer appears in Windows as:

```
Printer - Brother QL-820NWB (P-touch Label)
```

---

### System Requirements

- **Operating System**: Windows 10 / Windows 11
- **PowerShell**: Version 5.1 or higher
- **.NET Framework**: 4.5 or higher

(All pre-installed on Windows 10/11)

---

## Installation

Clone or download the repository:

```powershell
git clone <repository-url>
cd brother-ql-820nwb-device-labels
```

Verify the directory structure:

```
brother-ql-820nwb-device-labels/
├── PrintBrotherLabel.ps1
└── modules/
    ├── QuarantinedDevice.psm1
    └── ReadyForSetup.psm1
```

Set execution policy if required:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## Printer Name Configuration

Find your printer name:

```powershell
Get-Printer | Select-Object Name
```

If needed, update the printer name inside `PrintBrotherLabel.ps1` to exactly match the Windows printer name.

---

## Usage

### Print a Quarantined Device Label

```powershell
.\PrintBrotherLabel.ps1 `
  -Template "QuarantinedDevice" `
  -LastUser "John Smith" `
  -TicketNumber "INC123456"
```

This template automatically calculates and prints a **5-day quarantine hold**.

---

### Print a Device Ready for Setup Label

```powershell
.\PrintBrotherLabel.ps1 `
  -Template "ReadyForSetup"
```

---

## Automation Example

Example usage inside another PowerShell script:

```powershell
& "C:\Path\To\PrintBrotherLabel.ps1" `
  -Template "QuarantinedDevice" `
  -LastUser $username `
  -TicketNumber $ticket
```

Suitable for:
- Device wipe workflows
- Asset handling processes
- Technician quick actions

---

## Creating Custom Label Templates

Create a new `.psm1` file inside the `modules` folder.

### Example: `MyCustomLabel.psm1`

```powershell
function Get-MyCustomLabelInfo {
    return @{
        DisplayName = "My Custom Label"
        Description = "Description of this label"
        Parameters = @(
            @{
                Name = "Message"
                DisplayName = "Message"
                DefaultValue = ""
                UseDefault = $false
            }
        )
    }
}

function Draw-MyCustomLabel {
    param(
        [System.Drawing.Graphics]$Graphics,
        [float]$Width,
        [float]$Height,
        [hashtable]$Parameters
    )

    $text = $Parameters["Message"]

    # Calibration values (DO NOT CHANGE)
    $rightEdgeLoss = 25
    $bottomEdgeLoss = 12
    $offsetX = 3
    $offsetY = 6
    $margin = 1

    $rect = New-Object System.Drawing.Rectangle(
        $offsetX + $margin,
        $offsetY + $margin,
        $Width - $rightEdgeLoss - ($margin * 2),
        $Height - $bottomEdgeLoss - ($margin * 2)
    )

    $font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    $brush = [System.Drawing.Brushes]::Black
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = "Center"
    $format.LineAlignment = "Center"

    $Graphics.DrawString($text, $font, $brush, $rect, $format)

    $font.Dispose()
    $format.Dispose()
}

Export-ModuleMember -Function Get-MyCustomLabelInfo, Draw-MyCustomLabel
```

### Module Naming Rules

- File name: `MyCustomLabel.psm1`
- Info function: `Get-MyCustomLabelInfo`
- Draw function: `Draw-MyCustomLabel`

All `.psm1` files in the `modules` folder are automatically discovered.

---

## Label Alignment Calibration

The following values are mandatory for correct printing on the QL-820NWB:

```powershell
$rightEdgeLoss = 25
$bottomEdgeLoss = 12
$offsetX = 3
$offsetY = 6
```

These values compensate for printer edge loss and were determined through physical testing.

---

## Troubleshooting

### Printer Not Found

```powershell
Get-Printer | Select-Object Name
```

- Ensure the printer is powered on
- Verify USB or network connectivity
- Confirm the printer name matches exactly

---

### Execution Policy Error

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

### Labels Cutting Off Content

- Verify label size is **29mm × 90mm**
- Confirm calibration values are unchanged
- Ensure the correct DK label roll is installed

---

## Security & Data Handling

- No credentials stored
- No company-specific data embedded
- No logging or persistence
- All label content is supplied at runtime

Safe for **public GitHub repositories**.

---

## License

MIT 

---

**Version:** 1.0  
**Last Updated:** December 2024
