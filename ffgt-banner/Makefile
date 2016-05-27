include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-banner
PKG_VERSION:=1
PKG_RELEASE:=$(GLUON_VERSION).$(GLUON_SITE_CODE)-$(GLUON_RELEASE).$(GLUON_CONFIG_VERSION)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ffgt-banner
  SECTION:=ffgt
  CATEGORY:=Customization
  TITLE:=Banner file replacement
  DEPENDS:=+gluon-core +busybox
  MAINTAINER:=Freifunk Guetersloh <technik@guetersloh.freifunk.net>
  URL:=https://github.com/ffgtso/ffgt_packages-v2015.1
  SOURCE:=git@github.com:ffgtso/ffgt_packages-v2015.1.git
endef

define Package/ffgt-banner/description
	Banner file replacement
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/ffgt-banner/preinst
#!/bin/sh
cd "$${IPKG_INSTROOT}/etc/"
if [ -h "./banner" ] ; then
	/bin/rm "./banner"
elif [ -f "./banner" ] ; then
	/bin/mv "./banner" "./banner.openwrt"
fi
/bin/ln -s "./banner.openwrt" "./banner"
exit 0
endef

define Package/ffgt-banner/postinst
#!/bin/sh
cd "$${IPKG_INSTROOT}/etc/"
[ -h "./banner" ] && /bin/rm -f "./banner"
/bin/ln -s "./banner.ffgt" "./banner"
echo "" >> "./banner.ffgt"
#echo "OpenWRT-Basis: `grep ", r" ./banner.openwrt`"
#rm ./banner.openwrt
exit $$?
endef

define Package/ffgt-banner/prerm
#!/bin/sh
cd "$${IPKG_INSTROOT}/etc/"
if [ -h "./banner" ] ; then
	[[ "$$(readlink -n ./banner)" == "./banner.ffgt" ]] && \
	/bin/rm -f "./banner" && \
	[ -f "./banner.openwrt" ] && \
	/bin/ln -s "./banner.openwrt" "./banner"
fi
exit 0
endef

define Package/ffgt-banner/install
	$(CP) ./files/* $(1)/

#	$(INSTALL_DIR) $(1)/etc/
#	$(INSTALL_DATA) ./files/etc/banner.ffgt $(1)/etc/
endef

$(eval $(call BuildPackage,ffgt-banner))
