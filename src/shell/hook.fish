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
    switch $argv[1]
        case at
            "@WHERENVER_REPLACE_BIN@" --shell fish export $argv[2] | source
        case exit
            "@WHERENVER_REPLACE_BIN@" --shell fish exit | source
        case '*'
            "@WHERENVER_REPLACE_BIN@" --shell fish $argv
    end
end
