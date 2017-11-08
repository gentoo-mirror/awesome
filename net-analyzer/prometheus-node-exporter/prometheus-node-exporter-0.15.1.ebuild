# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit golang-base user eutils

DESCRIPTION="Prometheus exporter for machine metrics."
HOMEPAGE="http://prometheus.io"
EGO_PN="github.com/prometheus/node_exporter"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
IUSE=""

DEPEND=">=dev-lang/go-1.5
		dev-vcs/mercurial"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}/src/${EGO_PN}"

DAEMON_USER="prometheus"
LOG_DIR="/var/log/prometheus"

pkg_setup() {
	enewuser ${DAEMON_USER} -1 -1 -1 "wheel"
}

src_unpack() {
	default
	mkdir -p "temp/src/${EGO_PN%/*}" || die
	mv "node_exporter-${PV}" "temp/src/${EGO_PN}" || die
	mv "temp" "${P}" || die
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-Makefile.patch"
}

src_compile() {
    export GOPATH="${WORKDIR}/${P}"
	emake build
}

src_install() {
	insinto "/usr/bin"
	newbin "node_exporter" "prometheus-node-exporter"

	newconfd "${FILESDIR}/${PN}-confd" "prometheus-node-exporter"
	newinitd "${FILESDIR}/${PN}-initd" "prometheus-node-exporter"

	keepdir "${LOG_DIR}"
	fowners "${DAEMON_USER}" "${LOG_DIR}"
}