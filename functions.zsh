#!/usr/bin/env zsh
# ============================================================================
# Useful ZSH Functions
# ============================================================================

# ============================================================================
# Archive Management Functions
# ============================================================================

# List archive contents
lsarchive() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: lsarchive <archive-file>"
        return 1
    fi

    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found"
        return 1
    fi

    case "${file:l}" in
        *.tar.bz2|*.tbz2|*.tar.bz)
            tar -tjf "$file"
            ;;
        *.tar.gz|*.tgz)
            tar -tzf "$file"
            ;;
        *.tar.xz|*.txz)
            tar -tJf "$file"
            ;;
        *.tar.zst|*.tzst)
            tar --zstd -tf "$file"
            ;;
        *.tar)
            tar -tf "$file"
            ;;
        *.zip|*.jar|*.war|*.ear)
            unzip -l "$file"
            ;;
        *.rar)
            unrar l "$file"
            ;;
        *.7z)
            7z l "$file"
            ;;
        *.gz)
            gzip -l "$file"
            ;;
        *.bz2)
            echo "Cannot list bz2 file contents directly"
            return 1
            ;;
        *.xz)
            xz -l "$file"
            ;;
        *)
            echo "Error: Unknown archive format for '$file'"
            return 1
            ;;
    esac
}

# Extract archives
unarchive() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: unarchive <archive-file> [destination]"
        return 1
    fi

    local file="$1"
    local dest="${2:-.}"

    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found"
        return 1
    fi

    # Create destination directory if it doesn't exist
    [[ ! -d "$dest" ]] && mkdir -p "$dest"

    echo "Extracting $file to $dest..."

    case "${file:l}" in
        *.tar.bz2|*.tbz2|*.tar.bz)
            tar -xjf "$file" -C "$dest"
            ;;
        *.tar.gz|*.tgz)
            tar -xzf "$file" -C "$dest"
            ;;
        *.tar.xz|*.txz)
            tar -xJf "$file" -C "$dest"
            ;;
        *.tar.zst|*.tzst)
            tar --zstd -xf "$file" -C "$dest"
            ;;
        *.tar)
            tar -xf "$file" -C "$dest"
            ;;
        *.zip|*.jar|*.war|*.ear)
            unzip -q "$file" -d "$dest"
            ;;
        *.rar)
            unrar x "$file" "$dest"
            ;;
        *.7z)
            7z x "$file" -o"$dest"
            ;;
        *.gz)
            gunzip -c "$file" > "$dest/$(basename "$file" .gz)"
            ;;
        *.bz2)
            bunzip2 -c "$file" > "$dest/$(basename "$file" .bz2)"
            ;;
        *.xz)
            unxz -c "$file" > "$dest/$(basename "$file" .xz)"
            ;;
        *.zst)
            unzstd "$file" -o "$dest/$(basename "$file" .zst)"
            ;;
        *.Z)
            uncompress -c "$file" > "$dest/$(basename "$file" .Z)"
            ;;
        *)
            echo "Error: Unknown archive format for '$file'"
            return 1
            ;;
    esac

    if [[ $? -eq 0 ]]; then
        echo "✓ Successfully extracted to $dest"
    else
        echo "✗ Extraction failed"
        return 1
    fi
}

# Create archives with best compression
archive() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: archive <archive-name> <files/directories...>"
        echo ""
        echo "Supported formats (auto-detected from extension):"
        echo "  .tar.gz, .tgz     - gzip compressed tar"
        echo "  .tar.bz2, .tbz2   - bzip2 compressed tar (better compression)"
        echo "  .tar.xz, .txz     - xz compressed tar (best compression)"
        echo "  .tar.zst, .tzst   - zstd compressed tar (fast & good compression)"
        echo "  .zip              - zip archive"
        echo "  .7z               - 7zip archive (excellent compression)"
        return 1
    fi

    local archive_name="$1"
    shift
    local files=("$@")

    # Verify all files exist
    for file in "${files[@]}"; do
        if [[ ! -e "$file" ]]; then
            echo "Error: '$file' not found"
            return 1
        fi
    done

    echo "Creating archive: $archive_name"

    case "${archive_name:l}" in
        *.tar.gz|*.tgz)
            tar -czf "$archive_name" "${files[@]}"
            ;;
        *.tar.bz2|*.tbz2)
            tar -cjf "$archive_name" "${files[@]}"
            ;;
        *.tar.xz|*.txz)
            tar -cJf "$archive_name" "${files[@]}"
            ;;
        *.tar.zst|*.tzst)
            tar --zstd -cf "$archive_name" "${files[@]}"
            ;;
        *.tar)
            tar -cf "$archive_name" "${files[@]}"
            ;;
        *.zip)
            zip -r -9 "$archive_name" "${files[@]}"
            ;;
        *.7z)
            7z a -mx=9 "$archive_name" "${files[@]}"
            ;;
        *)
            echo "Error: Unknown or unsupported archive format"
            echo "Please use a supported extension (.tar.gz, .tar.bz2, .tar.xz, .tar.zst, .zip, .7z)"
            return 1
            ;;
    esac

    if [[ $? -eq 0 ]]; then
        echo "✓ Successfully created: $archive_name"
        ls -lh "$archive_name"
    else
        echo "✗ Archive creation failed"
        return 1
    fi
}

# ============================================================================
# Directory Navigation Functions
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && {
        if command -v zoxide &>/dev/null; then
            z "$1"
        else
            cd "$1"
        fi
    }
}

# Go up N directories
up() {
    local d=""
    local limit="${1:-1}"
    for ((i=1; i <= limit; i++)); do
        d="../$d"
    done
    cd "$d" || return 1
}

# Quick jump to project directories (customize these paths)
proj() {
    if [[ $# -eq 0 ]]; then
        # List common project directories
        echo "Usage: proj <project-name>"
        echo "Common locations:"
        [[ -d ~/projects ]] && ls -1 ~/projects
        [[ -d ~/work ]] && ls -1 ~/work
        [[ -d ~/code ]] && ls -1 ~/code
        [[ -d ~/dev ]] && ls -1 ~/dev
        return 1
    fi
    
    # Search in common project locations
    local project_dirs=(
        ~/projects
        ~/work
        ~/code
        ~/dev
        ~/workspace
    )
    
    for base_dir in "${project_dirs[@]}"; do
        if [[ -d "${base_dir}/$1" ]]; then
            if command -v zoxide &>/dev/null; then
                z "${base_dir}/$1"
            else
                cd "${base_dir}/$1"
            fi
            return 0
        fi
    done
    
    echo "Project '$1' not found in common directories"
    return 1
}

# ============================================================================
# File and Directory Operations
# ============================================================================

# Find file by name (fuzzy)
ff() {
    if command -v fd &>/dev/null; then
        fd --type f --hidden --follow --exclude .git "$@"
    else
        find . -type f -iname "*$@*" 2>/dev/null
    fi
}

# Find directory by name (fuzzy)
fd() {
    if command -v fd &>/dev/null; then
        command fd --type d --hidden --follow --exclude .git "$@"
    else
        find . -type d -iname "*$@*" 2>/dev/null
    fi
}

# Find and grep content in files
ftext() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: ftext <search-pattern> [path]"
        return 1
    fi

    local pattern="$1"
    local path="${2:-.}"

    if command -v rg &>/dev/null; then
        rg --hidden --follow --smart-case "$pattern" "$path"
    else
        grep -r -n -i "$pattern" "$path" 2>/dev/null
    fi
}

# Get file size in human readable format
fsize() {
    if [[ -f "$1" ]]; then
        du -h "$1" | cut -f1
    else
        echo "Error: File not found"
        return 1
    fi
}

# Count files in directory
count_files() {
    local dir="${1:-.}"
    find "$dir" -type f | wc -l
}

# Count lines in file
count_lines() {
    if [[ -f "$1" ]]; then
        wc -l < "$1"
    else
        echo "Error: File not found"
        return 1
    fi
}

# ============================================================================
# Text Processing Functions
# ============================================================================

# Convert text to lowercase
lower() {
    echo "$@" | tr '[:upper:]' '[:lower:]'
}

# Convert text to uppercase
upper() {
    echo "$@" | tr '[:lower:]' '[:upper:]'
}

# Trim whitespace
trim() {
    echo "$@" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# ============================================================================
# Process Management
# ============================================================================

# Kill process by name
killproc() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: killproc <process-name>"
        return 1
    fi
    
    pkill -f "$1"
}

# Find process by name
findproc() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: findproc <process-name>"
        return 1
    fi
    
    ps aux | grep -i "$1" | grep -v grep
}

# ============================================================================
# Network Functions
# ============================================================================
# Test if port is open
port_test() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: port_test <host> <port>"
        return 1
    fi
    
    timeout 2 bash -c "cat < /dev/null > /dev/tcp/$1/$2" 2>/dev/null && echo "Port $2 is open" || echo "Port $2 is closed"
}

# ============================================================================
# Git Functions
# ============================================================================

# Git commit and push
gcp() {
    git add -A && git commit -m "$*" && git push
}

# Create new branch and switch to it
gnb() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: gnb <branch-name>"
        return 1
    fi
    git checkout -b "$1"
}

# Delete merged branches
git_cleanup() {
    git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop" | xargs -r git branch -d
}

# Show git status of all repos in subdirectories
git_status_all() {
    find . -name ".git" -type d -prune | while read -r gitdir; do
        local repo_dir="${gitdir%/.git}"
        echo "\n${repo_dir}:"
        git -C "$repo_dir" status -s
    done
}

# ============================================================================
# System Information
# ============================================================================

# System information summary
sysinfo() {
    echo "System Information:"
    echo "===================="
    echo "Hostname:     $(hostname)"
    echo "OS:           $(uname -s) $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Kernel:       $(uname -v)"
    echo "Uptime:       $(uptime -p 2>/dev/null || uptime)"
    echo "CPU:          $(nproc) cores"
    echo "Memory:       $(free -h 2>/dev/null | awk '/^Mem:/ {print $3 " / " $2}' || echo 'N/A')"
}

# Disk usage of current directory
diskusage() {
    du -sh -- * 2>/dev/null | sort -hr | head -20
}

# ============================================================================
# Quick Notes
# ============================================================================

# Quick note taking
note() {
    local notes_file="${HOME}/.notes.txt"
    if [[ $# -eq 0 ]]; then
        # Show notes
        if [[ -f "$notes_file" ]]; then
            cat "$notes_file"
        else
            echo "No notes found"
        fi
    else
        # Add note
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$notes_file"
        echo "Note added"
    fi
}

# ============================================================================
# Backup Function
# ============================================================================

# Quick backup of a file
backup() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: backup <file>"
        return 1
    fi
    
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found"
        return 1
    fi
    
    local backup_name="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$file" "$backup_name"
    echo "✓ Backup created: $backup_name"
}

# ============================================================================
# Weather Function (using wttr.in)
# ============================================================================

weather() {
    local city="${1:-}"
    curl -s "wttr.in/${city}?format=v2"
}
