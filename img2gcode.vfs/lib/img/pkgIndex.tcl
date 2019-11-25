

if {![package vsatisfies [package provide Tcl] 8.4]} return

## img::base
package ifneeded img::base 1.4.4 [string map [list @ $dir] {
  package require Tcl 8.4
  package require Tk 8.4
  load [file join {@} libtkimg1.4.4.dylib]
  package provide img::base 1.4.4
}]

## img::jpeg
package ifneeded img::jpeg 1.4.4 [string map [list @ $dir] {
  package require img::base 1.4-2
  package require Tcl 8.4
  package require Tk 8.4
  package require jpegtcl
  load [file join {@} libtkimgjpeg1.4.4.dylib]
  package provide img::jpeg 1.4.4
}]

## img::png
package ifneeded img::png 1.4.4 [string map [list @ $dir] {
  package require img::base 1.4-2
  package require Tcl 8.4
  package require Tk 8.4
  package require pngtcl
  load [file join {@} libtkimgpng1.4.4.dylib]
  package provide img::png 1.4.4
}]

