
XT30_LENGTH = 12.6;
XT30_WIDTH = 10.2;
XT30_HEIGHT = 5.8;

module xt30_2d_base() {
  chamfer = 1.6;

  polygon([
      [0, 0],  // bottom corner
      [XT30_WIDTH - chamfer, 0],  // bottom edge
      [XT30_WIDTH, chamfer],
      [XT30_WIDTH,   XT30_HEIGHT - chamfer],  // right side
      [XT30_WIDTH - chamfer, XT30_HEIGHT],
      [0,    XT30_HEIGHT],
      [0,      0]
  ]);
}

module xt30_hull() {
  linear_extrude(XT30_LENGTH) xt30_2d_base();
}

module xt30() {
  shell_offset = 0.6;
  overlap = 0.1;
  pin_diameter = 1.9;
  pin_bottom_diameter = 2.5;

  module pin_hole(x_pos) {
      translate([x_pos, XT30_HEIGHT / 2, 0]) cylinder(h=XT30_LENGTH, d=pin_bottom_diameter);
  }

  module pin() {
    base_length = 8.8;
    pin_height = 5.5;

    module pin_top() {
      module pin_cutout() {
        cube([pin_diameter, 0.3, pin_height * 2], center=true); 
      }

      translate([0, 0, base_length])
        difference() {
          minkowski() {
            cylinder(d=pin_diameter - 1, h=pin_height - 1);
            sphere(r=0.5);
          }
          pin_cutout();
          rotate([0, 0, 90]) pin_cutout();
        }
    }

    module pin_bottom() {
      difference() {
        cylinder(d=pin_bottom_diameter, h=base_length);
        translate([0, 0, -overlap]) cylinder(d=pin_bottom_diameter - 0.8, h=5);
        translate([-pin_bottom_diameter / 2, 0, -overlap])
          cube([pin_bottom_diameter, pin_bottom_diameter, 2.4 + overlap]);
      }
    }

    color("gold") {
      pin_bottom();
      pin_top();
    }
  }

  pinx = [2.3, 7.5];

  color("yellow", 0.8) {
    difference() {
      xt30_hull();
      translate([0,0,6]) linear_extrude(XT30_LENGTH) offset(-shell_offset) xt30_2d_base();
      translate([0, 0, -overlap]) linear_extrude(5 + overlap) offset(-shell_offset) xt30_2d_base();
      for (i = [0:1]) {
        pin_hole(pinx[i]);
      }
    }
  }

  for (i = [0:1]) {
    translate([pinx[i], XT30_HEIGHT/2, -2.5]) rotate([0, 0, 90 + 180 * i]) pin();
  }
}

//$fn=30;
//xt30();
