include $(TOPDIR)/rules.mk

PKG_NAME:=fastd-traffic-status
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/fastd-traffic-status
  SECTION:=net
  CATEGORY:=Libraries
  TITLE:=Adds fastd traffic statistics to alfred
  DEPENDS:=+lua +fastd
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
	CFLAGS="$(TARGET_CFLAGS)" CPPFLAGS="$(TARGET_CPPFLAGS)" $(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
endef

define Package/fastd-traffic-status/install
	$(INSTALL_DIR) $(1)/lib/gluon/announce/statistics.d
	$(CP) $(PKG_BUILD_DIR)/traffic_fastd $(1)/lib/gluon/announce/statistics.d/traffic_fastd
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fastd-status $(1)/usr/bin/fastd-status
endef

$(eval $(call BuildPackage,fastd-traffic-status))
