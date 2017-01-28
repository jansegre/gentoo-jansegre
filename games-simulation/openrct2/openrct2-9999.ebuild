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
	S="${WORKDIR}/OpenRCT2-${PV}"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="+twitch +network +opengl +ttf +lightfx libressl"

DEPEND="
	twitch? ( net-misc/curl )
	network? (
		libressl? ( dev-libs/libressl:0= )
		!libressl? ( dev-libs/openssl:0= )
	)
	opengl? ( virtual/opengl )
	ttf? (
		media-libs/sdl2-ttf
		media-libs/fontconfig
	)
	media-libs/libsdl2
	media-libs/speex
	>=dev-libs/jansson-2.5
	>=media-libs/libpng-1.2
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DDISABLE_HTTP_TWITCH="$(usex !twitch)"
		-DDISABLE_NETWORK="$(usex !network)"
		-DDISABLE_OPENGL="$(usex !opengl)"
		-DDISABLE_TTF="$(usex !ttf)"
		-DENABLE_LIGHTFX="$(usex lightfx)"
	)

	cmake-utils_src_configure
}

pkg_preinst() {
	if ! has_version "<=${CATEGORY}/${PN}-${PVR}"; then
		first_install="1"
	fi
	gnome2_icon_savelist
}

pkg_postinst() {
	if [[ "${first_install}" == "1" ]]; then
		ewarn ""
		ewarn "You still need the original RollerCoaster Tycoon 2 files to play this game."
		ewarn "See: https://github.com/OpenRCT2/OpenRCT2/wiki/Required-RCT2-files#how-to-retrieve"
		ewarn ""
	fi
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
