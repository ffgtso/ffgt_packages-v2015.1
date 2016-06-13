include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-config-mode-contact-info-ffgt
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(GLUONDIR)/include/package.mk

PKG_CONFIG_DEPENDS += $(GLUON_I18N_CONFIG)


define Package/gluon-config-mode-contact-info-ffgt
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Set a custom string that will be distributed in the mesh.
  DEPENDS:=gluon-config-mode-core-virtual +gluon-node-info +ffgt-geolocate
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
	$(call GluonBuildI18N,gluon-config-mode-contact-info-ffgt,i18n)
endef

define Package/gluon-config-mode-contact-info-ffgt/install
	$(CP) ./files/* $(1)/
	$(call GluonInstallI18N,gluon-config-mode-contact-info-ffgt,$(1))
endef

$(eval $(call BuildPackage,gluon-config-mode-contact-info-ffgt))
