# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:i $

EAPI=5

inherit php-pear-r1

DESCRIPTION="WebDAV stream wrapper class"

LICENSE="PHP"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ia64 ~ppc ~ppc64 ~s390 ~sh sparc x86"
IUSE=""

RDEPEND="dev-lang/php
dev-php/PEAR-HTTP_Request"
