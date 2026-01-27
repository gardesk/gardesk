Name:           garlaunch
Version:        0.3.0
Release:        1%{?dist}
Summary:        Application launcher for the gar desktop suite

License:        MIT
URL:            https://github.com/gardesk/garlaunch
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  rust >= 1.75
BuildRequires:  cargo
BuildRequires:  libxcb-devel
BuildRequires:  cairo-devel
BuildRequires:  pango-devel

# Disable debug package
%global debug_package %{nil}

%description
Garlaunch is a rofi-like application launcher for X11 built in Rust. Features
fuzzy search, .desktop file parsing, and a sleek UI. Part of the gardesk
desktop environment suite.

%prep
# Pre-built from monorepo

%build
# Pre-built from monorepo

%install
mkdir -p %{buildroot}%{_bindir}
install -Dm755 %{_sourcedir}/garlaunch %{buildroot}%{_bindir}/garlaunch
install -Dm755 %{_sourcedir}/garlaunchctl %{buildroot}%{_bindir}/garlaunchctl

%files
%{_bindir}/garlaunch
%{_bindir}/garlaunchctl

%changelog
* Fri Jan 17 2026 mfw <espadonne@outlook.com> - 0.2.0-1
- Version 0.2.0 release

* Fri Jan 17 2025 mfw <espadonne@outlook.com> - 0.1.0-1
- Initial RPM release of garlaunch
- Application launcher with fuzzy search
- Part of gardesk desktop suite
