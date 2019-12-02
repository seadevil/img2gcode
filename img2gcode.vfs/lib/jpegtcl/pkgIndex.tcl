
if {![package vsatisfies [package provide Tcl] 8.4]} return

package ifneeded jpegtcl 8.4 [string map [list @ $dir] {
  package require Tcl 8.4
  switch -glob -- $::tcl_platform(os) {
    Lin* {error "missing lib (rwm)"}
	Win* {error "missing lib (rwm)"}
	Darwin* {load [file join {@} libjpegtcl8.4.dylib]}
	default {error "missing lib (rwm)"}
  }
  package provide jpegtcl 8.4
}]
