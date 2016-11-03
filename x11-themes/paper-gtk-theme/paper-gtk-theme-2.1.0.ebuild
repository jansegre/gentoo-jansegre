# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit eutils autotools

DESCRIPTION="Paper is a modern desktop theme suite. Its design is mostly flat with a minimal use of shadows for depth."
HOMEPAGE="http://snwh.org/paper"
LICENSE="GPL-3.0+"
SLOT="0"

BASE_URI="https://github.com/snwh/${PN}"

if [[ ${PV} == *9999* ]];then
	inherit git-r3
	SRC_URI=""
	EGIT_REPO_URI="${BASE_URI}.git"
	KEYWORDS=""
else
	SRC_URI="${BASE_URI}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 x86"
	RESTRICT="mirror"
fi

# TODO: verify these
DEPEND="
	x11-themes/gtk-engines-murrine
	dev-ruby/sass
	dev-libs/glib:2
	x11-libs/gdk-pixbuf:2
"
RDEPEND="${DEPEND}"

src_prepare(){
	eapply_user
	eautoreconf
}

src_compile(){
	emake DESTDIR="${D}" || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}
