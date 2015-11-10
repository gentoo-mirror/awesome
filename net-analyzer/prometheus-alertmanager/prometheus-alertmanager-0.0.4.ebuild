# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit golang-base user

DESCRIPTION="Prometheus Alert Manager"
HOMEPAGE="https://github.com/prometheus/alertmanager"
EGO_PN="github.com/prometheus/alertmanager"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"
IUSE=""

DEPEND=">=dev-lang/go-1.5.1"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}/src/${EGO_PN}"

DAEMON_USER="prometheus"
LOG_DIR="/var/log/prometheus"
DATA_DIR="/var/lib/prometheus"

pkg_setup() {
	enewuser ${DAEMON_USER} -1 -1 "${DATA_DIR}"
}

src_unpack() {
	default
	mv "alertmanager-${PV}" "${P}"
	mkdir -p temp/src/${EGO_PN%/*} || die
	mv ${P} temp/src/${EGO_PN} || die
	mv temp ${P} || die
}

src_compile() {
	export GOPATH="${WORKDIR}/${P}:$(get_golibdir_gopath)"
	emake
}
