# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:
EAPI=5
PYTHON_COMPAT=(python{2_7,3_3,3_4})

inherit distutils-r1 git-2

DESCRIPTION="The official Python 2 and 3 client for Prometheus"
HOMEPAGE="https://github.com/prometheus/client_python"
EGIT_REPO_URI="https://github.com/prometheus/client_python.git"
[[ ${PV} == "9999" ]] || EGIT_COMMIT=${PV}

LICENSE="Apache-2.0"
KEYWORDS="~amd64"
IUSE=""
SLOT="0"

DEPEND=""
RDEPEND="${DEPEND}"
