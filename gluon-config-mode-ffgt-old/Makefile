# Copyright (C) 2012 Nils Schneider <nils at nilsschneider.net>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-ffgt-old
PKG_VERSION:=2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-config-mode-ffgt-old
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Luci based config mode for user friendly setup of new meshnodes
  DEPENDS:=+gluon-luci-core +gluon-lock-password +gluon-node-info +gluon-simple-tc +uhttpd +dnsmasq +ip
  PROVIDES:=gluon-config-mode
endef

define Package/gluon-config-mode-ffgt-old/description
	Luci based config mode
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-config-mode-ffgt-old/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-config-mode-ffgt-old))
