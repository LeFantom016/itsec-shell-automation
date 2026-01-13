#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Nätverksanalys – Python
- Samlar aktiva nätverksanslutningar
- Identifierar lyssnande portar
- Flaggar enkla riskindikatorer
- Loggar resultat till fil
"""

import psutil
import datetime

# ===== Gröna kommentarer (terminal) =====
GREEN = "\033[92m"
RESET = "\033[0m"

def green_comment(text):
    print(f"{GREEN}# {text}{RESET}")

# ===== Logg =====
LOG_FILE = "network_analysis.log"

def log(line):
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(line + "\n")

# ===== Start =====
green_comment("Startar nätverksanalys")
log(f"Start: {datetime.datetime.now()}")

# ===== Samla nätverksanslutningar =====
green_comment("Hämtar aktiva nätverksanslutningar")
connections = psutil.net_connections(kind="inet")

green_comment(f"Totalt antal anslutningar: {len(connections)}")
log(f"Antal anslutningar: {len(connections)}")

# ===== Lyssnande portar =====
green_comment("Identifierar lyssnande portar")
listening = [c for c in connections if c.status == psutil.CONN_LISTEN]

log(f"Lyssnande portar: {len(listening)}")
for c in listening:
    laddr = f"{c.laddr.ip}:{c.laddr.port}" if c.laddr else "okänd"
    line = f"LISTEN: {laddr} (PID={c.pid})"
    print(line)
    log(line)

# ===== Enkla riskindikatorer =====
green_comment("Analyserar enkla riskindikatorer")

# Exempel på ovanliga portar (indikativt, inte absolut sanning)
SUSPECT_PORTS = {4444, 1337, 6667, 9001}

for c in connections:
    if c.raddr:
        remote_port = c.raddr.port
        if remote_port in SUSPECT_PORTS:
            warning = (
                f"VARNING: Ovanlig fjärrport {remote_port} "
                f"(lokal {c.laddr.ip}:{c.laddr.port}, PID={c.pid})"
            )
            print(warning)
            log(warning)

# ===== Avslut =====
green_comment("Nätverksanalys klar")
log(f"Slut: {datetime.datetime.now()}")
