include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-site-select-ffgt
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-config-mode-site-select-ffgt
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Package for (automatic) selection of a site.conf file
  DEPENDS:=+ffgt-geolocate
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-config-mode-site-select-ffgt/install
	mkdir -p $(1)/etc/config/
	mkdir -p $(1)/lib/gluon/site-select/
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-config-mode-site-select-ffgt))
