functions -c __direnv_export_eval __wherenver_tmp_direnv_export_eval
functions -e __direnv_export_eval

functions -c __wherenver_tmp_direnv_export_eval __direnv_export_eval
functions -e __wherenver_tmp_direnv_export_eval

function __wherenver_export_eval --on-event fish_prompt
    if not set -q __wherenver_active
        __direnv_export_eval
    end
end

function wherenver
    if test -z "$argv"
        "@WHERENVER_REPLACE_BIN@"
    else if "@WHERENVER_REPLACE_BIN@" test-eval $argv
        "@WHERENVER_REPLACE_BIN@" --shell fish $argv | source
    else
        "@WHERENVER_REPLACE_BIN@" --shell fish $argv
    end
end
