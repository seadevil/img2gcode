#
# all image manipulation code
#



namespace eval image {
  #
  variable v
  set v(imgFmts) {}
  ## natine fmts
  #lappend v(imgFmts) *.gif *.ppm 
  lappend v(imgFmts) {"gif Image" {.gif} {GIFF}}
  lappend v(imgFmts) {"ppm Image" {.ppm} {PPMf}}
  if {[catch {package require img::jpeg}]} {
    ## not loaded
    puts stderr "unable to load jpg image format library"
  } else {
    lappend v(imgFmts) {"JPEG Image" {*.jpg .jpeg} {JPEG}}
  }
  ## {png .png {PNGf}}
  ## types doc at http://livecode.byu.edu/helps/file-creatorcodes.php


  ## LoadImg
  proc Load... {} {
    variable v
    #puts stderr [format "formats=%s" $v(imgFmts)]
    set fName [tk_getOpenFile -filetypes $v(imgFmts)]
    if {$fName ne ""} {
      global f1
      $v(srcW) config -image {}
      srcimg blank
      srcimg read $fName
      set ::v(pw) [image width srcimg]
      set ::v(ph) [image height srcimg]
      set ::v(aspect) [expr {1.0*$::v(pw)/$::v(ph)}]
      set scale [expr {100.0/$::v(pw)}]    
      scaleOfImage srcimg $scale srcImgIcon
      $v(srcW) config -image srcImgIcon
      set ::v(gX) $::v(pw)
      set ::v(gY) $::v(ph)
      set ::v(ppmm) 1
      #$::f1.i.dst config -width $::v(gX) -height $::v(gY)
      rast::Dst config -width $::v(gX) -height $::v(gY)
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
  	label $w.srcLabel -text "Source Image"
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
  	grid {*}[labelThing -path $w.srci -name pw -text "img pixel width" -label -value ?]
  	grid {*}[labelThing -path $w.srci -name ph -text "img pixel height" -label -value ?]
  	grid {*}[labelThing -path $w.srci -name aspect -text "img aspect w/h" -label -value ?]
  	#
  	return $w
  }
}