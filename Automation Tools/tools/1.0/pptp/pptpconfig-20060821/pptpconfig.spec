# Uncomment the following line for beta release versions
# (i.e. change hash symbol to percent symbol and specify beta version)
#define beta rc1

%define ver 20060821
%define rel 0

%define rpmrel %{?beta:0.%{beta}.}%{rel}
%define private_suffix -pcntl
%define private_php_dir %{_libdir}/php%{private_suffix}
%define desktop_vendor PPTP

# SuSE or Mandriva versions of the package can be built by defining suse_version or mandriva_version
# on the rpmbuild command line, e.g. rpmbuild --define "suse_version 910" -ba pptpconfig.spec
%if %{?mandriva_version:1}%{!?mandriva_version:0}
%define is_mandriva 1
%else
%define is_mandriva 0
%endif
%{!?__id_u:%define __id_u /bin/id -u}

Summary:	Point-to-Point Tunneling Protocol (PPTP) Client Configuration GUI
Name:		pptpconfig
Version:	%{ver}
%if %{is_mandriva}
Release:	%{rpmrel}mdk
Requires:	iproute2
%else
Release:	%{rpmrel}%{?suse_version:suse}
Requires:	iproute
%endif
Source0:	http://quozl.netrek.org/pptp/pptpconfig/pptpconfig-%{version}.tar.gz
Source1:	pptpconfig.png
Patch1:		pptpconfig-desktop.patch
Patch2:		pptpconfig-desktop-suse.patch
License:	GPL
%if %{!?suse_version:1}%{?suse_version:0}
Group:		Applications/Internet
Requires:	usermode >= 1.36
%else
Group:		Productivity/Networking/PPP
Requires:	xsu
%endif
Distribution:	PPTP Client Project
URL:		http://quozl.netrek.org/pptp/pptpconfig/
Requires:	ppp >= 2.4.2, pptp >= 1.2.0, php-gtk%{private_suffix}, php%{private_suffix} >= 4.3.9-2
BuildRequires:	desktop-file-utils
Buildroot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Obsoletes:	pptp-php-gtk
BuildArch:	noarch

%description
Graphical user interface for PPTP Client.
Supports configuration of tunnels, starting, stopping, catching debug
output from pppd, DNS and routing changes.

%prep
%setup -q
%patch1 -p0
%if %{?suse_version:1}%{!?suse_version:0}
%patch2 -p0
%endif
%{__sed} -i -e 's@/usr/lib/php-pcntl/bin/php@/bin/php%{private_suffix}@' pptpconfig.php
%{__sed} -i -e 's#@sbindir@#%{_sbindir}#' -e 's#@datadir@#%{_datadir}#' pptpconfig.desktop
%{__cp} %{SOURCE1} .

%install
# Some directory names hardcoded here because they are hardcoded in the PHP script
%{__rm} -rf %{buildroot}
%{__make} bindir=%{_bindir} \
	sbindir=%{_sbindir} \
	sysconfdir=/etc \
	datadir=%{_datadir} \
	DESTDIR=%{buildroot} \
	install%{!?suse_version: install-pam}
%{__install} -D -m 0444 pptpconfig.png %{buildroot}/%{_datadir}/pixmaps/pptpconfig.png
/usr/bin/desktop-file-install \
		--vendor %{desktop_vendor} \
		--delete-original \
                --dir %{buildroot}%{_datadir}/applications \
		%{buildroot}%{_datadir}/applications/pptpconfig.desktop

%clean
%{__rm} -rf %{buildroot}

%post
# Attempt to migrate tunnels from old pptp-php-gtk package
if [ ! -f /etc/pptpconfig/tunnels -a -f /etc/pptp-php-gtk/tunnels ]; then
	%{__cp} -p /etc/pptp-php-gtk/tunnels /etc/pptpconfig/tunnels
fi
/usr/bin/update-desktop-database %{_datadir}/applications &>/dev/null || :

%postun
/usr/bin/update-desktop-database %{_datadir}/applications &>/dev/null || :

%files
%defattr(-,root,root)
%dir /etc/pptpconfig
%dir /usr/lib/pptpconfig
%{_bindir}/pptpconfig.php
%{_sbindir}/pptpconfig
%if %{!?suse_version:1}%{?suse_version:0}
%{_bindir}/pptpconfig
%config(noreplace) /etc/pam.d/pptpconfig
%config(noreplace) /etc/security/console.apps/pptpconfig
%endif
%{_datadir}/applications/%{desktop_vendor}-pptpconfig.desktop
%{_datadir}/pixmaps/pptpconfig.png
/usr/lib/pptpconfig/pptpconfig.xml
/usr/lib/pptpconfig/*.xpm
%doc AUTHORS COPYING DEVELOPERS NEWS README TODO ChangeLog

%changelog
* Mon Apr 10 2006 James Cameron <quozl@us.netrek.org> 20060410-0
- update to 20060410

* Tue Mar 14 2006 Paul Howarth <paul@city-fan.org> 20060222-1
- update to 20060222

* Mon Feb 13 2006 Paul Howarth <paul@city-fan.org> 20060214-1
- update to 20060214
- don't attempt to auto-detect Mandriva
- cosmetic tweak: use macros instead of variables
- remove buildroot unconditionally in %%clean and %%install
- don't use macros in build-time command paths, hardcode them instead

* Mon Apr 11 2005 Paul Howarth <paul@city-fan.org> 20040722-7
- further tweaks to desktop entries to try to get SuSE working

* Tue Feb 22 2005 Paul Howarth <paul@city-fan.org> 20040722-6
- tweak detection of Mandrake build system

* Tue Nov 16 2004 Paul Howarth <paul@city-fan.org> 20040722-5
- tweak desktop entry and add icon

* Thu Sep 30 2004 Paul Howarth <paul@city-fan.org> 20040722-4
- use php from /bin/php-pcntl instead of architecure-specific
  library directory
- this requires php-pcntl >= 4.3.9-2, the first version with the
  required symlink in place

* Thu Sep  9 2004 Paul Howarth <paul@city-fan.org> 20040722-3
- don't include usermode functions in SuSE versions
- group is Productivity/Networking/PPP in SuSE versions
- require pptp rather than pptp-linux

* Mon Aug  9 2004 Paul Howarth <paul@city-fan.org> 20040722-2
- require iproute2 instead of iproute for Mandrake versions

* Thu Jul 15 2004 Paul Howarth <paul@city-fan.org> 20040722-1
- update to new version 20040722 (a week early?)

* Thu Jul 15 2004 Paul Howarth <paul@city-fan.org> 20040619-2
- hardcode paths for /etc instead of using %{_sysconfdir}, just like
  Red Hat do, as this actually helps portability
- make /etc/pam.d/pptpconfig & /etc/security/console.apps/pptpconfig
  %config files, so that users keep their changes on upgrade
- use desktop-file-install for the desktop entry
- remove BuildRequires: perl, no longer needed

* Wed Jul 14 2004 Paul Howarth <paul@city-fan.org> 20040619-1
- update to new upstream pptpconfig package, remove all patches handling
  name change

* Fri Jun 18 2004 James Cameron <james.cameron@hp.com>
- use upstream pptpconfig package

* Thu Jun 17 2004 Paul Howarth <paul@city-fan.org> 20040619-0.rc1.2
- move pptpconfig.pam & pptpconfig.app creation from spec file to patch
- move renaming and editing of files for pptp-php-gtk -> pptpconfig name
  change from install to prep phase
- try to migrate existing tunnel definitions from the old pptp-php-gtk package
- patch Makefile to make it properly usable in the RPM build
- patch Makefile to add install-pam target
- use Makefile for install process

* Tue Jun 15 2004 Paul Howarth <paul@city-fan.org>
- Initial RPM build.
