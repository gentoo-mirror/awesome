# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/icinga-web/icinga-web-1.11.2.ebuild,v 1.1 2014/10/16 23:34:09 prometheanfire Exp $

EAPI="5"

inherit depend.apache eutils user multilib git-2

DESCRIPTION="Icinga Web 2 - Newest Frontend for icinga2"
HOMEPAGE="http://www.icinga.org/"
EGIT_REPO_URI="git://git.icinga.org/icingaweb2.git"
[[ ${PV} == "9999" ]] || EGIT_COMMIT="v${PV/_beta/-beta}"

LICENSE="GPL-2"
SLOT="0"
IUSE="apache2 ldap mysql nginx postgres"
DEPEND=">=net-analyzer/icinga2-2.1.1
		dev-lang/php[apache2?,cli,gd,json,intl,ldap?,mysql?,pdo,postgres?,sockets,ssl,xslt,xml]
		dev-php/pecl-imagick
		apache2? ( >=www-servers/apache-2.4.0 )
		nginx? ( >=www-servers/nginx-1.7.0 )"
RDEPEND="${DEPEND}"
KEYWORDS="~amd64"

use apache2 && want_apache2

pkg_setup() {
	if use apache2 ; then
		depend.apache_pkg_setup
	fi

	enewgroup icingaweb2
	enewgroup icingacmd
	use nginx && usermod -a -G icingacmd,icingaweb2 nginx
	use apache2 && usermod -a -G icingacmd,icingaweb2 apache2
}

pkg_config() {

	if [[ -d /etc/icingaweb2 ]] ; then
	
		einfo "Updating existing installation ..."

	else

		einfo "Running first time setup ..."

		einfo "Creating configuration directory ..."
		/usr/share/${PN}/bin/icingacli setup config directory

		einfo "Creating authentication token for web setup ..."
		/usr/share/${PN}/bin/icingacli setup token create

		if use apache2 ; then
			einfo "The following might be useful for your Apache2 configuration:"
			/usr/share/${PN}/bin/icingacli setup config webserver apache --document-root /usr/share/${PN}/public
		fi

		if use nginx ; then
			einfo "The following might be useful for your NGinx configuration:"
			/usr/share/${PN}/bin/icingacli setup config webserver nginx --document-root /usr/share/${PN}/public
		fi
	fi

	einfo "All done."
}

src_install() {
  mkdir -p "${D}/usr/share/${PN}"
  cp -R ${S}/* ${D}/usr/share/${PN}
  chmod -R a+rX ${D}/usr/share/${PN}/public
}

pkg_postinst() {
	einfo "Run 'emerge --config net-analyzer/icinga-web2' to finish setup."
}
