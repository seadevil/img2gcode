
if {![package vsatisfies [package provide Tcl] 8.4]} return

package ifneeded pngtcl 1.6.17 [string map [list @ $dir] {
  package require Tcl 8.4
  package require zlibtcl
  load [file join {@} libpngtcl1.6.17.dylib]
  package provide pngtcl 1.6.17
}]
