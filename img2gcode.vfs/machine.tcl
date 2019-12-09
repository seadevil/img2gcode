#
# machine
#  gcodes for laser
#

namespace eval machine {
  variable v
  set v(laserFmt) "M03 S%-1d"
  set v(feedMmPerMinute) 2400
  set v(fp) ""
  # note final Init call at the end of this file

  proc Init {} {
    variable v
    set v(totalDistance) 0
    set v(totalTimeSeconds) 0
    set v(totalTimeHours) 0
    set v(moves) 0
    set v(xp) 0
    set v(yp) 0
    if {$v(fp) eq ""} {
      if {[info exists v(fileName)] && $v(fileName) ne ""} {
        set v(fp) [open $v(fileName) "w"]
      } else {
        error "No defined file name"
      }
    }
    if {$v(fp) ne ""} {
      #seek $v(fp) 0 start
      Header
    }
  }

  proc setLaserLevel {level} {
    # expect level to be 0..255 (0=light, 255=dark)
    variable v
    puts $v(fp) [format $v(laserFmt) $level]
  }
  proc mapLevel {lvl} {
    # in images 0 is dark and 255 is lite
    # on lasers 0 is light and 255 is dark
    ## maybe add gama later
    set ans [expr {255-$lvl}]
    return $ans
  }
  proc XY {x y} {
    #puts stderr "x=$x y=$y"
    variable v
  	# expect x,y to be in integer mm
  	puts $v(fp) [format "G1 X%d Y%d F%d" $x $y $v(feedMmPerMinute)]
  	# future, buffer lines until you see a change in level or direction, then flush...
    set deltaXY [expr {sqrt(($x-$v(xp))*($x-$v(xp))+($y-$v(yp))*($y-$v(yp)))}]
  	set v(xp) $x
  	set v(yp) $y
    #G1 X20 F3600 ; move to X=20mm
    set v(totalDistance) [expr {$v(totalDistance)+$deltaXY}]
    incr v(totalTimeSeconds) [expr {int(ceil($deltaXY/($v(feedMmPerMinute)*60.0)))}]
    set v(totalTimeHours) [format "%4.2f" [expr {$v(totalTimeSeconds)/3600.0}]]
    incr v(moves)
  }
  proc Header {} {
    variable v
    puts $v(fp) [format "G90"] ;# use absolute positioning for the XYZ axes
    puts $v(fp) [format "G21"] ;# run in mm
  }
  proc Footer {} {
    variable v
  }
  proc Close {} {
    variable v
    if {$v(fp) ne ""} {
      Footer
      close $v(fp)
        set v(fp) ""
    }
  }
  proc openFile... {} {
    variable v
    set initialName [file rootname [file tail $::image::v(fName)]].gcode
    #set fName [tk_getSaveFile -defaultextension ".gcode" -filetypes {"Gcode Files" {.gcode}} -initialfile initialName]
    set fName [tk_getSaveFile -defaultextension ".gcode" -initialfile $initialName]
    if {$fName ne ""} {
      set v(fileName) $fName
      set v(fp) [open $fName "w"]
    }
    Header
  }
  proc Frame {w} {
    frame $w -relief ridge -bd 2 -bg grey
    label $w.lb -text "Machine Settings"
    grid $w.lb
    grid {*}[labelThing -path $w -name laserFmt -variable [namespace current]::v(laserFmt) -text "gcode for laser level =" -label] -sticky ew
    grid {*}[labelThing -path $w -name spotY    -variable [namespace current]::v(spotY)    -text "Laser spot size Y (mm)"  -entry -value 1] -sticky ew
    grid {*}[labelThing -path $w -name spotX    -variable [namespace current]::v(spotX)    -text "laser spot size X (mm)"  -entry -value 1] -sticky ew
    grid {*}[labelThing -path $w -name feed     -variable [namespace current]::v(feedMmPerMinute) -text "feed mm/min" -entry] -sticky ew
    grid {*}[labelThing -path $w -name gcodeFileName -variable [namespace current]::v(fileName) -text "gcode output file: " -label -cmd {...} [namespace code {openFile...}]] -sticky ew
    grid {*}[labelThing -path $w -name dist     -variable [namespace current]::v(totalDistance) -text "total distance" -label] -sticky ew
    grid {*}[labelThing -path $w -name timeS    -variable [namespace current]::v(totalTimeSeconds) -text "total time (sec)" -label] -sticky ew
    grid {*}[labelThing -path $w -name timeH    -variable [namespace current]::v(totalTimeHours) -text "total time (hours)" -label] -sticky ew
    grid {*}[labelThing -path $w -name moves    -variable [namespace current]::v(moves) -text "total moves" -label] -sticky ew
    return $w
  }
  #Init
}