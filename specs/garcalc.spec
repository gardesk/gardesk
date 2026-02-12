Name:           garcalc
Version:        0.1.0
Release:        1%{?dist}
Summary:        Calculator suite for the gar desktop environment

License:        MIT
URL:            https://github.com/gardesk/garcalc
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  rust >= 1.75
BuildRequires:  cargo
BuildRequires:  libxcb-devel
BuildRequires:  cairo-devel
BuildRequires:  pango-devel

# Disable debug package
%global debug_package %{nil}

%description
Garcalc is a TI-Nspire-like calculator suite for X11 built in Rust.
Includes a graphical calculator, daemon control utility, and standalone
CAS CLI. Part of the gardesk desktop environment suite.

%prep
# Pre-built from monorepo

%build
# Pre-built from monorepo

%install
mkdir -p %{buildroot}%{_bindir}
install -Dm755 %{_sourcedir}/garcalc %{buildroot}%{_bindir}/garcalc
install -Dm755 %{_sourcedir}/garcalcctl %{buildroot}%{_bindir}/garcalcctl
install -Dm755 %{_sourcedir}/garcas %{buildroot}%{_bindir}/garcas

%files
%{_bindir}/garcalc
%{_bindir}/garcalcctl
%{_bindir}/garcas

%changelog
* Thu Feb 12 2026 mfw <espadonne@outlook.com> - 0.1.0-1
- Initial RPM release of garcalc
- TI-Nspire-like calculator with CAS and graphing support
