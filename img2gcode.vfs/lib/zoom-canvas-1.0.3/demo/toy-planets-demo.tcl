# toy-planets-demo

set THIS_DIR [file dirname [file normalize [info script]]]
lappend auto_path $THIS_DIR/..


package require tile
package require zoom-canvas


tk::panedwindow .w -orient horizontal
pack .w -expand 1 -fill both

# --- control panel
ttk::frame .panel -relief raised -pad {10 10 10 10}     
    set row 0
    
    ttk::label .panel.help -text "* Use MouseWheel for zooming\n* Press Left-Button for panning" \
        -relief ridge
    grid x .panel.help -row [incr row]
    incr row

    set ::TIMESCALE 33000
    
    ttk::label .panel.time -text "Simulated time"
    ttk::scale .panel.timeScale -variable ::TIMESCALE -from 31E4 -to 31E6   
    grid .panel.time  .panel.timeScale - -row [incr row]
    
    set ::SHOWORBITS 1
    set ::ANIMATION 1
    ttk::checkbutton .panel.animation -text "Animation" -variable ::ANIMATION
    ttk::checkbutton .panel.showOrbit -text "Show Orbits" -variable ::SHOWORBITS    
    grid .panel.animation x .panel.showOrbit -row [incr row]
    
    set ::CENTER elio
    ttk::radiobutton  .panel.elio -text "ElioCentric" -value "elio" -variable CENTER
    ttk::radiobutton  .panel.geo  -text "GeoCentric"  -value "geo"  -variable CENTER
    grid x .panel.elio x -row [incr row]
    grid x .panel.geo  x -row [incr row]

    incr row    
    ttk::button .panel.bestFit -text "Best Zoom" -command {.c zoomfit xy}
    grid x .panel.bestFit x -row [incr row]
    incr row

    lassign [grid size .panel] cols rows
    for {set i 0} { $i < $rows} {incr i} {
        grid rowconfigure .panel $i -minsize 30
    }
    grid columnconfigure . all -pad 4
    
.w add .panel


# -- panel for zoom-canvas and status bar
ttk::frame .cvspanel

    zoom-canvas .c -highlightthickness 0

    ttk::frame .status
    ttk::label .status.zoom -textvariable ::ZOOMSTATUS
    ttk::label .status.xy -textvariable ::XYSTATUS
    pack .status.xy -side right
    pack .status.zoom   -side left

    pack .c      -in .cvspanel -expand 1 -fill both 
    pack .status -in .cvspanel -side bottom -fill x

.w add .cvspanel

# === control panel logic =====================================================

bind .c <<Zoom>> { ZoomStatus %d }
proc ZoomStatus { z } {
    set ::ZOOMSTATUS "Zoom: $z"
}
bind .c <Motion> { XYStatus %W %x %y }
proc XYStatus { zc x y } {
    set ::XYSTATUS [format "(%.2f,%.2f)" {*}[$zc V2W $x $y]]
}


trace add variable ANIMATION write ToggleAnimation
proc ToggleAnimation {args} {
    global ANIMATION
    if { $ANIMATION } {
        StartAnimation
    } else {
        StopAnimation    
    }
}

trace add variable SHOWORBITS write ShowOrbits
proc ShowOrbits {args} {
    global SHOWORBITS
    set state [expr {$SHOWORBITS ? "normal" : "hidden"}]
    .c itemconfigure ORBIT -state $state
}

trace add variable CENTER write ToggleCenter
proc ToggleCenter {args} {
    global ANIMATION
    global CENTER
    if { $ANIMATION } {
        StartAnimation    
    }
}

## ----------------------------------------------------------------------------

#  * planet-name
#  * distance-from-Sun(km) 
#  * radius(km) 
#  * orbit-period(sec) 
#  * theta0: angular position at time T0  (? assume 0.0 )
#  * color: planet's color

set Planets {
 { Mercury  57.9E6  2440   7595130  0.0  orange}
 { Venus   108.2E6  6051  19400852  0.0  green }
 { Earth   149.5E6  6371  31536548  0.0  blue  }
 { Mars    227.9E6  3389  59312908  0.0  red   }
 { Jupiter 778.3E6 69900 374016960  0.0  yellow}
 { Saturn  1426E6  58200 927158400  0.0  yellow}
}

proc CreateSolarSystem {zc} {
    # draw the Sun
    set R 10E6   ; # ???
    $zc create oval [$zc W2C -$R -$R $R $R] -fill yellow
    
    foreach planet $::Planets {
        lassign $planet name orad prad period theta0 color
         # draw orbit
        $zc create oval [$zc W2C -$orad -$orad $orad $orad] -outline gray30 -tags ORBIT
         # draw planet at theta 0
        set prad [expr 100.0*$prad] ; #  draw planets 100x
         # planets (even at 100x) are too small; draw also a "point"
        $zc create point 0 0 -tags $name -foreground $color                   
        $zc create oval [$zc W2C -$prad -$prad $prad $prad] -fill $color -tags $name
        set ::lastPos($name) [list $orad 0.0]  
        $zc move $name {*}[$zc W2C $::lastPos($name)] 
    }
}
    

proc StopAnimation {} { 
    after cancel [after info] 
}

  
set T0 [clock milliseconds]

  # get the real time, then 
proc currTime {} {
    global T0
    global TIMESCALE

    expr {(([clock milliseconds]-$T0)/1000.0)*$TIMESCALE}
    expr {(([clock milliseconds]*$TIMESCALE-$T0)/1000.0)}
}  

proc StartAnimation {} {
    global CENTER
    
    StopAnimation
    switch -- $CENTER {
     elio ElioCentricLoop
     geo  GeoCentricLoop
    }
}

proc updateElioCentric {zc t} {
    global Planets
    global lastPos
    
    foreach planet $Planets {
        lassign $planet name orad prad period theta0 color

         # new angular pos will be   2PI*t/period + theta0
        set theta [expr {$theta0+2*3.1414*$t/$period}]
        set x [expr {$orad*cos($theta)}]
        set y [expr {$orad*sin($theta)}]
        lassign $lastPos($name) x0 y0
        set dx [expr {$x-$x0}] ;
        set dy [expr {$y-$y0}] ;
        $zc move $name {*}[$zc W2C $dx $dy]

        set lastPos($name) [list $x $y]  
    }
}
 
proc ElioCentricLoop {} {
    updateElioCentric .c [currTime]
    after 100 ElioCentricLoop
}
  

proc updateGeoCentric {zc t} {
    global lastPos
    global Planets
    
    set VXY [$zc W2V $lastPos(Earth)]

    foreach planet $Planets {
        lassign $planet name orad prad period theta0 color

         # new angular pos will be   2PI*t/period + theta0
        set theta [expr {$theta0+2*3.1414*$t/$period}]
        set x [expr {$orad*cos($theta)}]
        set y [expr {$orad*sin($theta)}]
        lassign $lastPos($name) x0 y0
        set dx [expr {$x-$x0}] ;
        set dy [expr {$y-$y0}] ;
        $zc move $name {*}[$zc W2C $dx $dy]

        set lastPos($name) [list $x $y]  
    }
    $zc overlap {*}$lastPos(Earth) {*}$VXY
}  

proc GeoCentricLoop {} {
    updateGeoCentric .c [currTime]
    after 100 GeoCentricLoop
} 

# ----------------------
.c configure -background black
CreateSolarSystem .c

update
.c zoomfit


set TIMESCALE 3000000
set ANIMATION 1