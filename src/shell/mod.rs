use std::env;

use clap::ValueEnum;
use strum::Display;

#[derive(Clone, Debug, Display, ValueEnum)]
#[strum(serialize_all = "lowercase")]
pub enum Shell {
    Bash,
    Fish,
}

impl Shell {
    pub fn hook(&self) -> String {
        let bin = env::args().nth(0).unwrap_or("wherenver".to_string());

        match self {
            Shell::Bash => include_str!("hook.bash"),
            Shell::Fish => include_str!("hook.fish"),
        }
        .replace("@WHERENVER_REPLACE_BIN@", &bin)
    }
    pub fn export(&self) -> &str {
        match self {
            Shell::Bash => "__wherenver_active=0;",
            Shell::Fish => "set -g __wherenver_active 0;",
        }
    }
    pub fn exit(&self) -> &str {
        match self {
            Shell::Bash => "unset __wherenver_active;",
            Shell::Fish => "set -e __wherenver_active;",
        }
    }
}
