Name:           gargears
Version:        0.1.0
Release:        1%{?dist}
Summary:        Settings application for the gar desktop suite

License:        MIT
URL:            https://github.com/gardesk/gargears
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  rust >= 1.75
BuildRequires:  cargo

# Disable debug package
%global debug_package %{nil}

%description
Gargears is a settings and configuration application for the gardesk desktop
environment suite. Provides a graphical interface for managing system and
desktop settings.

%prep
# Pre-built from monorepo

%build
# Pre-built from monorepo

%install
mkdir -p %{buildroot}%{_bindir}
install -Dm755 %{_sourcedir}/gargears %{buildroot}%{_bindir}/gargears
install -Dm755 %{_sourcedir}/gargearsctl %{buildroot}%{_bindir}/gargearsctl

%files
%{_bindir}/gargears
%{_bindir}/gargearsctl

%changelog
* Mon Feb 03 2026 mfw <espadonne@outlook.com> - 0.1.0-1
- Initial RPM release of gargears
- Settings application for gardesk desktop suite
