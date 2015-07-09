# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/odoo/odoo-7.0.20130219-r5.ebuild,v 1.2 2013/03/11 03:10:59 patrick Exp $

EAPI="5"

inherit eutils distutils user versionator

BASE_VERSION="$( get_version_component_range 1-2 )"

DESCRIPTION="Open Source ERP & CRM"
HOMEPAGE="http://www.odoo.com/"
SRC_URI="http://nightly.odoo.com/${BASE_VERSION}/nightly/src/${PN}_${PV}.tar.gz"

SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
IUSE="+postgres ldap ssl"

CDEPEND="postgres? ( dev-db/postgresql[server] )
	dev-python/pytz
	dev-python/simplejson
	dev-python/requests
	dev-python/pyPdf
	dev-python/pyparsing
	dev-python/passlib
	virtual/python-imaging[jpeg]
	dev-python/decorator
	dev-python/psutil
	dev-python/docutils
	dev-python/lxml
	dev-python/psycopg:2
	dev-python/pychart
	dev-python/reportlab
	media-gfx/pydot
	dev-python/vobject
	dev-python/mako
	dev-python/pyyaml
	dev-python/Babel
	ldap? ( dev-python/python-ldap )
	dev-python/python-openid
	dev-python/werkzeug
	dev-python/xlwt
	dev-python/feedparser
	dev-python/python-dateutil
	dev-python/pywebdav
	ssl? ( dev-python/pyopenssl )
	dev-python/vatnumber
	dev-python/mock
	dev-python/unittest2
	dev-python/jinja
	dev-libs/libxslt
	media-gfx/wkhtmltopdf
"

RDEPEND="${CDEPEND}"
DEPEND="${CDEPEND}"

ODOO_USER="odoo"
ODOO_GROUP="odoo"

S="${WORKDIR}/${PN}"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_unpack() {
	unpack ${A}

	mv ${WORKDIR}/${PN}-* $S
}

src_install() {
	distutils_src_install

	newinitd "${FILESDIR}/odoo.initd" "${PN}"
	newconfd "${FILESDIR}/odoo.confd" "${PN}"
	keepdir /var/log/odoo

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/odoo.logrotate odoo || die
	
	dodir /etc/odoo
	insinto /etc/odoo
	newins "${FILESDIR}"/odoo.cfg odoo.cfg || die

	dodir /var/lib/odoo
	keepdir /var/lib/odoo
}

pkg_preinst() {
	enewgroup ${ODOO_GROUP}
	enewuser ${ODOO_USER} -1 -1 -1 ${ODOO_GROUP}

	fowners ${ODOO_USER}:${ODOO_GROUP} /var/log/odoo
	fowners ${ODOO_USER}:${ODOO_GROUP} /var/lib/odoo

	use postgres || sed -i '6,8d' "${D}/etc/init.d/odoo" || die "sed failed"
}

pkg_postinst() {
	elog "In order to create the database user, run:"
	elog " emerge --config '=${CATEGORY}/${PF}'"
	elog "Be sure the database is started before"
	elog
	elog "Use odoo web interface in order to create a "
	elog "database for your company."
}

psqlquery() {
	psql -q -At -U postgres -d template1 -c "$@"
}

pkg_config() {
	einfo "In the following, the 'postgres' user will be used."
	if ! psqlquery "SELECT usename FROM pg_user WHERE usename = '${ODOO_USER}'" | grep -q ${ODOO_USER}; then
		ebegin "Creating database user ${ODOO_USER}"
		createuser --username=postgres --createdb --no-adduser ${ODOO_USER}
		eend $? || die "Failed to create database user"
	fi
}
