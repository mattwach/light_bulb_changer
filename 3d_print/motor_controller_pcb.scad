use <lib/mattwach/util.scad>
include <lib/mattwach/vitamins/electronics/capacitor.scad>
include <lib/mattwach/vitamins/electronics/led.scad>
include <lib/mattwach/vitamins/electronics/voltage_regulators.scad>
include <lib/NopSCADlib/core.scad>
include <lib/NopSCADlib/vitamins/dip.scad>
include <lib/NopSCADlib/vitamins/pcbs.scad>
include <lib/NopSCADlib/vitamins/axials.scad>
include <lib/NopSCADlib/vitamins/pin_headers.scad>

MOTOR_CONTROLLER_PCB_LENGTH = 51.5;
MOTOR_CONTROLLER_PCB_WIDTH = 30;
MOTOR_CONTROLLER_PCB_HEIGHT = 1.6;

module motor_controller_pcb() {
  pspace = 2.54;
  pcb_orig_length = 70;

  module resistor_1k() {
    tx(pspace * 3 / 2) ax_res(res1_4, 1000);
  }

  module battery_connector() {
    tx(pspace) pin_header(2p54header, 3, 1, right_angle=true);
  }

  module motor_connector() {
    tx(pspace) rz(180) pin_header(2p54header, 3, 1, right_angle=true);
  }

  module pin_header_3_1() {
    tx(pspace) pin_header(2p54header, 3, 1);
  }

  module led() {
    tx(pspace * 2) rz(90) red_green_3mm_led();
  }

  module tiny85_socket() {
    txy(pspace * 3 / 2, pspace * 3 / 2) rz(90) dil_socket(4, 7.62);
  }

  module tiny85() {
    translate([pspace * 3 / 2, pspace * 3 / 2, 4.0]) rz(90) pdip(8, "ATTiny85", false);
  }

  module motor_driver() {
    txy(pspace * 3 / 2, pspace * 7 / 2) pdip(16, "L293D", false);
  }

  difference() {
    translate([MOTOR_CONTROLLER_PCB_WIDTH / 2, pcb_orig_length / 2, -MOTOR_CONTROLLER_PCB_HEIGHT]) rz(90)
      pcb(PERF70x30);
    translate([-1, MOTOR_CONTROLLER_PCB_LENGTH, -MOTOR_CONTROLLER_PCB_HEIGHT - 0.2]) cube([MOTOR_CONTROLLER_PCB_WIDTH + 2, 70, 2]);
  }
  
  txy(3.65, 5.87) {
    boardxy(1, 2.5) small_vreg();
    boardxy(3, 0) ceramic_capacitor("104");
    boardxy(3, 4) ceramic_capacitor("104");
    boardxy(5, 2) rz(180) electrolytic_capacitor_220f_16v();
    boardxy(8, 2) rz(180)electrolytic_capacitor_470f_16v();
    boardxy(5, 4.5) electrolytic_capacitor_100f_16v();
    boardxy(0, 0) battery_connector();
    boardxy(0, 7) pin_header_3_1();
    boardxy(0, 10) ceramic_capacitor("104");
    boardxy(1, 9) { tiny85_socket(); tiny85(); }
    boardxy(6, 6) motor_driver();
    boardxy(1, 15) led();
    boardxy(1, 13) resistor_1k();
    boardxy(3, 14) resistor_1k();
    boardxy(6, 16) motor_connector();
  }
}

