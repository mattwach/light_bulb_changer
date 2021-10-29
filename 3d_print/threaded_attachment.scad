$fn = 36;

include <vitamins/flange.scad>
include <lib/pole_threads.scad>

THREADED_ATTACHMENT_FLANGE_BOLT_LENGTH = 12;
THREADED_ATTACHMENT_BASE_HEIGHT = THREADED_ATTACHMENT_FLANGE_BOLT_LENGTH - FLANGE_BASE_HEIGHT + 2;
THREADED_ATTACHMENT_LENGTH = THREADED_ATTACHMENT_BASE_HEIGHT + POLE_THREADS_LENGTH;

module threaded_attachment() {
  overlap = 0.01;
  base_diameter = 24;
  hole_diameter = 2.85;
  hole_depth = THREADED_ATTACHMENT_FLANGE_BOLT_LENGTH - FLANGE_BASE_HEIGHT + 1;

  module hole() {
    tz(THREADED_ATTACHMENT_LENGTH - hole_depth)
      cylinder(d=hole_diameter, h=hole_depth + overlap);
  }

  color("blue", 0.7) difference() {
    union() {
      pole_threads(true, false);
      tz(POLE_THREADS_LENGTH - overlap)
        cylinder(d=base_diameter, h=THREADED_ATTACHMENT_BASE_HEIGHT + overlap);
    }
    tx(FLANGE_HOLE_SPACING / 2) hole();
    tx(-FLANGE_HOLE_SPACING / 2) hole();
    ty(FLANGE_HOLE_SPACING / 2) hole();
    ty(-FLANGE_HOLE_SPACING / 2) hole();
  }
}
