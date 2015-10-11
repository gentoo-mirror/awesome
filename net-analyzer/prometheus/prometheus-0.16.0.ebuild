# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit golang-base

DESCRIPTION="Systems and service monitoring system"
HOMEPAGE="http://prometheus.io"
EGO_PN="github.com/${PN}/${PN}"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
IUSE=""

DEPEND=">=dev-lang/go-1.5"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}/src/${EGO_PN}"

src_unpack() {
	default
	mkdir -p temp/src/${EGO_PN%/*} || die
	mv ${P} temp/src/${EGO_PN} || die
	mv temp ${P} || die
}

src_compile() {
	export GOPATH="${WORKDIR}/${P}:$(get_golibdir_gopath)"
	emake build
}

src_install() {
	dobin ${PN}
	dobin promtool

	insinto /etc/
	doins documentation/examples/prometheus.yml

	doinitd "${FILESDIR}"/${PN}-initd
}
