include <lib/mattwach/vitamins/bolts.scad>
include <motor_carriage.scad>
use <lib/pole_threads.scad>

module pole_interface() {
  interface_diameter = 24;
  interface_gap = 0.5;
  interface_offset = DISTANCE_FROM_AXIS_TO_HOLE + CONNECTION_TAB_WIDTH / 2 + interface_gap;
  interface_base_thickness = 3;
  interface_tube_length = POLE_THREADS_LENGTH + interface_base_thickness;
  slot_thickness = 4.75;
  nut_depth = 2.3;
  slot_pad = 0.25;
  slot_to_slot_thickness = slot_thickness * 2 + slot_pad * 2 + LINKAGE_TAB_WIDTH;
  overlap = 0.01;

  module interface_tube() {
    difference() {
      cylinder(d=interface_diameter, h=interface_tube_length);
      tz(interface_base_thickness - overlap + POLE_THREADS_LENGTH) rx(180) pole_threads(false, true);
      tz(POLE_THREADS_LENGTH + interface_base_thickness + overlap - 6)
        cylinder(d1=POLE_THREADS_INNER_DIAMETER - 5, d2=POLE_THREADS_INNER_DIAMETER, 6);
    }
//    #cylinder(d=19.2, h=20);
  }

//  !interface_tube();

  module slot() {
    txz(-DISTANCE_FROM_AXIS_TO_HOLE, CONNECTION_TAB_WIDTH / 2)
      rotate([90, 180, 0])
      tz(-slot_thickness / 2)
      difference() {
        union() {
          cylinder(d=CONNECTION_TAB_WIDTH, h=slot_thickness);  
          ty(-CONNECTION_TAB_WIDTH / 2)
            cube([
                CONNECTION_TAB_WIDTH / 2 + interface_tube_length + interface_gap,
                CONNECTION_TAB_WIDTH,
                slot_thickness]);
        }
        tz(-overlap) cylinder(
          d=3.25,
          h=slot_thickness + overlap * 2
        );
      }
  }

  module ziptie_slot() {
    ziptie_width = 2.5;
    tz((interface_tube_length - ziptie_width) / 2) difference() {
      cylinder(d=interface_diameter * 1.5, h=ziptie_width);
      tz(-overlap) cylinder(d=interface_diameter, h=ziptie_width + overlap * 2);
    }
  }

  union() {
    txz(
        -interface_offset,
        CONNECTION_TAB_WIDTH / 2 - (interface_diameter - CONNECTION_TAB_WIDTH) / 2
    ) ry(-90) interface_tube();

    difference() {
      union() {
        ty((LINKAGE_TAB_WIDTH + slot_thickness + slot_pad) / 2)
          difference() {
            slot();
            translate([
                -DISTANCE_FROM_AXIS_TO_HOLE,
                slot_thickness / 2 + overlap,
                CONNECTION_TAB_WIDTH / 2
            ]) rx(90) solid_nut(5.9, nut_depth);
          }
        ty(-(LINKAGE_TAB_WIDTH + slot_thickness + slot_pad) / 2)
          slot();
        translate([
            -(DISTANCE_FROM_AXIS_TO_HOLE + CONNECTION_TAB_WIDTH / 2 + interface_gap + interface_tube_length),
            -slot_to_slot_thickness / 2,
            CONNECTION_TAB_WIDTH - (interface_diameter - POLE_THREADS_INNER_DIAMETER)
        ]) cube([
          interface_tube_length,
          slot_to_slot_thickness,
          interface_diameter - POLE_THREADS_INNER_DIAMETER
        ]);
      }
      txz(
          -(DISTANCE_FROM_AXIS_TO_HOLE + CONNECTION_TAB_WIDTH / 2 + interface_gap + overlap),
          CONNECTION_TAB_WIDTH / 2 - (interface_diameter - CONNECTION_TAB_WIDTH) / 2
      ) ry(-90) cylinder(d=POLE_THREADS_INNER_DIAMETER, h=interface_tube_length);
      txz(
          -interface_offset,
          CONNECTION_TAB_WIDTH / 2 - (interface_diameter - CONNECTION_TAB_WIDTH) / 2
      ) ry(-90) ziptie_slot();
    }
  }
}
