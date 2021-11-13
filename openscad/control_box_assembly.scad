use <lib/mattwach/util.scad>
use <lib/mattwach/shapes.scad>
use <lib/mattwach/honeycomb.scad>
use <lib/mattwach/vitamins/bolts.scad>
include <lib/mattwach/vitamins/rc/ps2_analog_stick.scad>
include <lib/mattwach/vitamins/rc/female_servo_connector.scad>
include <lib/mattwach/vitamins/rc/xt30.scad>
include <motor_controller_pcb.scad>

module control_box_assembly() {
  ps2_analog_stick_y = -55;
  pin_spacing = 2.54;
  xoffset = 8.73;
  yoffset = 5.87;
  overlap = 0.01;
  control_box_left_border = 4;
  control_box_right_border = 4;
  control_box_back_border = 8;
  control_box_front_border = 8;
  control_box_width = MOTOR_CONTROLLER_PCB_WIDTH + control_box_left_border +
    control_box_right_border;
  control_box_length = -ps2_analog_stick_y + MOTOR_CONTROLLER_PCB_LENGTH +
    control_box_back_border + control_box_front_border;
  control_box_base_to_pcb = 5;
  control_box_bottom_pad = 1;
  control_box_height = control_box_base_to_pcb + MOTOR_CONTROLLER_PCB_HEIGHT;
  pole_interface_thickness = 2;
  assembly_bolt_hole_diameter = 3.25;

  xt30_xdepth = 10;
  xt30_ypad = 3;
  xt30_y = -15;
  xt30_z = 7;

  bolt_inset = 4;
  bolt_centers = [
    [-control_box_left_border + bolt_inset, ps2_analog_stick_y - control_box_back_border + bolt_inset],
    [-control_box_left_border + bolt_inset, MOTOR_CONTROLLER_PCB_LENGTH + control_box_front_border - bolt_inset],
    [-control_box_left_border + control_box_width - bolt_inset, ps2_analog_stick_y - control_box_back_border + bolt_inset],
    [-control_box_left_border + control_box_width - bolt_inset, MOTOR_CONTROLLER_PCB_LENGTH + control_box_front_border - bolt_inset]
  ];

  module assembly_bolts() {
    for (i = [0:3]) {
      translate([
          bolt_centers[i][0],
          bolt_centers[i][1],
          -control_box_height - pole_interface_thickness,
      ]) rx(180) bolt_M3(16); 
    }
  }

  module pole_interface() {
    module interface() {
      pole_meet_thickness = 10;
      pole_meet_width = control_box_width - (bolt_inset + 4) * 2;
      ziptie_overhang = 10;
      ziptie_width = 4;
      ziptie_inset = 3;

      module ziptie_cutout_pair() {
        module ziptie_cutout() {
          cube([
              ziptie_inset,
              ziptie_width,
              pole_meet_thickness + overlap * 2
          ]);
        }

        tx((control_box_width - pole_meet_width) / 2 - overlap) ziptie_cutout();
        tx((control_box_width + pole_meet_width) / 2 - ziptie_inset + overlap) ziptie_cutout();
      }

      tz(-pole_interface_thickness) difference() {
        union() {
          cube([control_box_width, control_box_length, pole_interface_thickness]);
          translate([
              bolt_inset + 4,
              -ziptie_overhang,
              -pole_meet_thickness + pole_interface_thickness - overlap
          ]) cube([
            pole_meet_width,
            control_box_length + ziptie_overhang * 2,
            pole_meet_thickness + overlap
          ]);
        }
        translate([
            control_box_left_border,
            -ps2_analog_stick_y + control_box_back_border,
            -overlap-pole_meet_thickness
        ]) cube([
            MOTOR_CONTROLLER_PCB_WIDTH,
            MOTOR_CONTROLLER_PCB_LENGTH,
            pole_interface_thickness + overlap * 2 + pole_meet_thickness]);
        tz(-pole_meet_thickness + pole_interface_thickness) {
          ty(-ziptie_width) ziptie_cutout_pair();
          ty(control_box_length) ziptie_cutout_pair();
        }
      }
    }

    color("#840", 0.7) difference() {
      translate([
          -control_box_left_border,
          ps2_analog_stick_y - control_box_back_border,
          -control_box_height
      ]) {
        interface();
      }
      for (i = [0:3]) {
        translate([
          bolt_centers[i][0],
          bolt_centers[i][1],
          -control_box_height - pole_interface_thickness - overlap,
        ]) cylinder(d=assembly_bolt_hole_diameter, h=pole_interface_thickness + overlap * 2);
      }
      pole();
    }
  }

  module control_box_bottom() {
    board_spacing = 0.2;

    module main_body() {
      module xt30_bottom_support() {
        translate([
            control_box_width - control_box_left_border - xt30_xdepth,
            xt30_y,
            -overlap
        ]) difference() {
          ty(-xt30_ypad) cube([
              xt30_xdepth,
              XT30_WIDTH + xt30_ypad * 2,
              xt30_z + overlap + XT30_HEIGHT / 2
          ]);
          translate([-overlap, 0, xt30_z]) rotate([90, 0, 90]) xt30_hull();
        }
      }

      union() {
        translate([
            -control_box_left_border,
            ps2_analog_stick_y - control_box_back_border,
            - MOTOR_CONTROLLER_PCB_HEIGHT - control_box_base_to_pcb
        ]) cube([
          control_box_width,
          control_box_length,
          control_box_base_to_pcb + MOTOR_CONTROLLER_PCB_HEIGHT
        ]);
        xt30_bottom_support();
      }
    }

    module ps2_cutout() {
      hole_diameter=2.85;
      module post() {
        pad = 2.8;
        translate([0, 0, -overlap]) rounded_cylinder(
            d=hole_diameter + pad * 2,
            h=control_box_base_to_pcb + overlap - control_box_bottom_pad,
            fillet=-3);
      }

      module hole() {
        translate([0, 0, - control_box_bottom_pad - overlap * 2]) cylinder(
            d=hole_diameter, h=control_box_base_to_pcb + overlap * 4);
      }

      translate([
          (MOTOR_CONTROLLER_PCB_WIDTH - PS2_ANALOG_STICK_WIDTH) / 2,
          ps2_analog_stick_y,
          -MOTOR_CONTROLLER_PCB_HEIGHT - control_box_base_to_pcb +
              control_box_bottom_pad
      ]) union() {
        difference() {
          txy(-board_spacing, -board_spacing) cube([
              PS2_ANALOG_STICK_WIDTH + board_spacing * 2,
              PS2_ANALOG_STICK_LENGTH + board_spacing * 2,
              control_box_base_to_pcb + MOTOR_CONTROLLER_PCB_HEIGHT]);
          txy(
              (PS2_ANALOG_STICK_WIDTH - PS2_ANALOG_STICK_HOLE_SPACING_Y) / 2,
              PS2_ANALOG_STICK_HOLE_OFFSET_X) post();
          txy(
              (PS2_ANALOG_STICK_WIDTH + PS2_ANALOG_STICK_HOLE_SPACING_Y) / 2,
              PS2_ANALOG_STICK_HOLE_OFFSET_X) post();
          txy(
              (PS2_ANALOG_STICK_WIDTH - PS2_ANALOG_STICK_HOLE_SPACING_Y) / 2,
              PS2_ANALOG_STICK_HOLE_OFFSET_X + PS2_ANALOG_STICK_HOLE_SPACING_X
          ) post();
          txy(
              (PS2_ANALOG_STICK_WIDTH + PS2_ANALOG_STICK_HOLE_SPACING_Y) / 2,
              PS2_ANALOG_STICK_HOLE_OFFSET_X + PS2_ANALOG_STICK_HOLE_SPACING_X
          ) post();
        }
        txy(
            (PS2_ANALOG_STICK_WIDTH - PS2_ANALOG_STICK_HOLE_SPACING_Y) / 2,
            PS2_ANALOG_STICK_HOLE_OFFSET_X) hole();
        txy(
            (PS2_ANALOG_STICK_WIDTH + PS2_ANALOG_STICK_HOLE_SPACING_Y) / 2,
            PS2_ANALOG_STICK_HOLE_OFFSET_X) hole();
        txy(
            (PS2_ANALOG_STICK_WIDTH - PS2_ANALOG_STICK_HOLE_SPACING_Y) / 2,
            PS2_ANALOG_STICK_HOLE_OFFSET_X + PS2_ANALOG_STICK_HOLE_SPACING_X
        ) hole();
        txy(
            (PS2_ANALOG_STICK_WIDTH + PS2_ANALOG_STICK_HOLE_SPACING_Y) / 2,
            PS2_ANALOG_STICK_HOLE_OFFSET_X + PS2_ANALOG_STICK_HOLE_SPACING_X
        ) hole();
      }

    }

    module motor_controller_cutout() {
      module corner() {
        corner_radius = 4;
        tz(-overlap) cylinder(
            r=corner_radius, control_box_base_to_pcb + overlap * 2);
      }
      tz(-MOTOR_CONTROLLER_PCB_HEIGHT - control_box_base_to_pcb - overlap)
        difference() {
          txy(-board_spacing, -board_spacing) cube([
              MOTOR_CONTROLLER_PCB_WIDTH + board_spacing * 2,
              MOTOR_CONTROLLER_PCB_LENGTH + board_spacing * 2,
              control_box_base_to_pcb + MOTOR_CONTROLLER_PCB_HEIGHT +
                  overlap * 2]);
          txy(-board_spacing, -board_spacing) difference() {
            cube([
                MOTOR_CONTROLLER_PCB_WIDTH + board_spacing * 2,
                MOTOR_CONTROLLER_PCB_LENGTH + board_spacing * 2,
                control_box_bottom_pad
            ]);
            translate([
                MOTOR_CONTROLLER_PCB_WIDTH / 2,
                MOTOR_CONTROLLER_PCB_LENGTH / 2,
                -overlap]) honeycomb([
                  MOTOR_CONTROLLER_PCB_WIDTH,
                  MOTOR_CONTROLLER_PCB_LENGTH * 1.5,
                  control_box_base_to_pcb], 5,
                  1);
          }
          corner();
          tx(MOTOR_CONTROLLER_PCB_WIDTH) corner();
          ty(MOTOR_CONTROLLER_PCB_LENGTH) corner();
          txy(MOTOR_CONTROLLER_PCB_WIDTH, MOTOR_CONTROLLER_PCB_LENGTH)
            corner();
        }
    }

    color("#77f", 0.7)
      difference() {
        main_body();
        ps2_cutout();
        motor_controller_cutout();
        for (i = [0:3]) {
          translate([
            bolt_centers[i][0],
            bolt_centers[i][1],
            -control_box_height - overlap,
          ]) cylinder(d=assembly_bolt_hole_diameter, h=control_box_height + overlap * 2);
        }
      }
  }

  module control_box_top() {
    height = 20;
    thickness = 2;
    top_fillet = 7;
    ps2_stick_y_offset = 16.5;
    ps2_hole_inset = 1;

    module body(offset=0) {
      module top_tube(r,h) {
        translate([
            top_fillet,
            0,
            height - top_fillet
        ]) rx(-90) cylinder(r=r, h=h);
      }

      hull() {
        ty(offset)
          top_tube(
              top_fillet - offset,
              control_box_length - offset * 2);
        txy(control_box_width - top_fillet * 2, offset)
          top_tube(
              top_fillet - offset,
              control_box_length - offset * 2);
        translate([
            offset,
            offset,
            -overlap
        ]) cube([
            control_box_width - offset * 2,
            control_box_length - offset * 2,
            1,
        ]);
      }
    }

    module xt30_top_support() {
      translate([
        control_box_width - xt30_xdepth,
        xt30_y - ps2_analog_stick_y + control_box_back_border - xt30_ypad,
        xt30_z + XT30_HEIGHT / 2
      ]) difference() {
        cube([xt30_xdepth, XT30_WIDTH + xt30_ypad * 2, height]);
        translate([-overlap, xt30_ypad, -XT30_HEIGHT / 2]) rotate([90, 0, 90])
          xt30_hull();
      }
    }

    module xt30_cutout() {
      translate([
          control_box_width - thickness - overlap,
          xt30_y - ps2_analog_stick_y + control_box_back_border - xt30_ypad,
          -overlap * 2
      ]) union() {
        cube([
            thickness + overlap * 2,
            XT30_WIDTH + xt30_ypad * 2,
            xt30_z + XT30_HEIGHT / 2
        ]);
        translate([-overlap, xt30_ypad, xt30_z]) rotate([90, 0, 90])
          xt30_hull();
      }
    }

    module ps2_stick_cutout() {
      translate([
          control_box_width / 2,
          control_box_back_border + ps2_stick_y_offset,
          height - thickness - overlap * 2])
        cylinder(
            d=PS2_STICK_BASE_DIAMETER - ps2_hole_inset * 2,
            h=thickness + overlap * 4);
    }

    module ps2_stick_shroud() {
      shroud_thickness = 1.5;
      shroud_height = 3;
        translate([
          control_box_width / 2,
          control_box_back_border + ps2_stick_y_offset,
          height - thickness - shroud_height]) difference() {
          cylinder(
              d=PS2_STICK_BASE_DIAMETER - ps2_hole_inset * 2 +
                  shroud_thickness * 2,
              h=shroud_height + thickness / 2);
          tz(-overlap) cylinder(
              d=PS2_STICK_BASE_DIAMETER - ps2_hole_inset * 2,
              h=shroud_height + thickness / 2 + overlap * 2);
        }
    }

    module motor_controller_cutout() {
      pad = 2;
      width = MOTOR_CONTROLLER_PCB_WIDTH - pad * 2;
      length = MOTOR_CONTROLLER_PCB_LENGTH - pad * 2;
      translate([
          control_box_left_border + pad,
          -ps2_analog_stick_y + control_box_back_border + pad,
          height / 2
      ]) intersection() {
        rounded_cube_xy([width, length, height], r=10);
        txy(width / 2, length / 2)
          honeycomb([width, length * 1.2, height], 5, 1);
      }
    }

    module motor_controller_holddown() {
      diameter = 3.5;
      module pole_pair() {
        module pole() {
          txy(-diameter, -diameter/2) cube([diameter, diameter, height]);
          cylinder(d=diameter, h=height);
        }
        pole();
        tx(MOTOR_CONTROLLER_PCB_WIDTH) rz(180) pole();
      }
      translate([
          control_box_left_border,
          -ps2_analog_stick_y + control_box_back_border,
          0,
      ]) {
        pole_pair();
        ty(MOTOR_CONTROLLER_PCB_LENGTH) pole_pair();
      }
    }

    module motor_power_cutout() {
      width = 10;
      height = 4;
      offset = 17.5;
      translate(
          [control_box_width - offset,
          control_box_length - thickness - overlap,
          -overlap * 2
       ]) cube([width, thickness + overlap * 2, height]);
    }

    module motor_holder() {
      diameter = 15.1;
      length = 15;
      center_slot = 6.5;

      module cutout_tab() {
          tz(length / 2 - overlap)
            cube([
                center_slot,
                diameter + overlap * 2,
                length + overlap * 4],
                center=true);
      }

      difference() {
        translate([
            diameter / 2 + 5,
            control_box_length - overlap,
            height - diameter / 2 + 2
        ]) rx(-90) {
          difference() {
            rounded_cylinder(d=diameter, h=length, fillet2=3);
            cutout_tab();
          }
        }
        tz(height) cube([control_box_width, control_box_length + length, 5]);
      }
    }

    module bolt_holder() {
      difference() {
        tz(height/2) cube([7, 7, height], center=true);
        tz(-overlap) cylinder(d=2.85, h=16);
      }
    }

    color("#5aa", 0.5) union() {
      translate([
          -control_box_left_border,
          ps2_analog_stick_y - control_box_back_border,
          0
      ]) union() {
        difference() {
          body();
          tz(-overlap) body(thickness);
          xt30_cutout();
          ps2_stick_cutout();
          motor_controller_cutout();
          motor_power_cutout();
        }
        intersection() {
          body(thickness - overlap);
          xt30_top_support();
        }
        ps2_stick_shroud();
        motor_holder();
        intersection() {
          body(thickness - overlap);
          motor_controller_holddown();
        }
      }
      intersection() {
        translate([
          -control_box_left_border,
          ps2_analog_stick_y - control_box_back_border,
          0
        ]) body(thickness - overlap);
        for (i = [0:3]) {
          translate([
            bolt_centers[i][0],
            bolt_centers[i][1],
            0,
          ]) bolt_holder();
        }
      }
    }
  }

  module pole() {
    translate([MOTOR_CONTROLLER_PCB_WIDTH / 2, -75, -25]) rx(-90) cylinder(d=32, h=150);
  }

  module battery() {
    length = 54;
    width = 29;
    height = 12.8;
    radius = 2;

    module plane() {
      translate([radius, radius, 0]) sphere(r=radius);
      translate([length - radius, radius, 0]) sphere(r=radius);
      translate([length - radius, width - radius, 0]) sphere(r=radius);
      translate([radius, width - radius, 0]) sphere(r=radius);
    }

    color("#808", 0.4) hull() {
      tz(radius) plane();
      tz(height - radius) plane();
    }
  }

  // START OF ASSEMBLY

  tz(overlap) motor_controller_pcb();

  translate([
      xoffset,
      yoffset + pin_spacing * 3,
      FEMALE_SERVO_CONNECTOR_LENGTH + pin_spacing - 3
  ]) rotate([0, 180 - 45, 90]) female_servo_connector();

  translate([
      xoffset - pin_spacing * 2,
      yoffset - pin_spacing * 7.5,
      pin_spacing / 2])
    rotate([0, -90, -90])
    female_servo_connector(show_white_wire=false);

  translate([
      xoffset + pin_spacing * 6,
      yoffset + pin_spacing * 23.5,
      pin_spacing / 2])
    rotate([0, -90, 90])
    female_servo_connector(
        show_white_wire=false,
        black_wire_color="red",
        red_wire_color="#333");

  translate([
      PS2_ANALOG_STICK_WIDTH +
          (MOTOR_CONTROLLER_PCB_WIDTH - PS2_ANALOG_STICK_WIDTH) / 2,
      ps2_analog_stick_y,
      -MOTOR_CONTROLLER_PCB_HEIGHT + overlap
  ]) rz(90) ps2_analog_stick();

  translate([
      PS2_ANALOG_STICK_WIDTH +
          (MOTOR_CONTROLLER_PCB_WIDTH - PS2_ANALOG_STICK_WIDTH) / 2 -
          PS2_ANALOG_STICK_PIN_XOFFSET + pin_spacing * 2,
      ps2_analog_stick_y + PS2_ANALOG_STICK_LENGTH -
          PS2_ANALOG_STICK_PIN_INSET + FEMALE_SERVO_CONNECTOR_LENGTH,
      -MOTOR_CONTROLLER_PCB_HEIGHT + PS2_ANALOG_STICK_PIN_ZOFFSET
  ]) rotate([0, -90, 90]) female_servo_connector();

  translate([
      control_box_width - control_box_left_border - XT30_LENGTH,
      xt30_y,
      xt30_z,
  ]) rotate([90, 0, 90]) xt30();

  translate([
      control_box_width - control_box_left_border,
      0,
      -8]) rotate([90, 0, 90]) battery();

  // Instructions: add a ! to print the part.  Example !control_box_bottom()
  control_box_bottom();  // Prefix a ! here to 3D print this part
  control_box_top();  // Prefix a ! here to 3D print this part
  pole_interface();  // Prefix a ! here to 3D print this part
  assembly_bolts();
  pole();

}

$fa = 2.0;
$fs = 0.5;
control_box_assembly();
