#
# machine
#  gcodes for laser
#

namespace eval machine {
  variable v
  set v(laserFmt) "M03 S%3d"
  set v(fp) ""
  proc setLaserIntensity {level} {
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
  	# expect x,y to be in integer mm
  	puts $v(fp) [format "G1 X%d Y%d" $x $y]
  	# future, buffer lines until you see a change in level or direction, then flush...
  	set v(xp) $x
  	set v(yp) $y
    #G1 X20 F3600 ; move to X=20mm
  }
  proc Header {} {
    variable v
    puts $v(fp) [format "G90"] ;# use absolute positioning for the XYZ axes
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
  }
  proc Frame {w} {
    frame $w -relief ridge -bd 2 -bg grey
    label $w.lb -text "Machine Settings"
    grid $w.lb
    grid {*}[labelThing -path $w -name laserFmt -variable [namespace current]::v(laserFmt) -text "gcode for laser level =" -label] -sticky ew
    grid {*}[labelThing -path $w -name spotY    -variable [namespace current]::v(spotY)    -text "Laser spot size Y (mm)"  -entry -value 1] -sticky ew
    grid {*}[labelThing -path $w -name spotX    -variable [namespace current]::v(spotX)    -text "laser spot size X (mm)"  -entry -value 1] -sticky ew
    grid {*}[labelThing -path $w -name gcodeFileName -variable [namespace current]::v(fileName) -text "gcode output file: " -label -cmd {...} [namespace code {openFile...}]] -sticky ew
    return $w
  }
}