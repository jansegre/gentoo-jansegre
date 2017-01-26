# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils gnome2-utils toolchain-funcs qmake-utils flag-o-matic

MY_P=${PN}_v${PV}-source

DESCRIPTION="A Nintendo multi-system emulator formerly known as bsnes"
HOMEPAGE="https://byuu.org/emulation/higan/ https://gitlab.com/higan/higan/"
SRC_URI="https://download.byuu.org/${MY_P}.7z"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ao +alsa +icarus openal opengl oss pulseaudio qt4 +sdl udev xv custom-optimization"
REQUIRED_USE="
	|| ( ao openal alsa pulseaudio oss )
	|| ( xv opengl sdl )
"
RESTRICT="mirror"

RDEPEND="
	x11-libs/libX11
	x11-libs/libXext
	icarus? ( x11-libs/gtksourceview:2.0
			  x11-libs/gtk+:2
			  x11-libs/pango
			  dev-libs/atk
			  x11-libs/cairo
			  x11-libs/gdk-pixbuf
			  dev-libs/glib:2
			  media-libs/fontconfig
			  media-libs/freetype
			)
	ao? ( media-libs/libao )
	openal? ( media-libs/openal )
	alsa? ( media-libs/alsa-lib )
	pulseaudio? ( media-sound/pulseaudio )
	xv? ( x11-libs/libXv )
	opengl? ( virtual/opengl )
	sdl? ( media-libs/libsdl[X,joystick,video] )
	udev? ( virtual/udev )
	!qt4? ( x11-libs/gtk+:2 )
	qt4? (  dev-qt/qtcore:4
			>=dev-qt/qtgui-4.5:4 )"
DEPEND="${RDEPEND}
	app-arch/p7zip
	virtual/pkgconfig"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}"/${P}-QA.patch
	"${FILESDIR}"/${P}-shared.patch
	"${FILESDIR}"/${P}-install.patch
)

disable_module() {
	sed -i \
		-e "s|$1\b||" \
		"${S}"/higan/target-tomoko/GNUmakefile || die
}

src_prepare() {
	default

	sed -i \
		-e "/handle/s#/usr/local/lib#/usr/$(get_libdir)#" \
		nall/dl.hpp || die "fixing libdir failed!"

	# audio modules
	use ao || disable_module audio.ao
	use openal || disable_module audio.openal
	use pulseaudio ||  { disable_module audio.pulseaudio
		disable_module audio.pulseaudiosimple ;}
	use oss || disable_module audio.oss
	use alsa || disable_module audio.alsa

	# video modules
	use opengl || disable_module video.glx
	use xv || disable_module video.xv
	use sdl || disable_module video.sdl

	# input modules
	use sdl || disable_module input.sdl
	use udev || disable_module input.udev

	# regenerate .moc if needed
	if use qt4; then
		cd hiro/qt || die
		 "$(qt4_get_bindir)"/moc -i -I. -o qt.moc qt.hpp || die
	fi
}

src_compile() {
	local mytoolkit

	if use !custom-optimization; then
		filter-flags "-O?"
		append-flags "-O3"
	fi

	if use qt4; then
		mytoolkit="qt"
	else
		mytoolkit="gtk"
	fi

	cd "${S}/higan" || die
	emake \
		platform="linux" \
		compiler="$(tc-getCXX)" \
		mycflags="${CFLAGS}" \
		mycxxflags="${CXXFLAGS}" \
		myldflags="${LDFLAGS}" \
		hiro="${mytoolkit}"

	if use icarus; then
		cd "${S}/icarus" || die
		emake \
			platform="linux" \
			compiler="$(tc-getCXX)" \
			mycflags="${CFLAGS}" \
			mycxxflags="${CXXFLAGS}" \
			myldflags="${LDFLAGS}"
	fi
}

src_install() {
	dodir /usr/share/applications

	cd "${S}/higan"
	emake \
		prefix="${ED}/usr" \
		install

	# use our desktop entry
	rm "${ED}/usr/share/applications/${PN}.desktop"
	make_desktop_entry "${PN}" "${PN}"

	if use icarus; then
		cd "${S}/icarus"
		emake \
			prefix="${ED}/usr" \
			install
	fi
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
