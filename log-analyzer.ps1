$InputFile = "sample.log"
# Loggfil som ska analyseras
 
$LogFile = "analysis.log"
# Fil där analysresultatet sparas
 
$failed = 0
$errorCount = 0
$unauth = 0
# Räknare för olika händelser
 
function Write-Log {
    param ([string]$Message)
    # Funktion för loggning
 
    $entry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    $entry | Tee-Object -FilePath $LogFile -Append
}
 
# Kontrollera att loggfilen finns
if (-not (Test-Path $InputFile)) {
    Write-Log "ERROR: Loggfilen $InputFile saknas."
    exit 1
}
 
foreach ($line in Get-Content $InputFile) {
    # Loopar igenom varje rad i loggfilen
 
    if ($line -match "failed") {
        Write-Log "Misslyckat inloggningsförsök: $line"
        $failed++
    }
 
    if ($line -match "error") {
        Write-Log "Error hittad: $line"
        $errorCount++
    }
 
    if ($line -match "unauthorized") {
        Write-Log "Obehörigt försök: $line"
        $unauth++
    }
}
 
# Slutrapport
Write-Log "ANALYS KLAR"
Write-Log "Antal misslyckade inloggningar: $failed"
Write-Log "Antal errors: $errorCount"
Write-Log "Antal obehöriga försök: $unauth"
 