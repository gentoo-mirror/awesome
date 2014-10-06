# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} )
inherit git-2 python-single-r1 user

DESCRIPTION="A federated, autonomous-style platform to host various forms of media"
HOMEPAGE="http://mediagoblin.org/"

EGIT_REPO_URI="https://gitorious.org/mediagoblin/mediagoblin.git"
EGIT_COMMIT="v${PV}"

LICENSE="AGPLv3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+nginx +ldap"

DEPEND="${PYTHON_DEPS}
		dev-db/postgresql-server 
		dev-db/postgresql-base
		dev-python/virtualenv[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

pkg_setup() {
	enewuser mediagoblin -1 /sbin/nologin /usr/share/mediagoblin
}

src_unpack() {
	git-2_src_unpack
	cd ${S}
	git submodule init && git submodule update
}

src_prepare() {
	
	einfo "Setting up in-package virtualenv ..."
	virtualenv --python=python2 .
	
	einfo "Activating virtuelenv ..."
	source bin/activate
	
	einfo "Installing dependencies ..."
	./bin/easy_install lxml Pillow psycopg2
	use ldap && ./bin/easy_install python-ldap
	use nginx && ./bin/easy_install flup

	einfo "Running python setup ..."
	python setup.py develop

	# Enable Postgresql
	sed -s 's/# sql_engine = postgresql:\/\/\/mediagoblin/sql_engine = postgresql:\/\/\/mediagoblin/g' -i mediagoblin.ini || die "Could not enable PostgreSQL in mediagoblin.ini"

	# Add ldap config
	if use ldap ; then
		cat <<-EOF >> mediagoblin.ini
		# [[mediagoblin.plugins.ldap]]
		#[[[server1]]]
		#LDAP_SERVER_URI = 'ldap://ldap.testathon.net:389'
		#LDAP_USER_DN_TEMPLATE = 'cn={username},ou=users,dc=testathon,dc=net'
		EOF
	fi

	# Leave virtuelenv
	deactivate
}

src_install() {

    # Replace hardcoded install dir
    grep "${WORKDIR}/${PF}" * -R | while read f ; do
        file=$(echo $f | awk -F':' '{print $1}')
        sed -s "s#${WORKDIR}/${PF}#/usr/share/mediagoblin#g" -i $file
    done

	dodir "/usr/share/mediagoblin"
	cp -a "${WORKDIR}/${PF}/"* "${D}/usr/share/mediagoblin/"
	fowners -hR mediagoblin: "/usr/share/mediagoblin/"

	use nginx && dodoc ${FILESDIR}/nginx.conf

	doinitd "${FILESDIR}/init.d/mediagoblin"
	doinitd	"${FILESDIR}/init.d/celery-worker"

	doconfd "${FILESIDR}/conf.d/mediagoblin"
	doconfd "{$FILESDIR}/conf.d/celery-worker"

	dodir "/usr/share/mediagoblin/user_dev"
	fperms 0755 "/usr/share/mediagoblin/user_dev"
	fowners mediagoblin "/usr/share/mediagoblin/user_dev"
}

pkg_postinst() {
	einfo "Mediagoblin was successfully installed."
	einfo ""
	einfo "If this is a fresh installation, edit \"/usr/share/mediagoblin/mediagoblin.ini\" and "
	einfo "rename as follows: "
	einfo "$ cp /usr/share/mediagoblin/mediagoblin.ini /usr/share/mediagoblin/mediagoblin_local.ini"
	einfo ""
	einfo "Further create a postgresql user and database as follows:"
	einfo ""
	einfo "$ sudo -u postgres createuser -A -D mediagoblin"
	einfo "$ sudo -u postgres createdb -E UNICODE -O mediagoblin mediagoblin"
	einfo ""
	einfo ""
	einfo "Run the following command to initial configure or update your instance:"
	einfo "$ emerge --config \"=${CATEGORY}/${PF}\""
	einfo ""
	einfo "Additional installation and upgrade instructions can be found here: "
	einfo "http://mediagoblin.readthedocs.org/en/v${PV}/siteadmin/deploying.html"
}

pkg_config() {

	einfo "Do you want to upgrade an existing instance? [Y|n] "
	do_upgrade=""
	while true
	do
		read -r do_upgrade
		if [[ $do_upgrade == "n" || $do_upgrade == "N" ]] ; then do_upgrade="" && break
		elif [[ $do_upgrade == "y" || $do_upgrade == "Y" || $do_upgrade == "" ]] ; then do_upgrade=1 && break
		else eerror "Please type either \"Y\" or \"N\" ... " ; fi
	done	

	pushd /usr/share/mediagoblin &>/dev/null
	source bin/activate

	if [[ -n "$do_upgrade" ]] ; then
		einfo "Updating database structure ..."
		sudo -u mediagoblin ./bin/gmg dbupdate

	else
		einfo "Populating database structure ..."
		sudo -u mediagoblin ./bin/gmg dbupdate

		einfo "Creating admin user ..."
		sudo -u mediagoblin ./bin/gmg adduser
		sudo -u mediagoblin ./bin/gmg makeadmin admin

		if use nginx ; then
			einfo "Configuring nginx ..."
			echo -n "Please enter the servername(s) for this instance e.g. \"example.com www.example.com\": "
			read server_names
			server_name=$(echo $server_names | awk -F" " '{print $1}')
			site_conf="/etc/nginx/sites-available/${server_name}"
			einfo "Preparing nginx site configuration in \"$site_conf\" ..."
			cp "/usr/share/doc/${PF}/nginx.conf.bz2" "${site_conf}.bz2"
			bunzip2 "${site_conf}.bz2"
			sed -s "s/<SERVER_NAMES>/${server_names}/g" -i "${site_conf}"
			sed -s "s/<SERVER_NAME>/${server_name}/g" -i "${site_conf}"
		fi
	fi

	deactivate
	einfo "All done."
}
