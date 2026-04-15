# oneliner_maker
A pure Bash implementation that converts any shell script into a self-contained, self-decoding one-liner without external dependencies

## Features

- **Pure Bash**: No external tools like `base64`, `openssl`, or `uuencode` required
- **Universal**: Works on any system with Bash 4.0+
- **Self-Decoding**: Generated one-liners decode and execute themselves
- **Clean**: Removes temporary files automatically after execution

## How It Works

1. **Encoding**: Reads your script character-by-character and encodes it to Base64 using pure Bash bit manipulation
2. **Embedding**: Wraps the encoded payload in a decoder stub that:
   - Decodes Base64 without external tools
   - Writes decoded content to a temporary file
   - Makes it executable and runs it
   - Cleans up afterwards

## Installation

### Option 1: One-Liner Function
``` bash
f() { a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";s=$(cat "$1");o="";i=0;n=0;v=0;for((i=0;i<${#s};i++));do v=$((v<<8|$(printf '%d' "'${s:$i:1}")));n=$((n+8));while [[ $n -ge 6 ]];do n=$((n-6));o="$o${a:$((v>>n&63)):1}";done;done;while [[ $((n%6)) -ne 0 ]];do v=$((v<<2));n=$((n+2));o="$o${a:$((v>>n&63)):1}";done;while [[ $((${#o}%4)) -ne 0 ]];do o="$o=";done;t="/tmp/s_$$";echo "t='$t';echo '$o'|{ a='$a';read c;i=0;n=0;v=0;while [[ \$i -lt \${#c} ]];do x=\${c:\$i:1};i=\$((i+1));[[ \$x == = ]]&&break;p=\${a%%\$x*};[[ \${#p} -eq 64 ]]&&continue;v=\$((v<<6|\${#p}));n=\$((n+6));while [[ \$n -ge 8 ]];do n=\$((n-8));printf \"\\\\x\$(printf %02x \$((v>>n&255)))\";done;done>\$t;chmod +x \$t;\$t \"\$@\";rm \$t;}"; }; f "your_script.sh"
```

### Option 2.1: Script File via curl
``` bash
curl -sL https://github.com/ultrapg/oneliner_maker/raw/refs/heads/main/sh2one.sh | bash -s -- /pfad/zu/deinem/script.sh
```

### Option 2.2: Script File locally
``` bash
chmod +x sh2one.sh
./sh2one.sh your_script.sh
```

**Usage**
``` bash
# From file
./sh2one.sh script.sh

# From stdin
cat script.sh | ./sh2one.sh

# Using function
f script.sh
```

## Technical Details
### **Base64 Encoding (Pure Bash)**
Uses bit-shifting (<<, >>) and bitwise operations (&, |)

24-bit buffer accumulates input bytes

Extracts 6-bit indices for Base64 alphabet lookup

Handles padding for non-aligned data


### **Base64 Decoding (Pure Bash)**
Reverse lookup via string prefix matching (${a%%char*})

24-bit buffer reconstructs original bytes

Outputs raw bytes via printf octal escapes


### **Security Notes**
Temporary files use PID ($$) to prevent collisions

Files are created with standard umask permissions

Automatic cleanup via rm (even on interruption with trap)

Warning: One-liners execute decoded code with eval-equivalent behavior


### **Limitations**
Requires Bash 4.0+ (for printf '%d' "'char" syntax)

Binary data in scripts may not encode correctly (text-only)

Large scripts (>100KB) will be slow due to pure Bash implementation

One-liner output length is ~4/3 of original due to Base64 overhead
