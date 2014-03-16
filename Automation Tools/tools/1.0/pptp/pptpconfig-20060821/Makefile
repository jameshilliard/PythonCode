VERSION=20060821
PACKAGE=pptpconfig
sbindir=/usr/sbin
bindir=/usr/bin
sysconfdir=/etc
datadir=/usr/share
INSTALL=install
RM=rm
MV=mv
MKDIR=mkdir
CP=cp
TAR=tar
MD5SUM=md5sum
LN=ln

all:
	exit 0

distclean:
	exit 0

dist:
	$(RM) -f $(PACKAGE)-$(VERSION).tar.gz
	$(RM) -rf $(PACKAGE)-$(VERSION)
	$(MKDIR) $(PACKAGE)-$(VERSION)
	$(CP) *.php *.xml ChangeLog Makefile *.spec *.desk* $(PACKAGE)-$(VERSION)
	$(CP) AUTHORS COPYING DEVELOPERS NEWS README TODO $(PACKAGE)-$(VERSION)
	$(CP) *.app *.pam $(PACKAGE)-$(VERSION)
	$(MKDIR) $(PACKAGE)-$(VERSION)/pixmaps
	$(CP) pixmaps/*.xpm $(PACKAGE)-$(VERSION)/pixmaps
	$(TAR) czf $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION)
	$(RM) -f -r $(PACKAGE)-$(VERSION)
	$(MD5SUM) $(PACKAGE)-$(VERSION).tar.gz

install:
	$(MKDIR) -p $(DESTDIR)/etc/$(PACKAGE)
	$(MKDIR) -p $(DESTDIR)/usr/lib/$(PACKAGE)
	$(MKDIR) -p $(DESTDIR)$(bindir)
	$(MKDIR) -p $(DESTDIR)$(sbindir)
	$(MKDIR) -p $(DESTDIR)$(datadir)/applications
	$(INSTALL) -m 755 pptpconfig.php $(DESTDIR)$(bindir)
	$(LN) -sf $(bindir)/pptpconfig.php $(DESTDIR)$(sbindir)/$(PACKAGE)
	$(INSTALL) -m 644 pptpconfig.xml $(DESTDIR)/usr/lib/$(PACKAGE)
	$(INSTALL) -m 644 pixmaps/*.xpm $(DESTDIR)/usr/lib/$(PACKAGE)
	$(INSTALL) -m 644 pptpconfig.desktop $(DESTDIR)/$(datadir)/applications

install-pam:
	$(MKDIR) -p $(DESTDIR)$(sysconfdir)/pam.d
	$(MKDIR) -p $(DESTDIR)$(sysconfdir)/security/console.apps
	$(INSTALL) -m 644 pptpconfig.pam $(DESTDIR)$(sysconfdir)/pam.d/$(PACKAGE)
	$(INSTALL) -m 644 pptpconfig.app $(DESTDIR)$(sysconfdir)/security/console.apps/$(PACKAGE)
	$(LN) -s consolehelper $(DESTDIR)$(bindir)/pptpconfig

package: deb rpm

deb:
	fakeroot dpkg-buildpackage -us -uc
	$(MV) ../$(PACKAGE)_$(VERSION)-0_all.deb .

RPM_SOURCES=/usr/src/rpm/SOURCES
RPM_RPMS=/usr/src/rpm/RPMS
RPM_SRPMS=/usr/src/rpm/SRPMS
rpm:
	$(CP) $(PACKAGE)-$(VERSION).tar.gz $(RPM_SOURCES)
	fakeroot rpmbuild -ba --nodeps $(PACKAGE).spec
	$(RM) $(RPM_SOURCES)/$(PACKAGE)-$(VERSION).tar.gz
	$(RM) -rf $(RPM_SOURCES)/BUILD/$(PACKAGE)-$(VERSION)
	$(MV) $(RPM_RPMS)/noarch/$(PACKAGE)-${VERSION}-0.noarch.rpm .
	$(MV) $(RPM_SRPMS)/$(PACKAGE)-${VERSION}-0.src.rpm .

rpm-to-deb:
	fakeroot alien $(PACKAGE)-${VERSION}.noarch.rpm

WEB=~/public_html/external/mine/pptp/pptpconfig
release:
	$(CP) $(PACKAGE)-$(VERSION).tar.gz $(WEB)
	$(CP) $(PACKAGE)-${VERSION}-0.noarch.rpm $(WEB)
	$(CP) $(PACKAGE)-${VERSION}-0.src.rpm $(WEB)
	$(CP) $(PACKAGE)_$(VERSION)-0_all.deb $(WEB)
