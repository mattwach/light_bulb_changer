use <lib/mattwach/util.scad>
include <lib/pole_threads.scad>
include <vitamins/motor_with_gearbox.scad>

CONNECTION_TAB_WIDTH = 18;
MOTOR_CARRIAGE_MOUNT_THICKNESS = 2;
MOTOR_CARRIAGE_HEIGHT = MOTOR_CARRIAGE_MOUNT_THICKNESS + MOTOR_AND_GEAR_BOX_LENGTH + 12;
MOTOR_CARRIAGE_HOLDER_PAD = 3;
MOTOR_CARRIAGE_DIAMETER = MOTOR_DIAMETER + MOTOR_CARRIAGE_HOLDER_PAD * 2;
MOTOR_SPACING = 0.2;
LINKAGE_TAB_EXTENSION = 10;
LINKAGE_TAB_WIDTH = 7;
SCREW_HOLE_PAD = 0.25;
DISTANCE_FROM_AXIS_TO_HOLE = GEAR_BOX_DIAMETER / 2 - MOTOR_CARRIAGE_MOUNT_THICKNESS / 2 + MOTOR_CARRIAGE_HOLDER_PAD + LINKAGE_TAB_EXTENSION;

module motor_carriage() {
  overlap = 0.01;
  module linkage_tabs() {
    module linkage_tab() {
      fillet = CONNECTION_TAB_WIDTH;
      tab_size = 6;

      module hole() {
        tz(-overlap) cylinder(d=3.25, h=LINKAGE_TAB_WIDTH + overlap * 2);
      }

      rx(90)
        difference() {
          tz(-LINKAGE_TAB_WIDTH / 2)
            hull() {
              tx(-tab_size) cube([tab_size, CONNECTION_TAB_WIDTH, LINKAGE_TAB_WIDTH]);
              txy(LINKAGE_TAB_EXTENSION, CONNECTION_TAB_WIDTH / 2) cylinder(d=fillet, h=LINKAGE_TAB_WIDTH);
            }
          translate([
              LINKAGE_TAB_EXTENSION,
              CONNECTION_TAB_WIDTH / 2,
              -LINKAGE_TAB_WIDTH / 2
          ]) hole();
        }
    }

    rz(180) difference() {
      tx(GEAR_BOX_DIAMETER / 2 + MOTOR_CARRIAGE_HOLDER_PAD - MOTOR_CARRIAGE_MOUNT_THICKNESS / 2)
        linkage_tab();
      tz(-overlap)
        cylinder(
            d=(MOTOR_CARRIAGE_DIAMETER + MOTOR_DIAMETER) / 2,
            h=CONNECTION_TAB_WIDTH + overlap * 2);
    }
  }

  module gear_box_carriage() {
    bushing_pad = 1;
    module gear_box_screw_hole() {
      tz(-overlap)
        cylinder(
            d=GEAR_BOX_SCREW_HOLE_DIAMETER + SCREW_HOLE_PAD * 2,
            h = MOTOR_CARRIAGE_MOUNT_THICKNESS + overlap * 2); 
    }

    module wire_slot() {
      wire_diameter = 5;
      rz(30)
        tyz(MOTOR_DIAMETER / 2, MOTOR_CARRIAGE_HEIGHT - wire_diameter + overlap)
        rx(-90) union() {
          cylinder(d=wire_diameter, h = MOTOR_CARRIAGE_HOLDER_PAD);
          txy(-wire_diameter / 2, -wire_diameter)
            cube([wire_diameter, wire_diameter, MOTOR_CARRIAGE_HOLDER_PAD]);
      }
    }

    module ziptie_ring() {
      ziptie_width = 2.5;
      indent = 1;
      offset = 15;

      outer_diameter = MOTOR_CARRIAGE_DIAMETER + overlap;
      inner_diameter = outer_diameter - indent * 2;

      tz(MOTOR_CARRIAGE_HEIGHT - ziptie_width - offset)
        difference() {
          cylinder(d=outer_diameter, h=ziptie_width);
          tz(-overlap) cylinder(d=inner_diameter, h=ziptie_width + overlap * 2);
        }
    }

    module cooling_slots() {
      slot_count = 8;
      module cooling_slot() {
        slot_width = 3;
        top_border = 22;
        bottom_border = 12;
        tyz(MOTOR_CARRIAGE_DIAMETER / 2, bottom_border)
        rx(90)
          hull() {
            cylinder(d=slot_width, h=MOTOR_CARRIAGE_DIAMETER / 2);
            ty(MOTOR_CARRIAGE_HEIGHT - top_border - bottom_border) cylinder(d=slot_width, h=MOTOR_CARRIAGE_DIAMETER / 2);
          }
      }

      for (i = [3:slot_count + 1]) {
        rz(i * 360 / slot_count) cooling_slot();
      }
    }

    difference() {
      cylinder(d = GEAR_BOX_DIAMETER + MOTOR_CARRIAGE_HOLDER_PAD * 2, h=MOTOR_CARRIAGE_HEIGHT);
      tz(MOTOR_CARRIAGE_MOUNT_THICKNESS)
        cylinder(d = MOTOR_DIAMETER + MOTOR_SPACING * 2, h=MOTOR_CARRIAGE_HEIGHT); 
      tz(-overlap)
        cylinder(d=MOTOR_BUSHING_DIAMETER + bushing_pad * 2, h=MOTOR_CARRIAGE_MOUNT_THICKNESS + overlap * 2);
      ty(GEAR_BOX_SCREW_SPACING / 2) gear_box_screw_hole();
      ty(-GEAR_BOX_SCREW_SPACING / 2) gear_box_screw_hole();
      wire_slot();
      ziptie_ring();
      cooling_slots();
    }
  }

  union() {
    gear_box_carriage();
    linkage_tabs();
  }
}

module motor_carriage_cover() {
  cover_thickness = 3;
  seal_overlap = 3;
  seal_thickness = 2.5;
  overlap = 0.01;
  seal_diameter = MOTOR_DIAMETER + MOTOR_SPACING * 2;
  tz(MOTOR_CARRIAGE_HEIGHT) {
    union() {
      cylinder(d=MOTOR_CARRIAGE_DIAMETER, h=cover_thickness);
      difference() {
        tz(-seal_overlap)
          cylinder(d=seal_diameter, h=seal_overlap + overlap);
        tz(-seal_overlap-overlap)
          cylinder(d=seal_diameter - seal_thickness * 2, h=seal_overlap + overlap);
      }
    }
  }
}
