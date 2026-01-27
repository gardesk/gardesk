Name:           garfield
Version:        0.1.0
Release:        1%{?dist}
Summary:        File manager for the gar desktop suite

License:        MIT
URL:            https://github.com/gardesk/garfield
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  rust >= 1.75
BuildRequires:  cargo

# Disable debug package
%global debug_package %{nil}

%description
Garfield is a file manager for X11 built in Rust. Features dual-pane view,
keyboard navigation, and integration with gardesk. Part of the gardesk
desktop environment suite.

%prep
# Pre-built from monorepo

%build
# Pre-built from monorepo

%install
mkdir -p %{buildroot}%{_bindir}
install -Dm755 %{_sourcedir}/garfield %{buildroot}%{_bindir}/garfield
install -Dm755 %{_sourcedir}/garfieldctl %{buildroot}%{_bindir}/garfieldctl

%files
%{_bindir}/garfield
%{_bindir}/garfieldctl

%changelog
* Tue Jan 21 2026 mfw <espadonne@outlook.com> - 0.1.0-1
- Initial RPM release of garfield
- File manager for gardesk desktop suite
