# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils gnome2-utils

DESCRIPTION="An open source re-implementation of RollerCoaster Tycoon 2"
HOMEPAGE="https://openrct2.website/"
MY_REPO="https://github.com/OpenRCT2/OpenRCT2"
if [ "${PV}" == "9999" ]; then
	EGIT_REPO_URI="${MY_REPO}.git"
	EGIT_BRANCH="develop"
	inherit git-r3
else
	KEYWORDS="~amd64 ~x86"
	SRC_URI="${MY_REPO}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="libressl"
RESTRICT="mirror"

DEPEND="
	virtual/opengl
	dev-libs/jansson
	media-libs/libsdl2
	media-libs/sdl2-ttf
	media-libs/speex
	media-libs/libpng
	net-misc/curl
	libressl? ( dev-libs/libressl:0= )
	!libressl? ( dev-libs/openssl:0= )
"
RDEPEND="${DEPEND}"

if [ "${PV}" != "9999" ]; then
	S="${WORKDIR}/OpenRCT2-${PV}"
fi

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
