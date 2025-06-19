# Test
function dotenv --description "Load .env into current fish session"
    set -l file (test -n "$argv[1]"; and echo $argv[1]; or echo ".env")
    if not test -f $file
        echo "dotenv ❌  $file not found" >&2
        return 1
    end

    for line in (string match -v '^\s*#' (cat $file | string trim -l -r))
        set -l kv (string split -m1 '=' $line)
        if test (count $kv) -eq 2
            set -gx $kv[1] $kv[2]
        end
    end
end
