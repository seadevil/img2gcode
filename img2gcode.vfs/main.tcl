package require starkit
  if {[starkit::startup] ne "sourced"} {
  	#::tcl::tm::path add [file join $starkit::topdir lib]
  	#starkit::autoextend [file join $starkit::topdir lib tcllib]
  	::tcl::tm::path add [file join $starkit::topdir lib img];
  	::tcl::tm::path add [file join $starkit::topdir lib tkcon]
  	#::tcl::tm::path add [file join $starkit::topdir lib zlibtcl]
  	#::tcl::tm::path add [file join $starkit::topdir lib jpegtcl]
  	set v(root) $starkit::topdir
    source [file join $starkit::topdir img2gcode.tcl]
    #puts stderr "Got here 1..."
  } else {
  	puts stderr "Got here... (not sourced ??)"
  }

