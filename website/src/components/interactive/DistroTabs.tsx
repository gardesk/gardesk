import { useState } from 'react';

interface Distro {
  id: string;
  name: string;
  commands: string[];
  available: boolean;
}

const distros: Distro[] = [
  {
    id: 'universal',
    name: 'Universal',
    commands: ['curl -fsSL https://gar.musicsian.com/install.sh | bash'],
    available: true
  },
  {
    id: 'fedora',
    name: 'Fedora/RHEL',
    commands: [
      '# Coming soon',
      'sudo dnf copr enable gardesk/gardesk',
      'sudo dnf install gardesk'
    ],
    available: false
  },
  {
    id: 'debian',
    name: 'Debian/Ubuntu',
    commands: [
      '# Coming soon',
      'sudo add-apt-repository ppa:gardesk/gardesk',
      'sudo apt update && sudo apt install gardesk'
    ],
    available: false
  },
  {
    id: 'arch',
    name: 'Arch Linux',
    commands: [
      '# Coming soon (AUR)',
      'yay -S gardesk'
    ],
    available: false
  },
  {
    id: 'opensuse',
    name: 'openSUSE',
    commands: [
      '# Coming soon',
      'sudo zypper install gardesk'
    ],
    available: false
  }
];

export default function DistroTabs() {
  const [activeDistro, setActiveDistro] = useState(distros[0]);
  const [copied, setCopied] = useState(false);

  const copyCommands = async function() {
    const text = activeDistro.commands
      .filter(function(cmd) { return !cmd.startsWith('#') })
      .join('\n');

    try {
      await navigator.clipboard.writeText(text);
      setCopied(true);
      setTimeout(function() { setCopied(false) }, 2000);
    } catch (err) {
      console.error('Failed to copy:', err);
    }
  };

  return (
    <div className="distro-tabs w-full max-w-2xl mx-auto">
      {/* Tab buttons */}
      <div className="flex flex-wrap gap-2 mb-4" role="tablist">
        {distros.map(function(distro) {
          return (
            <button
              key={distro.id}
              role="tab"
              aria-selected={activeDistro.id === distro.id}
              onClick={function() { setActiveDistro(distro) }}
              className={`
                px-4 py-2 rounded-lg text-sm font-medium transition-all duration-200
                ${activeDistro.id === distro.id
                  ? 'bg-gar-accent-blue text-gar-bg-deep'
                  : 'bg-gar-bg-secondary text-gar-text-secondary hover:bg-gar-bg-tertiary hover:text-gar-text-primary'
                }
                ${!distro.available && distro.id !== 'universal' ? 'opacity-60' : ''}
              `}
            >
              {distro.name}
              {!distro.available && distro.id !== 'universal' && (
                <span className="ml-1.5 text-xs opacity-75">(soon)</span>
              )}
            </button>
          )
        })}
      </div>

      {/* Command panel */}
      <div
        role="tabpanel"
        className="rounded-lg overflow-hidden border border-gar-text-muted/20"
      >
        {/* Terminal header */}
        <div className="flex items-center justify-between px-4 py-2.5 bg-gar-bg-secondary border-b border-gar-text-muted/20">
          <div className="flex items-center gap-2">
            <div className="flex gap-1.5">
              <span className="w-3 h-3 rounded-full bg-gar-accent-red"></span>
              <span className="w-3 h-3 rounded-full bg-gar-accent-yellow"></span>
              <span className="w-3 h-3 rounded-full bg-gar-accent-green"></span>
            </div>
            <span className="text-gar-text-secondary text-sm font-mono ml-2">bash</span>
          </div>
          <button
            onClick={copyCommands}
            className="p-1.5 rounded hover:bg-gar-bg-tertiary transition-colors text-gar-text-secondary hover:text-gar-text-primary"
            aria-label="Copy commands"
          >
            {copied ? (
              <svg className="w-5 h-5 text-gar-accent-green" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
              </svg>
            ) : (
              <svg className="w-5 h-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
              </svg>
            )}
          </button>
        </div>

        {/* Terminal body */}
        <div className="bg-gar-bg-primary p-4 font-mono text-sm">
          {activeDistro.commands.map(function(cmd, i) {
            return (
              <div key={i} className="mb-1 last:mb-0">
                {cmd.startsWith('#') ? (
                  <span className="text-gar-text-muted">{cmd}</span>
                ) : (
                  <div className="flex gap-2">
                    <span className="text-gar-accent-green select-none">$</span>
                    <span className="text-gar-text-primary">{cmd}</span>
                  </div>
                )}
              </div>
            )
          })}
        </div>
      </div>
    </div>
  );
}
