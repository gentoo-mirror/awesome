# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit golang-base user

DESCRIPTION="Gorgeous metric viz, dashboards & editors for Graphite, InfluxDB & OpenTSDB"
HOMEPAGE="http://grafana.org"
EGO_PN="github.com/${PN}/${PN}"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
IUSE="hardened"

DEPEND="
	>=dev-lang/go-1.5
	>=net-libs/nodejs-0.12
	!www-apps/grafana-plugins-prometheus
	hardened? ( sys-apps/paxctl )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}/src/${EGO_PN}"

DAEMON_USER="grafana"
LOG_DIR="/var/log/grafana"
DATA_DIR="/var/lib/grafana"

pkg_setup() {
	enewuser ${DAEMON_USER} -1 -1 "${DATA_DIR}"
}

src_unpack() {
	default
	mkdir -p temp/src/${EGO_PN%/*} || die
	mv ${P} temp/src/${EGO_PN} || die
	mv temp ${P} || die
}

src_compile() {
	export GOPATH="${WORKDIR}/${P}"
	export PATH="$PATH:${WORKDIR}/${P}/bin"
	emake
}

src_install() {
	insinto /usr/share/${PN}
	doins -r conf vendor

	insinto /usr/share/${PN}/public
	doins -r public_gen/*

	# Disable MPROTECT to run in hardened kernels
	use hardened && paxctl -m bin/grafana-server
	dobin bin/grafana-server

	newconfd "${FILESDIR}"/grafana.confd grafana
	newinitd "${FILESDIR}"/grafana.initd grafana

	keepdir /etc/grafana
	insinto /etc/grafana
	doins "${FILESDIR}"/grafana.ini

    keepdir "${LOG_DIR}"
	fowners "${DAEMON_USER}" "${LOG_DIR}"
	fperms 0750 "${LOG_DIR}"

	keepdir "${DATA_DIR}"
	fowners "${DAEMON_USER}" "${DATA_DIR}"
	fperms 0750 "${DATA_DIR}"
}
