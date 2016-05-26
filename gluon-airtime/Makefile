include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-airtime
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-airtime
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Airtime reporter
  DEPENDS:=+gluon-core
endef

define Build/Prepare
        mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-airtime/install
        $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-airtime))

