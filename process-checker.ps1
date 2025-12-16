$ProcessFile = "processlist.txt"
# Filen som innehåller processnamn (en per rad)
$LogFile = "processlog.log"
# Loggfil där alla resultat sparas
$RunningCount = 0
# Räknare för processer som körs
$MissingCount = 0
# Räknare för processer som saknas
 
function Write-Log {
    # Funktion för loggning med tidsstämpel
    param ($Message)
    # Tar emot ett meddelande som parameter
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Tee-Object -FilePath $LogFile -Append
}
 
function Check-Process {
    param ($ProcessName)
 
    if (Get-Process -Name $ProcessName -ErrorAction SilentlyContinue) {
        # Kontrollerar om processen finns i systemet
        Write-Log "OK: Processen '$ProcessName' körs."
        $script:RunningCount++
        # Ökar räknaren för körande processer
    } else {
        Write-Log "WARNING: Processen '$ProcessName' körs INTE."
        $script:MissingCount++
        # Ökar räknaren för saknade processer
    }
}
 
# 🔹 Huvudblock
if (-not (Test-Path $ProcessFile)) {
    Write-Log "ERROR: Filen $ProcessFile saknas."
    exit 1
}
 
Write-Log "Startar processkontroll"
 
Get-Content $ProcessFile | ForEach-Object {
    if ($_ -ne "") {
        Check-Process $_
    }
}
 
Write-Log "Sammanfattning: $RunningCount körs, $MissingCount saknas"
Write-Log "Processkontroll slutförd"
 