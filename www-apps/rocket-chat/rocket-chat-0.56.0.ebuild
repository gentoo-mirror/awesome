# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit user

DESCRIPTION="The ultimate open source web chat platform"
HOMEPAGE="https://rocket.chat/"
SRC_URI="https://github.com/RocketChat/Rocket.Chat/archive/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="dev-db/mongodb
		 net-libs/nodejs
		 media-gfx/imagemagick[jpeg,png]"
DEPEND="${RDEPEND}"

NODEJS_VERSION="4.6.1"
ROCKET_DEST="/usr/share/${PN}"
ROCKET_LOG="/var/log/${PN}"
ROCKET_USER="rocket"
ROCKET_GROUP="daemon"

pkg_setup() {
	enewgroup ${ROCKET_GROUP}
	enewuser ${ROCKET_USER} -1 -1 ${ROCKET_DEST} "${ROCKET_GROUP}"
}

src_unpack()
{
	default
	mv "$WORKDIR/Rocket.Chat-${PV}" "$WORKDIR/$P"
}

src_prepare()
{
	default
	npm install n &>/dev/null || die "Error installing n"
	N_PREFIX="${WORKDIR}/${P}/node"
	elog "Installing node v${NODEJS_VERSION} in $N_PREFIX ..."
	N_PREFIX=$N_PREFIX ./node_modules/n/bin/n -q ${NODEJS_VERSION} &>/dev/null || die "Error installing node v${NODEJS_VERSION}"
	PATH=$N_PREFIX/bin:$PATH
	elog "Using $(which node) $(node --version) ..."
	pushd "programs/server" &>/dev/null
	elog "Installing rocker-chat ..."
	npm install || die "Error in npm install"
	popd
}

src_install()
{
	mkdir -p "${D}${ROCKET_DEST}"
	cp -a . "${D}${ROCKET_DEST}"

	keepdir "${ROCKET_LOG}"
	fowners "${ROCKET_USER}:${ROCKET_GROUP}" "${ROCKET_LOG}"

	# This is to enable webhook integration with script support
	keepdir "${ROCKET_DEST}/.babel-cache"
	fowners "${ROCKET_USER}:${ROCKET_GROUP}" "${ROCKET_DEST}/.babel-cache"

	newconfd "${FILESDIR}/${PN}-conf.d" "rocket-chat"
	newinitd "${FILESDIR}/${PN}-init.d" "rocket-chat"
}
