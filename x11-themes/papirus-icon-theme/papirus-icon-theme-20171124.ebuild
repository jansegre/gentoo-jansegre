# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

DESCRIPTION="Papirus icon theme for Linux"
HOMEPAGE="https://git.io/papirus-icon-theme"
MY_REPO="https://github.com/PapirusDevelopmentTeam/papirus-icon-theme"
if [[ ${PV} == *9999* ]];then
	inherit git-r3
	SRC_URI=""
	EGIT_REPO_URI="${MY_REPO}.git"
	KEYWORDS=""
else
	SRC_URI="${MY_REPO}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="*"
	RESTRICT="mirror"
fi

LICENSE="LGPL-3"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install(){
	emake DESTDIR="${D}" install || die
}
