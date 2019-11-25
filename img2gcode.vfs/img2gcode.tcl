package require Tk
#package require ttk
package require img::jpeg

# Get the current scripts directory

# Source in the supporting file with the current scripts 
# directory as its base

#source [file join $starkit::topdir funcs.tcl]

#helpers
proc shift {vname} {
  upvar $vname x
  #set ans [lindex $x 0]
  set x [lassign $x ans]
  return $ans
}
proc labelEntry {path name text value} {
  label $path.${name}l -text $text
  entry $path.${name}e -textvariable v($name)
  set ::v($name) $value
  return [list $path.${name}l $path.${name}e]
}
proc labelThing {args} {
  set path ".t"
  set name "name"
  set scr {}
  set wl {}
  while {[llength $args] > 0} {
    set cmd [shift args]
    switch -- $cmd {
      -path {set path [shift args]}
      -name {set name [shift args]}
      -text  {lappend scr [subst -novariables {label $path.${name}l -text "[shift args]" -anchor w; lappend wl $path.${name}l}]}
      -entry {lappend scr [subst -novariables {entry $path.${name}e -textvariable ::v($name); lappend wl $path.${name}e}]}
      -label {lappend scr [subst -novariables {label $path.${name}v -textvariable ::v($name) -relief sunken -bd 2; lappend wl $path.${name}v}]}
      -value {lappend scr [subst -novariables {set ::v($name) [shift args]}]}
      -cmd   {lappend scr [subst -novariables {button $path.${name}c -text "[shift args]" -command [shift args]; lappend wl $path.${name}c}]}
      -scale {lappend scr [subst -novariables {scale $path.${name}s -variable ::v($name) -orient horizontal {*}[shift args]; lappend wl $path.${name}s}]}
      default {error "labelThing bad cmd=$cmd"}
    }
    #puts stderr [format "labelThing: cmd='%s' scr='%s'" $cmd $scr]
  }
  #puts stderr [join $scr "\n  "]
  eval [join $scr "\n"]
  return $wl
}


## Menu
grid [frame .m -relief raised -bd 2] -sticky ew
## File Menu
menubutton .m.f -menu .m.f.m -text "File"
menu .m.f.m
.m.f.m insert end command -label "Exit" -command exit
.m.f.m insert 0 command -label "Load Img..." -command loadImg...

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
set f2 [.nb add [frame .nb.f2] -text log]
set f3 [.nb add [frame .nb.f3] -text machine]


## photo panel
grid [frame $f1.i] -sticky nsew
label $f1.i.srcLabel -text "Source Image"
image create photo srcimg ;#
label $f1.i.src -image srcimg -width 100 -height 100 -padx 2 -pady 2 -relief groove
frame $f1.i.srci -relief sunken -bd 2
label $f1.i.dstLabel -text "Gcode Region"
canvas $f1.i.dst -relief groove -bd 2
frame $f1.i.dsti -relief sunken -bd 2
grid $f1.i.srcLabel $f1.i.dstLabel -sticky ew
grid $f1.i.src  $f1.i.dst -sticky nsew
grid $f1.i.srci $f1.i.dsti -sticky nsew
##
grid {*}[labelThing -path $f1.i.srci -name pw -text "img pixel width" -label -value ?]
grid {*}[labelThing -path $f1.i.srci -name ph -text "img pixel height" -label -value ?]
grid {*}[labelThing -path $f1.i.srci -name aspect -text "img aspect w/h" -label -value ?]
##
grid {*}[labelThing -path $f1.i.dsti -name gX   -text "gcode width (mm)" -label -value ?] -sticky ew
grid {*}[labelThing -path $f1.i.dsti -name gY   -text "gcode height (mm)" -label -value ?] -sticky ew
grid {*}[labelThing -path $f1.i.dsti -name ppmm -text "pixels/mm" -label -value ? -scale {-from 1 -to 10 -showvalue 0 -command changePPMM}] -sticky ew


## LoadImg
proc loadImg... {} {
  set fName [tk_getOpenFile]
  if {$fName ne ""} {
    global f1
    $f1.i.src config -image {}
    srcimg blank
    srcimg read $fName
    $f1.i.src config -image srcimg
    set ::v(pw) [image width srcimg]
    set ::v(ph) [image height srcimg]
    set ::v(aspect) [expr {1.0*$::v(pw)/$::v(ph)}]
    set ::v(gX) $::v(pw)
    set ::v(gY) $::v(ph)
    set ::v(ppmm) 1
  }
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
button $f1.t.go -text "go" -command go
grid $f1.t.go

proc go {} {
  global f1
  set W [image width srcimg]
  set H [image height srcimg]
  set w [expr {$W/$::v(pps)}]
  set h [expr {$H/$::v(pps)}]
  #set xp 0
  #set yp 0
  $f1.i.dst delete all
  for {set y 0} {$y < $h} {incr y 1} {
    set Y0 [expr {$::v(pps)*($y)}]
    set Y1 [expr {$::v(pps)*($y+1)}]
    set Y  [expr {round($::v(pps)*($y+0.5))}]
    for {set x 0} {$x < $w} {incr x 1} {
      set X0 [expr {$::v(pps)*($x)}]
      set X1 [expr {$::v(pps)*($x+1)}]
      set X  [expr {round($::v(pps)*($x+0.5))}]
      # find average of pixels xp...x  yp...y X0...X1 Y0...Y1 (centered at X Y)
      if {1} {
        set data [srcimg data -from $X0 $Y0 $X1 $Y1 -grayscale]
	#puts stderr [format "data=%s" $data]
	catch {unset R; unset G; unset B}
	foreach row $data {
	  foreach column $row {
             scan $column "#%2x%2x%2x" r g b
             lappend R $r
             lappend G $g
             lappend B $b
	  }
        }
#puts stderr $R
	set R [expr "([join $R "+"])/[llength $R]"]
	set G [expr "([join $G "+"])/[llength $G]"]
	set B [expr "([join $B "+"])/[llength $B]"]
      } else {
        lassign [srcimg get $X $Y] R G B
      }
      set lvl [expr {round(sqrt($R*$R+$G*$G+$B*$B))}]
      if {[info exists xp] && [info exists yp]} {
	#$f1.i.dst create line  $xp $yp $X $Y -width $::v(pps) -fill [format "#%02x%02x%02x" $lvl $lvl $lvl]
	#$f1.i.dst create line  $xp $yp $X $Y -width $::v(pps) -fill [format "#%02x%02x%02x" $R $G $B]
	#$f1.i.dst create line  $xp $Y $X $Y -width 1  -fill [format "#%02x%02x%02x" $R $G $B]
	#$f1.i.dst create line  $xp $Y $X $Y -width $::v(ss)  -fill [format "#%02x%02x%02x" $R $G $B]
	$f1.i.dst create line  $xp $Y0 $X $Y0 -width $::v(ss)  -fill [format "#%02x%02x%02x" $R $G $B]
	update idletasks
      }
      set xp $X
    }
    unset xp
    set yp $Y
  }
}
