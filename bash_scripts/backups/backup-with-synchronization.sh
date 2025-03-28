#!/bin/bash
set -euo pipefail

source_dir=""
target_dir=""
device=""

usage() {
    echo "Usage: $0 -s source_dir -d device -m target_dir"
    echo "Example: sudo $0 -s ~/Documents -d /dev/sdb1 -m /mnt/backup"
    exit 1
}

while getopts "s:d:m:" opt; do
    case $opt in
        s) source_dir="$OPTARG" ;;
        d) device="$OPTARG" ;;
        m) target_dir="$OPTARG" ;;
        *) usage ;;
    esac
done

[[ -z "$source_dir" ]] && { echo "ERROR: Source directory required"; usage; }
[[ -b "$device" ]] || { echo "ERROR: Device $device not found"; exit 1; }
[[ -d "$source_dir" ]] || { echo "ERROR: Source directory $source_dir does not exist"; exit 1; }

[[ -d "$target_dir" ]] || sudo mkdir -p "$target_dir"

echo "Mounting $device to $target_dir"
if ! sudo mount "$device" "$target_dir"; then
    echo "Mount failed. Check:"
    echo "1. Device formatting"
    echo "2. Filesystem type (use -t option if needed)"
    echo "3. Hardware connection"
    exit 1
fi

declare -A exclude_patterns=(
    # File patterns
    ['*.d']=1 ['*.slo']=1 ['*.lo']=1 ['*.o']=1 ['*.obj']=1
    ['*.gch']=1 ['*.pch']=1 ['*.so']=1 ['*.dylib']=1 ['*.dll']=1
    ['*.mod']=1 ['*.smod']=1 ['*.lai']=1 ['*.la']=1 ['*.a']=1
    ['*.lib']=1 ['*.exe']=1 ['*.out']=1 ['*.app']=1 ['*.ko']=1
    ['*.elf']=1 ['*.ilk']=1 ['*.map']=1 ['*.exp']=1 ['*.so.*']=1
    ['*.i*86']=1 ['*.x86_64']=1 ['*.hex']=1 ['*.su']=1 ['*.idb']=1
    ['*.pdb']=1 ['*.mod*']=1 ['*.cmd']=1 ['*.class']=1 ['*.log']=1
    ['*.ctxt']=1 ['*.jar']=1 ['*.war']=1 ['*.nar']=1 ['*.ear']=1
    ['*.zip']=1 ['*.tar.gz']=1 ['*.rar']=1 ['hs_err_pid*']=1 ['replay_pid*']=1

    # Directory patterns
    ['__pycache__']=1 ['build']=1 ['develop-eggs']=1 ['dist']=1
    ['downloads']=1 ['eggs']=1 ['.eggs']=1 ['lib']=1 ['lib64']=1
    ['parts']=1 ['sdist']=1 ['var']=1 ['wheels']=1 ['share/python-wheels']=1
    ['*.egg-info']=1 ['.tox']=1 ['.nox']=1 ['.cache']=1 ['htmlcov']=1
    ['.webassets-cache']=1 ['.scrapy']=1 ['docs/_build']=1 ['.pybuilder']=1
    ['target']=1 ['.ipynb_checkpoints']=1 ['profile_default']=1 ['.pytest_cache']=1
    ['.hypothesis']=1 ['cover']=1 ['instance']=1 ['.spyderproject']=1 ['.spyproject']=1
    ['.ropeproject']=1 ['site']=1 ['.mypy_cache']=1 ['.pyre']=1 ['.pytype']=1
    ['cython_debug']=1 ['.idea']=1 ['.ruff_cache']=1 ['.venv']=1 ['env']=1
    ['venv']=1 ['ENV']=1 ['env.bak']=1 ['venv.bak']=1 ['node_modules']=1
)

EXCLUDE_FILE=$(sudo mktemp /tmp/backup-excludes.XXXXXX)
trap 'cleanup' EXIT INT TERM

cleanup() {
    echo "Performing cleanup..."
    [[ -f "$EXCLUDE_FILE" ]] && sudo rm -f "$EXCLUDE_FILE"
    
    if mountpoint -q "$target_dir"; then
        echo -n "Unmounting $device"
        for i in {1..5}; do
            if sudo umount "$target_dir"; then
                echo " Success!"
                break
            else
                echo -n "."
                sleep 1
            fi
        done
        if mountpoint -q "$target_dir"; then
            echo " Force unmounting..."
            sudo umount -l "$target_dir"
        fi
    fi
    exit 0
}

printf "%s\n" "${!exclude_patterns[@]}" | sudo tee "$EXCLUDE_FILE" >/dev/null

clean_target() {
    echo "Starting cleanup process for directory: $target_dir"
    
    (
        echo "Changing working directory to: $target_dir"
        if ! cd "$target_dir"; then
            echo "ERROR: Failed to change directory to $target_dir" >&2
            exit 1
        fi

        echo "Building exclude patterns list..."
        find_args=(-false)
        
        for pattern in "${!exclude_patterns[@]}"; do
            if [[ "$pattern" == */* ]]; then
                echo "  Adding path pattern: '*/$pattern'"
                find_args+=(-o -path "*/$pattern")
            else
                echo "  Adding name pattern: '$pattern'"
                find_args+=(-o -name "$pattern")
            fi
        done

        echo "Constructed find command arguments:"
        printf "    %s\n" "${find_args[@]}"

        echo "Beginning deletion process..."
        echo "WARNING: The following items will be permanently deleted:"
        
        if sudo find . -depth \( "${find_args[@]}" \) -exec echo "[DRY RUN] Would delete: {}" \; 2>&1; then
            echo "----------------------------------------"
            echo "Dry run completed successfully"
            echo "Executing actual deletion now..."
            
            sudo find . -depth \( "${find_args[@]}" \) -exec rm -rfv {} + 2>&1 | while read -r line; do
                echo "DELETED: $line"
            done
            
            echo "----------------------------------------"
            echo "Cleanup completed successfully!"
        else
            echo "ERROR: Dry run failed. Aborting actual deletion." >&2
            exit 1
        fi
    )
    
    if [ $? -ne 0 ]; then
        echo "CRITICAL ERROR: Cleanup process failed" >&2
        return 1
    fi
}
perform_backup() {
    echo "Starting backup operation..."
    sudo rsync -avh --delete \
        --exclude-from="$EXCLUDE_FILE" \
        --stats \
        --info=progress2 \
        "$source_dir/" "$target_dir/"
}

clean_target
perform_backup

cleanup
