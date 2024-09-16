use std::{
    io::{self, Write},
    os::unix::process::CommandExt,
    process,
};

use anyhow::Result;
use clap::Parser;
use cli::{Cli, Command};

mod cli;
mod shell;

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Command::Hook => println!("{}", cli.shell.hook()),
        Command::Export { ref path } => {
            print!("{}", cli.shell.export());
            io::stdout().flush()?;

            return Err(process::Command::new("direnv")
                .args(["export", &cli.shell.to_string()])
                .current_dir(path)
                .exec()
                .into());
        }
        Command::Exit => println!("{}", cli.shell.exit()),
    }

    Ok(())
}
