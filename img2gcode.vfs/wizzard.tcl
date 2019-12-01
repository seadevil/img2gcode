#
## wizzard - or guided tool flow screen
#

namespace eval wizzard {
  proc Frame {w} {
	frame $w -relief ridge -bd 2
  	label $w.dstLabel -text "Step-by-step guided flow wizzard"
  	grid $w.dstLabel - -sticky ew
  	#
  	grid {*}[labelThing -path $w -name step1 -text "Step-1 :" -cmd "Load Image..." image::Load...] -sticky ew
   	grid {*}[labelThing -path $w -name step2 -text "Step-2 :" -cmd "Choose gcode output file..." {machine::openFile...}] -sticky ew
   	grid {*}[labelThing -path $w -name step3 -text "Step-3 :" -cmd "xxChoose gcode image size..." {FIXME_3}] -sticky ew
	  grid {*}[labelThing -path $w -name step4 -text "Step-4 :" -cmd "xxSet machine/gcode options" {FIXME_4}] -sticky ew
   	grid {*}[labelThing -path $w -name step5 -text "Step-5 :" -cmd "Simulate on src/dst screen" {.nb select .nb.f1; rast::rasterize}] -sticky ew
   	grid {*}[labelThing -path $w -name step6 -text "Step-6 :" -cmd "Generate g-code" {.nb select .nb.f1; rast::rasterize 1}] -sticky ew

	return $w
  }
}