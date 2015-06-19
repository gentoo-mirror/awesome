# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apps/redmine/redmine-2.4.5.ebuild,v 1.1 2014/06/01 18:11:37 pva Exp $

EAPI="5"
USE_RUBY="ruby19 ruby20 ruby21 ruby22"
inherit eutils depend.apache ruby-ng user

DESCRIPTION="Redmine is a flexible project management web application written using Ruby on Rails framework"
HOMEPAGE="http://www.redmine.org/"
SRC_URI="http://www.redmine.org/releases/${P}.tar.gz"

BACKLOG_GIT_REPO_URI="https://github.com/backlogs/redmine_backlogs.git"
BACKLOG_GIT_COMMIT="v1.0.6"

RECURRING_TASKS_GIT_REPO_URI="https://github.com/nutso/redmine-plugin-recurring-tasks.git"
RECURRING_TASKS_GIT_COMMIT="v1.6.0"

# backlogs plugin does not support redmine 3, masked for now
KEYWORDS=""
LICENSE="GPL-2"
SLOT="0"
IUSE="+ldap +imagemagick passenger backlog recurring-tasks postgres sqlite +mysql"

ruby_add_rdepend "
	passenger? ( || ( www-apache/passenger www-servers/nginx[nginx_modules_http_passenger] ) )
	"
DEPEND="
	dev-ruby/bundler
	imagemagick? ( media-gfx/imagemagick )
	"
REDMINE_DIR="/var/lib/${PN}"

pkg_setup() {
	enewgroup redmine
	enewuser redmine -1 -1 "${REDMINE_DIR}" redmine
}

all_ruby_prepare() {
	rm -r log files/delete.me || die

	# bug #406605
	rm .gitignore .hgignore || die

	echo "CONFIG_PROTECT=\"${EPREFIX}${REDMINE_DIR}/config\"" > "${T}/50${PN}"
	echo "CONFIG_PROTECT_MASK=\"${EPREFIX}${REDMINE_DIR}/config/locales ${EPREFIX}${REDMINE_DIR}/config/settings.yml\"" >> "${T}/50${PN}"

	# remove ldap staff module if disabled to avoid #413779
	use ldap || rm app/models/auth_source_ldap.rb || die

	# TODO(rlutz,20150619): use git eclass to clone repos into disfiles and copy them from there
	if use backlog ; then
		pushd plugins
		git clone ${BACKLOG_GIT_REPO_URI} redmine_backlogs
		cd redmine_backlogs
		git checkout ${BACKLOG_GIT_COMMIT}

		# Set fixed icalendar version to be compatible with i.e.
		# https://github.com/buschmais/redmics/blob/master/Gemfile
		sed -s 's#gem "icalendar"#gem "icalendar", ">=1.1.6", "<=1.5.3"#' -i Gemfile

        # from plugins/redmine_backlogs/redmine_install.sh 
        sed -i -e 's=.*gem ["'\'']capybara["'\''].*==g' Gemfile
        sed -i -e 's=gem "simplecov".*=gem "simplecov", "~>0.9.1"=g' Gemfile

		popd
	fi
	
	if use recurring-tasks ; then
		pushd plugins
		git clone ${RECURRING_TASKS_GIT_REPO_URI} recurring_tasks
		cd recurring_tasks
		git checkout ${RECURRING_TASKS_GIT_COMMIT}
		popd
	fi
	
	# Enable database adapter
	cp config/database.yml.example config/database.yml
	if use postgres ; then
		sed -s 's/mysql2/postgresql/g' -i config/database.yml
	elif use sqlite ; then
		sed -s 's/mysql2/sqlite3/g' -i config/database.yml
	fi # mysql is enable by default
	
	# Run bundler to install dependencies
	local without="development test"
    local flag; for flag in imagemagick; do
        without+="$(use $flag || echo ' '$flag)"
    done

    # Deployment requires a valid Gemfile.lock which is not available from upstream
    #local bundle_args="--deployment ${without:+--without ${without}}"
    local bundle_args="--path vendor/bundle ${without:+--without=\"${without}\"}"
	
	einfo "Running bundle install ${bundle_args} in ..."
	/usr/bin/bundle install ${bundle_args} || die "bundler failed"	
}

all_ruby_install() {

	dodoc doc/{CHANGELOG,INSTALL,README_FOR_APP,RUNNING_TESTS,UPGRADING}
	rm -fr doc || die
	dodoc README.rdoc
	rm README.rdoc || die

	keepdir /var/log/${PN}
	dosym /var/log/${PN}/ "${REDMINE_DIR}/log"

	insinto "${REDMINE_DIR}"
	doins -r .
	keepdir "${REDMINE_DIR}/files"
	keepdir "${REDMINE_DIR}/public/plugin_assets"

	fowners -R redmine:redmine \
		"${REDMINE_DIR}/config" \
		"${REDMINE_DIR}/files" \
		"${REDMINE_DIR}/public/plugin_assets" \
		"${REDMINE_DIR}/tmp" \
		/var/log/${PN}

	fowners redmine:redmine "${REDMINE_DIR}"

	# protect sensitive data, see bug #406605
	fperms -R go-rwx \
		"${REDMINE_DIR}/config" \
		"${REDMINE_DIR}/files" \
		"${REDMINE_DIR}/tmp" \
		/var/log/${PN}

	if use passenger; then
		has_apache
		insinto "${APACHE_VHOSTS_CONFDIR}"
		doins "${FILESDIR}/10_redmine_vhost.conf"
	else
		newconfd "${FILESDIR}/${PN}.confd" ${PN}
		newinitd "${FILESDIR}/${PN}.initd" ${PN}
	fi
	doenvd "${T}/50${PN}"
}

pkg_postinst() {
	einfo
	if [ -e "${EPREFIX}${REDMINE_DIR}/config/initializers/session_store.rb" -o -e "${EPREFIX}${REDMINE_DIR}/config/initializers/secret_token.rb" ]; then
		elog "Execute the following command to upgrade environment:"
		elog
		elog "# emerge --config \"=${CATEGORY}/${PF}\""
		elog
		elog "For upgrade instructions take a look at:"
		elog "http://www.redmine.org/wiki/redmine/RedmineUpgrade"
	else
		elog "Execute the following command to initlize environment:"
		elog
		elog "# cd ${EPREFIX}${REDMINE_DIR}"
		elog "# cp config/database.yml.example config/database.yml"
		elog "# \${EDITOR} config/database.yml"
		elog "# chown redmine:redmine config/database.yml"
		elog "# emerge --config \"=${CATEGORY}/${PF}\""
		elog
		elog "Installation notes are at official site"
		elog "http://www.redmine.org/wiki/redmine/RedmineInstall"
	fi
	einfo
}

pkg_config() {

	if [ ! -e "${EPREFIX}${REDMINE_DIR}/config/database.yml" ]; then
		eerror "Copy ${EPREFIX}${REDMINE_DIR}/config/database.yml.example to ${EPREFIX}${REDMINE_DIR}/config/database.yml"
		eerror "then edit this file in order to configure your database settings for \"production\" environment."
		die
	fi

	local RAILS_ENV=${RAILS_ENV:-production}
	if [ ! -L /usr/bin/ruby ]; then
		eerror "/usr/bin/ruby is not a valid symlink to any ruby implementation."
		eerror "Please update it via 'eselect ruby'"
		die
	fi
	local RUBY=${RUBY:-ruby}

	cd "${EPREFIX}${REDMINE_DIR}" || die
	if [ -e "${EPREFIX}${REDMINE_DIR}/config/initializers/session_store.rb" ]; then
		einfo
		einfo "Generating secret token."
		einfo
		rm config/initializers/session_store.rb || die
		RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake generate_secret_token || die
	fi
	if [ -e "${EPREFIX}${REDMINE_DIR}/config/initializers/secret_token.rb" ]; then
		einfo 
		einfo "Upgrading database."
		einfo

		einfo "Migrating database."
		einfo 
		RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake db:migrate || die
		einfo "Upgrading the plugin migrations."
		RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake redmine:plugins:migrate || die
		einfo "Clear the cache and the existing sessions."
		RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake tmp:cache:clear || die
		RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake tmp:sessions:clear || die
	else
		einfo
		einfo "Initializing database."
		einfo

		einfo "Generating a session store secret."
		${RUBY} -S rake generate_secret_token || die
		einfo "Creating the database structure."
		RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake db:migrate || die
		einfo "Populating database with default configuration data."
		RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake redmine:load_default_data || die
		chown redmine:redmine "${EPREFIX}${REDMINE_DIR}"/log/production.log
		einfo
		einfo "If you use sqlite3, please do not forget to change the ownership of the sqlite files."
		einfo
		einfo "# cd \"${EPREFIX}${REDMINE_DIR}\""
		einfo "# chown redmine:redmine db/ db/*.sqlite3"
		einfo
	fi

	if use backlog ; then
		RAILS_ENV="${RAILS_ENV}" ${RUBY} -S rake redmine:backlogs:install
	fi
}
