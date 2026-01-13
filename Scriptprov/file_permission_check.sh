#!/usr/bin/env bash
# Scriptet körs med Bash och används för att kontrollera fil- och katalogrättigheter

set -euo pipefail
# -e  : avsluta scriptet direkt vid fel
# -u  : fel om odefinierad variabel används
# -o pipefail : fånga fel även i pipade kommandon

IFS=$'\n\t'
# Sätter hur Bash delar upp input (radbrytning och tab)
# Minskar risken för fel vid filnamn med mellanslag

# ===== Mål (ändra vid behov) =====
TARGETS=(
  "$HOME"        # Användarens hemkatalog
  "$HOME/.ssh"   # SSH-katalog (känslig, ska vara hårt låst)
  "/etc/passwd"  # Systemfil med användarinformation
  "/etc/shadow"  # Systemfil med lösenordshashar
)

echo "Kontroll av filrättigheter"
echo "Tid: $(date)"
echo "===================================="

# Loopar igenom alla mål som ska kontrolleras
for TARGET in "${TARGETS[@]}"; do

  # Kontrollerar om filen eller katalogen finns
  if [[ -e "$TARGET" ]]; then

    # Hämtar rättigheter i både text- och sifferformat samt ägare
    PERM="$(stat -c '%A %a %U:%G' "$TARGET")"

    # Hämtar endast numeriska POSIX-rättigheter (t.ex. 640, 755)
    MODE="$(stat -c '%a' "$TARGET")"

    # Skriver ut grundinformation
    echo "$TARGET -> $PERM"

    # Kontrollerar om grupp har skrivrättighet
    # (andra siffran i rättighetsvärdet)
    GROUP_WRITE=$(( (MODE / 10) % 10 & 2 ))

    # Kontrollerar om andra användare har skrivrättighet
    # (sista siffran i rättighetsvärdet)
    OTHER_WRITE=$(( MODE % 10 & 2 ))

    # Riskbedömning baserad på rättigheter
    if [[ $OTHER_WRITE -ne 0 ]]; then
      # Andra användare kan skriva → hög säkerhetsrisk
      echo "  [RISK: HÖG] Andra användare har skrivrättighet"

    elif [[ $GROUP_WRITE -ne 0 ]]; then
      # Grupp kan skriva → medelhög risk
      echo "  [RISK: MEDEL] Grupp har skrivrättighet"

    else
      # Endast ägare kan skriva → låg risk
      echo "  [RISK: LÅG] Inga otillåtna skrivrättigheter"
    fi

  else
    # Om filen eller katalogen inte finns
    echo "$TARGET -> saknas [RISK: OKÄND]"
  fi

done

echo "===================================="
echo "Klar."
