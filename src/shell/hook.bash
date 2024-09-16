_wherenver_hook() {
    if [ -z "${__wherenver_active:-}" ]; then
        _direnv_hook
    fi
}

PROMPT_COMMAND="$(
    sed 's/\b_direnv_hook\b/_wherenver_hook/' <<EOF
${PROMPT_COMMAND}
EOF
)"

wherenver() {
    case "${1}" in
    at)
        eval "$("@WHERENVER_REPLACE_BIN@" --shell bash export "${2}")"
        ;;
    exit)
        eval "$("@WHERENVER_REPLACE_BIN@" --shell bash exit)"
        ;;
    *)
        "@WHERENVER_REPLACE_BIN@" --shell bash "${@}"
        ;;
    esac
}
