use anyhow::{Context, Result};
use garcard_ipc::socket_path;
use std::path::PathBuf;

/// Runtime configuration for the garcard daemon.
#[derive(Debug, Clone)]
pub struct Config {
    pub socket_path: PathBuf,
    pub socket_mode: u32,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            socket_path: socket_path(),
            socket_mode: 0o600,
        }
    }
}

impl Config {
    pub fn load() -> Result<Self> {
        let mut cfg = Self::default();

        if let Some(raw_mode) = std::env::var_os("GARCARD_SOCKET_MODE") {
            let parsed = parse_octal_mode(&raw_mode.to_string_lossy())
                .with_context(|| "Invalid GARCARD_SOCKET_MODE (expected octal, e.g. 600)")?;
            cfg.socket_mode = parsed;
        }

        Ok(cfg)
    }
}

fn parse_octal_mode(raw: &str) -> Result<u32> {
    let trimmed = raw.trim();
    let mode = u32::from_str_radix(trimmed, 8)
        .with_context(|| format!("failed to parse mode value: {trimmed}"))?;
    Ok(mode)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_mode_octal() {
        let mode = parse_octal_mode("640").expect("valid mode");
        assert_eq!(mode, 0o640);
    }

    #[test]
    fn parse_mode_rejects_invalid() {
        let err = parse_octal_mode("x00").expect_err("should fail");
        assert!(err.to_string().contains("failed to parse mode value"));
    }
}
