
FEMALE_SERVO_CONNECTOR_LENGTH = 14.3;

module female_servo_connector(
    wire_length=5,
    wire_thickness=1,
    show_black_wire=true,
    black_wire_color="#333",
    show_red_wire=true,
    red_wire_color="red",
    show_white_wire=true,
    white_wire_color="#ddd") {
  base_height = 5;
  overlap = 0.01;
  pin_spacing = 2.54;
  inlet_height = 2.1;
  inlet_zoffset = 8.5;

  module base() {
    width = 8.2;
    thickness = 2.8;
    translate([0, 0, base_height / 2])
      cube([thickness, width, base_height + overlap], center=true);
  }

  module upper() {
    width = 7.8;
    thickness = 2.6;
    height = FEMALE_SERVO_CONNECTOR_LENGTH - base_height;
    translate([-0.1, 0, base_height + height / 2])
      cube([thickness, width, height + overlap], center=true);
  }

  module hole_and_inlet() {
    module hole() {
      width = 1.5;
      thickness = 1.4;
      height = 14.3 + overlap * 2;
      translate([0, 0, height / 2 - overlap])
        cube([thickness, width, height], center=true);
    }

    module inlet() {
      width = 1.5;
      depth = 1;
      xoffset = -1;

      translate([xoffset, 0, inlet_zoffset + inlet_height / 2])
        cube([depth, width, inlet_height], center=true);
    }

    hole();
    inlet();
  }

  module wire_and_pin(wire_color) {
    module wire() {
      color(wire_color)
        translate([0, 0, -wire_length])
        cylinder(d=wire_thickness, h=wire_length + base_height);
    }

    module pin() {
      width = 1;
      thickness = 1;
      xoffset = -0.6;
      gap = 0.1;
      color("gold") translate([xoffset, 0, inlet_zoffset + gap + (inlet_height - gap) / 2])
        cube([thickness, width, inlet_height - gap], center=true); 
    }

    wire();
    pin();
  }

  translate([0, pin_spacing, 0]) {
    color("#444") difference() {
      union() {
        base();
        upper();
      }
      translate([0, -pin_spacing, 0]) hole_and_inlet();
      hole_and_inlet();
      translate([0, pin_spacing, 0]) hole_and_inlet();
    }
    if (show_black_wire) {
      translate([0, -pin_spacing, 0]) wire_and_pin(black_wire_color);
    }
    if (show_red_wire) {
      wire_and_pin(red_wire_color);
    }
    if (show_white_wire) {
      translate([0, pin_spacing, 0]) wire_and_pin(white_wire_color);
    }
  }
}

//$fn=36;
//female_servo_connector();
