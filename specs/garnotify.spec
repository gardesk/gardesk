Name:           garnotify
Version:        0.1.1
Release:        1%{?dist}
Summary:        Notification daemon for the gar desktop suite

License:        MIT
URL:            https://github.com/gardesk/garnotify
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  rust >= 1.75
BuildRequires:  cargo

# Disable debug package
%global debug_package %{nil}

%description
Garnotify is a notification daemon for X11 built in Rust. Implements the
freedesktop.org notification specification. Part of the gardesk desktop
environment suite.

%prep
# Pre-built from monorepo

%build
# Pre-built from monorepo

%install
mkdir -p %{buildroot}%{_bindir}
install -Dm755 %{_sourcedir}/garnotify %{buildroot}%{_bindir}/garnotify
install -Dm755 %{_sourcedir}/garnotifyctl %{buildroot}%{_bindir}/garnotifyctl

%files
%{_bindir}/garnotify
%{_bindir}/garnotifyctl

%changelog
* Mon Jan 27 2026 mfw <espadonne@outlook.com> - 0.1.1-1
- Version bump to 0.1.1
- Bug fixes and improvements

* Tue Jan 21 2026 mfw <espadonne@outlook.com> - 0.1.0-1
- Initial RPM release of garnotify
- Notification daemon for gardesk desktop suite
