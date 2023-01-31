// по мотивам видео «Циклон с кавернами, для сбора мелкодисперсной пыли»
// https://www.youtube.com/watch?v=WKm1e92MP1Y
include <NopSCADlib/utils/core/core.scad>
include <NopSCADlib/vitamins/screws.scad>


/**
 * this design tested to perform well with plastic
 * and wooden small fraction dust
 * being used with 1.5kW vacuum cleaner.
 * xref:docs/issledovanie-harakteristik-tsiklona-s-vnutrennimi-elementami.pdf[]
 */
SMALL_CYCLONE = ["ABS_cyclone_with_elements", "Cyclone with Elements", 180, 90, 180, 250, M4_cap_screw, 50, 28];

use <cyclone_dust_collector.scad>
