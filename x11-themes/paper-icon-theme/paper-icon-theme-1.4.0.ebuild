# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils autotools

DESCRIPTION="Paper Icon Theme"
HOMEPAGE="http://snwh.org/paper"
MY_REPO="https://github.com/snwh/paper-icon-theme"
if [[ ${PV} == *9999* ]];then
	inherit git-r3
	SRC_URI=""
	EGIT_REPO_URI="${MY_REPO}.git"
	KEYWORDS=""
else
	SRC_URI="${MY_REPO}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="*"
	RESTRICT="mirror"
fi

LICENSE="CC-BY-SA-4.0"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare(){
	eapply_user
	eautoreconf
}

src_compile(){
	emake DESTDIR="${D}"
}

src_install(){
	emake DESTDIR="${D}" install || die
}
