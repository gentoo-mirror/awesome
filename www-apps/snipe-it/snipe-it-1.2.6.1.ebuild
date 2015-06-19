# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apps/ampache/ampache-3.5.4.ebuild,v 1.2 2012/06/22 21:24:02 mabi Exp $

EAPI="5"

inherit webapp git-2 depend.php

DESCRIPTION="A free open source IT asset/license management system built in PHP on Laravel and Bootstrap."
HOMEPAGE="http://snipeitapp.com"

EGIT_REPO_URI="https://github.com/snipe/snipe-it.git"
[[ ${PV} == "9999" ]] || EGIT_COMMIT=v${PV}

LICENSE="AGPL-3"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

RDEPEND=">=dev-lang/php-5.4[fileinfo,gd,sqlite]
	dev-libs/libmcrypt
	dev-php/pecl-imagick"
DEPEND="dev-php/composer"

need_php_httpd

pkg_pretend() {
	# Check Github API token
	if [[ -n "$GITHUB_API_TOKEN" ]] ; then
		einfo "Using Github API token \"$GITHUB_API_TOKEN\" from environment variable GITHUB_API_TOKEN ..."
	else
		eerror "Please specify a Github API key in GITHUB_API_TOKEN environment"
		eerror "variable to avoid exhausting the Github API limit when installing"
		eerror "vendor files using PHP's composer."
		eerror "You can get your Github API token using: "
		eerror "$ curl -u \"yourgithubname\" https://api.github.com/authorizations."
		
		die "Please specify a Github API key in GITHUB_API_TOKEN environment variable!"
	fi
}

src_prepare() {

	# Fix composer lock
	sed -s 's/\^1.0.2/~1.0.2/g' -i composer.lock
	sed -s 's#https://api.github.com/repos/d11wtq/boris/zipball/125dd4e5752639af7678a22ea597115646d89c6e#https://github.com/borisrepl/boris/archive/v1.0.8.zip#g' -i composer.lock

    # Composer might create this
    addpredict /var/lib/net-snmp/mib_indexes

    # Add Github API token to composer file
	composer config -g github-oauth.github.com "$GITHUB_API_TOKEN"

	einfo "Running composer  ..."
	composer install
	composer dump-autoload

	# Prepare config files in order to protect them as webapp configfile
	cp "app/config/production/app.example.php" "app/config/production/app.php"
	cp "app/config/production/database.example.php" "app/config/production/database.php"
	cp "app/config/production/mail.example.php" "app/config/production/mail.php"
}

src_install() {
	webapp_src_preinst

	dodoc "$FILESDIR/nginx.conf"

	insinto "${MY_HTDOCSDIR}"
	doins -r .

	webapp_postinst_txt en "${FILESDIR}"/installdoc.txt
	webapp_serverowned -R "${MY_HTDOCSDIR}/"{"app/storage","public/uploads"}

	webapp_configfile "${MY_HTDOCSDIR}/app/config/production/app.php"
	webapp_configfile "${MY_HTDOCSDIR}/app/config/production/database.php"
	webapp_configfile "${MY_HTDOCSDIR}/app/config/production/mail.php"
	webapp_configfile "${MY_HTDOCSDIR}/bootstrap/start.php"

	webapp_src_install
	fperms -R 0660 "${MY_HTDOCSDIR}/"{"app/storage","public/uploads"}
}
