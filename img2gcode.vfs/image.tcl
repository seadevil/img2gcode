#
# all image manipulation code
#



namespace eval image {
  #
  variable v
  set v(maxDisplayX) 800
  set v(maxDisplayY)  600

  set v(imgFmts) {}
  ## natine fmts
  #lappend v(imgFmts) *.gif *.ppm 
  lappend v(imgFmts) {"gif Image" {.gif} {GIFF}}
  lappend v(imgFmts) {"ppm Image" {.ppm} {PPMf}}
  if {[catch {package require img::base 1.4.4}]} {
    puts stderr "unable to load img::base :\n$::errorInfo"
  }
  puts stderr "============================================ jpg"
  if {[catch {package require img::jpeg}]} {
    ## not loaded
    puts stderr "unable to load jpg image format library:\n$::errorInfo"
  } else {
    lappend v(imgFmts) {"JPEG Image" {*.jpg .jpeg} {JPEG}}
  }
  puts stderr "============================================ png"
  if {[catch {package require -exact img::png 1.4.4}]} {
    ## not loaded
    puts stderr "unable to load png image format library:\n$::errorInfo"
  } else {
    lappend v(imgFmts) {"PNG Image" {*.png} {PNGf}}
  }
  puts stderr "============================================"
  #
  ## {png .png {PNGf}}
  ## types doc at http://livecode.byu.edu/helps/file-creatorcodes.php


  ## LoadImg
  proc Load... {} {
    variable v
    #puts stderr [format "formats=%s" $v(imgFmts)]
    set fName [tk_getOpenFile -filetypes $v(imgFmts)]
    if {$fName ne ""} {
      global f1 ;#<---------------------------- remove?
      $v(srcW) config -image {}
      srcimg blank
      image delete srcimg
      catch {image delete srcImgIcon}
      image create photo srcimg ;#
      srcimg read $fName
      set v(pw) [image width srcimg]
      set v(ph) [image height srcimg]
      #puts stderr [format "v(pw)='%s' v(ph)='%s'" $v(pw) $v(ph)]
      if {($v(pw) == 0) || ($v(ph) == 0) } {
      	puts stderr "?? something failed in the image load..."
      	# fallback for the p?? error
      	set v(pw) 100
      	set v(ph) 100
      }
      set v(aspect) [expr {1.0*$v(pw)/$v(ph)}]
      set scale [expr {100.0/$v(pw)}]
      scaleOfImage srcimg $scale srcImgIcon
      ## adjust gcode/canvas settings
      $v(srcW) config -image srcImgIcon
      if {0} {
        set ::rast::v(gX) $v(pw)
        set ::rast::v(gY) $v(ph)
        set ::rast::v(ppmm) 1
      } else {
        ::rast::changePPMM 1
        ## scale down the rast canvas based on maxDisplay size variables
        #puts stderr {($::rast::v(gX) > $v(maxDisplayX)) || ($::rast::v(gY) > $v(maxDisplayY))}
        #puts stderr "($::rast::v(gX) > $v(maxDisplayX) ) || ($::rast::v(gY) > $v(maxDisplayY) )"
        while {($::rast::v(gX) > $v(maxDisplayX)) || ($::rast::v(gY) > $v(maxDisplayY))} {
          #puts stderr "scale down by 2" ; flush stderr
    	    set ::rast::v(ppmm) [expr {$::rast::v(ppmm)*2}]
      	  ::rast::changePPMM $::rast::v(ppmm)
        }
      }
      #rast::Dst config -width $::rast::v(gX) -height $::rast::v(gY)
      set v(fName) $fName
    }
  }

  proc scaleOfImage {im scale {imName {}}} {
    ## ref: https://wiki.tcl-lang.org/page/Image+scaling
    ## but changed, I use a factor of 10x for now
    if {abs($scale) < 1} {
      set num 10
      set sf [expr {round(1.0*$num/$scale)}]
      set t1 [image create photo]
      $t1 copy $im -shrink -zoom $num
      set t [image create photo {*}$imName]
      $t copy $t1 -shrink -subsample $sf
      image delete $t1
    } else {
      set num 10
      set sf [expr {round($num*$scale)}]
      set t1 [image create photo]
      $t1 copy $im -shrink -zoom $sf
      set t [image create photo {*}$imName]
      $t copy $t1 -shrink -subsample $num
      image delete $t1
    }
    return $t
  }

  proc Frame {w} {
  	frame $w -relief ridge -bd 2 -bg grey
  	button $w.srcLabel -text "Source Image" -command [namespace code {Load...}]
  	#menubutton $f1.i.srcZoom -menu $f1.i.srcZoom.m -text "Zoom"
  	#menu $f1.i.srcZoom.m insert end -label "Fit" -command "srcZoom 1"
  	image create photo srcimg ;#
  	label $w.src -image srcimg -width 100 -height 100 -bd 2 -relief groove
  	variable v
  	set v(srcW) $w.src
  	frame $w.srci -relief sunken -bd 2 -bg red
  	grid $w.srcLabel
  	grid $w.src ;#-sticky ew
  	grid $w.srci -sticky nsew
  	grid {*}[labelThing -path $w.srci -name pw -variable [namespace current]::v(pw) -text "img pixel width" -label -value ?]
  	grid {*}[labelThing -path $w.srci -name ph -variable [namespace current]::v(ph) -text "img pixel height" -label -value ?]
  	grid {*}[labelThing -path $w.srci -name aspect -variable [namespace current]::v(aspect) -text "img aspect w/h" -label -value ?]
  	#
  	return $w
  }
}