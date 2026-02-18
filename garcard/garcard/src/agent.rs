use anyhow::Result;

/// Backend interface for Polkit agent integration.
pub trait AuthAgentBackend {
    fn name(&self) -> &'static str;
    fn register(&self) -> Result<()>;
    fn unregister(&self) -> Result<()>;
}

/// Placeholder backend used during Sprint 01 scaffolding.
#[derive(Default)]
pub struct StubPolkitAgent;

impl AuthAgentBackend for StubPolkitAgent {
    fn name(&self) -> &'static str {
        "stub-polkit-agent"
    }

    fn register(&self) -> Result<()> {
        tracing::info!("Registered stub auth-agent backend");
        Ok(())
    }

    fn unregister(&self) -> Result<()> {
        tracing::info!("Unregistered stub auth-agent backend");
        Ok(())
    }
}
