#!/usr/bin/env bash
# flaghunt.sh - find CTF flag files on a Linux box you already have a shell on.
# For CTFs, labs, and systems you are authorized to test. Read-only: it only
# lists and prints; it never modifies files.
#
# Usage: ./flaghunt.sh [-d DIR] [-c] [-p]
#   -d DIR   search root (default: /)
#   -c       also grep file contents for flag-format strings (slower)
#   -p       print contents of flag files that are readable

set -u
ROOT="/"; CONTENT=0; PRINT=0
while getopts "d:cph" o; do
    case "$o" in
        d) ROOT="$OPTARG" ;;
        c) CONTENT=1 ;;
        p) PRINT=1 ;;
        *) sed -n '2,10p' "$0"; exit 0 ;;
    esac
done

NAMES='user.txt root.txt proof.txt local.txt flag.txt flag flag*.txt *.flag secret.txt'
FORMATS='(HTB|THM|flag|FLAG|CTF|picoCTF|DUCTF|csaw)\{[^}]{4,}\}'
PRUNE='/proc /sys /dev /run /snap /usr/lib /usr/share /var/lib/dpkg'

G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[0m'
echo "[*] $(id -un)@$(hostname) | search root: $ROOT"

prune_args=()
for p in $PRUNE; do prune_args+=( -path "$p" -prune -o ); done

echo "[*] Flag-named files"
for n in $NAMES; do
    find "$ROOT" "${prune_args[@]}" -type f -name "$n" -print 2>/dev/null
done | sort -u | while read -r f; do
    if [ -r "$f" ]; then
        echo "${G}[+] readable${R}  $f"
        [ "$PRINT" = 1 ] && sed 's/^/      /' "$f" | head -5
    else
        echo "${Y}[!] exists, not readable${R}  $f  (needs privesc?)"
    fi
done

echo "[*] Usual hiding spots"
for d in /root /home/* /var/www /opt /srv /tmp /var/backups; do
    [ -d "$d" ] && [ -r "$d" ] && find "$d" -maxdepth 3 -type f \
        \( -iname '*flag*' -o -iname '*.txt' -o -iname '.*secret*' \) \
        -size -4k -print 2>/dev/null
done | sort -u | head -50

if [ "$CONTENT" = 1 ]; then
    echo "[*] Content search for flag formats"
    grep -rIEo --exclude-dir={proc,sys,dev,run,snap} "$FORMATS" "$ROOT" 2>/dev/null | head -50
fi
