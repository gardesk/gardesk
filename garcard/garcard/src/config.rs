use anyhow::{Context, Result};
use garcard_ipc::socket_path;
use serde::Deserialize;
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
        cfg.apply_file_config()?;

        if let Some(raw_mode) = std::env::var_os("GARCARD_SOCKET_MODE") {
            let parsed = parse_octal_mode(&raw_mode.to_string_lossy())
                .with_context(|| "Invalid GARCARD_SOCKET_MODE (expected octal, e.g. 600)")?;
            cfg.socket_mode = parsed;
        }

        if let Some(raw_socket) = std::env::var_os("GARCARD_SOCKET") {
            cfg.socket_path = PathBuf::from(raw_socket);
        }

        Ok(cfg)
    }

    fn apply_file_config(&mut self) -> Result<()> {
        let Some(path) = config_path() else {
            return Ok(());
        };
        if !path.exists() {
            return Ok(());
        }

        let content = std::fs::read_to_string(&path)
            .with_context(|| format!("Failed to read config file {}", path.display()))?;
        let file_cfg: FileConfig = toml::from_str(&content)
            .with_context(|| format!("Failed to parse config file {}", path.display()))?;

        if let Some(socket_path) = file_cfg.socket_path {
            self.socket_path = PathBuf::from(socket_path);
        }
        if let Some(socket_mode) = file_cfg.socket_mode {
            self.socket_mode = parse_octal_mode(&socket_mode)
                .with_context(|| "Invalid socket_mode in config file (expected octal)")?;
        }

        Ok(())
    }
}

#[derive(Debug, Clone, Deserialize, Default)]
#[serde(default)]
struct FileConfig {
    socket_path: Option<String>,
    socket_mode: Option<String>,
}

fn config_path() -> Option<PathBuf> {
    if let Some(explicit) = std::env::var_os("GARCARD_CONFIG") {
        return Some(PathBuf::from(explicit));
    }

    dirs::config_dir().map(|base| base.join("garcard/config.toml"))
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

    #[test]
    fn parse_file_config_values() {
        let parsed: FileConfig = toml::from_str(
            r#"
socket_path = "/tmp/custom-garcard.sock"
socket_mode = "640"
"#,
        )
        .expect("parse file config");

        assert_eq!(
            parsed.socket_path.as_deref(),
            Some("/tmp/custom-garcard.sock")
        );
        assert_eq!(parsed.socket_mode.as_deref(), Some("640"));
    }
}
