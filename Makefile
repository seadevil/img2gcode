#
# makefile for managing tclkits
#

# find tclkits ... (https://code.google.com/archive/p/tclkit/downloads)
# or
# build them with "kbs"
# there is an online kbs at: http://kitcreator.rkeene.org/kitcreator

# how to build stand alone apps:
# * http://www.whoopis.com/howtos/standalone-tcl-tk-binaries-howto.html (close but not correct)
# * http://wookie.tcl.tk/11861 (better, it uses sdx)
# * https://wiki.tcl-lang.org/page/Building+Stand-Alone+Tcl%2FTk+Applications+under+Mac+OS+X (best yet, I didnt try it yet)
# * https://wiki.tcl-lang.org/page/How+do+I+create+a+Tcl-based+"clickable"+Mac+OS+X+application%3F (might bet better?)
# * https://www.tcl.tk/community/tcl2002/archive/Tcl2002papers/landers-tclkit/tclkit.pdf (dated but still good)

# Make variables:
# OS - this OS
# UNAME_S - a better unix description of this OS
# TARGETOS - the intended target OS, will default to OS or UNAME_S

ifeq ($(OS),Windows_NT)
 TARGETOS := Win
 TCLKIT = $(TCLKIT_Win)
 HOSTOS := Win
else
 UNAME_S := $(shell uname -s)
 ifeq ($(UNAME_S),Linux)
  TARGETOS := Linux
  TCLKIT = $(TCLKIT_Linux)
  HOSTOS := Linux
 else
  ifeq ($(UNAME_S),Darwin)
   TARGETOS := Darwin
   TCLKIT = $(TCLKIT_Osx)
   HOSTOS := Darwin
  else
   $(error "unknown OS='$(OS)")
  endif
 endif
endif

ifeq ($(TARGETOS),Darwin)
 TARGET_TCLKIT = $(TCLKIT_Osx)
 EXENAME = $(APPNAME)
else
 ifeq ($(TARGETOS),Linux)
  TARGET_TCLKIT = $(TCLKIT_Linux)
  EXENAME = $(APPNAME)
else
  ifeq ($(TARGETOS),Win)
   TARGET_TCLKIT = $(TCLKIT_Win)
   EXENAME = $(APPNAME).exe
  else
   $(error "unknown TARGETOS=$(TARGETOS), must be one of Darwin,Linux,Win")
  endif
 endif
endif

help :
	@echo "no help for you"
debug :
	@echo "HOSTOS=$(HOSTOS)"
	@echo "TARGETOS=$(TARGETOS)"
	@echo "TCLKIT=$(TCLKIT)"
	@echo "TARGET_TCLKIT=$(TARGET_TCLKIT)"
	@echo "SDX=$(SDX)"
	@echo "EXENAME=$(EXENAME)"
tteesstt :
	@echo "OS='$(OS)' PROCESSOR_ARCHITEW6432='$(PROCESSOR_ARCHITEW6432)' PROCESSOR_ARCHITECTURE='$(PROCESSOR_ARCHITECTURE)'"


## Kits for mac
#TCLKIT_Osx := ./tclkit-osx-8.5.19       ## runs with errors
#TCLKIT_Osx := ./tclkit-osx-8.5.19_cfs   ## runs with prompt, seems to skip main?
#TCLKIT_Osx := ./tclkit-osx-8.5.19_zip
#TCLKIT_Osx := ./tclkit-osx-8.6.1
#TCLKIT_Osx := ./tclkit-osx-8.6.1h
#TCLKIT_Osx := ./tclkit-osx-8.6.1_0.9.5
#TCLKIT_Osx := ./tclkit-osx-8.6.9_0.11.
#-TCLKIT_Osx := ./tclkit-osx-8.6.3.1
#TCLKIT_Osx := ./tclkit-8.6.3-macosx10.5-ix86+x86_64
## from: https://tclkits.rkeene.org/fossil/wiki/Downloads
TCLKIT_Osx := ./kbsvq8.6-gui

## Kits for Win
TCLKIT_Win := ./tclkit-win32.upx_8.5.1.exe

## Kits for Linux
TCLKIT_Linux := tclkit-8.6.3-linux

SDXKIT  := sdx-20110317.kit
SDXEXEC := tclsh
SDXEXEC  = $(TCLKIT)
SDX      = $(SDXEXEC) $(SDXKIT)


## app version
MAJOR  := 0
MINOR  := 1
PATCH  := 0
VERSION = $(MAJOR).$(MINOR).$(PATCH)
APPNAME := img2gcode
OSX_APP_DIR :="$(APPNAME).app/Contents/MacOS"

sdxhelp :
	$(SDX) help

wrap : img2gcode_$(VERSION).kit
img2gcode_$(VERSION).kit :
	$(SDX) wrap img2gcode.kit
	mv img2gcode.kit img2gcode_$(VERSION).kit

exe : $(EXENAME)
$(EXENAME) :
	cp $(TARGET_TCLKIT) copy_$(notdir $(TARGET_TCLKIT))
	$(SDX) wrap $(EXENAME) -runtime copy_$(notdir $(TARGET_TCLKIT))
	rm copy_$(notdir $(TARGET_TCLKIT))
	chmod a+x $(EXENAME)


## windows icon
## https://stackoverflow.com/questions/1207965/is-there-a-command-line-utility-to-change-the-embedded-icon-of-a-win32-exe
##

bf :
	cp $(TCLKIT) copy_$(notdir $(TCLKIT))
	#echo "source vfs_mkcl_1.4.tcl; set argv {sdx-20110317.kit wrap img2gcode -runtime copy_tclkit-osx-8.5.19}; package require starkit; source $(SDXKIT)" | $(TCLKIT)
	echo "source mkclvfs_1.5.tcl; set argv {sdx-20110317.kit wrap img2gcode -runtime copy_tclkit-osx-8.5.19}; package require starkit; source $(SDXKIT)" | $(TCLKIT)
	rm copy_$(notdir $(TCLKIT))
	chmod a+x $(APPNAME)


app :
	$(MAKE) exe
	mkdir -p $(OSX_APP_DIR)
	mv $(APPNAME) $(OSX_APP_DIR)/


go :
	#$(MAKE) wrap
	$(SDX) unwrap img2gcode_$(VERSION).kit
	$(SDX) wrap img2gcode_$(VERSION).exe -runtime $(TCLKIT)

clean :
	-rm img2gcode_$(VERSION).kit
	-rm img2gcode_$(VERSION).exe
	-rm $(APPNAME)

####### build kits
osxkit : TMP:= newtmp
osxkit :
	mkdir $(TMP)
	cd $(TMP) ; wget http://teapot.activestate.com/application/name/base-tcl-thread/ver/8.6.4.1.299146/arch/macosx10.5-i386-x86_64/file.exe\
	          ; mv file.exe bootstrap_tclkit \
	          ; chmod a+x bootstrap_tclkit
	#cd $(TMP) ; curl -o kbs.tcl -L http://sourceforge.net/projects/kbskit/files/kbs/0.4.9/kbs.tcl/download
	cd $(TMP) ; wget -O kbs.tcl http://sourceforge.net/projects/kbskit/files/kbs/0.4.9/kbs.tcl/download
	#cd $(TMP) ; ../tclkit-osx-8.6.3.1 kbs.tcl -v install kbskit8.6
	cd $(TMP) ; ./bootstrap_tclkit kbs.tcl -r -v sources kbskit8.6
	cd $(TMP) ; ./bootstrap_tclkit kbs.tcl -r -v install kbskit8.6
	#cp $(TMP)/buildDarwin/bin/kbsvq8.6-gui ./

