# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit golang-base

DESCRIPTION="Prometheus exporter for machine metrics, written in Go with pluggable metric collectors."
HOMEPAGE="http://prometheus.io"
SRC_URI="https://github.com/prometheus/node_exporter/archive/${PV/_rc/rc}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
IUSE=""

DEPEND=">=dev-lang/go-1.5"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}/src/${EGO_PN}"

src_compile() {
    export GOPATH="${WORKDIR}/${P}:$(get_golibdir_gopath)"
    emake build
}

src_install() {
	insinto /usr/bin
	newbin node_exporter prometheus-node-exporter
}
