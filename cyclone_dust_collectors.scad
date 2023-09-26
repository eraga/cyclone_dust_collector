// по мотивам видео «Циклон с кавернами, для сбора мелкодисперсной пыли»
// https://www.youtube.com/watch?v=WKm1e92MP1Y
include <NopSCADlib/utils/core/core.scad>
include <NopSCADlib/vitamins/screws.scad>

/**
* part
* name
* diameter_top
* diameter_bottom
* heigth_top
* heigth_cone
* screw_type
* duct_dia_out
* duct_dia_in
*/
//              part,                        name,                 d_top,d_bot,h_top,h_cone, screw, duct_o, wall_step, duct_in

/**
 * this design tested to perform well with plastic
 * and wooden small fraction dust
 * being used with 1.5kW vacuum cleaner.
 * xref:docs/issledovanie-harakteristik-tsiklona-s-vnutrennimi-elementami.pdf[]
 */
SMALL_CYCLONE = ["ABS_cyclone_with_elements", "Cyclone with Elements", 180, 90, 180, 250, M4_cap_screw, 50, 28, 28];
SMALL_CYCLONE_40MM = ["ABS_cyclone_40mm", "Cyclone for 40mm hose", 180, 90, 180, 250, M4_cap_screw, 50, 28, 40];

/**
*
                           d_i,d_o,d_sh,d_cy,h_d,c_d,
*/
FITTING_40_45_30 = ["", "", 30, 45, 50, 38.5, 35, 72, 6.5, 8, 2.5];
FITTING_32_45_30 = ["", "", 29, 45, 50, 33, 35, 72, 6.5, 8, 2.5];
use <cyclone_dust_collector.scad>


//cyclone_assembly(SMALL_CYCLONE_40MM, trans = 30);
//cyclone_cylinder(SMALL_CYCLONE_40MM);
//cyclone_hose_fitting(FITTING_32_45_30);
//cyclone_hat(SMALL_CYCLONE_40MM);
//cyclone_hat_hose_in(SMALL_CYCLONE_40MM);
