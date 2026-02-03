Name:           garchomp
Version:        0.1.0
Release:        1%{?dist}
Summary:        Wayland compositor for the gar desktop suite

License:        MIT
URL:            https://github.com/gardesk/garchomp
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  rust >= 1.75
BuildRequires:  cargo

# Disable debug package
%global debug_package %{nil}

%description
Garchomp is a Wayland compositor built in Rust. Part of the gardesk desktop
environment suite.

%prep
# Pre-built from monorepo

%build
# Pre-built from monorepo

%install
mkdir -p %{buildroot}%{_bindir}
install -Dm755 %{_sourcedir}/garchomp %{buildroot}%{_bindir}/garchomp
install -Dm755 %{_sourcedir}/garchompctl %{buildroot}%{_bindir}/garchompctl

%files
%{_bindir}/garchomp
%{_bindir}/garchompctl

%changelog
* Mon Feb 03 2026 mfw <espadonne@outlook.com> - 0.1.0-1
- Initial RPM release of garchomp
- Wayland compositor for gardesk desktop suite
