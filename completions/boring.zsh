_boring() {
    local -a commands
    commands=(
        "open"
        "close"
        "list"
        "edit"
    )

    _boring_get_names() {
        local -a names

        if [[ "$1" == "closed" ]]; then
            names=($(boring list 2>/dev/null | awk 'NR > 1 && $1 == "closed" { print $2 }'))
        else
            names=($(boring list 2>/dev/null | awk 'NR > 1 && $1 != "closed" { print $2 }'))
        fi

        # filter names based on already provided arguments
        result=()
        for name in "${names[@]}"; do
            found=0
            for arg in "${@:2}"; do
                if [[ "$name" == "$arg" ]]; then
                    found=1
                    break
                fi
            done
            if [[ $found -eq 0 ]]; then
                result+=("$name")
            fi
        done

        if (( ${#result[@]} )); then
            _values 'name' "${result[@]}"
        fi
    }

    _arguments \
        '1:command:->commands' \
        '*:resource name:->names'

    case $state in
        commands)
            _values 'command' "${commands[@]}"
            ;;
        names)
            if [[ $line[1] == "open" || $line[1] == "o" ]]; then
                _boring_get_names "closed" "${line[@]:1}"
            elif [[ $line[1] == "close" || $line[1] == "c" ]]; then
                _boring_get_names "open" "${line[@]:1}"
            fi
            ;;
    esac
}

compdef _boring boring
