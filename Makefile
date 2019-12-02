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

## runs with errors
#TCLKIT := ./tclkit-osx-8.5.19 

## runs with prompt, seems to skip main?
#TCLKIT := ./tclkit-osx-8.5.19_cfs

## ??
#TCLKIT := ./tclkit-osx-8.5.19_zip

#TCLKIT := ./tclkit-osx-8.6.1
#TCLKIT := ./tclkit-osx-8.6.1h
#TCLKIT := ./tclkit-osx-8.6.1_0.9.5
#TCLKIT := ./tclkit-osx-8.6.9_0.11.
TCLKIT := ./tclkit-8.6.3-macosx10.5-ix86+x86_64
## from: https://tclkits.rkeene.org/fossil/wiki/Downloads


SDXKIT := sdx-20110317.kit
#SDX    = $(TCLKIT) $(SDXKIT)
#SDX    = tclsh $(SDXKIT)
SDX    = $(TCLKIT) $(SDXKIT)

MAJOR  := 0
MINOR  := 1
PATCH  := 0
VERSION = $(MAJOR).$(MINOR).$(PATCH)
APPNAME := img2gcode
DIR     :="$(APPNAME).app/Contents/MacOS"

sdxhelp :
	$(SDX) help

wrap : img2gcode_$(VERSION).kit
img2gcode_$(VERSION).kit :
	$(SDX) wrap img2gcode.kit
	mv img2gcode.kit img2gcode_$(VERSION).kit

exe : $(APPNAME)
$(APPNAME) :
	cp $(TCLKIT) copy_$(notdir $(TCLKIT))
	$(SDX) wrap $(APPNAME) -runtime copy_$(notdir $(TCLKIT))
	#mv img2gcode img2gcode_$(VERSION).exe
	rm copy_$(notdir $(TCLKIT))
	#chmod a+x img2gcode_$(VERSION).exe
	chmod a+x $(APPNAME)

app :
	$(MAKE) exe
	mkdir -p $(DIR)
	mv $(APPNAME) $(DIR)/


go :
	#$(MAKE) wrap
	$(SDX) unwrap img2gcode_$(VERSION).kit
	$(SDX) wrap img2gcode_$(VERSION).exe -runtime $(TCLKIT)

clean :
	-rm img2gcode_$(VERSION).kit
	-rm img2gcode_$(VERSION).exe
	-rm $(APPNAME)


