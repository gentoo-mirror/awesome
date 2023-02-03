# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit git-r3

DESCRIPTION="Cast macOS and Linux Audio/Video to your Google Cast and Sonos Devices"
HOMEPAGE="http://mkchromecast.com"

EGIT_REPO_URI="https://github.com/muammar/mkchromecast"
[[ ${PV} == "9999" ]] || EGIT_COMMIT=${PV}
[[ ${PV} == "0.3.9" ]] && EGIT_COMMIT="d789d128ab9c5ef873216932efc3c6049ead4ee9"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ffmpeg qt"

DEPEND=">=dev-python/pychromecast-7.2.1
		media-sound/pulseaudio
		dev-python/psutil
		media-sound/pavucontrol
		media-libs/mutagen
		dev-python/flask
		media-sound/vorbis-tools
		media-sound/sox
		media-sound/lame
		media-libs/flac
		ffmpeg? ( media-video/ffmpeg[vorbis] )
		qt? ( dev-python/PyQt5 )
		net-misc/yt-dlp"
RDEPEND="${DEPEND}"
BDEPEND=""

S=$WORKDIR

src_compile() {
	cd ${P}
	python3 setup.py build
}

src_install() {
	cd ${P}
	einfo $D
	python3 setup.py install --prefix ${D}/usr
}
