# Copyright 2014 awesome information technology, http://awesome-it.de
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Dependency Manager for PHP"
HOMEPAGE="https://getcomposer.org/"
SRC_URI="https://getcomposer.org/download/${PV/_alpha/-alpha}/composer.phar -> composer-${PV}.phar"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-lang/php"
RDEPEND="${DEPEND}"

src_unpack() {
	mkdir "${WORKDIR}/${PF}"
	cp "${DISTDIR}/composer-${PV}.phar" "${WORKDIR}/${PF}/composer"
}

src_install() {
	into "/usr/local"
	dobin "composer"
}
