package require starkit
  if {[starkit::startup] ne "sourced"} {
  	#::tcl::tm::path add [file join $starkit::topdir lib]
  	#starkit::autoextend [file join $starkit::topdir lib tcllib]
  	set v(root) $starkit::topdir
    source [file join $starkit::topdir img2gcode.tcl]
  } else {
  	puts stderr "Got here..."
  }

