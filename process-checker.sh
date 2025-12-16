#!/bin/bash
# Anger att skriptet ska köras med Bash
 
PROCESS_FILE="processlist.txt"
# Filen som innehåller processnamn (en per rad)
LOGFILE="processlog.log"
# Loggfil där alla resultat sparas
RUNNING_COUNT=0
# Räknare för processer som körs
MISSING_COUNT=0
# Räknare för processer som saknas
 
log() {
    # Funktion för loggning med tidsstämpel
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}
# Skriver både till terminal och loggfil
check_process() {
    # Funktion som kontrollerar om en process körs
    local process="$1"
# Tar emot processnamn som argument
    if pgrep "$process" > /dev/null; then
    # Kontrollerar om processen finns i systemet
        log "OK: Processen '$process' körs."
        ((RUNNING_COUNT++))
    else
        log "WARNING: Processen '$process' körs INTE."
        ((MISSING_COUNT++))
    fi
}
 
run_checks() {
    if [[ ! -f "$PROCESS_FILE" ]]; then
        log "ERROR: Filen $PROCESS_FILE saknas."
        exit 1
    fi
 
    while read -r process; do
        [[ -z "$process" ]] && continue
        check_process "$process"
    done < "$PROCESS_FILE"
}
 
# 🔹 Huvudblock
log "Startar processkontroll"
run_checks
log "Sammanfattning: $RUNNING_COUNT körs, $MISSING_COUNT saknas"
log "Processkontroll slutförd"
 