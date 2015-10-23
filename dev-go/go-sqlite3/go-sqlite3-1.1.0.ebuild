# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
EGO_PN="github.com/mattn/go-sqlite3"

inherit golang-build

DESCRIPTION="sqlite3 driver for go that using database/sql"
HOMEPAGE="https://github.com/mattn/go-sqlite3"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="icu"

RDEPEND=""
DEPEND="
	dev-db/sqlite:3[icu?]
"

src_prepare() {
	mkdir -p "${WORKDIR}"/${PN}/src/${EGO_PN%/*} || die
	mv "${S}" "${WORKDIR}"/${PN}/src/${EGO_PN} || die
	mv "${WORKDIR}"/${PN} "${S}" || die
}

src_compile() {
	local myconf=( libsqlite3 linux )
	if use icu ; then
		myconf+=( icu )
	fi
	golang-build_src_compile --tags "${myconf[$@]}"
}
