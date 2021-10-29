include <../../util.scad>
include <../../2d_shapes.scad>
include <../../../NopSCADlib/utils/core/core.scad>
include <../../../NopSCADlib/vitamins/pin_headers.scad>

PS2_ANALOG_STICK_WIDTH = 26.3;
PS2_ANALOG_STICK_HEIGHT = 1.6;
PS2_ANALOG_STICK_LENGTH = 34.3;

PS2_ANALOG_STICK_PIN_INSET = 1.4;
PS2_ANALOG_STICK_PIN_XOFFSET = 2.54 * 5 / 2 + 6;
PS2_ANALOG_STICK_PIN_ZOFFSET = 5.5;

PS2_ANALOG_STICK_HOLE_OFFSET_X = 2.75;
PS2_ANALOG_STICK_HOLE_SPACING_X = 26.1;
PS2_ANALOG_STICK_HOLE_SPACING_Y = 19.8;
PS2_ANALOG_STICK_HOLE_DIAMETER = 3;

PS2_STICK_BASE_DIAMETER = 26.2;

module ps2_analog_stick() {
  overlap = 0.01;

  module pcb() {
    module hole() {
      tz(-overlap) cylinder(d=PS2_ANALOG_STICK_HOLE_DIAMETER, h=PS2_ANALOG_STICK_HEIGHT+overlap * 2);
    }

    color("#555") difference() {
      cube([PS2_ANALOG_STICK_LENGTH, PS2_ANALOG_STICK_WIDTH, PS2_ANALOG_STICK_HEIGHT]);
      txy(PS2_ANALOG_STICK_HOLE_OFFSET_X, (PS2_ANALOG_STICK_WIDTH - PS2_ANALOG_STICK_HOLE_SPACING_Y) / 2) hole();
      txy(PS2_ANALOG_STICK_HOLE_OFFSET_X, (PS2_ANALOG_STICK_WIDTH + PS2_ANALOG_STICK_HOLE_SPACING_Y) / 2) hole();
      txy(PS2_ANALOG_STICK_HOLE_OFFSET_X + PS2_ANALOG_STICK_HOLE_SPACING_X, (PS2_ANALOG_STICK_WIDTH - PS2_ANALOG_STICK_HOLE_SPACING_Y) / 2) hole();
      txy(PS2_ANALOG_STICK_HOLE_OFFSET_X + PS2_ANALOG_STICK_HOLE_SPACING_X, (PS2_ANALOG_STICK_WIDTH + PS2_ANALOG_STICK_HOLE_SPACING_Y) / 2) hole();
    }
  }

  // modded from nopscadlib to move the black mounts
  module ra_pin_header() { //! Draw pin header
    type = 2p54header;
    cols = 5;
    pitch =  hdr_pitch(type);
    base_colour = hdr_base_colour(type);
    h = pitch;
    ra_offset = 2.4;
    width = pitch;

    for(x = [0 : cols - 1]) {
      // Vertical part of the pin
      translate([pitch * (x - (cols - 1) / 2), 0, -2.53])
        pin(type, 7.2);

      w = hdr_pin_width(type);
      // Horizontal part of the pin
      rotate([-90, 0, 180])
        translate([pitch * (x - (cols - 1) / 2), - width / 2, hdr_pin_below(type)])
        pin(type, 7.6);
      // corner
      translate([pitch * (x - (cols - 1) / 2), - w / 2, width / 2 - w / 2])
        rotate([0, -90, 0])
        color(hdr_pin_colour(type))
        rotate_extrude(angle = 90, $fn = 32)
        translate([0, -w / 2])
        square(w);
    }
    // Insulator
    translate([0, 0, -2.54])
      color(base_colour)
      linear_extrude(h)
      for(x = [0 : cols - 1])
        translate([pitch * (x - (cols - 1) / 2), 0, pitch / 2])
          hull() {
            chamfer = pitch / 4;
            square([pitch + eps, pitch - chamfer], center = true);

            square([pitch - chamfer, pitch + eps], center = true);
          }
  }

  module metal_can_with_thumb_pad() {
    can_length = 16;
    can_width = 16;
    can_height = 12.2;

    module metal_can() {
      module base() {
        cube([can_length, can_width, can_height]);
      }

      module top_pin() {
        length = 7.4;
        width = 1.9;
        thickness = 1.1;
        txy(-thickness / 2, -width / 2) cube([thickness, width, length + overlap]);
      }

      module side_pot() {
        width = 9.5;
        thickness = 3;
        color("#444") ty(-width / 2) cube([thickness, width, can_height]);
      }

      module button() {
        width = 9.4;
        thickness = 4.7;
        height = 5.2;
        color("#444") tx(-width / 2) cube([width, thickness, height]);
      }

      base();
      translate([can_length / 2, can_width / 2, can_height - overlap]) top_pin();
      ty(can_length / 2) rz(180) side_pot();
      tx(can_width / 2) rz(-90) side_pot();
      txy(can_length / 2, can_width) button();
    }

    module thumb_pad() {
      base_height = 8;
      stick_height = 5.7;

      module mushroom(height, diameter) {
        union() {
          rotate_extrude()
            tx(diameter / 2 - height)
              arc(r=height, start_angle=0, end_angle=90);
          cylinder(d=(diameter - height * 2) + overlap, h=height);
        }
      }

      module stick() {
        cylinder(d=10.45, h=stick_height + overlap * 2);
      }

      module base() {
        offset = 1;

        difference() {
          mushroom(base_height, PS2_STICK_BASE_DIAMETER);
          tz(-overlap) mushroom(base_height - offset, PS2_STICK_BASE_DIAMETER - offset);
        }
      }

      module top() {
        mushroom(4.3, 19.8);
      }

      color("#333") union() {
        base();
        tz(base_height - overlap) stick();
        tz(base_height + stick_height) top();
      }
    }

    metal_can();
    translate([can_length / 2, can_width / 2, can_height - 2]) thumb_pad();
  }

  pcb();
  translate([8.5, 4.7, PS2_ANALOG_STICK_HEIGHT]) metal_can_with_thumb_pad();
  translate([
      PS2_ANALOG_STICK_LENGTH - 2.54 / 2 - 1.5,
      PS2_ANALOG_STICK_PIN_XOFFSET,
      2.54 + PS2_ANALOG_STICK_HEIGHT
  ]) rz(90) ra_pin_header();
}

//$fn = 36;
//ps2_analog_stick();
