PACKAGE            ?= $(NAME)
PACKAGE_URL        ?= github.com/krimtonz/kz
ifeq ($(origin PACKAGE_VERSION), undefined)
PACKAGE_VERSION	   := $(shell git describe --tags --dirty 2>/dev/null)
ifeq ('$(PACKAGE_VERSION)', '')
PACKAGE_VERSION		= unknown version
endif
endif
target              = mips64
CC                  = $(target)-gcc
LD                  = $(target)-g++
AS                  = $(target)-gcc -x assembler-with-cpp
OBJCOPY             = $(target)-objcopy
GRC                 = grc
GENHOOKS            = CPPFLAGS='$(subst ','\'',$(CPPFLAGS))' ./genhooks
CFILES              = *.c
SFILES              = *.S
RESFILES            = *.png
SRCDIR              = src
OBJDIR              = obj
BINDIR              = bin
LIBDIR              = lib
VCDIR               = vc
HOMEBOYDIR          = homeboy
PATCHDIR            = patch/dol
KZ_VERSIONS         = NZSE NZSJ NZSJ10
VC_VERSIONS         = NARJ NARE
NAME                = kz
RESDESC             = res.json

ADDRESS_FULL        = 0x80800060
ADDRESS_VC			= 0x8003DF60
ADDRESS_LITE        = 0x8003DF60
ADDRESS_LDR         = 0x80080000
ALL_CFLAGS          = -Iinclude -c -MMD -MP -std=gnu11 -Wall -ffunction-sections -fdata-sections -fno-reorder-blocks -mno-check-zero-division $(CFLAGS)
ALL_CPPFLAGS        = -DPACKAGE=$(PACKAGE) -DPACKAGE_URL=$(PACKAGE_URL) -DPACKAGE_VERSION=$(PACKAGE_VERSION) -DF3DEX_GBI_2 -DHB_DBG $(CPPFLAGS)
ALL_LDFLAGS         = -T gl-n64.ld -L$(LIBDIR) -nostartfiles -specs=nosys.specs -Wl,--gc-sections $(LDFLAGS)
ALL_LIBS            = $(LIBS)

KZ_VC               = $(foreach v,$(KZ_VERSIONS),kz-vc-$(v))
KZ_LITE             = $(foreach v,$(KZ_VERSIONS),kz-lite-$(v))
KZ_FULL				= $(foreach v,$(KZ_VERSIONS),kz-full-$(v))
LDR                 = $(foreach v,$(KZ_VERSIONS),ldr-kz-$(v))
LDRLITE             = $(foreach v,$(KZ_VERSIONS),ldr-kz-lite-$(v))

ELF-VC				= $(ELF-kz-vc-NZSE) $(ELF-kz-vc-NZSJ) $(ELF-kz-vc-NZSJ10)
ELF-FULL            = $(ELF-kz-full-NZSE) $(ELF-kz-full-NZSJ) $(ELF-kz-full-NZSJ10)
ELF-LITE            = $(ELF-kz-lite-NZSE) $(ELF-kz-lite-NZSJ) $(ELF-kz-lite-NZSJ10)

KZ-VC               = $(KZ-VC-NZSE) $(KZ-VC-NZSJ) $(KZ-VC-NZSJ10)
KZ-VC-NZSE			= $(OBJ-kz-vc-NZSE) $(ELF-kz-vc-NZSE) $(HOOKS-kz-vc-NZSE)
KZ-VC-NZSJ			= $(OBJ-kz-vc-NZSJ) $(ELF-kz-vc-NZSJ) $(HOOKS-kz-vc-NZSJ)
KZ-VC-NZSJ10		= $(OBJ-kz-vc-NZSJ10) $(ELF-kz-vc-NZSJ10) $(HOOKS-kz-vc-NZSJ10)
OBJ-VC				= $(OBJ-kz-vc-NZSE) $(OBJ-kz-vc-NZSJ) $(OBJ-kz-vc-NZSJ10)

KZ-FULL             = $(KZ-FULL-NZSE) $(KZ-FULL-NZSJ) $(KZ-FULL-NZSJ10)
KZ-FULL-NZSE		= $(OBJ-kz-full-NZSE) $(ELF-kz-full-NZSE) $(HOOKS-kz-full-NZSE)
KZ-FULL-NZSJ		= $(OBJ-kz-full-NZSJ) $(ELF-kz-full-NZSJ) $(HOOKS-kz-full-NZSJ)
KZ-FULL-NZSJ10		= $(OBJ-kz-full-NZSJ10) $(ELF-kz-full-NZSJ10) $(HOOKS-kz-full-NZSJ10)

KZ-LITE             = $(KZ-LITE-NZSE) $(KZ-LITE-NZSJ) $(KZ-LITE-NZSJ10)
KZ-LITE-NZSE        = $(OBJ-kz-lite-NZSE) $(ELF-kz-lite-NZSE) $(HOOKS-kz-lite-NZSE)
KZ-LITE-NZSJ        = $(OBJ-kz-lite-NZSJ) $(ELF-kz-lite-NZSJ) $(HOOKS-kz-lite-NZSJ)
KZ-LITE-NZSJ10      = $(OBJ-kz-lite-NZSJ10) $(ELF-kz-lite-NZSJ10) $(HOOKS-kz-lite-NZSJ10)

KZ-NZSE             = $(KZ-FULL-NZSE) $(KZ-VC-NZSE) $(KZ-LITE-NZSE)
KZ-NZSJ             = $(KZ-FULL-NZSJ) $(KZ-VC-NZSJ) $(KZ-LITE-NZSJ)
KZ-NZSJ10           = $(KZ-FULL-NZSJ10) $(KZ-VC-NZSJ10) $(KZ-LITE-NZSJ10)

VC                  = $(foreach v,$(VC_VERSIONS),kz-vc-$(v))

all                 :   $(KZ) $(KZ_LITE) $(VC)
clean               :
	rm -rf $(OBJDIR) $(BINDIR)
distclean           :   clean
	rm -rf build/*.z64 build/*.wad
clean-vc            :
	cd $(VCDIR) && make clean
clean-homeboy       :
	cd $(HOMEBOYDIR) && make clean

clean-all           :   clean clean-vc clean-homeboy
distclean-all       :   distclean clean-vc clean-homeboy

.PHONY              :   all clean distclean clean-vc clean-homeboyclean-all distclean-all

define bin_template
SRCDIR-$(1)         = $(5)
OBJDIR-$(1)         = obj/$(1)
BINDIR-$(1)         = bin/$(1)
HOOKSDIR-$(1)       = patch/$(1)
RESDIR-$(1)         = $(6)
NAME-$(1)           = $(1)
ADDRESS-$(1)        = $(4)
CSRC-$(1)          := $$(foreach s,$$(CFILES),$$(wildcard $$(SRCDIR-$(1))/$$(s)))
COBJ-$(1)           = $$(patsubst $$(SRCDIR-$(1))/%,$$(OBJDIR-$(1))/%.o,$$(CSRC-$(1)))
SSRC-$(1)          := $$(foreach s,$$(SFILES),$$(wildcard $$(SRCDIR-$(1))/$$(s)))
SOBJ-$(1)           = $$(patsubst $$(SRCDIR-$(1))/%,$$(OBJDIR-$(1))/%.o,$$(SSRC-$(1)))
RESSRC-$(1)        := $$(wildcard $$(RESDIR-$(1))/*)
RESOBJ-$(1)         = $$(patsubst $$(RESDIR-$(1))/%,$$(OBJDIR-$(1))/%.o,$$(RESSRC-$(1)))
OBJ-$(1)            = $$(COBJ-$(1)) $$(SOBJ-$(1)) $$(RESOBJ-$(1))
ELF-$(1)            = $$(BINDIR-$(1))/$(3).elf
BIN-$(1)            = $$(BINDIR-$(1))/$(3).bin
OUTDIR-$(1)         = $$(OBJDIR-$(1)) $$(BINDIR-$(1)) $$(HOOKSDIR-$(1))
HOOKS-$(1)          = patch/gsc/$(1)/hooks.gsc
BUILD-$(1)          = $(1)
CLEAN-$(1)          = clean-$(1)
$$(ELF-$(1))        :   ALL_LDFLAGS += -Wl,--defsym,start=$$(ADDRESS-$(1))
$$(BUILD-$(1))      :   $$(BIN-$(1))
$$(CLEAN-$(1))      :
	rm -rf $$(OUTDIR-$(1))

$$(COBJ-$(1))       :   $$(OBJDIR-$(1))/%.o: $$(SRCDIR-$(1))/% | $$(OBJDIR-$(1))
	$(CC) $$(ALL_CPPFLAGS) $$(ALL_CFLAGS) $$< -o $$@
$$(SOBJ-$(1))       :   $$(OBJDIR-$(1))/%.o: $$(SRCDIR-$(1))/% | $$(OBJDIR-$(1))
	$(AS) -c -MMD -MP $$(ALL_CPPFLAGS) $$< -o $$@
$$(RESOBJ-$(1))     :   $$(OBJDIR-$(1))/%.o: $$(RESDIR-$(1))/% | $$(OBJDIR-$(1))
	$(GRC) $$< -d $(RESDESC) -o $$@
$$(ELF-$(1))        :   $$(OBJ-$(1)) | $$(BINDIR-$(1))
	$(LD) $$(ALL_LDFLAGS) $$^ $$(ALL_LIBS) -o $$@
$$(BIN-$(1))        :   $$(ELF-$(1)) | $$(BINDIR-$(1))
	$(OBJCOPY) -S -O binary $$< $$@
$$(OUTDIR-$(1))     :
	mkdir -p $$@
$$(HOOKS-$(1))      :   $$(ELF-$(1)) $$(HOOKSDIR-$(1))
	$$(GENHOOKS) $$< $(7) >$$@
endef

define vc_template
VCDIR-$(1)          = $(PATCHDIR)/vc/$(1)
PATCH-$(1)          = $$(VCDIR-$(1))/$(2).gzi
BIN-$(1)            = $$(VCDIR-$(1))/$(2).bin
HOMEBOY-$(1)        = $$(VCDIR-$(1))/homeboy.bin
BUILD-$(1)          = $(1)
$$(BUILD-$(1))      :   $$(PATCH-$(1))

$$(PATCH-$(1))      :   $$(BIN-$(1))
	cd $(VCDIR) && make ../$$@

$$(BIN-$(1))        : $$(HOMEBOY-$(1))
	cd $(VCDIR) && make ../$$@

$$(VCDIR-$(1))		:
	mkdir -p $$@

$$(HOMEBOY-$(1))    : $$(VCDIR-$(1))
	cd $(HOMEBOYDIR) && CPPFLAGS="-DHB_DBG -DHB_HEAP -DHB_FAT $(HBCPPFLAGS)" make bin/hb-$(3)/homeboy.bin
	cp $(HOMEBOYDIR)/bin/hb-$(3)/homeboy.bin $$@
endef

$(foreach v,$(KZ_VERSIONS),$(eval $(call bin_template,kz-vc-$(v),$(v),kz,$(ADDRESS_VC),src,res)))
$(foreach v,$(KZ_VERSIONS),$(eval $(call bin_template,kz-lite-$(v),$(v),kz,$(ADDRESS_LITE),src,res,lite)))
$(foreach v,$(KZ_VERSIONS),$(eval $(call bin_template,kz-full-$(v),$(v),kz,$(ADDRESS_FULL),src,res)))
$(foreach v,$(KZ_VERSIONS),$(eval $(call bin_template,ldr-kz-vc-$(v),$(v),ldr,$(ADDRESS_LDR),ldr,ldr/res)))
$(foreach v,$(KZ_VERSIONS),$(eval $(call bin_template,ldr-kz-lite-$(v),$(v),ldr,$(ADDRESS_LDR),ldr,ldr/res)))
$(foreach v,$(KZ_VERSIONS),$(eval $(call bin_template,ldr-kz-full-$(v),$(v),ldr,$(ADDRESS_LDR),ldr,ldr/res)))
$(foreach v,$(VC_VERSIONS),$(eval $(call vc_template,kz-vc-$(v),kz-vc,$(v))))

$(KZ-NZSE)          :   CPPFLAGS    ?=	-DZ2_VERSION=NZSE
$(KZ-NZSE)          :   LIBS	    :=	-lNZSE
$(KZ-NZSJ)          :   CPPFLAGS    ?=	-DZ2_VERSION=NZSJ
$(KZ-NZSJ)          :   LIBS	    :=	-lNZSJ
$(KZ-NZSJ10)        :   CPPFLAGS    ?=	-DZ2_VERSION=NZSJ10
$(KZ-NZSJ10)        :   LIBS	    :=	-lNZSJ10
$(KZ-FULL)          :   CPPFLAGS    +=	-DKZ_VERSION=KZ_FULL
$(ELF-FULL)         :   LDFLAGS     ?=	-O3 -flto=auto
$(KZ-FULL)          :   CFLAGS      ?=  -O3 -flto=auto -ffat-lto-objects
$(KZ-VC)			:	CPPFLAGS	+=	-DKZ_VERSION=KZ_VC
$(ELF-VC)			:	LDFLAGS		?= -O2 -fno-optimize-strlen
$(KZ-VC)			:	CFLAGS		?= -O2 -fno-optimize-strlen -ffat-lto-objects
$(KZ-LITE)          :   CPPFLAGS    +=	-DLITE -DKZ_VERSION=KZ_LITE
$(KZ-LITE)          :   CFLAGS      ?=  -Os
$(ELF-LITE)         :   LDFLAGS     ?=	-Os
ifeq '$(shell $(CC) -dumpmachine 2>/dev/null)' 'mips64-ultra-elf'
$(OBJ-VC)			:	ALL_CFLAGS		+= -n64-wiivc
$(OBJ-VC)			:	ALL_CXXFLAGS	+= -n64-wiivc
$(OBJ-VC)			:	ALL_LDFLAGS		+= -n64-wiivc
else
$(OBJ-VC)			: 	ALL_CPPFLAGS	+= -DWIIVC
endif
