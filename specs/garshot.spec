Name:           garshot
Version:        0.2.1
Release:        1%{?dist}
Summary:        Screenshot utility for the gar desktop suite

License:        MIT
URL:            https://github.com/gardesk/garshot
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  rust >= 1.75
BuildRequires:  cargo
BuildRequires:  libxcb-devel
BuildRequires:  cairo-devel
BuildRequires:  lua-devel

# Disable debug package
%global debug_package %{nil}

%description
Garshot is a screenshot utility for X11 built in Rust. Features full-screen,
region, and monitor capture with interactive selection overlay. Supports PNG,
JPEG, and WebP output formats. Part of the gardesk desktop environment suite.

%prep
# Pre-built from monorepo

%build
# Pre-built from monorepo

%install
mkdir -p %{buildroot}%{_bindir}
install -Dm755 %{_sourcedir}/garshot %{buildroot}%{_bindir}/garshot
install -Dm755 %{_sourcedir}/garshotctl %{buildroot}%{_bindir}/garshotctl

%files
%{_bindir}/garshot
%{_bindir}/garshotctl

%changelog
* Fri Jan 17 2026 mfw <espadonne@outlook.com> - 0.1.0-1
- Initial RPM release of garshot
- Screenshot utility with region selection
- Part of gardesk desktop suite
