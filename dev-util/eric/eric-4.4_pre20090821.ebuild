# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
NEED_PYTHON="2.4"
SUPPORT_PYTHON_ABIS="1"

inherit eutils python

MY_PN="${PN}4"
MY_PV="${PV/_pre/-snapshot-}"
MY_P="${MY_PN}-${MY_PV}"

LANGS="cs de es fr it ru tr zh_CN"

DESCRIPTION="A full featured Python IDE written in PyQt4 using the QScintilla editor widget"
HOMEPAGE="http://eric-ide.python-projects.org/"
SRC_URI="mirror://sourceforge/eric-ide/${MY_P}.tar.gz"
RESTRICT="mirror"

SLOT="4"
LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
IUSE="spell"

for L in ${LANGS}; do
	SRC_URI="${SRC_URI}
		linguas_${L}? ( mirror://sourceforge/eric-ide/${MY_PN}-i18n-${L/zh_CN/zh_CN.GB2312}-${MY_PV}.tar.gz )"
	IUSE="${IUSE} linguas_${L}"
done

DEPEND=">=dev-python/PyQt4-4.4[assistant,svg,webkit,X]
	>=dev-python/qscintilla-python-2.2[qt4]"
RDEPEND="${DEPEND}
	>=dev-python/chardet-1.0.1
	>=dev-python/pygments-1.0
	>=dev-python/simplejson-2.0.9"
PDEPEND="spell? ( dev-python/pyenchant )"

S="${WORKDIR}"/${MY_P}

src_prepare() {
	epatch "${FILESDIR}"/eric-snapshot-20090627-no-interactive.patch

	# remove bundled copies, bug #283148
	rm -rf "${S}"/eric/ThirdParty
}

src_install() {
	installation() {
		"$(PYTHON)" install.py \
			-b "/usr/bin" \
			-i "${D}" \
			-d "$(python_get_sitedir)" \
			-c \
			-z
	}
	python_execute_function installation

	make_desktop_entry eric4 eric4 \
			"$(python_get_sitedir)/eric4/icons/default/eric.png" \
			"Development;IDE;Qt"
}

pkg_postinst() {
	python_mod_optimize eric4{,config.py,plugins}

	elog
	elog "If you want to use eric4 with mod_python, have a look at"
	elog "'${ROOT%/}$(python_get_sitedir)/eric4/patch_modpython.py'."
	elog
	elog "The following packages will give eric extended functionality:"
	elog "  dev-python/pylint"
	elog "  dev-python/pysvn"
	elog
	elog "This version has a plugin interface with plugin-autofetch from"
	elog "the application itself. You may want to check those as well."
	elog
}

pkg_postrm() {
	python_mod_cleanup
}
