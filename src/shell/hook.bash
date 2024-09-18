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
    if [ -z "${*}" ]; then
        "@WHERENVER_REPLACE_BIN@"
    elif "@WHERENVER_REPLACE_BIN@" test-eval "${@}"; then
        eval "$("@WHERENVER_REPLACE_BIN@" --shell bash "${@}")"
    else
        "@WHERENVER_REPLACE_BIN@" --shell bash "${@}"
    fi
}
