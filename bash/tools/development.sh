#!/bin/bash


function makefile.template () {
cat >>Makefile.template <<'EOF'
PKGDIR=packaging

.debname: $(PKGDIR)/DEBIAN/control
	nano $(PKGDIR)/DEBIAN/control
	grep -E '^Package:' $(PKGDIR)/DEBIAN/control | awk '{print $$2}' > .debname
	grep -E '^Version:' $(PKGDIR)/DEBIAN/control | awk '{print $$2}' >> .debname
	grep -E '^Architecture:' $(PKGDIR)/DEBIAN/control | awk '{print $$2}' >>.debname
	cat .debname | tr -s '\n' '_' | sed 's/_$$//' > .debname.two
	mv .debname.two .debname

deb: .debname
	dpkg-deb --build ./$(PKGDIR) ../$(shell cat .debname).deb

snapshot: .debname
	tar -czvf ../$(shell cat .debname).tar.gz ./ --exclude=.git

release: deb snapshot
EOF
}

# vim: noexpandtab shiftwidth=4 
