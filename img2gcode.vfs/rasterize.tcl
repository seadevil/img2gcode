#
# code to rasterize the image
#

namespace eval rast {
  #
  proc rasterize {{gcode 0}} {
    global f1
    variable v
    set W [image width srcimg]
    set H [image height srcimg]
   ## gcode window coords
    set Y0 [expr {0}]
    set Y1 [expr {$v(gY)}]
    set X0 [expr {0}]
    set X1 [expr {$v(gX)}]
    Dst delete all
    for {set Y $Y0} {$Y < $Y1} {incr Y $::machine::v(spotY)} {
      # scan bottom to top. (images are top=0 so we will need to invert Y)
      #- the raster size Y0...Y1 centered at Y in gcode coords (bottom to top)
      # compute the window in image coords
      set y1 [expr {int(round($H-$v(ppmm)*$Y))}] ;#<----------------------------- image-rows top
      set y0 [expr {int(round($H-$v(ppmm)*($Y+$::machine::v(spotY))))}];#<------- image-rows bottom (N pixels below top), but dont scan this row twice...
      # compute inverted Yi (canvas coords Y is at top)
      set Yi [expr {($Y1-$Y)+(($::machine::v(spotY))/2)}] ;# add a 1/2Y offset to center the line within the raster-spot-row
  	  #Dst create line $X0 $Yi $X1 $Yi -width 1 -fill red -tags hilight ; update idletasks
  	  #Dst delete hilight
      for {set X $X0} {$X < $X1} {incr X $::machine::v(spotX)} {
      	# find x0..x1 in image coords
        set x0 [expr {int(round($v(ppmm)*$X))}] ;#<-------------------------------------- image-col left
        set x1 [expr {int(round(min($v(ppmm)*($X+$::machine::v(spotX)),$W)))}] ;#<------- image-col right, but dont repeat col twice
        # find average of pixels xp...x  yp...y X0...X1 Y0...Y1 (centered at X Y)
        switch {newest} {
		  newest {
		    lassign {0 0 0 0} R G B pcount
		    for {set x $x0} {$x < $x1} {incr x} {
			  for {set y $y0} {$y < $y1} {incr y} {
			    if {[catch {lassign [srcimg get $x $y] r g b}]} {
				   puts stderr [format "out of bounds in img x=%d y=%d (x0=%d y0=%d x1=%d y1=%d) X=%s Y=%s" $x $y $x0 $y0 $x1 $y1 $X $Y]
				   return
				}
				incr R $r
				incr G $g
				incr B $b
				incr pcount
			  }
			}
			set R [expr {$R/$pcount}]
			set G [expr {$G/$pcount}]
			set B [expr {$B/$pcount}]
		  }
      new {
          	#puts stderr [format "x0:x1=%d:%d   y0:y1=%d:%d" $x0 $x1 $y0 $y1]
            set data [srcimg data -from $x0 $y0 $x1 $y1 -grayscale]
    	      puts stderr [format "data=%s" $data]
    	      puts stderr [format "get =%s" [srcimg get $x0 $y0]]
			      exit
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
            #puts stderr [format "R=%s G=%s B=%s" $R $G $B]
  	        set R [expr "([join $R "+"])/[llength $R]"]
  	        set G [expr "([join $G "+"])/[llength $G]"]
  	        set B [expr "([join $B "+"])/[llength $B]"]
            #puts stderr [format "R=%s G=%s B=%s" $R $G $B]
          }
          old {
            lassign [srcimg get $x0 $y0] R G B
          }
        }
        set lvl [expr {round(sqrt($R*$R+$G*$G+$B*$B))}]
        set lvl [expr {sqrt($R*$R+$G*$G+$B*$B)}]
        set lvl [expr {int($R*0.3+$G*0.59+$B*0.11)}]
        switch {new} {
          old {
            if {[info exists xp] && [info exists yp]} {
    	      Dst create line  $xp $Y0 $X $Y0 -width $::v(ss)  -fill [format "#%02x%02x%02x" $lvl $lvl $lvl]
  	          #update idletasks
  	        }
  	      }
  	      new {
          	set Xi(0) [expr {$X}]
          	set Xi(1) [expr {$X+$::machine::v(spotX)}]
          	Dst create line $Xi(0) $Yi $Xi(1) $Yi -width $::machine::v(spotY) -fill [format "#%02x%02x%02x" $lvl $lvl $lvl]
            if {$gcode} {
              machine::setLaserLevel [machine::mapLevel $lvl]
              machine::XY $Xi(1) $Yi
            }
          }
        }
        set xp $X
      }
      update idletasks
      unset xp
      set yp $Y
      if {$gcode} {
        machine::setLaserLevel 0
      }
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