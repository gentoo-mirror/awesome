# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
EGO_PN="github.com/grafana/grafana"

inherit golang-build user

DESCRIPTION="Gorgeous metric viz, dashboards & editors for Graphite, InfluxDB & OpenTSDB"
HOMEPAGE="http://grafana.org"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="prometheus"

RDEPEND=""
# XXX: finish packaging dependencies
DEPEND="${RDEPEND}
	>=net-libs/nodejs-0.12
	dev-go/go-net:=
	dev-go/go-oauth2:=
	dev-go/go-sqlite3:=
"

STRIP_MASK="*.a"

pkg_setup() {
	enewgroup grafana
	enewuser grafana -1 -1 /usr/share/grafana grafana
}

src_prepare() {
	# XXX: move deps in place until they are packages
	mkdir src || die
	mv Godeps/_workspace/src/* src || die
	# Remove packaged dependencies
	rm -rf src/golang.org/x src/github.com/mattn || die

	mkdir -p src/${EGO_PN} || die
	mv *.go pkg src/${EGO_PN} || die

	# For local npm installs
	mkdir -p node_modules || die
}

src_compile() {
	golang-build_src_compile

	# XXX: no nodejs eclass to help with this mess yet
	npm install || die
	npm install grunt-cli || die
	PATH="${PATH}:${S}/node_modules/.bin/" grunt || die
}

src_test() {
	golang-build_src_test
}

src_install() {
	golang-build_src_install

	# Frontend assets
	insinto /usr/share/${PN}
	doins -r public conf

	dosbin grafana

	newconfd "${FILESDIR}"/grafana.confd grafana
	newinitd "${FILESDIR}"/grafana.initd grafana

	keepdir /etc/grafana
	insinto /etc/grafana
	doins "${FILESDIR}"/grafana.ini

	keepdir /var/{lib,log}/grafana
	fowners grafana:grafana /var/{lib,log}/grafana
	fperms 0750 /var/{lib,log}/grafana
}
