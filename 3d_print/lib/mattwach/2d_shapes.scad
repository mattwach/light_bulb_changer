
module arc(r, start_angle, end_angle, wedge=true) {
  sides = $fn == 0 ? 36 : $fn;
  step = (end_angle - start_angle) / sides;
  points = [
    for (i = [0:sides]) [r * cos(start_angle + i * step), r * sin(start_angle + i * step)]
  ];
  if (wedge) {
    polygon(concat([[0, 0]], points));
  } else {
    polygon(concat([[r * cos(start_angle), r * sin(start_angle)]], points));
  }
}
