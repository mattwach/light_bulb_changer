// This file shows all of the components on the same screen
// For 3D printing, you'll want to load control_box_assembly and motor_assembly separately
// and search for "Prefix a ! here"

use <control_box_assembly.scad>
use <motor_assembly.scad>

translate([-15, -100, 25])
  control_box_assembly();

translate([0, 70, -4]) rotate([0, 0, 90])
  motor_assembly();
