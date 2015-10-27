# Copyright 2015 awesome information technology, http://awesome-it.de                                                                  
# Distributed under the terms of the GNU General Public License v3
# $Header: $

EAPI=5

inherit git-2

DESCRIPTION="Grafana datasource for Prometheus Monitoring"
HOMEPAGE="https://github.com/grafana/grafana-plugins"
EGIT_REPO_URI="https://github.com/grafana/grafana-plugins.git"
# https://github.com/grafana/grafana-plugins/issues/39
[[ ${PV} == "2.1.3" ]] && EGIT_COMMIT="57055f72c4745abe6c33a26359ebfb6e59920345"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="=www-apps/grafana-2.1.3"
RDEPEND="${DEPEND}"

src_install() {

	into /usr/share/grafana/public/app/plugins/datasource
	doins ${P}/datasources/prometheus 
}
