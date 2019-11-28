#helpers
proc shift {vname} {
  upvar $vname x
  #set ans [lindex $x 0]
  set x [lassign $x ans]
  return $ans
}
proc labelEntry {path name text value} {
  label $path.${name}l -text $text
  entry $path.${name}e -textvariable v($name)
  set ::v($name) $value
  return [list $path.${name}l $path.${name}e]
}
proc labelThing {args} {
  set path ".t"
  set name "name"
  set scr {}
  set wl {}
  set var {::v($name)}
  while {[llength $args] > 0} {
    set cmd [shift args]
    switch -- $cmd {
      -path {set path [shift args]}
      -name {set name [shift args]}
      -text  {lappend scr [subst -novariables {label $path.${name}l -text "[shift args]" -anchor w; lappend wl $path.${name}l}]}
      -entry {lappend scr [subst -novariables {entry $path.${name}e -textvariable [subst {$var}] -justify right; lappend wl $path.${name}e}]}
      -label {lappend scr [subst -novariables {label $path.${name}v -textvariable [subst {$var}] -anchor e -relief sunken -bd 2; lappend wl $path.${name}v}]}
      -value {lappend scr [subst -novariables {set [subst {$var}] [shift args]}]}
      -cmd   {lappend scr [subst -novariables {button $path.${name}c -text "[shift args]" -command "[shift args]"; lappend wl $path.${name}c}]}
      -scale {lappend scr [subst -novariables {scale $path.${name}s -variable [subst {$var}] -orient horizontal {*}[shift args]; lappend wl $path.${name}s}]}
      -variable {set var [shift args]}
      default {error "labelThing bad cmd=$cmd"}
    }
    #puts stderr [format "labelThing: cmd='%s' scr='%s'" $cmd $scr]
  }
  #puts stderr [join $scr "\n  "]
  eval [join $scr "\n"]
  return $wl
}
