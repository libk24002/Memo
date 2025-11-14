# Text Processing Tools - Production Operations Guide

> **Comprehensive reference for awk, sed, grep, cut, sort, and advanced text processing**
> **For production systems, log analysis, data extraction, and automation**

---

## Table of Contents

1. [Overview](#overview)
2. [Grep - Pattern Matching](#grep---pattern-matching)
3. [Sed - Stream Editor](#sed---stream-editor)
4. [Awk - Text Processing Language](#awk---text-processing-language)
5. [Cut - Column Extraction](#cut---column-extraction)
6. [Sort - Data Ordering](#sort---data-ordering)
7. [Advanced Pipelines](#advanced-pipelines)
8. [Performance Optimization](#performance-optimization)
9. [Production Patterns](#production-patterns)
10. [Quick Reference](#quick-reference)

---

## Overview

### Text Processing Philosophy

```bash
# Core principles
- **Pipes**: Chain tools for complex operations
- **Streams**: Process data without loading entire files
- **Patterns**: Use regex for flexible matching
- **Efficiency**: Process millions of lines efficiently
```

### Standard Tool Chain

```bash
# Typical processing pipeline
grep "ERROR" app.log \      # Filter lines
  | awk '{print $1,$5}' \    # Extract columns
  | sort \                   # Order results
  | uniq -c \                # Count occurrences
  | sort -rn \               # Sort by count
  | head -10                 # Top 10
```

---

## Grep - Pattern Matching

### Basic Usage

```bash
# Simple pattern matching
grep "error" logfile.txt
grep -i "error" logfile.txt          # Case insensitive
grep -v "debug" logfile.txt          # Invert match (exclude)
grep -w "fail" logfile.txt           # Match whole word only
grep -c "error" logfile.txt          # Count matches
grep -n "error" logfile.txt          # Show line numbers

# Multiple patterns
grep -e "error" -e "warning" log.txt # OR matching
grep "error" log.txt | grep "critical" # AND matching
grep -E "error|warning" log.txt      # Extended regex OR
```

### Advanced Grep

```bash
# Context lines
grep -A 3 "error" log.txt            # 3 lines after match
grep -B 2 "error" log.txt            # 2 lines before match
grep -C 2 "error" log.txt            # 2 lines before & after

# Recursive search
grep -r "TODO" /project/src/         # Search directory recursively
grep -r --include="*.py" "import" .  # Filter by file pattern
grep -r --exclude-dir="node_modules" "error" .

# Binary files
grep -I "text" *                     # Skip binary files
grep -a "text" binary.dat            # Treat binary as text

# Output control
grep -l "error" *.log                # List filenames only
grep -L "error" *.log                # Files without match
grep -h "error" *.log                # Suppress filename in output
grep -H "error" *.log                # Always show filename

# Quiet mode
if grep -q "error" app.log; then
  echo "Errors found"
fi
```

### Regular Expressions in Grep

```bash
# Basic regex
grep "^error" log.txt                # Lines starting with "error"
grep "error$" log.txt                # Lines ending with "error"
grep "err.r" log.txt                 # Any single character
grep "erro*r" log.txt                # Zero or more 'o'
grep "[Ee]rror" log.txt              # Character class
grep "[0-9]\{3\}" log.txt           # Exactly 3 digits (basic regex)

# Extended regex (-E or egrep)
grep -E "error|warning" log.txt      # Alternation
grep -E "erro+r" log.txt             # One or more 'o'
grep -E "erro?r" log.txt             # Zero or one 'o'
grep -E "[0-9]{3}" log.txt           # Exactly 3 digits
grep -E "\berror\b" log.txt          # Word boundaries
grep -E "(error|warning):.*critical" log.txt  # Groups

# Perl regex (-P)
grep -P "\d{3}-\d{3}-\d{4}" data.txt # Phone numbers
grep -P "(?<=@)\w+\.\w+" emails.txt  # Domain after @
grep -P "^(?!#)" config.txt          # Negative lookahead
```

### Production Grep Patterns

```bash
# Find errors in last hour
grep "$(date -d '1 hour ago' '+%Y-%m-%d %H')" /var/log/app.log \
  | grep -i error

# Monitor errors in real-time
tail -f /var/log/app.log | grep --line-buffered -i error

# Extract IPs from logs
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort -u

# Find failed login attempts
grep "Failed password" /var/log/auth.log \
  | grep -oE "from [0-9.]+" \
  | sort | uniq -c | sort -rn

# Check for security issues
grep -r "password\s*=\s*['\"][^'\"]*['\"]" /project/src/ --include="*.py"

# Find large transactions
grep -E "transaction.*amount:[0-9]{6,}" financial.log
```

---

## Sed - Stream Editor

### Basic Substitution

```bash
# Simple replacement
sed 's/old/new/' file.txt            # Replace first occurrence per line
sed 's/old/new/g' file.txt           # Replace all occurrences
sed 's/old/new/2' file.txt           # Replace second occurrence only
sed 's/old/new/gi' file.txt          # Case insensitive global replace

# In-place editing
sed -i 's/old/new/g' file.txt        # Modify file directly
sed -i.bak 's/old/new/g' file.txt    # Keep backup (.bak)

# Multiple files
sed -i 's/old/new/g' *.txt
```

### Advanced Substitution

```bash
# Delimiter alternatives (when / appears in pattern)
sed 's|/old/path|/new/path|g' file.txt
sed 's#http://old#https://new#g' file.txt

# Backreferences
sed 's/\(error\): \(.*\)/[\1] \2/' log.txt  # Rearrange captured groups
sed -E 's/(error): (.*)/[\1] \2/' log.txt    # Extended regex

# Special characters
sed 's/\./\\./g' file.txt            # Escape dots
sed 's/$/\r/' unix.txt               # Add carriage return (DOS line endings)
sed 's/\r$//' dos.txt                # Remove carriage return (Unix conversion)
sed 's/\t/ /g' file.txt              # Replace tabs with spaces
```

### Line Selection and Deletion

```bash
# Print specific lines
sed -n '5p' file.txt                 # Print line 5 only
sed -n '10,20p' file.txt             # Print lines 10-20
sed -n '1p;$p' file.txt              # Print first and last line
sed -n '/pattern/p' file.txt         # Print lines matching pattern (like grep)

# Delete lines
sed '5d' file.txt                    # Delete line 5
sed '10,20d' file.txt                # Delete lines 10-20
sed '/pattern/d' file.txt            # Delete lines matching pattern
sed '/^$/d' file.txt                 # Delete empty lines
sed '/^#/d' file.txt                 # Delete comment lines
sed '/^ *$/d' file.txt               # Delete blank lines (with spaces)

# Range operations
sed '/start/,/end/d' file.txt        # Delete from start to end pattern
sed '1,/pattern/d' file.txt          # Delete from beginning to pattern
```

### Insert, Append, Change

```bash
# Insert before line
sed '5i\New line before 5' file.txt
sed '/pattern/i\New line before match' file.txt

# Append after line
sed '5a\New line after 5' file.txt
sed '/pattern/a\New line after match' file.txt

# Change entire line
sed '5c\Replacement line' file.txt
sed '/pattern/c\Replacement line' file.txt

# Multiple lines (GNU sed)
sed '5i\Line 1\nLine 2\nLine 3' file.txt
```

### Advanced Sed Scripting

```bash
# Multiple commands
sed -e 's/foo/bar/' -e 's/baz/qux/' file.txt
sed 's/foo/bar/; s/baz/qux/' file.txt

# Sed script file
cat > script.sed << 'EOF'
# Comment
s/error/ERROR/g
/debug/d
/warning/s/^/[WARN] /
EOF
sed -f script.sed logfile.txt

# Hold space (advanced)
sed -n 'x; n; p' file.txt            # Print even lines
sed -n 'n; p' file.txt               # Print odd lines

# Conditional substitution
sed '/pattern/s/foo/bar/' file.txt   # Replace foo only on lines with pattern
```

### Production Sed Examples

```bash
# Sanitize logs - remove sensitive data
sed -E 's/password=[^&]*/password=REDACTED/g' access.log

# Format JSON logs
sed 's/},{/},\n{/g' compact.json | sed 's/\[{/{\n{/' | sed 's/}\]/}\n]/'

# Update configuration across servers
sed -i 's/max_connections=100/max_connections=500/' /etc/myapp/config.ini

# Extract timestamps and errors
sed -n 's/.*\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9:]\{8\}\).*\(ERROR\).*/\1 \2/p' app.log

# Convert CSV delimiter
sed 's/,/\t/g' data.csv > data.tsv

# Add line numbers
sed = file.txt | sed 'N; s/\n/\t/'

# Remove ANSI color codes
sed 's/\x1b\[[0-9;]*m//g' colored-output.txt
```

---

## Awk - Text Processing Language

### Basic Awk Syntax

```bash
# Print columns
awk '{print $1}' file.txt            # First column
awk '{print $1, $3}' file.txt        # First and third column
awk '{print $NF}' file.txt           # Last column
awk '{print $(NF-1)}' file.txt       # Second to last column
awk '{print $0}' file.txt            # Entire line

# Field separator
awk -F: '{print $1}' /etc/passwd     # Use : as delimiter
awk -F'[ ,]' '{print $1}' file.txt   # Multiple delimiters (space or comma)
awk 'BEGIN{FS=":"} {print $1}' /etc/passwd

# Output separator
awk 'BEGIN{OFS="\t"} {print $1,$2}' file.txt   # Tab-separated output
awk '{print $1,$2}' OFS="," file.txt
```

### Pattern Matching and Conditions

```bash
# Pattern matching
awk '/error/ {print}' logfile.txt    # Lines containing "error"
awk '!/debug/ {print}' logfile.txt   # Lines NOT containing "debug"
awk '/^error/ {print}' logfile.txt   # Lines starting with "error"
awk '/error$/ {print}' logfile.txt   # Lines ending with "error"

# Conditional expressions
awk '$3 > 100 {print}' data.txt      # Third column > 100
awk '$1 == "ERROR" {print}' log.txt  # First column equals "ERROR"
awk 'NF > 5 {print}' file.txt        # More than 5 fields
awk 'length($0) > 80 {print}' file.txt # Lines longer than 80 chars

# Logical operators
awk '$3 > 100 && $4 < 50 {print}' data.txt      # AND
awk '$1 == "ERROR" || $1 == "FATAL" {print}' log.txt # OR
awk '!($3 > 100) {print}' data.txt              # NOT

# Range patterns
awk '/start/,/end/ {print}' file.txt # Print lines between start and end
```

### Built-in Variables

```bash
# Field and record variables
awk '{print NF}' file.txt            # Number of fields
awk '{print NR, $0}' file.txt        # Line number and line
awk 'END {print NR}' file.txt        # Total number of lines
awk '{print FNR, $0}' file.txt       # Line number within file

# BEGIN and END blocks
awk 'BEGIN {print "Starting..."; sum=0}
     {sum += $1}
     END {print "Total:", sum}' numbers.txt

# Multiple files - FILENAME variable
awk '{print FILENAME, NR, $0}' file1.txt file2.txt
```

### Arithmetic and Variables

```bash
# Arithmetic operations
awk '{print $1 + $2}' numbers.txt    # Addition
awk '{print $1 * $2}' numbers.txt    # Multiplication
awk '{sum += $1} END {print sum}' numbers.txt      # Sum column
awk '{sum += $1} END {print sum/NR}' numbers.txt   # Average

# User-defined variables
awk '{total += $3; count++} END {print total/count}' data.txt

# Increment operators
awk '{count++; print count, $0}' file.txt
```

### String Functions

```bash
# Length
awk '{print length($0)}' file.txt

# Substring
awk '{print substr($1, 1, 5)}' file.txt   # First 5 chars of column 1

# Index (position of substring)
awk '{print index($0, "error")}' file.txt

# Split
awk '{split($0, arr, ":"); print arr[1]}' file.txt

# Toupper/Tolower
awk '{print toupper($1)}' file.txt
awk '{print tolower($0)}' file.txt

# Sub/Gsub (substitution)
awk '{sub(/old/, "new"); print}' file.txt      # Replace first occurrence
awk '{gsub(/old/, "new"); print}' file.txt     # Replace all occurrences

# Match (regex matching)
awk 'match($0, /[0-9]+/) {print substr($0, RSTART, RLENGTH)}' file.txt
```

### Advanced Awk Patterns

```bash
# Associative arrays
awk '{count[$1]++} END {for (word in count) print word, count[word]}' file.txt

# Multi-dimensional concept (using concatenation)
awk '{key=$1 FS $2; sum[key] += $3}
     END {for (k in sum) print k, sum[k]}' data.txt

# Sorting array values (pipe to sort)
awk '{count[$1]++}
     END {for (w in count) print count[w], w}' file.txt | sort -rn
```

### Control Structures

```bash
# If-else
awk '{
  if ($3 > 100)
    print $1, "high"
  else if ($3 > 50)
    print $1, "medium"
  else
    print $1, "low"
}' data.txt

# For loop
awk '{
  for (i=1; i<=NF; i++)
    print "Field", i, "=", $i
}' file.txt

# While loop
awk '{
  i=1
  while (i <= NF) {
    print $i
    i++
  }
}' file.txt
```

### Production Awk Examples

```bash
# Parse Apache/Nginx access logs
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10  # Top IPs

awk '$9 == 500 {print $7}' access.log | sort | uniq -c | sort -rn  # URLs with 500 errors

awk '{sum += $10} END {print sum/1024/1024 " MB"}' access.log  # Total bandwidth

# System statistics
df -h | awk '$5+0 > 80 {print $6, $5}'  # Filesystems > 80% full

ps aux | awk '$3 > 10 {print $2, $11, $3"%"}'  # Processes using >10% CPU

free -m | awk 'NR==2 {printf "Memory: %.2f%%\n", $3/$2*100}'  # Memory usage %

# CSV processing
awk -F, '{sum[$1] += $3} END {for (key in sum) print key, sum[key]}' sales.csv

# Log analysis - calculate response times
awk '{sum+=$NF; count++} END {print "Avg:", sum/count "ms"}' response-times.log

# Count unique values
awk -F, '{count[$2]++} END {print "Unique customers:", length(count)}' orders.csv

# Time-based filtering (extract hour and filter)
awk -F'[ :]' '$2 >= 14 && $2 <= 16 {print}' timestamped-log.txt

# Generate report
awk 'BEGIN {print "Status Report"; print "============="}
     /ERROR/ {errors++}
     /WARN/ {warnings++}
     END {print "Errors:", errors; print "Warnings:", warnings}' app.log

# JSON-like output
awk 'BEGIN {print "["}
     {printf "%s{\"name\":\"%s\", \"value\":%d}", (NR>1?",\n":""), $1, $2}
     END {print "\n]"}' data.txt
```

---

## Cut - Column Extraction

### Basic Cut Usage

```bash
# Extract by character position
cut -c1-5 file.txt                   # Characters 1-5
cut -c1,3,5 file.txt                 # Characters 1, 3, and 5
cut -c5- file.txt                    # From character 5 to end
cut -c-10 file.txt                   # First 10 characters

# Extract by byte position (important for multi-byte characters)
cut -b1-10 file.txt

# Extract by delimiter
cut -d: -f1 /etc/passwd              # First field, colon delimiter
cut -d: -f1,3,6 /etc/passwd          # Fields 1, 3, and 6
cut -d: -f1-3 /etc/passwd            # Fields 1 through 3
cut -d, -f2- data.csv                # All fields from 2nd onward

# Complement (everything except)
cut -d: -f1 --complement /etc/passwd # All fields except first

# Output delimiter
cut -d: -f1,3 --output-delimiter=" - " /etc/passwd
```

### Production Cut Examples

```bash
# Extract usernames
cut -d: -f1 /etc/passwd | sort

# Extract IPs from logs
cut -d' ' -f1 access.log | sort -u

# Process CSV
cut -d, -f2,5 sales.csv | tail -n +2  # Skip header

# Extract specific columns from ps output
ps aux | tail -n +2 | tr -s ' ' | cut -d' ' -f2,11

# Get UIDs over 1000 (regular users)
cut -d: -f1,3 /etc/passwd | awk -F: '$2 >= 1000 {print $1}'
```

---

## Sort - Data Ordering

### Basic Sorting

```bash
# Default sorting (lexicographic)
sort file.txt
sort -r file.txt                     # Reverse order
sort -u file.txt                     # Unique (remove duplicates)
sort -f file.txt                     # Case insensitive

# Numeric sorting
sort -n numbers.txt                  # Numeric sort
sort -rn numbers.txt                 # Reverse numeric
sort -h file-sizes.txt               # Human numeric (K, M, G)

# Field-based sorting
sort -t: -k3 -n /etc/passwd          # Sort by 3rd field (UID), numeric
sort -t, -k2 data.csv                # Sort by 2nd field, comma delimiter
sort -k2,2 file.txt                  # Sort by 2nd field only
sort -k1,1 -k2,2n file.txt           # Sort by 1st field, then 2nd numeric

# Month sorting
sort -M months.txt                   # January, February, etc.

# Version sorting
sort -V versions.txt                 # 1.2, 1.10, 2.1 correctly
```

### Advanced Sort Options

```bash
# Multiple keys
sort -k1,1 -k2,2rn data.txt          # Sort by col1 asc, then col2 desc numeric

# Stable sort (preserve original order for equal keys)
sort -s -k2 file.txt

# Random sort
sort -R file.txt                     # Shuffle lines

# Check if sorted
sort -c file.txt                     # Exit with error if not sorted

# Merge sorted files
sort -m sorted1.txt sorted2.txt      # Merge pre-sorted files efficiently

# Buffer size (for large files)
sort -S 2G large-file.txt            # Use 2GB memory buffer

# Parallel sort
sort --parallel=4 large-file.txt     # Use 4 threads

# Temporary directory
sort -T /fast-disk/tmp large-file.txt
```

### Production Sort Examples

```bash
# Top 10 IPs from access log
cut -d' ' -f1 access.log | sort | uniq -c | sort -rn | head -10

# Sort by file size
ls -lh | tail -n +2 | sort -k5h

# Sort processes by memory usage
ps aux | tail -n +2 | sort -k4 -rn | head -10

# Sort CSV by numeric column
sort -t, -k3 -n sales.csv

# Find duplicate lines
sort file.txt | uniq -d

# Count unique entries
sort data.txt | uniq | wc -l

# Sort log by timestamp (assuming ISO format)
sort -t' ' -k1,2 app.log

# Large file sorting with optimization
sort -S 4G --parallel=8 -T /tmp --compress-program=gzip huge-file.txt
```

---

## Advanced Pipelines

### Complex Log Analysis

```bash
# Analyze HTTP status codes
awk '{print $9}' access.log \
  | sort \
  | uniq -c \
  | sort -rn \
  | awk '{printf "%s: %d\n", $2, $1}'

# Top URLs by response time
awk '{print $NF, $7}' access.log \
  | sort -rn \
  | head -20 \
  | awk '{print $2, $1"ms"}'

# Hourly error distribution
grep ERROR app.log \
  | awk '{print substr($1,12,2)}' \
  | sort \
  | uniq -c \
  | awk '{printf "%02d:00 - %d errors\n", $2, $1}'
```

### Data Transformation Pipelines

```bash
# CSV to JSON
awk -F, 'NR>1 {printf "{\"name\":\"%s\",\"age\":%d},\n", $1, $2}' data.csv \
  | sed '$ s/,$//' \
  | sed '1 i[' \
  | sed '$ a]'

# Log aggregation
cat app*.log \
  | grep -v DEBUG \
  | sed 's/^.*\[\(.*\)\].*/\1/' \
  | sort \
  | uniq -c \
  | awk '{print $2, $1}' \
  | sort -k2 -rn

# Extract and analyze API response times
grep "API" app.log \
  | grep -oE "took [0-9]+ms" \
  | cut -d' ' -f2 \
  | sed 's/ms//' \
  | awk '{sum+=$1; count++; if($1>max) max=$1}
         END {print "Avg:", sum/count "ms"; print "Max:", max "ms"}'
```

### Multi-File Processing

```bash
# Aggregate logs from multiple servers
for log in server*.log; do
  echo "=== $log ==="
  grep ERROR "$log" | wc -l
done | paste - - | sort -k2 -rn

# Compare configurations across servers
diff <(ssh server1 'cat /etc/app/config.ini | sort') \
     <(ssh server2 'cat /etc/app/config.ini | sort')

# Merge and deduplicate data
cat db1.txt db2.txt db3.txt | sort -u > merged.txt
```

---

## Performance Optimization

### Efficiency Tips

```bash
# Avoid unnecessary sorting
# Bad:
cat huge.log | sort | uniq | wc -l
# Good:
cat huge.log | awk '!seen[$0]++' | wc -l

# Use grep before awk when filtering
# Bad:
awk '/ERROR/ {print $5}' huge.log
# Good:
grep ERROR huge.log | awk '{print $5}'

# Process streams, don't load entire files
# Bad:
for line in $(cat huge.log); do ...
# Good:
while IFS= read -r line; do ...; done < huge.log
# Best:
awk '...' huge.log  # Let awk handle it
```

### Parallel Processing

```bash
# GNU Parallel
cat urls.txt | parallel -j4 'curl -s {} | wc -l'

# Split work across cores
split -n l/4 huge.txt part-
for part in part-*; do
  awk '{sum+=$3} END {print sum}' "$part" &
done
wait

# Parallel grep
find /logs -name "*.log" -print0 | xargs -0 -P4 grep -l "ERROR"
```

### Large File Strategies

```bash
# Use LC_ALL=C for faster processing (no locale overhead)
LC_ALL=C sort huge.txt
LC_ALL=C grep pattern huge.txt

# Limit early
head -n 100000 huge.log | awk '{...}'  # Process sample first

# Memory-efficient sorting
sort -S 50% huge.txt  # Use 50% of RAM

# Stream processing
tail -f live.log | grep --line-buffered ERROR | awk '{print $1, $5}'
```

---

## Production Patterns

### Log Monitoring Scripts

```bash
#!/bin/bash
# Real-time error alerting
tail -f /var/log/app/application.log | \
while read line; do
  if echo "$line" | grep -qi "error\|fatal\|exception"; then
    echo "[ALERT] $line" | mail -s "App Error" ops@example.com
  fi
done
```

### Daily Report Generation

```bash
#!/bin/bash
# Daily log summary
LOGFILE="/var/log/app/app.log"
REPORT="/tmp/daily_report.txt"

{
  echo "=== Daily Application Report $(date +%F) ==="
  echo
  echo "Total Requests:"
  wc -l < "$LOGFILE"
  echo
  echo "Status Code Distribution:"
  awk '{print $9}' "$LOGFILE" | sort | uniq -c | sort -rn
  echo
  echo "Top 10 IPs:"
  awk '{print $1}' "$LOGFILE" | sort | uniq -c | sort -rn | head -10
  echo
  echo "Errors:"
  grep -i error "$LOGFILE" | wc -l
  echo
  echo "Slow Requests (>1000ms):"
  awk '$NF > 1000 {print $7, $NF"ms"}' "$LOGFILE" | sort -k2 -rn | head -10
} > "$REPORT"

cat "$REPORT" | mail -s "Daily App Report" team@example.com
```

### Data Extraction for Analysis

```bash
#!/bin/bash
# Extract user activity for date range
START="2024-01-01"
END="2024-01-31"

awk -v start="$START" -v end="$END" '
  $1 >= start && $1 <= end {
    user=$3
    action=$5
    count[user][action]++
  }
  END {
    for (u in count) {
      printf "%s: ", u
      for (a in count[u])
        printf "%s=%d ", a, count[u][a]
      printf "\n"
    }
  }' user-activity.log | sort
```

### Configuration Management

```bash
#!/bin/bash
# Update config value across multiple servers
NEW_VALUE="512M"
SERVERS="web1 web2 web3"
CONFIG_FILE="/etc/app/config.ini"

for server in $SERVERS; do
  echo "Updating $server..."
  ssh "$server" "
    sudo sed -i.bak 's/^memory_limit=.*/memory_limit=$NEW_VALUE/' $CONFIG_FILE &&
    sudo systemctl reload app
  "
done

# Verify changes
for server in $SERVERS; do
  echo -n "$server: "
  ssh "$server" "grep memory_limit $CONFIG_FILE"
done
```

---

## Quick Reference

### Grep Cheatsheet

```bash
grep "pattern" file              # Search
grep -i "pattern" file           # Case insensitive
grep -v "pattern" file           # Invert match
grep -r "pattern" dir            # Recursive
grep -l "pattern" *              # List filenames
grep -c "pattern" file           # Count matches
grep -n "pattern" file           # Show line numbers
grep -A 3 "pattern" file         # 3 lines after
grep -E "pat1|pat2" file         # Extended regex
grep -P "\d+" file               # Perl regex
```

### Sed Cheatsheet

```bash
sed 's/old/new/' file            # Replace first occurrence
sed 's/old/new/g' file           # Replace all occurrences
sed -i 's/old/new/g' file        # In-place edit
sed -n '10,20p' file             # Print lines 10-20
sed '5d' file                    # Delete line 5
sed '/pattern/d' file            # Delete matching lines
sed '/pattern/i\text' file       # Insert before match
sed '/pattern/a\text' file       # Append after match
sed -E 's/([0-9]+)/[\1]/' file   # Extended regex with groups
```

### Awk Cheatsheet

```bash
awk '{print $1}' file            # Print first column
awk '{print $NF}' file           # Print last column
awk -F: '{print $1}' file        # Use : as delimiter
awk '/pattern/ {print}' file     # Print matching lines
awk '$3 > 100' file              # Condition on column
awk '{sum+=$1} END {print sum}'  # Sum column
awk '{count[$1]++} END {for (w in count) print w, count[w]}'  # Count occurrences
```

### Cut Cheatsheet

```bash
cut -c1-10 file                  # Characters 1-10
cut -d: -f1 file                 # First field, : delimiter
cut -d: -f1,3,5 file             # Fields 1, 3, 5
cut -d: -f2- file                # From field 2 onward
```

### Sort Cheatsheet

```bash
sort file                        # Lexicographic sort
sort -n file                     # Numeric sort
sort -r file                     # Reverse
sort -u file                     # Unique
sort -k2 file                    # Sort by 2nd column
sort -t: -k3 -n file             # Delimiter :, sort by 3rd col numeric
sort -h file                     # Human numeric (K, M, G)
```

### Common Pipeline Patterns

```bash
# Count unique
sort file.txt | uniq | wc -l

# Top 10 occurrences
sort file.txt | uniq -c | sort -rn | head -10

# Remove duplicates
sort -u file.txt

# Merge and sort
cat file1 file2 | sort

# Column sum
awk '{sum+=$1} END {print sum}' numbers.txt

# Average
awk '{sum+=$1; count++} END {print sum/count}' numbers.txt

# Filter and extract
grep ERROR log.txt | awk '{print $5}'
```

---

## Related Documentation

- [Regular Expressions Guide](../regex/README.md)
- [Bash Scripting](../../scripting/bash/README.md)
- [System Monitoring](../monitoring/README.md)
- [Log Management](../../operations/logging/README.md)

---

**Document Version:** 1.0
**Last Updated:** 2024
**Maintained By:** Operations Team
