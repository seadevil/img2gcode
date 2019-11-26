#=============================================
##
## demo for zoom-canvas
##
#=============================================

set THIS_DIR [file dirname [file normalize [info script]]]
lappend auto_path $THIS_DIR/..

# ----------------------------------------------------------------------------
# --  prepare some info widgets ...
# ----------------------------------------------------------------------------
frame .info
 label .info.msg -textvariable msgInfo
 label .info.xy -textvariable xyInfo
 label .info.zoom -textvariable zoomInfo
pack .info -fill x -side bottom
 pack .info.msg
 pack .info.zoom .info.xy -side right
 pack .info.zoom -side left
 pack .info.xy -side right

set msgInfo {
* Press Mouse-Button-1 and drag the canvas
* Use MouseWheel for zooming
* Press key F1 for Zoom Best Fit

* When you are on a "draggable" item, cursor changes; you can drag it !
  
* You can also interact with this widget (.zc) through the wish console
}

catch {console show}

# ----------------------------------------------------------------------------
# -- create a zoom-canvas widget
# ----------------------------------------------------------------------------
package require zoom-canvas
zoom-canvas .zc -background gray90
pack .zc -expand 1 -fill both


# ----------------------------------------------------------------------------
# -- Set some "classic" bindings
# ----------------------------------------------------------------------------

 # add a draggable-conformant binding ..
.zc bind draggable <Button-1> { set ::X0 %x ; set ::Y0 %y }
.zc bind draggable <B1-Motion> { dragItem %W current %x %y ; break }
proc dragItem {cvs id x y} {
  set dx [expr $x-$::X0]
  set dy [expr $y-$::Y0]
  
  $cvs move $id $dx $dy
  set ::X0 $x
  set ::Y0 $y
}
.zc bind draggable <Enter>  { %W configure -cursor fleur }
.zc bind draggable <Leave>  { %W configure -cursor {} }

 # -- some bindings for status-bar continuos update
bind .zc <Key-F1> { %W zoomfit xy }

 # -- track the mouse position (and the related World-Coords) 
bind .zc <Motion> { showPosition %W %x %y }
proc showPosition {cvs x y} {
   set ::xyInfo [format "Viewport (%d,%d) --> World (%.2f,%.2f)" $x $y {*}[$cvs V2W $x $y]]
}

 # -- track the zoom factor 
bind .zc <<Zoom>> { showZoom %d }
proc showZoom {f} {
    set ::zoomInfo "Zoom: [format %.2f $f]" 
}
showZoom [.zc zoom]


# ----------------------------------------------------------------------------
# -- Here is the core demo
# --   add some canvas items ...
# ----------------------------------------------------------------------------

lassign {-3000 -1000 +3000 +1000} Wx0 Wy0 Wx1 Wy1

 # draw X axis
.zc create line [.zc W2C $Wx0 0 $Wx1 0] -fill gray
for {set x $Wx0} {$x <=$Wx1} {incr x 100} {
   .zc create text [.zc W2C  $x 0] -text $x -anchor s
   .zc create point [.zc W2C $x 0] -foreground gray
}
 # draw Y axis
.zc create line [.zc W2C 0 $Wy0 0 $Wy1] -fill gray
for {set y $Wy0} {$y <=$Wy1} {incr y 100} {
   .zc create text [.zc W2C -10 $y] -text $y -anchor e
   .zc create point [.zc W2C 0 $y] -foreground gray
}

# unnecessary, just for demo:  change the zoom  .. and then add some more
#  canvas items.
.zc zoom 0.5


 # draw a point at world-coord 100,100 (with some text). 
.zc create point [.zc W2C 100 100]
.zc create text [.zc W2C 100 110] -text "(100,100)"

 # draw a spline (in world-coords) - this is draggable
.zc create line [.zc W2C -200 0 -100 200 100 -200 200 0] -smoot true -tags draggable

 # draw a circle with radius 100, then scale it 2x - this is draggable
.zc create oval [.zc W2C -100 -100 100 100] -tag {CIRCLE draggable}
.zc scale CIRCLE -0 0 2.0 2.0

 # a draggable point
.zc create point [.zc W2C 50 50] -foreground blue -tags draggable

 # a draggable polygon
.zc create polygon [.zc W2C 127 143 177 263.2 277 23.2 327 143] \
  -fill orange -outline blue \
  -tags draggable -smooth true


 # -- just for demo readability: all !draggable items must be gray
foreach id [.zc find withtag !draggable] {
    switch -- [.zc type $id] {
      line -
      text -
      arc { set opt1 -fill}
      rectangle -
      polygon -
      oval { set opt1 -outline}
      bitmap { set opt1 -foreground}
      default { set opt1 {} }
    }
    if { $opt1 != {} } {
        .zc itemconfigure $id $opt1 "gray"
    }
}

update
.zc zoomfit xy
.zc zoom 0.5
focus .zc
