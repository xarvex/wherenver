use std::path::PathBuf;

use clap::{Parser, Subcommand};

use crate::shell::Shell;

#[derive(Debug, Parser)]
#[command(author, version, about)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Command,
    #[arg(long, hide = true)]
    pub shell: Option<Shell>,
}

#[derive(Debug, Subcommand)]
pub enum Command {
    Hook { shell: Shell },
    At { path: PathBuf },
    Exit,
}
