MOTOR_LENGTH = 24.7;
MOTOR_DIAMETER = 20.4;
MOTOR_BUSHING_DIAMETER = 7;
GEAR_BOX_LENGTH = 17.1;
GEAR_BOX_DIAMETER = 20;
GEAR_BOX_SCREW_SPACING = 15;
GEAR_BOX_SCREW_HOLE_DIAMETER = 2.5;
MOTOR_AND_GEAR_BOX_LENGTH = MOTOR_LENGTH + GEAR_BOX_LENGTH;

// motor with 0,0 at base center.  Shaft and pins extend
// to negative values.
module motor_with_gearbox() {
  bushing_height = 3;
  overlap = 0.01;

  module motor() {
    slot_width = 15.4;

    module body() {
      module cutout() {
        translate([-MOTOR_DIAMETER / 2, -MOTOR_DIAMETER / 2, -overlap])
          cube([MOTOR_DIAMETER, MOTOR_DIAMETER, MOTOR_LENGTH + overlap * 2]);
      }

      module shaft_nub() {
        // VERIFY
        nub_length = 1.8;
        tz(-nub_length)
          cylinder(d=7, h=nub_length + overlap);
      }

      color("#aaa") union() {
        difference() {
          cylinder(d=MOTOR_DIAMETER, h=MOTOR_LENGTH);
          tx((MOTOR_DIAMETER + slot_width) / 2) cutout();
          tx(-(MOTOR_DIAMETER + slot_width) / 2) cutout();
        }
        shaft_nub();
      }
    }

    module contact() {
      width = 2.2;
      thickness = 0.6;
      length = 4;
      hole_size = 1.4;

      color("gold") ry(90) tz(-thickness / 2)
        difference() {
          union() {
            ty(- width / 2) cube([length - width / 2, width, thickness]);
            tx(length - width / 2) cylinder(d=width, h=thickness);
          }
          txz(length - width / 2, -overlap)
            cylinder(d=hole_size, h=thickness + overlap * 2);
        }
    }

    body();
    inset = MOTOR_DIAMETER / 2 - 2.5;
    txy(0.7, inset) contact();
    txy(-0.7, -inset) contact();
  }

  module gear_box() {
    module hole() {
      tz(3)
        cylinder(d=GEAR_BOX_SCREW_HOLE_DIAMETER, h = GEAR_BOX_LENGTH - 3 + overlap);
    }

    difference() {
      color("#ccc") cylinder(d=GEAR_BOX_DIAMETER, h=GEAR_BOX_LENGTH);
      ty(GEAR_BOX_SCREW_SPACING / 2) hole();
      ty(-GEAR_BOX_SCREW_SPACING / 2) hole();
    }
  }

  module bushing() {
    color("#db0") cylinder(d=MOTOR_BUSHING_DIAMETER, h=bushing_height);
  }

  module shaft() {
    shaft_diameter = 4;
    shaft_length = 7.9;
    color("#ddd") difference() {
      cylinder(d=shaft_diameter, h=shaft_length);
      translate([-shaft_diameter / 2, -shaft_diameter * 3 / 2 + 0.5, 1])
        cube([shaft_diameter, shaft_diameter, shaft_length]);
    }
  }

  motor();
  tz(MOTOR_LENGTH) gear_box();
  tz(MOTOR_LENGTH + GEAR_BOX_LENGTH) bushing();
  tz(MOTOR_LENGTH + GEAR_BOX_LENGTH + bushing_height) shaft();
}

