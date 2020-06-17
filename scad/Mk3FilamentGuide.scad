//###############################################################################
//# MK3 Filament Guide - Main Assembly                                          #
//###############################################################################
//#    Copyright 2020 Dirk Heisswolf                                            #
//#    This file is part of the MK3 Filament Guide project.                     #
//#                                                                             #
//#    This project is free software: you can redistribute it and/or modify     #
//#    it under the terms of the GNU General Public License as published by     #
//#    the Free Software Foundation, either version 3 of the License, or        #
//#    (at your option) any later version.                                      #
//#                                                                             #
//#    This project is distributed in the hope that it will be useful,          #
//#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
//#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
//#    GNU General Public License for more details.                             #
//#                                                                             #
//#    You should have received a copy of the GNU General Public License        #
//#    along with this project.  If not, see <http://www.gnu.org/licenses/>.    #
//#                                                                             #
//#    This project makes use of the NopSCADlib library                         #
//#    (see https://github.com/nophead/NopSCADlib).                             #
//#                                                                             #
//###############################################################################
//# Description:                                                                #
//#   Assembly of the MK3 Filament Guide.                                       #
//#                                                                             #
//###############################################################################
//# Version History:                                                            #
//#   May 31, 2020                                                              #
//#      - Initial release                                                      #
//#                                                                             #
//#   June 14, 2020                                                             #
//#      - Fixed compatibility issue with recent NopSCADlib                     #
//#                                                                             #
//###############################################################################

include <NopSCADlib/lib.scad>
//include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/ball_bearings.scad>

//Filament offset
//===============
$fo_y          = 50.0;    //Distance to frame   
$fo_z          = 50.0;    //Height offset

//Frame dimensions
//================
$frame_z       = 40.3;    //Frame height
$frame_y       =  6.5;    //Frame thickness

//Holder
//======
$holder_min_width    = 10; //Minimum holder width                              
$holder_clamp_width  =  4; //Minimum holder width                              
$holder_clamp_depth  = 30; //Minimum holder depth                              
$holder_clamp_height = 12; //Minimum holder height                              

//Filament
//========
$filament_width = 1.75; //Filament width  

//Ball bearings
//=============
$bb_type            = BB608;                          //Standard 608 bearings
$bb_height          = $bb_type[3];                    //Ball bearing height
$bb_diameter        = $bb_type[2];                    //Ball bearing diameter
$bb_bore            = $bb_type[1];                    //Ball bearing bore
$bb_radius          = $bb_diameter/2;                 //Ball bearing radius
$bb_halfheight      = $bb_height/2;                   //Half of the ball bearing height
$bb_offset          = $bb_halfheight+.1 ;             //Axis offset
$bb_spacer_diameter = $bb_bore+2;                     //Spacer width                  
$bb_spacer_height   = 1;                              //Spacer height
$bb_spacer_radius   = $bb_spacer_diameter/2;          //Spacer height
$bb_clearance       = 2;                              //Space around the bearing
$bb_slot            = 2;                              //Width of the holder's slot
$bb_holder_width    = $bb_bore-2;                     //Width of the Bearing holder

//$explode=1;
//$vpr = [70,0,110];
//$vpt = [0, 0, 0];

//Common shapes
module torus(diameter=$bb_bore,height=($bb_bore/2)) {
    rotate_extrude() translate([(diameter/2)-(height/2),0,0]) circle(d=height);
}
module bearing_holder() {
    difference() {    
        union() {
            translate([0,0,$bb_halfheight+($bb_spacer_height/2)]) torus(diameter=$bb_bore+$bb_spacer_height,height=$bb_spacer_height); 
            translate([0,0,-$bb_halfheight])                   cylinder($bb_height+$bb_spacer_height,d=$bb_bore);
            translate([0,0,-$bb_halfheight-$bb_spacer_height]) cylinder($bb_spacer_height,d=$bb_spacer_diameter);
        } 
        union() {
            translate([0,0,$bb_spacer_height]) cube([$bb_diameter,$bb_slot,$bb_height+(2*$bb_spacer_height)],center=true);
            translate([10+($bb_holder_width/2),0,0])  cube([20,20,20],center=true);
            translate([-10-($bb_holder_width/2),0,0]) cube([20,20,20],center=true);
        }
    }
}
   
//! This is a filament guide for Prusa MK3(S) printers . 
// ![inside](doc/DIYLB.gif?raw=true)

//3D Print
module MK3FilamentGuide_stl() {  
    stl("MK3FilamentGuide");
    color(pp1_colour)
    difference() {
        union() {
            //Bearing holders            
            translate([0,$bb_radius+$bb_offset,0])  rotate([0,0,0])   bearing_holder();
            translate([0,-$bb_radius-$bb_offset,0]) rotate([180,0,0]) bearing_holder();
            translate([0,0,-$bb_radius-$bb_offset]) rotate([90,0,0])  bearing_holder();
            //Frame
            hull() {
                translate([-$bb_holder_width/2,$bb_offset+$bb_radius-$bb_spacer_radius,-$bb_halfheight-$bb_spacer_height-$holder_min_width/sqrt(2)]) 
                    cube([$bb_holder_width,$bb_spacer_diameter,$holder_min_width/sqrt(2)]);
                translate([-$bb_holder_width/2,$bb_halfheight+$bb_spacer_height,-$bb_offset-$bb_radius-$bb_spacer_radius]) 
                    cube([$bb_holder_width,$holder_min_width/sqrt(2),$bb_spacer_diameter]);
            }
            translate([-$bb_holder_width/2,$bb_halfheight+$bb_spacer_height,-$bb_offset-$bb_diameter-$bb_clearance]) 
                cube([$bb_holder_width,$holder_min_width,$bb_radius+$bb_spacer_radius+$bb_clearance]);
            hull() {
                translate([-$bb_holder_width/2,$bb_halfheight+$bb_spacer_height,-$bb_offset-$bb_diameter-$bb_clearance-$holder_min_width/sqrt(2)]) 
                    cube([$bb_holder_width,$holder_min_width,$holder_min_width/sqrt(2)]);
                translate([-$bb_holder_width/2,$bb_halfheight+$bb_spacer_height,-$bb_offset-$bb_diameter-$bb_clearance-$holder_min_width]) 
                    cube([$bb_holder_width,$holder_min_width/sqrt(2),$holder_min_width]);
            }
            translate([-$bb_holder_width/2,-$fo_y+$frame_y/2,-$bb_offset-$bb_diameter-$bb_clearance-$holder_min_width]) 
                cube([$bb_holder_width,$fo_y+$bb_halfheight+$bb_spacer_height-$frame_y/2,$holder_min_width]);
            translate([-$bb_holder_width/2,-$bb_offset-$bb_diameter-$bb_clearance,$bb_halfheight+$bb_spacer_height]) 
                cube([$bb_holder_width,$bb_diameter+$bb_clearance,$holder_min_width]);
            hull() {
                translate([-$bb_holder_width/2,
                        -$bb_offset-$bb_diameter-$bb_clearance-$holder_min_width,
                        -$bb_offset-$bb_diameter-$bb_clearance-$holder_min_width]) 
                    cube([$bb_holder_width,
                        $holder_min_width,
                        $bb_spacer_height+$bb_halfheight+$bb_offset+$bb_diameter+$bb_clearance+2*$holder_min_width]);
                translate([-$bb_holder_width/2,-$fo_y-$frame_y/2-$holder_clamp_width,-$fo_z+$frame_z/2-$holder_clamp_height]) 
                    cube([$bb_holder_width,$frame_y+2*$holder_clamp_width,$holder_clamp_width+$holder_clamp_height]);
            }
            translate([-$bb_holder_width/2,-$fo_y-$frame_y/2-$holder_clamp_width,-$fo_z+$frame_z/2-$holder_clamp_height]) 
                cube([$holder_clamp_depth,$frame_y+2*$holder_clamp_width,$holder_clamp_width+$holder_clamp_height]);
            
            translate([-$bb_holder_width/2,0,$bb_halfheight+$bb_spacer_height]) rotate([90,0,90]) linear_extrude($bb_holder_width) 
            polygon(points=[[-$bb_offset,$holder_min_width],
                            [-$bb_offset,0],
                            [-$bb_offset+0,4],
                            [$bb_offset-3,4],
                            [$bb_offset-1,$filament_width-$bb_spacer_height],
                            [$bb_offset,$filament_width-$bb_spacer_height],
                            [$bb_offset,$holder_min_width-3],
                            [$bb_offset-3,$holder_min_width]]);            
        }   
        union() {
            translate([0,-$fo_y,-$fo_z]) rotate([0,0,0]) cube([100,$frame_y,$frame_z],center=true);
        }
    }
}    

//! Push three ball bearings onto the printed part. 
module main_assembly() {
    pose([70, 0, 110], [0,0,0])
    assembly("main") {

        //3D Print
        MK3FilamentGuide_stl()

        //Ball bearing
        translate([0,($bb_radius+$bb_offset),0])  rotate([0,0,0])  explode(15)  ball_bearing($bb_type);
        translate([0,($bb_radius+$bb_offset),0])  rotate([0,0,0])  explode(15)  ball_bearing($bb_type); //Somehow must be duplicated to be visible in review
        translate([0,(-$bb_radius-$bb_offset),0]) rotate([0,0,0])  explode(-45) ball_bearing($bb_type);
        translate([0,0,(-$bb_radius-$bb_offset)]) rotate([90,0,0]) explode(23)  ball_bearing($bb_type);

        //Frame
        color("black")
        translate([0,-$fo_y,-$fo_z]) rotate([0,0,0]) cube([100,$frame_y,$frame_z],center=true);
                
        //Filament
        color("orange")
        translate([-50,0,0]) rotate([0,90,0]) cylinder(100,d=1.75);

    }
}

if($preview) {
    
   main_assembly();
}