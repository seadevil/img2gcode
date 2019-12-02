#
# code to rasterize the image
#

namespace eval rast {
  variable v
  #set v(optizimationLevel) basic
  set v(optLevels) {basic experimental}
  set v(updateRates) {raster rasterLine never}
  
  proc rasterize {{gcode 0}} {
    variable v
    switch -- $v(optimizationLevel) {
      basic        {rasterize_1 $gcode}
      experimental {rasterize_N $gcode}
      default {error "unknown optimzation '$v(optimizationLevel)'"}
    }
  }

  proc rasterize_1 {{gcode 0}} {
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
    set scanLineCount 0
    set lastX 0;# <---- new var for scanline optimization
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
		    # newest-branch
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
        ##
        set lvl [expr {int($R*0.3+$G*0.59+$B*0.11)}]
        #new-branch
        set Xi(0) [expr {$X}]
        set Xi(1) [expr {$X+$::machine::v(spotX)}]
        Dst create line $Xi(0) $Yi $Xi(1) $Yi -width $::machine::v(spotY) -fill [format "#%02x%02x%02x" $lvl $lvl $lvl]
        if {$gcode} {
          machine::setLaserLevel [machine::mapLevel $lvl]
          machine::XY $Xi(1) $Yi
        }
        set xp $X
      } ;# <----------------- end of x loop
      update idletasks
      unset xp
      set yp $Y
      if {$gcode} {
        machine::setLaserLevel 0
      }
    } ;# <------------------- end of y loop
  }

  proc rasterize_N {{gcode 0}} {
    global f1
    variable v
    if {$gcode} {machine::Init}
    set W [image width srcimg]
    set H [image height srcimg]
   ## gcode window coords
    set Y0 [expr {0}]
    set Y1 [expr {$v(gY)}]
    set X0 [expr {0}]
    set X1 [expr {$v(gX)}]
    Dst delete all
    set scanLineCount 0
    set lastX 0;# <---- new var for scanline optimization
    for {set Y $Y0} {$Y < $Y1} {incr Y $::machine::v(spotY)} {
      # scan bottom to top. (images are top=0 so we will need to invert Y)
      #- the raster size Y0...Y1 centered at Y in gcode coords (bottom to top)
      # compute the window in image coords
      set y1 [expr {int(round($H-$v(ppmm)*$Y))}] ;#<----------------------------- image-rows top
      set y0 [expr {int(round($H-$v(ppmm)*($Y+$::machine::v(spotY))))}];#<------- image-rows bottom (N pixels below top), but dont scan this row twice...
      # compute inverted Yi (canvas coords Y is at top)
      set Yi [expr {($Y1-$Y)+(($::machine::v(spotY))/2)}] ;# add a 1/2Y offset to center the line within the raster-spot-row
      set Yg [expr {($Y)+(($::machine::v(spotY))/2)}] ;# add a 1/2Y offset to center the line within the raster-spot-row
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
        set lvl [expr {int($R*0.3+$G*0.59+$B*0.11)}]
        switch {newest} {
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
              machine::XY $Xi(1) $Yg
            }
          }
          newest {
            set Xi(0) [expr {$X}]
            set Xi(1) [expr {$X+$::machine::v(spotX)}]
            lappend scanLine $lvl $X
          }
        }
        set xp $X
      } ;# <----------------- end of x loop
      incr scanLineCount
      if {[info exists scanLine]} {
        if {$scanLineCount & 1} {
          ## left-to-right line
          set lvl0 [shift scanLine]
          set pt0 [shift scanLine]
          #  walk line lookng for non-0 level
          #while {$lvl0 == 255} {}
          while {[lvl== $lvl0 255]} {
            if {[llength $scanLine] == 0} {
              set pt $pt0
              set lvl $lvl0
              break
            }
            set lvl0 [shift scanLine]
            set pt0 [shift scanLine]
          }
          if {[llength $scanLine] > 0} {
            # move to new line start from lastX,?? to pt0,Yi
            machine::setLaserLevel 0
            machine::XY $pt0 $Yg
          } else {
            #break
          }
          foreach {lvl pt} $scanLine {
            #if {$lvl != $lvl0} {}
            if {[lvl!= $lvl $lvl0]} {
              Dst create line $pt0 $Yi $pt $Yi -width $::machine::v(spotY) -fill [format "#%02x%02x%02x" [lvlMask $lvl0] [lvlMask $lvl0] [lvlMask $lvl0]]
              if {$gcode} {
                machine::setLaserLevel [machine::mapLevel [lvlMask $lvl]]
                machine::XY $pt $Yg
              }
              if {$v(updateRate) eq "raster"} {update idletasks}
              set lvl0 $lvl
              set pt0 $pt
            }
          }
          if {$pt != $pt0} { ;# complete the scanline which was unchanged
            #if {$lvl != 255} {}
            if {[lvl!= $lvl 255]} {
              # dont bother drawing laser-off endlines
              Dst create line $pt0 $Yi $pt $Yi -width $::machine::v(spotY) -fill [format "#%02x%02x%02x" [lvlMask $lvl] [lvlMask $lvl] [lvlMask $lvl]]
              if {$v(updateRate) eq "raster"} {update idletasks}
              if {$gcode} {
                machine::setLaserLevel [machine::mapLevel [lvlMask $lvl]]
                machine::XY $pt $Yg
              }
            }
          }
        } else {
          ## right-to-left line
          set scanLine [lreverse $scanLine]
          set pt0 [shift scanLine]
          set lvl0 [shift scanLine]
          #  walk line lookng for non-0 level
          #while {$lvl0 == 255} {}
          while {[lvl== $lvl0 255]} {
            if {[llength $scanLine] == 0} {
              set pt $pt0
              set lvl $lvl0
              break
            }
            set pt0 [shift scanLine]
            set lvl0 [shift scanLine]
          }
          if {[llength $scanLine] > 0} {
            # move to new line start from lastX,?? to pt0,Yi
            machine::setLaserLevel 0
            machine::XY $pt0 $Yg
          }
          foreach {pt lvl} $scanLine {
            #if {$lvl != $lvl0} {}
            if {[lvl!= $lvl $lvl0]} {
              Dst create line $pt0 $Yi $pt $Yi -width $::machine::v(spotY) -fill [format "#%02x%02x%02x" [lvlMask $lvl0] [lvlMask $lvl0] [lvlMask $lvl0]]
              if {$gcode} {
                machine::setLaserLevel [machine::mapLevel [lvlMask $lvl0]]
                machine::XY $pt $Yg
              }
              if {$v(updateRate) eq "raster"} {update idletasks}
              set lvl0 $lvl
              set pt0 $pt
            }
          }
          if {$pt != $pt0} { ;# complete the scanline which was unchanged
            #if {$lvl != 255} {}
            if {[lvl!= $lvl 255]} {
              # dont bother drawing laser-off endlines
              Dst create line $pt0 $Yi $pt $Yi -width $::machine::v(spotY) -fill [format "#%02x%02x%02x" [lvlMask $lvl] [lvlMask $lvl] [lvlMask $lvl]]
              if {$v(updateRate) eq "raster"} {update idletasks}
              if {$gcode} {
                machine::setLaserLevel [machine::mapLevel [lvlMask $lvl]]
                machine::XY $pt $Yg
              }
            }
          }
        }
        if {$v(updateRate) eq "rasterLine"} {update idletasks}
        unset scanLine
      } else {
        update idletasks
      }
      unset xp
      set yp $Y
#      if {$gcode} {
#        machine::setLaserLevel 0
#      }
    } ;# <------------------- end of y loop
  }

  set v(lvlMask) 0xF0
  proc lvlMask {a} {variable v; return [expr {$a & $v(lvlMask)}]}
  proc lvl== {a b} {variable v; return [expr {($a & $v(lvlMask))==($b & $v(lvlMask))}]}
  proc lvl<  {a b} {variable v; return [expr {($a & $v(lvlMask))< ($b & $v(lvlMask))}]}
  proc lvl!= {a b} {variable v; return [expr {($a & $v(lvlMask))!=($b & $v(lvlMask))}]}


  proc changePPMM {ppmm} {
    variable v
    set v(ppmm) $ppmm
    catch {
      set v(gX) [format "%d" [expr {int(1.0*$::image::v(pw)/$v(ppmm))}]]
      set v(gY) [format "%d" [expr {int(1.0*$::image::v(ph)/$v(ppmm))}]]
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
    grid {*}[labelThing -path $w.dsti -name optimizationLevel -variable [namespace current]::v(optimizationLevel) -text "Optimization Level" -optMenu $v(optLevels)] -sticky ew
    grid {*}[labelThing -path $w.dsti -name updateRate -variable [namespace current]::v(updateRate) -text "update rate" -optMenu $v(updateRates)] -sticky ew
    #grid {*}[labelThing -path $w.dsti -name step6 -text "Step-6 :" -cmd "Generate g-code" {.nb select .nb.f1; rast::rasterize 1}] -sticky ew
    grid {*}[labelThing -path $w.dsti -name lvlMask -variable [namespace current]::v(lvlMask) -text "level Mask" -entry] -sticky ew

  	return $w
  }
}