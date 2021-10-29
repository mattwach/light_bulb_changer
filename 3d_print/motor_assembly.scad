use <lib/mattwach/util.scad>
include <lib/mattwach/vitamins/bolts.scad>
include <pole_interface.scad>
include <motor_carriage.scad>
include <threaded_attachment.scad>

module motor_assembly() {
  connection_bolt_length = 20;
  module motor() {
    tz(MOTOR_LENGTH + GEAR_BOX_LENGTH + MOTOR_CARRIAGE_MOUNT_THICKNESS)
      rx(180) {
      motor_with_gearbox();
      tz(MOTOR_LENGTH + GEAR_BOX_LENGTH + MOTOR_CARRIAGE_MOUNT_THICKNESS) {
        ty(GEAR_BOX_SCREW_SPACING / 2) bolt_M2_5(10);
        ty(-GEAR_BOX_SCREW_SPACING / 2) bolt_M2_5(10);
      }
    }
  }

  module linkage_bolt() {
    translate(
        [-DISTANCE_FROM_AXIS_TO_HOLE,
        -connection_bolt_length / 2 + 1.5,
        CONNECTION_TAB_WIDTH / 2
    ]) rx(90) {
      bolt_M3(length=connection_bolt_length);
      tz(-(connection_bolt_length - 1)) nut_M3();
    }
  }

  module threaded_attachment_assembled() {
    tz(-THREADED_ATTACHMENT_LENGTH - FLANGE_HEIGHT - 2) {
      tz(THREADED_ATTACHMENT_LENGTH)
        flange_with_bolts(THREADED_ATTACHMENT_FLANGE_BOLT_LENGTH);
      threaded_attachment();  // Prefix a ! here to 3D print this part
    }
  }

  // Instructions: add a ! to print the part.  Example !motor_carriage()
  motor();
  color("red", 0.7) motor_carriage();  // Prefix a ! here to 3D print this part
  color("purple", 0.7) motor_carriage_cover();  // Prefix a ! here to 3D print this part
  color("green", 0.7) pole_interface();  // Prefix a ! here to 3D print this part
  linkage_bolt();
  threaded_attachment_assembled();
}

$fn = 36;
motor_assembly();
