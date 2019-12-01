package require starkit
  if {[starkit::startup] ne "sourced"} {
  	set v(root) $starkit::topdir
    source [file join $starkit::topdir img2gcode.tcl]
  } else {
  	puts stderr "Got here..."
  }

