open_project [glob *.xpr]

set project_name [current_project]

if {[info exists sdk_workspace] == 0} {
    set sdk_workspace ${project_name}.linux
}
if { [file exists ${sdk_workspace}] == 0 } {
    file mkdir ${sdk_workspace}
}

set design_top_name [get_property "top" [current_fileset]]
file copy -force [file join $project_name.runs "impl_1" $design_top_name.hwdef] [file join $sdk_workspace $design_top_name.hwdef]
file copy -force [file join $project_name.runs "impl_1" $design_top_name.sysdef] [file join $sdk_workspace $design_top_name.hdf]
file copy -force [file join $project_name.runs "impl_1" $design_top_name.sysdef] [file join $sdk_workspace $design_top_name.sysdef]
file copy -force [file join $project_name.runs "impl_1" $design_top_name.bit] [file join $sdk_workspace $design_top_name.bit]

close_project