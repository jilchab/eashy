
# Auto-generated CLI shell functions
# All modifications will be lost when terminal is reloaded

venv() {
    setopt localoptions sh_word_split 2>/dev/null || true
    local subcmd="$1"
    if [ $# -gt 0 ]; then shift; fi
    case "$subcmd" in
        -h|--help)
            printf "Python venv management\n\n\\033[1;32mUsage:\\033[0m \\033[1;36mvenv \\033[0;36m<subcommand> [-h|--help]\\033[0m\n\n\\033[1;32mCommands:\\033[0m\n  \\033[1;36minit      \\033[0m  Create a new virtual environment\n  \\033[1;36mactivate  \\033[0m  Activate the virtual environment\n  \\033[1;36mdeactivate\\033[0m  Deactivate the virtual environment\n  \\033[1;36mdelete    \\033[0m  Delete the virtual environment\n\n\\033[1;32mOptions:\\033[0m\n  \\033[1;36m-h, --help\\033[0m  Show help information\n"
            return
            ;;
        init) _venv_init_ "$@";;
        activate) _venv_activate_ "$@";;
        deactivate) _venv_deactivate_ "$@";;
        delete) _venv_delete_ "$@";;
        -*)
            printf "\033[1;31mError:\033[0m Unknown option: $subcmd\n\n" >&2
            printf "\033[1;32mUsage:\033[0m \\033[1;36mvenv \\033[0;36m<subcommand> [-h|--help]\\033[0m\n\n" >&2
            printf "Try 'venv --help' for more information.\n" >&2
            return 1
            ;;
        *)
            printf "\033[1;31mError:\033[0m Unknown subcommand: $subcmd\n\n" >&2
            printf "\033[1;32mUsage:\033[0m \\033[1;36mvenv \\033[0;36m<subcommand> [-h|--help]\\033[0m\n\n" >&2
            printf "Try 'venv --help' for more information.\n" >&2
            return 1
            ;;
    esac
}

_venv_init_() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                printf "Create a new virtual environment\n\n\\033[1;32mUsage:\\033[0m \\033[1;36mvenv init \\033[0;36m[-h|--help]\\033[0m\n\n\\033[1;32mOptions:\\033[0m\n  \\033[1;36m-h, --help\\033[0m  Show help information\n"
                return
                ;;
            -*)
                printf "\033[1;31mError:\033[0m Unknown option: $1\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36mvenv init \\033[0;36m[-h|--help]\\033[0m\n\n" >&2
                printf "Try 'venv init --help' for more information.\n" >&2
                return 1
                ;;
            *)
                printf "\033[1;31mError:\033[0m Too many arguments\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36mvenv init \\033[0;36m[-h|--help]\\033[0m\n\n" >&2
                printf "Try 'venv init --help' for more information.\n" >&2
                return 1
                ;;
        esac
    done

    # Execute command
    python -m venv .venv
    source ".venv/bin/activate"
    echo "Activated virtual environment, version: $(python --version)"
}

_venv_activate_() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                printf "Activate the virtual environment\n\n\\033[1;32mUsage:\\033[0m \\033[1;36mvenv activate \\033[0;36m[-h|--help]\\033[0m\n\n\\033[1;32mOptions:\\033[0m\n  \\033[1;36m-h, --help\\033[0m  Show help information\n"
                return
                ;;
            -*)
                printf "\033[1;31mError:\033[0m Unknown option: $1\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36mvenv activate \\033[0;36m[-h|--help]\\033[0m\n\n" >&2
                printf "Try 'venv activate --help' for more information.\n" >&2
                return 1
                ;;
            *)
                printf "\033[1;31mError:\033[0m Too many arguments\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36mvenv activate \\033[0;36m[-h|--help]\\033[0m\n\n" >&2
                printf "Try 'venv activate --help' for more information.\n" >&2
                return 1
                ;;
        esac
    done

    # Execute command
    source ".venv/bin/activate" && echo "Activated virtual environment, version: $(python --version)" || echo "Failed to activate virtual environment. Make sure .venv exists."
}

_venv_deactivate_() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                printf "Deactivate the virtual environment\n\n\\033[1;32mUsage:\\033[0m \\033[1;36mvenv deactivate \\033[0;36m[-h|--help]\\033[0m\n\n\\033[1;32mOptions:\\033[0m\n  \\033[1;36m-h, --help\\033[0m  Show help information\n"
                return
                ;;
            -*)
                printf "\033[1;31mError:\033[0m Unknown option: $1\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36mvenv deactivate \\033[0;36m[-h|--help]\\033[0m\n\n" >&2
                printf "Try 'venv deactivate --help' for more information.\n" >&2
                return 1
                ;;
            *)
                printf "\033[1;31mError:\033[0m Too many arguments\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36mvenv deactivate \\033[0;36m[-h|--help]\\033[0m\n\n" >&2
                printf "Try 'venv deactivate --help' for more information.\n" >&2
                return 1
                ;;
        esac
    done

    # Execute command
    deactivate && echo "Deactivated virtual environment"
}

_venv_delete_() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                printf "Delete the virtual environment\n\n\\033[1;32mUsage:\\033[0m \\033[1;36mvenv delete \\033[0;36m[-h|--help]\\033[0m\n\n\\033[1;32mOptions:\\033[0m\n  \\033[1;36m-h, --help\\033[0m  Show help information\n"
                return
                ;;
            -*)
                printf "\033[1;31mError:\033[0m Unknown option: $1\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36mvenv delete \\033[0;36m[-h|--help]\\033[0m\n\n" >&2
                printf "Try 'venv delete --help' for more information.\n" >&2
                return 1
                ;;
            *)
                printf "\033[1;31mError:\033[0m Too many arguments\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36mvenv delete \\033[0;36m[-h|--help]\\033[0m\n\n" >&2
                printf "Try 'venv delete --help' for more information.\n" >&2
                return 1
                ;;
        esac
    done

    # Execute command
    deactivate
    rm -rf .venv && echo "Removed virtual environment"
}

_completions_venv_() {
    local -a array
    local current=$1; shift
    local previous=($@)
    case "${previous[@]}" in
        "venv") array=(
            "init:        Create a new virtual environment"
            "activate:    Activate the virtual environment"
            "deactivate:  Deactivate the virtual environment"
            "delete:      Delete the virtual environment"
            );;
        *) ;;
    esac
    array+=("-h:         Show help information" "--help:     Show help information")
    for elem in "${array[@]}"; do
        if [[ $elem == "$current"* ]]; then echo "$elem"; fi
    done
}

args() {
    setopt localoptions sh_word_split 2>/dev/null || true
    local subcmd="$1"
    if [ $# -gt 0 ]; then shift; fi
    case "$subcmd" in
        -h|--help)
            printf "Test various argument types\n\n\\033[1;32mUsage:\\033[0m \\033[1;36margs \\033[0;36m<subcommand> [-h|--help]\\033[0m\n\n\\033[1;32mCommands:\\033[0m\n  \\033[1;36mtwo       \\033[0m  Exactly two arguments needed\n  \\033[1;36mcomplex1  \\033[0m  At least 1 args, the last is always arg2\n  \\033[1;36mcomplex2  \\033[0m  At least 1 args, the first is always arg1, unless if it's the only one\n  \\033[1;36mval_flags \\033[0m  Optional flags, can be in any order\n  \\033[1;36mbool_flags\\033[0m  Boolean optional flags\n\n\\033[1;32mOptions:\\033[0m\n  \\033[1;36m-h, --help\\033[0m  Show help information\n"
            return
            ;;
        two) _args_two_ "$@";;
        complex1) _args_complex1_ "$@";;
        complex2) _args_complex2_ "$@";;
        val_flags) _args_val_flags_ "$@";;
        bool_flags) _args_bool_flags_ "$@";;
        -*)
            printf "\033[1;31mError:\033[0m Unknown option: $subcmd\n\n" >&2
            printf "\033[1;32mUsage:\033[0m \\033[1;36margs \\033[0;36m<subcommand> [-h|--help]\\033[0m\n\n" >&2
            printf "Try 'args --help' for more information.\n" >&2
            return 1
            ;;
        *)
            printf "\033[1;31mError:\033[0m Unknown subcommand: $subcmd\n\n" >&2
            printf "\033[1;32mUsage:\033[0m \\033[1;36margs \\033[0;36m<subcommand> [-h|--help]\\033[0m\n\n" >&2
            printf "Try 'args --help' for more information.\n" >&2
            return 1
            ;;
    esac
}

_args_two_() {
    arg1=""
    arg2=""
    _pos_count=0

    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                printf "Exactly two arguments needed\n\n\\033[1;32mUsage:\\033[0m \\033[1;36margs two \\033[0;36m<arg1> <arg2> [-h|--help]\\033[0m\n\n\\033[1;32mPositional arguments:\\033[0m\n  \\033[1;36marg1      \\033[0m  First mandatory arg\n  \\033[1;36marg2      \\033[0m  Second mandatory arg\n\n\\033[1;32mOptions:\\033[0m\n  \\033[1;36m-h, --help\\033[0m  Show help information\n"
                return
                ;;
            -*)
                printf "\033[1;31mError:\033[0m Unknown option: $1\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36margs two \\033[0;36m<arg1> <arg2> [-h|--help]\\033[0m\n\n" >&2
                printf "Try 'args two --help' for more information.\n" >&2
                return 1
                ;;
            *)
                case "$_pos_count" in
                    0)
                        arg1="$1"
                        _pos_count=$((_pos_count + 1))
                        shift
                        ;;
                    1)
                        arg2="$1"
                        _pos_count=$((_pos_count + 1))
                        shift
                        ;;
                    *)
                        printf "\033[1;31mError:\033[0m Too many arguments\n\n" >&2
                        printf "\033[1;32mUsage:\033[0m \\033[1;36margs two \\033[0;36m<arg1> <arg2> [-h|--help]\\033[0m\n\n" >&2
                        printf "Try 'args two --help' for more information.\n" >&2
                        return 1
                        ;;
                esac
                ;;
        esac
    done

    if [ -z "$arg1" ]; then
        printf "\033[1;31mError:\033[0m arg1 is required\n\n" >&2
        printf "\033[1;32mUsage:\033[0m \\033[1;36margs two \\033[0;36m<arg1> <arg2> [-h|--help]\\033[0m\n\n" >&2
        printf "Try 'args two --help' for more information.\n" >&2
        return 1
    fi
    if [ -z "$arg2" ]; then
        printf "\033[1;31mError:\033[0m arg2 is required\n\n" >&2
        printf "\033[1;32mUsage:\033[0m \\033[1;36margs two \\033[0;36m<arg1> <arg2> [-h|--help]\\033[0m\n\n" >&2
        printf "Try 'args two --help' for more information.\n" >&2
        return 1
    fi
    # Execute command
    echo "Arg1: [$arg1]"
    echo "Arg2: [$arg2]"
}

_args_complex1_() {
    arg1=""
    arg2=""
    _pos_count=0

    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                printf "At least 1 args, the last is always arg2\n\n\\033[1;32mUsage:\\033[0m \\033[1;36margs complex1 \\033[0;36m[<arg1> ...] <arg2> [-h|--help]\\033[0m\n\n\\033[1;32mPositional arguments:\\033[0m\n  \\033[1;36marg1      \\033[0m  Zero or more\n  \\033[1;36marg2      \\033[0m  Required flag\n\n\\033[1;32mOptions:\\033[0m\n  \\033[1;36m-h, --help\\033[0m  Show help information\n"
                return
                ;;
            -*)
                printf "\033[1;31mError:\033[0m Unknown option: $1\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36margs complex1 \\033[0;36m[<arg1> ...] <arg2> [-h|--help]\\033[0m\n\n" >&2
                printf "Try 'args complex1 --help' for more information.\n" >&2
                return 1
                ;;
            *)
                case "$_pos_count" in
                    0)
                        while [ $# -gt 1 ] && [ "${1#-}" = "$1" ]; do
                            if [ -z "$arg1" ]; then
                                arg1="$1"
                            else
                                arg1="$arg1 $1"
                            fi
                            shift
                        done
                        _pos_count=$((_pos_count + 1))
                        ;;
                    1)
                        arg2="$1"
                        _pos_count=$((_pos_count + 1))
                        shift
                        ;;
                    *)
                        printf "\033[1;31mError:\033[0m Too many arguments\n\n" >&2
                        printf "\033[1;32mUsage:\033[0m \\033[1;36margs complex1 \\033[0;36m[<arg1> ...] <arg2> [-h|--help]\\033[0m\n\n" >&2
                        printf "Try 'args complex1 --help' for more information.\n" >&2
                        return 1
                        ;;
                esac
                ;;
        esac
    done

    if [ -z "$arg2" ]; then
        printf "\033[1;31mError:\033[0m arg2 is required\n\n" >&2
        printf "\033[1;32mUsage:\033[0m \\033[1;36margs complex1 \\033[0;36m[<arg1> ...] <arg2> [-h|--help]\\033[0m\n\n" >&2
        printf "Try 'args complex1 --help' for more information.\n" >&2
        return 1
    fi
    # Execute command
    echo "Arg1: [$arg1]"
    echo "Arg2: [$arg2]"
}

_args_complex2_() {
    arg1=""
    arg2=""
    _pos_count=0

    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                printf "At least 1 args, the first is always arg1, unless if it's the only one\n\n\\033[1;32mUsage:\\033[0m \\033[1;36margs complex2 \\033[0;36m[<arg1>] <arg2> [<arg2> ...] [-h|--help]\\033[0m\n\n\\033[1;32mPositional arguments:\\033[0m\n  \\033[1;36marg1      \\033[0m  zero or one\n  \\033[1;36marg2      \\033[0m  one or more\n\n\\033[1;32mOptions:\\033[0m\n  \\033[1;36m-h, --help\\033[0m  Show help information\n"
                return
                ;;
            -*)
                printf "\033[1;31mError:\033[0m Unknown option: $1\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36margs complex2 \\033[0;36m[<arg1>] <arg2> [<arg2> ...] [-h|--help]\\033[0m\n\n" >&2
                printf "Try 'args complex2 --help' for more information.\n" >&2
                return 1
                ;;
            *)
                case "$_pos_count" in
                    0)
                        if [ $# -gt 1 ]; then
                            arg1="$1"
                            shift
                        fi
                        _pos_count=$((_pos_count + 1))
                        ;;
                    1)
                        while [ $# -gt 0 ] && [ "${1#-}" = "$1" ]; do
                            if [ -z "$arg2" ]; then
                                arg2="$1"
                            else
                                arg2="$arg2 $1"
                            fi
                            shift
                        done
                        _pos_count=$((_pos_count + 1))
                        ;;
                    *)
                        printf "\033[1;31mError:\033[0m Too many arguments\n\n" >&2
                        printf "\033[1;32mUsage:\033[0m \\033[1;36margs complex2 \\033[0;36m[<arg1>] <arg2> [<arg2> ...] [-h|--help]\\033[0m\n\n" >&2
                        printf "Try 'args complex2 --help' for more information.\n" >&2
                        return 1
                        ;;
                esac
                ;;
        esac
    done

    if [ -z "$arg2" ]; then
        printf "\033[1;31mError:\033[0m arg2 is required at least once\n\n" >&2
        printf "\033[1;32mUsage:\033[0m \\033[1;36margs complex2 \\033[0;36m[<arg1>] <arg2> [<arg2> ...] [-h|--help]\\033[0m\n\n" >&2
        printf "Try 'args complex2 --help' for more information.\n" >&2
        return 1
    fi
    # Execute command
    echo "Arg1: [$arg1]"
    echo "Arg2: [$arg2]"
}

_args_val_flags_() {
    str_flag=""""
    n="42"
    empty_flag=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                printf "Optional flags, can be in any order\n\n\\033[1;32mUsage:\\033[0m \\033[1;36margs val_flags \\033[0;36m[--str_flag <str_flag>] [-n <n>] [--empty_flag <empty_flag>] [-h|--help]\\033[0m\n\n\\033[1;32mOptions:\\033[0m\n  \\033[1;36m--str_flag  \\033[0m  Long name flag\n  \\033[1;36m-n          \\033[0m  Short name flag\n  \\033[1;36m--empty_flag\\033[0m  Default is empty\n  \\033[1;36m-h, --help  \\033[0m  Show help information\n"
                return
                ;;
            --str_flag)
                if [ $# -lt 2 ]; then
                    printf "\033[1;31mError:\033[0m --str_flag requires a value\n\n" >&2
                    printf "\033[1;32mUsage:\033[0m \\033[1;36margs val_flags \\033[0;36m[--str_flag <str_flag>] [-n <n>] [--empty_flag <empty_flag>] [-h|--help]\\033[0m\n\n" >&2
                    printf "Try 'args val_flags --help' for more information.\n" >&2
                    return 1
                fi
                str_flag="$2"
                shift 2
                ;;
            -n)
                if [ $# -lt 2 ]; then
                    printf "\033[1;31mError:\033[0m -n requires a value\n\n" >&2
                    printf "\033[1;32mUsage:\033[0m \\033[1;36margs val_flags \\033[0;36m[--str_flag <str_flag>] [-n <n>] [--empty_flag <empty_flag>] [-h|--help]\\033[0m\n\n" >&2
                    printf "Try 'args val_flags --help' for more information.\n" >&2
                    return 1
                fi
                n="$2"
                shift 2
                ;;
            --empty_flag)
                if [ $# -lt 2 ]; then
                    printf "\033[1;31mError:\033[0m --empty_flag requires a value\n\n" >&2
                    printf "\033[1;32mUsage:\033[0m \\033[1;36margs val_flags \\033[0;36m[--str_flag <str_flag>] [-n <n>] [--empty_flag <empty_flag>] [-h|--help]\\033[0m\n\n" >&2
                    printf "Try 'args val_flags --help' for more information.\n" >&2
                    return 1
                fi
                empty_flag="$2"
                shift 2
                ;;
            -*)
                printf "\033[1;31mError:\033[0m Unknown option: $1\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36margs val_flags \\033[0;36m[--str_flag <str_flag>] [-n <n>] [--empty_flag <empty_flag>] [-h|--help]\\033[0m\n\n" >&2
                printf "Try 'args val_flags --help' for more information.\n" >&2
                return 1
                ;;
            *)
                printf "\033[1;31mError:\033[0m Too many arguments\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36margs val_flags \\033[0;36m[--str_flag <str_flag>] [-n <n>] [--empty_flag <empty_flag>] [-h|--help]\\033[0m\n\n" >&2
                printf "Try 'args val_flags --help' for more information.\n" >&2
                return 1
                ;;
        esac
    done

    # Execute command
    echo "\" --str_flag: [$str_flag] default is \\\"\\\"\""
    echo "\" --n: [$n] default is 42\""
    echo "\" --empty_flag: [$empty_flag], default is \\\"\\\"\""
    if "[" $n -lt 42 "]"
    then
    echo " -n flag is smaller than 42 (n == $n)"
    elif "[" $n -gt 42 "]"
    then
    echo " -n flag is greater than 42 (n == $n)"
    elif "[" $n -eq 42 "]"
    then
    echo " -n flag is equal to 42"
    fi
}

_args_bool_flags_() {
    a=false
    b=true
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                printf "Boolean optional flags\n\n\\033[1;32mUsage:\\033[0m \\033[1;36margs bool_flags \\033[0;36m[-a] [-b] [-h|--help]\\033[0m\n\n\\033[1;32mOptions:\\033[0m\n  \\033[1;36m-a        \\033[0m  Set to make it true\n  \\033[1;36m-b        \\033[0m  Set to make it false\n  \\033[1;36m-h, --help\\033[0m  Show help information\n"
                return
                ;;
            -a)
                a=true
                shift
                ;;
            -b)
                b=false
                shift
                ;;
            -*)
                printf "\033[1;31mError:\033[0m Unknown option: $1\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36margs bool_flags \\033[0;36m[-a] [-b] [-h|--help]\\033[0m\n\n" >&2
                printf "Try 'args bool_flags --help' for more information.\n" >&2
                return 1
                ;;
            *)
                printf "\033[1;31mError:\033[0m Too many arguments\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36margs bool_flags \\033[0;36m[-a] [-b] [-h|--help]\\033[0m\n\n" >&2
                printf "Try 'args bool_flags --help' for more information.\n" >&2
                return 1
                ;;
        esac
    done

    # Execute command
    if $a
    then
    echo " -a present (a == true)"
    else
    echo " -a absent (a == false)"
    fi
    if $b
    then
    echo " -b is absent (b == true)"
    else
    echo " -b present (b == false)"
    fi
}

_completions_args_() {
    local -a array
    local current=$1; shift
    local previous=($@)
    case "${previous[@]}" in
        "args") array=(
            "two:         Exactly two arguments needed"
            "complex1:    At least 1 args, the last is always arg2"
            "complex2:    At least 1 args, the first is always arg1, unless if it's the only one"
            "val_flags:   Optional flags, can be in any order"
            "bool_flags:  Boolean optional flags"
            );;
        "args val_flags") array=(
            "--str_flag:    <str_flag> Long name flag"
            "-n:            <n> Short name flag"
            "--empty_flag:  <empty_flag> Default is empty"
            );;
        "args bool_flags") array=(
            "-a:          Set to make it true"
            "-b:          Set to make it false"
            );;
        *) ;;
    esac
    array+=("-h:         Show help information" "--help:     Show help information")
    for elem in "${array[@]}"; do
        if [[ $elem == "$current"* ]]; then echo "$elem"; fi
    done
}

early_ret_on_error() {
    setopt localoptions sh_word_split 2>/dev/null || true
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                printf "\\033[1;32mUsage:\\033[0m \\033[1;36mearly_ret_on_error \\033[0;36m[-h|--help]\\033[0m\n\n\\033[1;32mOptions:\\033[0m\n  \\033[1;36m-h, --help\\033[0m  Show help information\n"
                return
                ;;
            -*)
                printf "\033[1;31mError:\033[0m Unknown option: $1\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36mearly_ret_on_error \\033[0;36m[-h|--help]\\033[0m\n\n" >&2
                printf "Try 'early_ret_on_error --help' for more information.\n" >&2
                return 1
                ;;
            *)
                printf "\033[1;31mError:\033[0m Too many arguments\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36mearly_ret_on_error \\033[0;36m[-h|--help]\\033[0m\n\n" >&2
                printf "Try 'early_ret_on_error --help' for more information.\n" >&2
                return 1
                ;;
        esac
    done

    # Execute command
    echo "This command has a & prefix" || return $?
    $(exit -1) || return $?
    echo "This command will not run if the previous command fails" || return $?
}

_completions_early_ret_on_error_() {
    local -a array
    local current=$1; shift
    local previous=($@)
    case "${previous[@]}" in
        *) ;;
    esac
    array+=("-h:         Show help information" "--help:     Show help information")
    for elem in "${array[@]}"; do
        if [[ $elem == "$current"* ]]; then echo "$elem"; fi
    done
}

early_ret_on_ok() {
    setopt localoptions sh_word_split 2>/dev/null || true
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                printf "\\033[1;32mUsage:\\033[0m \\033[1;36mearly_ret_on_ok \\033[0;36m[-h|--help]\\033[0m\n\n\\033[1;32mOptions:\\033[0m\n  \\033[1;36m-h, --help\\033[0m  Show help information\n"
                return
                ;;
            -*)
                printf "\033[1;31mError:\033[0m Unknown option: $1\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36mearly_ret_on_ok \\033[0;36m[-h|--help]\\033[0m\n\n" >&2
                printf "Try 'early_ret_on_ok --help' for more information.\n" >&2
                return 1
                ;;
            *)
                printf "\033[1;31mError:\033[0m Too many arguments\n\n" >&2
                printf "\033[1;32mUsage:\033[0m \\033[1;36mearly_ret_on_ok \\033[0;36m[-h|--help]\\033[0m\n\n" >&2
                printf "Try 'early_ret_on_ok --help' for more information.\n" >&2
                return 1
                ;;
        esac
    done

    # Execute command
    $(exit -1) && return 0
    echo "This command has a | prefix" && return 0
    echo "This command will not run if the previous command succeeds" && return 0
}

_completions_early_ret_on_ok_() {
    local -a array
    local current=$1; shift
    local previous=($@)
    case "${previous[@]}" in
        *) ;;
    esac
    array+=("-h:         Show help information" "--help:     Show help information")
    for elem in "${array[@]}"; do
        if [[ $elem == "$current"* ]]; then echo "$elem"; fi
    done
}

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

if [ -n "${ZSH_VERSION:-}" ]; then autoload -Uz compinit; compinit
    compdef _complete_zsh venv
    compdef _complete_zsh args
    compdef _complete_zsh early_ret_on_error
    compdef _complete_zsh early_ret_on_ok
elif [ -n "${BASH_VERSION:-}" ]; then [ "${BASH_VERSINFO[0]}" -lt 4 ] && no_sort="" || no_sort="-o nosort"
    complete -o default $no_sort -F _complete_bash venv
    complete -o default $no_sort -F _complete_bash args
    complete -o default $no_sort -F _complete_bash early_ret_on_error
    complete -o default $no_sort -F _complete_bash early_ret_on_ok
fi
