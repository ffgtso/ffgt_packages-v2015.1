# Copyright (C) 2016 Kai 'wusel' Siering <wusel+src@uu.org>
# This is free software, licensed under the Apache 2.0 license.

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-luci-macconfig
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)

define Package/gluon-luci-macconfig
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Luci module for setting flags governing MAC calculation
  DEPENDS:=+gluon-luci-admin +gluon-mesh-batman-adv
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-luci-macconfig,i18n)
endef

define Package/gluon-luci-macconfig/install
	$(CP) ./files/* $(1)/
	$(call GluonInstallI18N,gluon-luci-macconfig,$(1))
endef

$(eval $(call BuildPackage,gluon-luci-macconfig))
