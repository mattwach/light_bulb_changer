use <mattwach/util.scad>
use <threads.scad>

POLE_THREADS_LENGTH = 22;
POLE_THREADS_DIAMETER = 18;
POLE_THREADS_INNER_DIAMETER = POLE_THREADS_DIAMETER + 2;

module pole_threads(taper_bottom, internal) {
  diameter = internal ? POLE_THREADS_INNER_DIAMETER : POLE_THREADS_DIAMETER;
  thread_size = internal ? 5.5 : 5;
  tz(POLE_THREADS_LENGTH) rx(180) union() {
    metric_thread(diameter=diameter, pitch=5, thread_size=thread_size, length=POLE_THREADS_LENGTH, internal=internal, square=true, leadin=1);
    //taper out the last thread a little
    if (taper_bottom) {
      cylinder(d2=13, d1=16, h=5);
    }
  }
}

