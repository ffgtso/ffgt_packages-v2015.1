include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-announce-ffgt
PKG_VERSION:=1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-announce-ffgt
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-core +luci-lib-json +lua-ethtool-stats +gluon-announce
  TITLE:=Addon Lua scripts announcing various additional information
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-announce-ffgt/install
	$(CP) ./files/* $(1)/
	$(MV) $(1)/lib/gluon/announce/nodeinfo.d/software/firmware-ffgt $(1)/lib/gluon/announce/nodeinfo.d/software/firmware
endef

$(eval $(call BuildPackage,gluon-announce-ffgt))
