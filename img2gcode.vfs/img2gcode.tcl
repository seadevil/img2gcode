package require Tk
#package require ttk
#catch {package require img::jpeg}
#package require zoom-canvas

# Get the current scripts directory

# Source in the supporting file with the current scripts 
# directory as its base

#source [file join $starkit::topdir funcs.tcl]

source [file join $v(root) "helpers.tcl"]
source [file join $v(root) "image.tcl"]
source [file join $v(root) "machine.tcl"]
source [file join $v(root) "rasterize.tcl"]

#puts stderr $::tcl_platform(os)

## Menu
grid [frame .m -relief raised -bd 2] -sticky ew
## File Menu
menubutton .m.f -menu .m.f.m -text "File"
menu .m.f.m
.m.f.m insert end command -label "Exit" -command exit
.m.f.m insert 0 command -label "Load Img..." -command image::Load...

## View Menu
menubutton .m.v -menu .m.v.m -text "View"
menu .m.v.m
.m.v.m insert 0 command -label "Fit" -command {
  set w [image width srcimg]
  set h [image height srcimg]
  puts stderr [format "with='%s' height='%s'" $w $h]
  $f1.i.src config -width $w -height $h
  $f1.i.dst config -width $w -height $h
}

grid .m.f .m.v


## main notebook
ttk::notebook .nb
grid .nb -sticky nsew
.nb add [frame .nb.f1] -text src/dst  ;set f1 .nb.f1
.nb add [frame .nb.f2] -text log; set f2 .nb.f2
.nb add [machine::Frame .nb.f3] -text machine; set f3 .nb.f3


## photo panel
grid [frame $f1.i] -sticky nsew
grid [image::Frame $f1.i.src] [rast::Frame $f1.i.dst] -sticky nsew


## srcImg
proc srcZoom {zoom} {
  set ::v(srcZoom) $zoom
}



##
proc changePPMM {ppmm} {
  set ::v(ppmm) $ppmm
  catch {
      set ::v(gX) [format "%7.2f" [expr {1.0*$::v(pw)/$::v(ppmm)}]]
      set ::v(gY) [format "%7.2f" [expr {1.0*$::v(ph)/$::v(ppmm)}]]
  }
}

## toolboc
grid [frame $f1.t -relief sunken -bd 2] -sticky ew
button $f1.t.gs -text "Convert to greyscale" -command {srcimg configure -palette 256}
grid $f1.t.gs
grid {*}[labelEntry $f1.t pps "pixels per scanline" 7]
grid {*}[labelEntry $f1.t ss  "laser spot size (in mm)" 7]
grid {*}[labelThing -path $f1.t -name ppmm -text "pixels/mm" -entry -value 1 -cmd "recompute" rc]
button $f1.t.go -text "go" -command rast::go
grid $f1.t.go


