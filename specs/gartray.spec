Name:           gartray
Version:        0.1.0
Release:        1%{?dist}
Summary:        System tray for the gar desktop suite

License:        MIT
URL:            https://github.com/gardesk/gartray
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  rust >= 1.75
BuildRequires:  cargo

# Disable debug package
%global debug_package %{nil}

%description
Gartray is a system tray implementation for X11 built in Rust. Supports SNI
and XEmbed protocols for tray icons. Part of the gardesk desktop environment
suite.

%prep
# Pre-built from monorepo

%build
# Pre-built from monorepo

%install
mkdir -p %{buildroot}%{_bindir}
install -Dm755 %{_sourcedir}/gartray %{buildroot}%{_bindir}/gartray
install -Dm755 %{_sourcedir}/gartrayctl %{buildroot}%{_bindir}/gartrayctl

%files
%{_bindir}/gartray
%{_bindir}/gartrayctl

%changelog
* Tue Jan 21 2026 mfw <espadonne@outlook.com> - 0.1.0-1
- Initial RPM release of gartray
- System tray for gardesk desktop suite
