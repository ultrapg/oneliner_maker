#!/bin/bash

# Base64 alphabet lookup string
a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

# Read input from file argument or stdin
if [[ -n "$1" && -f "$1" ]]; then
    s=$(cat "$1")
else
    s=$(cat)
fi

# Encoder state variables
o=""
i=0
n=0
v=0

# Encode character by character
for ((i=0; i<${#s}; i++)); do
    # Get ASCII value of current character
    v=$((v << 8 | $(printf '%d' "'${s:$i:1}")))
    n=$((n + 8))
    
    # Extract 6-bit blocks
    while [[ $n -ge 6 ]]; do
        n=$((n - 6))
        o="$o${a:$((v >> n & 63)):1}"
    done
done

# Pad remaining bits
while [[ $((n % 6)) -ne 0 ]]; do
    v=$((v << 2))
    n=$((n + 2))
    o="$o${a:$((v >> n & 63)):1}"
done

# Add Base64 padding with =
while [[ $((${#o} % 4)) -ne 0 ]]; do
    o="$o="
done

# Temp file path
t="/tmp/s_$$"

# Output the self-decoding oneliner
echo "t='$t';echo '$o'|{ a='$a';read c;i=0;n=0;v=0;while [[ \$i -lt \${#c} ]];do x=\${c:\$i:1};i=\$((i+1));[[ \$x == = ]]&&break;p=\${a%%\$x*};[[ \${#p} -eq 64 ]]&&continue;v=\$((v<<6|\${#p}));n=\$((n+6));while [[ \$n -ge 8 ]];do n=\$((n-8));printf \"\\\\x\$(printf %02x \$((v>>n&255)))\";done;done>\$t;chmod +x \$t;\$t \"\$@\";rm \$t;}"
