use std::path::PathBuf;

use clap::{Parser, Subcommand};

use crate::shell::Shell;

#[derive(Debug, Parser)]
#[command(author, version, about)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Command,
    #[arg(long)]
    pub shell: Shell,
}

#[derive(Debug, Subcommand)]
pub enum Command {
    Hook,
    Export { path: PathBuf },
    Exit,
}
