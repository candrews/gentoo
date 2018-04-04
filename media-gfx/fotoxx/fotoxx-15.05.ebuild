# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit desktop toolchain-funcs xdg-utils

DESCRIPTION="Program for improving image files made with a digital camera"
HOMEPAGE="http://www.kornelix.com/fotoxx.html"
SRC_URI="http://www.kornelix.com/uploads/1/3/0/3/13035936/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	x11-libs/gtk+:3
	media-libs/libpng
	media-libs/tiff
	media-libs/lcms:2"
RDEPEND="${DEPEND}
	media-libs/exiftool
	media-gfx/ufraw[gtk]
	media-gfx/dcraw
	x11-misc/xdg-utils"

PATCHES=(
	"${FILESDIR}"/${PF}.patch
)

src_compile() {
	tc-export CXX
	emake
}

src_install() {
	# For the Help menu items to work, *.html must be in /usr/share/doc/${PF},
	# and README, changelog, translations, edit-menus, KB-shortcuts must not be compressed
	emake DESTDIR="${D}" install
	newmenu desktop ${PN}.desktop
	rm -f "${D}"/usr/share/doc/${PF}/*.man
	docompress -x /usr/share/doc
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
