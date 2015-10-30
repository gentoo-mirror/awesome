# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:
EAPI=5

inherit git-2

DESCRIPTION="Prometheus exporter for GLSA checks"
HOMEPAGE="https://gitlab.awesome-it.de/infrastructure/prometheus-glsa-exporter"
EGIT_REPO_URI="https://gitlab.awesome-it.de/infrastructure/prometheus-glsa-exporter.git"
[[ ${PV} == "9999" ]] || EGIT_COMMIT=${PV}

LICENSE="Apache-2.0"
KEYWORDS="~amd64"
IUSE=""
SLOT="0"

DEPEND=">=dev-python/prometheus-client-0.0.13"
RDEPEND="${DEPEND}"

src_install() {

    newconfd "${FILESDIR}/${PN}-confd" "${PN}"
    newinitd "${FILESDIR}/${PN}-initd" "${PN}"

    into "/usr"
    newbin "prometheus-glsa-exporter.py" "prometheus-glsa-exporter"
}
