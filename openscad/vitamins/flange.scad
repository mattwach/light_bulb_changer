use <../lib/mattwach/util.scad>
use <../lib/mattwach/vitamins/bolts.scad>

FLANGE_BASE_HEIGHT = 2;
FLANGE_HOLE_SPACING = 16;
FLANGE_UPPER_HEIGHT = 10;
FLANGE_HEIGHT = FLANGE_BASE_HEIGHT + FLANGE_UPPER_HEIGHT;

module flange() {
  overlap = 0.01;

  module base() {
    diameter = 22;
    module body() {
      cylinder(d=diameter, h=FLANGE_BASE_HEIGHT);
    }

    module hole() {
      tz(-overlap)
        cylinder(d=2.85, h=FLANGE_BASE_HEIGHT + overlap * 2);
    }

    difference() {
      body();
      tx(FLANGE_HOLE_SPACING / 2) hole();
      tx(-FLANGE_HOLE_SPACING / 2) hole();
      ty(FLANGE_HOLE_SPACING / 2) hole();
      ty(-FLANGE_HOLE_SPACING / 2) hole();
    }
  }

  module upper() {
    diameter = 10;
    chamfer = 0.75;
    
    module key_hole() {
      key_hole_offset = 5.5; // UNKNOWN
      key_hole_diameter = 3;
      tz(key_hole_offset)
      rotate([-90, 0, -45])
        cylinder(d=key_hole_diameter, h=diameter/2);
    }

    tz(FLANGE_BASE_HEIGHT - overlap) {
      difference() {
        union() {
          cylinder(d=diameter, h=FLANGE_UPPER_HEIGHT + overlap - chamfer);
          tz(FLANGE_UPPER_HEIGHT - chamfer - overlap)
            cylinder(d1=diameter, d2=diameter-chamfer * 2, h = chamfer + overlap);
        }
        key_hole();
      }
    }
  }

  module center_hole() {
    tz(-overlap)
      cylinder(d=4, h=FLANGE_UPPER_HEIGHT + FLANGE_BASE_HEIGHT + overlap * 2);
  }

  difference() {
    union() {
      base();
      upper();
    }
    center_hole();
  }
}

module flange_with_bolts(bolt_length) {
  flange();
  txz(-FLANGE_HOLE_SPACING / 2, FLANGE_BASE_HEIGHT)
    bolt_M3(bolt_length);
  txz(FLANGE_HOLE_SPACING / 2, FLANGE_BASE_HEIGHT)
    bolt_M3(bolt_length);
  tyz(-FLANGE_HOLE_SPACING / 2, FLANGE_BASE_HEIGHT)
    bolt_M3(bolt_length);
  tyz(FLANGE_HOLE_SPACING / 2, FLANGE_BASE_HEIGHT)
    bolt_M3(bolt_length);
}
