# Copyright (C) 2015 Kai 'wusel' Siering <wusel+src at uu.org>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-luci-geolocate
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-luci-geolocate
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Luci module for WIFI-based geolocalization
  DEPENDS:=+gluon-luci-admin
endef

define Package/gluon-luci-geolocate/description
	Luci module for WIFI-based geolocalization
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-luci-geolocate/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-luci-geolocate))
