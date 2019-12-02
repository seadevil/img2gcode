

if {![package vsatisfies [package provide Tcl] 8.4]} return

## img::base
package ifneeded hide_img::base 1.4.4 [string map [list @ $dir] {
  package require Tcl 8.4
  package require Tk 8.4
  load [file join {@} libtkimg1.4.4.dylib]
  package provide img::base 1.4.4
}]
package ifneeded hide_img::base 1.4.3 [string map [list @ $dir] {
  package require Tcl 8.4
  package require Tk 8.4
  switch -glob -- $::tcl_platform(os) {
    Lin* {error "missing lib (rwm)"}
    Win* {load [file join {@} tkimg143.dll]}
    Darwin* {error "missing lib (rwm)"}
    default {error "missing lib (rwm)"}
  }
  package provide img::base 1.4.3
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
package ifneeded hide_img::png 1.4.4 [string map [list @ $dir] {
  package require img::base 1.4-2
  package require Tcl 8.4
  package require Tk 8.4
  package require pngtcl
  load [file join {@} libtkimgpng1.4.4.dylib]
  package provide hide_img::png 1.4.4
}]
package ifneeded dorkus 1.1.1 {
  puts stderr "loading dorkus..."
  package provide dorkus 1.1.1
}
package ifneeded img::png 1.4.3 [string map [list @ $dir] {
  puts stderr "loading the lib/ png (rwm)"
  package require img::base 1.4-2
  package require Tcl 8.4
  package require Tk 8.4
  package require pngtcl
  switch -glob -- $::tcl_platform(os) {
    Lin* {error ""}
    Win*    {load [file join {@} tkimgpng143.dll]}
    Darwin* {load [file join {@} libtkimgpng1.4.3.dylib]}
    default {error ""}
  }
  package provide img::png 1.4.3
}]
package ifneeded hide_img::png 1.3 [string map [list @ $dir] {
  package require img::base 1.3-2
  package require Tcl 8.4-9
  package require Tk 8.4-9
  package require pngtcl
  load [file join {@} libtkimgpng1.3.dylib]
  package provide hide_img::png 1.3
}]
