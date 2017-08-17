# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6
CMAKE_MIN_VERSION="3.2.0"
inherit cmake-utils gnome2-utils

DESCRIPTION="StepMania is an advanced cross-platform rhythm game for home and arcade use"
HOMEPAGE="http://www.stepmania.com/"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/stepmania/stepmania.git"
	EGIT_BRANCH="master"
	EGIT_SUBMODULES=( '*' '-breathe' '-doc/*' '-*googletest*' '-*ogg*' '-*vorbis*' )
	inherit git-r3
else
	MY_PV="v${PV/_alpha/a}"
	MY_P="${PN}-${MY_PV#v}"
	KEYWORDS="~amd64 ~x86"

	# NOTE: track these with the submodules of the current version
	FFMPEG_V="eda6effcabcf9c238e4635eb058d72371336e09b"
	CPPFORMAT_V="1.1.0"
	TOMCRYPT_V="1.16"
	TOMMATH_V="0.40"

	FFMPEG_P="ffmpeg-${FFMPEG_V}"
	CPPFORMAT_P="fmt-${CPPFORMAT_V}"
	TOMCRYPT_P="libtomcrypt-${TOMCRYPT_V}"
	TOMMATH_P="libtommath-${TOMMATH_V}"

	SRC_URI="
		https://github.com/stepmania/stepmania/archive/${MY_PV}.tar.gz -> ${MY_P}.tar.gz
		ffmpeg? ( !system-ffmpeg? ( https://github.com/stepmania/ffmpeg/archive/${FFMPEG_V}.tar.gz -> ${PN}-${FFMPEG_P}.tar.gz ) )
		https://github.com/stepmania/fmt/archive/${CPPFORMAT_V}.tar.gz -> ${PN}-${CPPFORMAT_P}.tar.gz
		https://github.com/stepmania/libtomcrypt/archive/${TOMCRYPT_V}.tar.gz -> ${PN}-${TOMCRYPT_P}.tar.gz
		https://github.com/stepmania/libtommath/archive/${TOMMATH_V}.tar.gz -> ${PN}-${TOMMATH_P}.tar.gz

	"
	S="${WORKDIR}/${MY_P}"
fi
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
IUSE="+default-songs alsa oss pulseaudio jack +ffmpeg +system-ffmpeg gles2 +gtk +mp3 +ogg +jpeg networking wav parport crash-handler cpu_flags_x86_sse2"
REQUIRED_USE="
	|| ( alsa oss pulseaudio jack )
	system-ffmpeg? ( ffmpeg )
"

RDEPEND="
	virtual/opengl
	x11-libs/libSM
	x11-libs/libICE
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrandr
	x11-libs/libva
	alsa? ( media-libs/alsa-lib )
	pulseaudio? ( media-sound/pulseaudio )
	jack? ( media-sound/jack-audio-connection-kit )
	system-ffmpeg? ( <media-video/ffmpeg-3 )
	gtk? (
		x11-libs/gtk+:2
		dev-libs/glib:2
		x11-libs/gdk-pixbuf:2
		x11-libs/cairo
		x11-libs/pango
	)
	mp3? ( media-libs/libmad )
	ogg? ( || (
		media-libs/libvorbis
		media-libs/libogg
	) )
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-force-audio-backend.patch"
)

# This is needed to put the content of the required submodules in place
# and should be kept according to the layout described in .gitmodules
if [[ ! ${PV} == 9999 ]]; then
src_unpack() {
	default
	use ffmpeg && use !system-ffmpeg && (rmdir ${S}/extern/ffmpeg-git && mv ${WORKDIR}/${FFMPEG_P} ${S}/extern/ffmpeg-git || die)
	rmdir ${S}/extern/cppformat && mv ${WORKDIR}/${CPPFORMAT_P} ${S}/extern/cppformat || die
	rmdir ${S}/extern/tomcrypt && mv ${WORKDIR}/${TOMCRYPT_P} ${S}/extern/tomcrypt || die
	rmdir ${S}/extern/tommath && mv ${WORKDIR}/${TOMMATH_P} ${S}/extern/tommath || die
}
fi

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr/share
		-DWITH_ALSA="$(usex alsa)"
		-DWITH_CRASH_HANDLER="$(usex crash-handler)"
		-DWITH_GLES2="$(usex gles2)"
		-DWITH_GTK2="$(usex gtk)"
		-DWITH_JACK="$(usex jack)"
		-DWITH_JPEG="$(usex jpeg)"
		-DWITH_MP3="$(usex mp3)"
		-DWITH_NETWORKING="$(usex networking)"
		-DWITH_OGG="$(usex ogg)"
		-DWITH_OSS="$(usex oss)"
		-DWITH_PARALLEL_PORT="$(usex parport)"
		-DWITH_PULSEAUDIO="$(usex pulseaudio)"
		-DWITH_SSE2="$(usex cpu_flags_x86_sse2)"
		-DWITH_SYSTEM_FFMPEG="$(usex system-ffmpeg)"
		-DWITH_WAV="$(usex wav)"
		-DWITH_PORTABLE_TOMCRYPT="ON"
		-DWITH_FFMPEG="$(usex ffmpeg)"
		-DWITH_GPL_LIBS="ON"
		-DWITH_MINIMAID="OFF"
		-DWITH_TTY="OFF"
		-DWITH_LTO="ON"
		-DWITH_PROFILING="OFF"
		-DWITH_FULL_RELEASE="ON"
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# Simplify shared path (using /usr/share/stepmania instead of /usr/share/stepmania-5.1)
	local oldshared=$(ls "${ED}/usr/share" | grep ${PN})
	mv "${ED}/usr/share/${oldshared}" "${ED}/usr/share/${PN}" || die
	rm -r "${ED}/usr/share/${PN}/Docs" || die
	if ! use default-songs; then
		rm -r "${ED}/usr/share/${PN}/Songs/StepMania 5" || die
	fi

	# Create a wrapper (the compiled bin has to be in /usr/share/stepmania) and our own .desktop
	make_wrapper "${PN}" "${EROOT}usr/share/${PN}/${PN}"
	make_desktop_entry "${PN}" "StepMania" "stepmania-ssc"
	insinto /usr/share
	doins -r icons

	# Some useful user docs
	cd Docs || die
	dodoc Changelog_* CommandLineArgs.txt credits.txt KnownIssues.txt Mapping_keys_for_edit_mode.txt old_changelog.txt versioning.txt Userdocs/*
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
