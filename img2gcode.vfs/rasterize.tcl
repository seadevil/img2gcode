#
# code to rasterize the image
#

namespace eval rast {
  #
  proc go {} {
    global f1
    set W [image width srcimg]
    set H [image height srcimg]
    set w [expr {$W/$::v(pps)}]
    set h [expr {$H/$::v(pps)}]
    #set xp 0
    #set yp 0
    Dst delete all
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
  	        #puts stderr [format "row= %s" $row]
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
  	      Dst create line  $xp $Y0 $X $Y0 -width $::v(ss)  -fill [format "#%02x%02x%02x" $R $G $B]
  	      #update idletasks
        }
        set xp $X
      }
      update idletasks
      unset xp
      set yp $Y
    }
  }

  proc changePPMM {ppmm} {
    variable v
    set v(ppmm) $ppmm
    catch {
      set v(gX) [format "%7.2f" [expr {1.0*$::image::v(pw)/$v(ppmm)}]]
      set v(gY) [format "%7.2f" [expr {1.0*$::image::v(ph)/$v(ppmm)}]]
    }
  }



  proc Dst {args} {
  	variable v
  	$v(dstW) {*}$args
  }

  proc Frame {w} {
  	frame $w -relief ridge -bd 2
  	label $w.dstLabel -text "Gcode Region"
  	canvas $w.dst -bg cyan -relief groove -bd 2
  	variable v
  	set v(dstW) $w.dst
  	frame $w.dsti -relief sunken -bd 2
  	grid $w.dstLabel -sticky ew
  	grid $w.dst ;#-sticky nsew
  	grid $w.dsti -sticky nsew
  	##
  	#
  	grid {*}[labelThing -path $w.dsti -name gX   -variable [namespace current]::v(gX) -text "gcode width (mm)" -label -value ?] -sticky ew
  	grid {*}[labelThing -path $w.dsti -name gY   -variable [namespace current]::v(gY) -text "gcode height (mm)" -label -value ?] -sticky ew
  	grid {*}[labelThing -path $w.dsti -name ppmm -variable [namespace current]::v(ppm) -text "pixels/mm" -label -value ? -scale {-from 1 -to 10 -showvalue 0 -command rast::changePPMM}] -sticky ew

  	return $w
  }
}