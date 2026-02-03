Name:           gartop
Version:        0.1.0
Release:        1%{?dist}
Summary:        System monitor for the gar desktop suite

License:        MIT
URL:            https://github.com/gardesk/gartop
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  rust >= 1.75
BuildRequires:  cargo

# Disable debug package
%global debug_package %{nil}

%description
Gartop is a system monitor for the gardesk desktop environment suite.
Displays system resource usage including CPU, memory, and processes.

%prep
# Pre-built from monorepo

%build
# Pre-built from monorepo

%install
mkdir -p %{buildroot}%{_bindir}
install -Dm755 %{_sourcedir}/gartop %{buildroot}%{_bindir}/gartop
install -Dm755 %{_sourcedir}/gartopctl %{buildroot}%{_bindir}/gartopctl

%files
%{_bindir}/gartop
%{_bindir}/gartopctl

%changelog
* Mon Feb 03 2026 mfw <espadonne@outlook.com> - 0.1.0-1
- Initial RPM release of gartop
- System monitor for gardesk desktop suite
