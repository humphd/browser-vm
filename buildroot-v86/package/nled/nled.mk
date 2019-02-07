################################################################################
#
# nled
#
################################################################################

NLED_VERSION = 2.52
NLED_SITE = https://cdot.senecacollege.ca/software/nled
NLED_SOURCE = nled_2_52_src.tgz
NLED_LICENSE = GPL-2.0+
NLED_INSTALL_STAGING = YES
NLED_DEPENDENCIES = ncurses

# We need to override the C compiler used in the Makefile to 
# use buildroot's cross-compiler instead of cc.  Switch cc to $(CC)
# so we can override the variable via env vars.
define NLED_MAKEFILE_FIXUP
	$(SED) 's/cc $$(CCOPTIONS)/$$(CC) -static $$(CPPFLAGS) $$(CFLAGS) -c/g' $(@D)/Makefile
	$(SED) 's/cc -o/$$(CC) $$(LDFLAGS) -o/g' $(@D)/Makefile
endef

NLED_PRE_BUILD_HOOKS += NLED_MAKEFILE_FIXUP

define NLED_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) LDOPTIONS="-lncurses" LIBS="$(TARGET_CFLAGS) -lncurses"
endef

define NLED_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/nled $(TARGET_DIR)/usr/bin/nled
endef

define NLED_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/nled $(STAGING_DIR)/usr/bin/nled
endef

$(eval $(generic-package))
