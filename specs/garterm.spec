Name:           garterm
Version:        0.1.0
Release:        1%{?dist}
Summary:        Terminal emulator for the gar desktop suite

License:        MIT
URL:            https://github.com/gardesk/garterm
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  rust >= 1.75
BuildRequires:  cargo

# Disable debug package
%global debug_package %{nil}

%description
Garterm is a terminal emulator for X11 built in Rust. Features GPU-accelerated
rendering, tabs, and integration with gardesk. Part of the gardesk desktop
environment suite.

%prep
# Pre-built from monorepo

%build
# Pre-built from monorepo

%install
mkdir -p %{buildroot}%{_bindir}
install -Dm755 %{_sourcedir}/garterm %{buildroot}%{_bindir}/garterm
install -Dm755 %{_sourcedir}/gartermctl %{buildroot}%{_bindir}/gartermctl

%files
%{_bindir}/garterm
%{_bindir}/gartermctl

%changelog
* Tue Jan 21 2026 mfw <espadonne@outlook.com> - 0.1.0-1
- Initial RPM release of garterm
- Terminal emulator for gardesk desktop suite
