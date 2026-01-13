# ================================
# Windows Update – Uppdateringsstatus
# Körs i VS Code (PowerShell) som administratör
# ================================

Write-Host "# Startar kontroll av Windows Update-status" -ForegroundColor Green
# Startmeddelande för att visa att scriptet har initierats korrekt

# ===== Kontroll av administratörsrättigheter =====
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
# Kontrollerar om PowerShell körs med administratörsbehörighet

if (-not $IsAdmin) {
    Write-Error "Måste köras som administratör"
    # Avbryter scriptet om nödvändiga rättigheter saknas
    exit 1
}

Write-Host "# Administratörsrättigheter bekräftade" -ForegroundColor Green

# ===== Loggfil =====
$logFile = "windows_update_status.log"
# Anger loggfilens namn

"Start: $(Get-Date)" | Out-File $logFile
# Skapar loggfil och skriver starttid

Write-Host "# Loggfil skapad: $logFile" -ForegroundColor Green

try {
    Write-Host "# Initierar Windows Update API" -ForegroundColor Green
    # Försöker skapa en session mot Windows Update

    $updateSession = New-Object -ComObject Microsoft.Update.Session
    if (-not $updateSession) {
        throw "Kunde inte initiera Update Session"
    }
    # Säkerställer att COM-objektet skapades korrekt

    $updateSearcher = $updateSession.CreateUpdateSearcher()
    if (-not $updateSearcher) {
        throw "Kunde inte skapa Update Searcher"
    }
    # Säkerställer att sökobjektet är giltigt

    Write-Host "# Söker efter ej installerade uppdateringar" -ForegroundColor Green
    $result = $updateSearcher.Search("IsInstalled=0")

    if (-not $result) {
        throw "Ingen sökresultat returnerades"
    }
    # Felhantering om sökningen misslyckas

    $pending = $result.Updates.Count
    "Väntande uppdateringar: $pending" | Out-File $logFile -Append
    Write-Host "Väntande uppdateringar: $pending"

    if ($pending -gt 0) {
        Write-Host "# Lista väntande uppdateringar" -ForegroundColor Green
        # Loopar igenom alla hittade uppdateringar

        foreach ($u in $result.Updates) {
            $line = "UPDATE: $($u.Title)"
            $line | Out-File $logFile -Append
            Write-Host $line
        }
    }
    else {
        Write-Host "# Systemet är fullt uppdaterat" -ForegroundColor Green
        # Ingen åtgärd krävs
    }
}
catch {
    Write-Error "Fel vid kontroll av Windows Update: $_"
    # Fångar alla oväntade fel

    "Fel: $_" | Out-File $logFile -Append
    # Loggar felet för felsökning

    exit 2
}
finally {
    "Slut: $(Get-Date)" | Out-File $logFile -Append
    # Körs alltid, oavsett om fel inträffar eller inte

    Write-Host "# Scriptet avslutades korrekt" -ForegroundColor Green
}

Write-Host "# Klar – uppdateringsstatus kontrollerad" -ForegroundColor Green

