_complete_bash() {
    local -a raw trimmed
    local IFS=$'\n'
    local previous=("${COMP_WORDS[@]:0:COMP_CWORD}")

    raw=($("_completions_${COMP_WORDS[0]}_" "${COMP_WORDS[$COMP_CWORD]}" "${previous[@]}"))

    if (( ${#raw[@]} == 1 )); then
        trimmed=( "${raw[0]%%:*}" )
    else
        trimmed=( "${raw[@]}" )
    fi

    COMPREPLY=( "${trimmed[@]}" )
}

_complete_zsh() {
    local -a raw trimmed
    local IFS=$'\n'
    local previous="${(j: :)words[1,$((CURRENT-1))]}"
    raw=($("_completions_${words[1]}_" "" "${previous[@]}"))

    if [ -z "$raw" ]; then
        _default
    else
        for d in "${raw[@]}"; do trimmed+=( "${d%%:*}" ); done
        compadd -V $i -- -d raw -- $trimmed
    fi
}

