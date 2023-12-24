// по мотивам видео «Циклон с кавернами, для сбора мелкодисперсной пыли»
// https://www.youtube.com/watch?v=WKm1e92MP1Y
include <NopSCADlib/utils/core/core.scad>
include <NopSCADlib/vitamins/screws.scad>


/**
*
                           d_i,d_o,d_sh,d_cy,h_d,c_d,
*/
FITTING_40_45_30 = ["", "", 30, 45, 50, 38.5, 35, 72, 6.5, 8, 2.5];
FITTING_32_45_30 = ["", "", 29, 45, 50, 33, 35, 72, 6.5, 8, 2.5];
FITTING_32_45    = ["", "", 33, 45, 50, 37, 35, 74, 6.5, 8, 2.5];
FITTING_32_45_0    = ["", "", 33, 45, 50, 37, 35, 10, 6.5, 8, 2.5];


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
* f_type — fitting type
*/

/**
 * this design tested to perform well with plastic
 * and wooden small fraction dust
 * being used with 1.5kW vacuum cleaner.
 * xref:docs/issledovanie-harakteristik-tsiklona-s-vnutrennimi-elementami.pdf[]
 */
//              part,                        name,                      d_top,d_bot,h_top,h_cone,   screw,      duct_o, wall_step, duct_in
SMALL_CYCLONE = ["ABS_cyclone_with_elements", "Cyclone with Elements",  180,    90,   180,   250, M4_cap_screw,     50,        28, 28];
SMALL_CYCLONE_40MM = ["ABS_cyclone_40mm",     "Cyclone for 40mm hose",  180,    90,   180,   250, M4_cap_screw,     50,        28, 40];
SMALL_CYCLONE_40MM_F = ["ABS_cyclone_40mm",   "Cyclone for 40mm hose",  180,    90,   100,   200, M4_cap_screw,FITTING_32_45_0,  29, FITTING_32_45];

use <cyclone_dust_collector.scad>


//cyclone_assembly(SMALL_CYCLONE_40MM_F, trans = 30);
cyclone_cone(SMALL_CYCLONE_40MM_F);
//translate([0,0,-9]) {
//    cyclone_out_tube(SMALL_CYCLONE_40MM_F);

//color("blue")
//    cyclone_out_tube_connector(SMALL_CYCLONE_40MM_F);
//}

//cyclone_hat_hose_in(SMALL_CYCLONE_40MM_F);

//color("teal")
//translate([0,0,-100])
//cyclone_cylinder(SMALL_CYCLONE_40MM_F);

//linear_extrude(height = 10)
//cyclone_cylinder_shape(SMALL_CYCLONE_40MM_F);

//cyclone_hose_fitting(FITTING_32_45_30);
//cyclone_hat_hose_in(SMALL_CYCLONE_40MM);
//cyclone_hat_hose_in(SMALL_CYCLONE_40MM);
