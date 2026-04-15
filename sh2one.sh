#!/bin/bash

# Base64 Alphabet
a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

# Input lesen
if [[ -n "$1" && -f "$1" ]]; then
    s=$(cat "$1")
else
    s=$(cat)
fi

# Encoder Variablen
o=""
i=0
n=0
v=0

# Zeichen für Zeichen encodieren
for ((i=0; i<${#s}; i++)); do
    # ASCII-Wert holen
    v=$((v << 8 | $(printf '%d' "'${s:$i:1}")))
    n=$((n + 8))
    
    # 6-Bit Blöcke extrahieren
    while [[ $n -ge 6 ]]; do
        n=$((n - 6))
        o="$o${a:$((v >> n & 63)):1}"
    done
done

# Padding für restliche Bits
while [[ $((n % 6)) -ne 0 ]]; do
    v=$((v << 2))
    n=$((n + 2))
    o="$o${a:$((v >> n & 63)):1}"
done

# Base64 Padding mit =
while [[ $((${#o} % 4)) -ne 0 ]]; do
    o="$o="
done

# Temp-Datei Pfad
t="/tmp/s_$$"

# Oneliner ausgeben
echo "t='$t';echo '$o'|{ a='$a';read c;i=0;n=0;v=0;while [[ \$i -lt \${#c} ]];do x=\${c:\$i:1};i=\$((i+1));[[ \$x == = ]]&&break;p=\${a%%\$x*};[[ \${#p} -eq 64 ]]&&continue;v=\$((v<<6|\${#p}));n=\$((n+6));while [[ \$n -ge 8 ]];do n=\$((n-8));printf \"\\\\x\$(printf %02x \$((v>>n&255)))\";done;done>\$t;chmod +x \$t;\$t \"\$@\";rm \$t;}"
