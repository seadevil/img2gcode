if {![package vsatisfies [package provide Tcl] 8.4]} return

package ifneeded zlibtcl 1.2.8.1 [string map [list @ $dir] {
  package require Tcl 8.4
  switch -glob -- $::tcl_platform(os) {
    Lin* {error "missing lib (rwm)"}
    Win* {error "missoing lib (rwm)"}
    Darwin* {load [file join {@} libzlibtcl1.2.8.1.dylib]}
    default {error "missoing lib (rwm)"}
  }
  package provide zlibtcl 1.2.8.1
}]
