#
# machine
#  gcodes for laser
#

namespace eval machine {
  variable v
  set v(laserFmt) "G03 S%3d"
  set v(fp) ""
  proc laser {level} {
    # expect level to be 0..255 (0=light, 255=dark)
    variable v
    puts $v(fp) [format $v(laserFmt) $level]
  }
  proc scanto {x y} {
  	# expect x,y to be in integer mm
  	puts $v(fp) [format "g?? %d %d" $x $y]
  	# future, buffer lines until you see a change in level or direction, then flush...
  	set v(xp) $x
  	set v(yp) $y
  }
  proc Frame {w} {
  	frame $w -relief ridge -bd 2 -bg grey
  	label $w.lb -text "Machine Settings"
  	grid $w.lb
  	grid {*}[labelThing -path $w -name laserFmt -variable [namespace current]::v(laserFmt) -text "gcode for laser level =" -label -value ?] -sticky ew
  	return $w
  }
}