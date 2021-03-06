# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit user

DESCRIPTION="A GPL'd perl server for house automation"
HOMEPAGE="https://www.fhem.de/"
SRC_URI="https://www.fhem.de/${P}.tar.gz"

KEYWORDS="~amd64 ~x86"
LICENSE="GPL-2+"
SLOT="0"
IUSE="doc"

RDEPEND="dev-perl/Crypt-CBC
	dev-perl/Device-SerialPort
	dev-perl/Digest-CRC
	dev-perl/JSON"

DEPEND="media-gfx/pngcrush"

QA_PREBUILT="opt/fhem/contrib/lcd4linux/fritzbox_dpf/lcd4linux
	opt/fhem/contrib/lcd4linux/rpi_dpf/lcd4linux"

pkg_setup() {
	enewgroup fhem
	enewuser fhem -1 -1 /opt/fhem fhem
}

src_prepare() {
	default

	# Allow install path to be set by DESTDIR in Makefile
	sed -i -e 's,^\(BINDIR=\),\1'\$\(DESTDIR\)',' Makefile || die

	# Remove docs in Makefile, as they will be installed manually
	sed -i -e 's/docs//g' Makefile || die
	sed -i -e '/README_DEMO.txt/d' Makefile || die

	# Remove manpage in Makefile, as it will be installed manually
	sed -i -e '/fhem.pl.1/d' Makefile || die

	# Remove log dir, as it will be replaced with a symlink
	rm -r log || die

	# Fix fhemicon_darksmall.png, as it reports "broken IDAT window length"
	# Reported to Upstream: https://forum.fhem.de/index.php/topic,86238.0.html
	pngcrush -fix -force -ow www/images/default/fhemicon_darksmall.png || die

	cp "${FILESDIR}"/fhem.cfg fhem.cfg || die
}

src_compile() {
	:
}

src_install() {
	local DOCS=(
		"CHANGED"
		"HISTORY"
		"README.SVN"
		"README_DEMO.txt"
		"docs"/*.txt
		"docs"/*.patch
		"docs"/*.pdf
		"docs/changelog"
		"docs/copyright"
		"docs/dotconfig"
		"docs/fhem.odg.readme"
		"docs/LIESMICH.update-thirdparty"
		"docs"/README*
		"docs/X10"
	)

	if use doc; then
		local DOCS+=( "docs/X10" )
		local HTML_DOCS=( "docs/"*.eps "docs/"*.html "docs"/*.jpg "docs"/*.js "docs"/*.odg "docs/"*.png "docs/km271" )
	fi

	diropts -o fhem -g fhem
	keepdir "/var/lib/fhem"
	keepdir "/var/log/fhem"

	dosym ../../var/lib/fhem /opt/fhem/data
	dosym ../../var/log/fhem /opt/fhem/log

	default

	newinitd "${FILESDIR}"/fhem.initd fhem

	newman docs/fhem.man fhem.pl.1

	echo 'CONFIG_PROTECT="/opt/fhem /var/lib/fhem"' > "${T}"/99fhem || die
	doenvd "${T}"/99fhem

	fowners fhem:fhem /opt/fhem/fhem.cfg
}
