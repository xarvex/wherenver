use std::{
    io::{self, Write},
    os::unix::process::CommandExt,
    process::{self, ExitCode},
};

use anyhow::Result;
use clap::{CommandFactory, Parser};
use cli::{Cli, Command};

mod cli;
mod shell;

fn main() -> Result<ExitCode> {
    let cli = Cli::parse();

    let shell = cli.shell.ok_or_else(|| {
        Cli::command().error(
            clap::error::ErrorKind::MissingRequiredArgument,
            "
Subcommand was called without shell argument.
This should have been provided by the shell hook function. Is it active?
",
        )
    });

    match cli.command {
        Command::TestEval(raw) => {
            return Ok(match Cli::try_parse_from(raw) {
                Ok(args) => match args.command {
                    Command::At { .. } | Command::Exit => ExitCode::SUCCESS,
                    _ => ExitCode::FAILURE,
                },
                Err(_) => ExitCode::FAILURE,
            });
        }
        Command::Hook { shell } => println!("{}", shell.hook()),
        Command::At { path } => match shell {
            Ok(shell) => {
                print!("{}", shell.export());
                io::stdout().flush()?;

                return Err(process::Command::new("direnv")
                    .args(["export", &shell.to_string()])
                    .current_dir(path)
                    .exec()
                    .into());
            }
            Err(e) => {
                eprintln!("{}", e);

                return Ok(ExitCode::FAILURE);
            }
        },
        Command::Exit => match shell {
            Ok(shell) => println!("{}", shell.exit()),
            Err(e) => {
                eprintln!("{}", e);

                return Ok(ExitCode::FAILURE);
            }
        },
    }

    Ok(ExitCode::default())
}
