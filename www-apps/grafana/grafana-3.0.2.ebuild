# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit user

DESCRIPTION="Gorgeous metric viz, dashboards & editors for Graphite, InfluxDB & OpenTSDB"
HOMEPAGE="http://grafana.org"

# They append the build tag for some releases. If no build tag is specified, 
# the release URL still contains the "-" i.e. https://grafanarel.s3.amazonaws.com/builds/grafana-3.0.1-.linux-x64.tar.gz
BUILD=""
[[ $PV == "3.0.2" ]] && BUILD="1463383025"
SRC_URI="https://grafanarel.s3.amazonaws.com/builds/${P}-${BUILD}.linux-x64.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	>=net-libs/nodejs-0.12
	>=dev-lang/go-1.4"

pkg_setup() {
	enewgroup grafana
	enewuser grafana -1 -1 /usr/share/grafana grafana
}

src_unpack() {
	default
	mv "${P}-${BUILD}" "${P}"
}

src_install() {

	# Frontend assets
	insinto /usr/share/${PN}
	doins -r public conf vendor

	dobin bin/grafana-server

	newconfd "${FILESDIR}"/grafana.confd grafana
	newinitd "${FILESDIR}"/grafana.initd grafana

	keepdir /etc/grafana
	insinto /etc/grafana
	doins "${FILESDIR}"/grafana.ini

	keepdir /var/{lib,log}/grafana
	fowners grafana:grafana /var/{lib,log}/grafana
	fperms 0750 /var/{lib,log}/grafana
}
