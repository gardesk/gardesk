Name:           garview
Version:        0.3.1
Release:        1%{?dist}
Summary:        Document viewer for the gar desktop suite

License:        MIT
URL:            https://github.com/gardesk/garview
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  rust >= 1.75
BuildRequires:  cargo

# Disable debug package
%global debug_package %{nil}

%description
Garview is a document viewer for X11 built in Rust. Supports PDF, images,
and comic book archives. Part of the gardesk desktop environment suite.

%prep
# Pre-built from monorepo

%build
# Pre-built from monorepo

%install
mkdir -p %{buildroot}%{_bindir}
install -Dm755 %{_sourcedir}/garview %{buildroot}%{_bindir}/garview
install -Dm755 %{_sourcedir}/garviewctl %{buildroot}%{_bindir}/garviewctl

%files
%{_bindir}/garview
%{_bindir}/garviewctl

%changelog
* Sat Feb 08 2026 mfw <espadonne@outlook.com> - 0.3.1-1
- Version bump to 0.3.1

* Sat Feb 08 2026 mfw <espadonne@outlook.com> - 0.3.0-1
- Version bump to 0.3.0
- Annotation multi-select support

* Sat Feb 08 2026 mfw <espadonne@outlook.com> - 0.1.1-1
- Version bump to 0.1.1
- Fix aarch64 build

* Sat Feb 08 2026 mfw <espadonne@outlook.com> - 0.1.0-1
- Initial RPM release of garview
- Document viewer for gardesk desktop suite
