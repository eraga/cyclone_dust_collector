include <NopSCADlib/utils/core/core.scad>
include <NopSCADlib/utils/core/rounded_rectangle.scad>
use <NopSCADlib/vitamins/screw.scad>

// по мотивам видео «Циклон с кавернами, для сбора мелкодисперсной пыли»
// https://www.youtube.com/watch?v=WKm1e92MP1Y

function cyclone_part(type) = type[0];
function cyclone_name(type) = type[1];
function cyclone_diameter_top(type) = type[2];
function cyclone_diameter_bottom(type) = type[3];
function cyclone_heigth_top(type) = type[4];
function cyclone_heigth_cone(type) = type[5];
function cyclone_screw_type(type) = type[6];

function cyclone_duct_dia_out(type) = is_list(type[7]) ? fitting_hose_dia_outer(type[7]) : type[7];
function cyclone_is_fitting_out(type) = is_list(type[7]);
function cyclone_fitting_out(type) = type[7];

function cyclone_duct_wall_step(type) = type[8];

function cyclone_duct_dia_in(type) = is_list(type[9]) ? fitting_hose_dia_inner(type[9]) : type[9];
function cyclone_fitting_in(type) = type[9];
function cyclone_is_fitting_in(type) = is_list(type[9]);


function fitting_part(type) = type[0];
function fitting_name(type) = type[1];
function fitting_hose_dia_inner(type) = type[2];
function fitting_hose_dia_outer(type) = type[3];
function fitting_shell_dia(type) = type[4];
function fitting_duct_dia_out(type) = type[5];
function fitting_hose_depth(type) = type[6];
function fitting_cyclone_depth(type) = type[7];
function fitting_hose_pocket_offset(type) = type[8];
function fitting_hose_pocket_width(type) = type[9];
function fitting_hose_pocket_thickness(type) = type[10];


WALL_THICKNESS = 3;

module cyclone_assembly(type, trans = 0) {
    assembly(cyclone_part(type)) {
        color("white")
        render()
        cyclone_cone(type);
        translate_z(cyclone_heigth_cone(type)+trans) {
            color("red")
            render()
            cyclone_cone_cylinder_gasket(type);

            translate_z(1+trans)
            color("teal")
            render()
            cyclone_cylinder(type);


//            rotate([0,0,30])
            translate_z(cyclone_heigth_top(type)+trans){
                translate_z(1+trans)
                color("red")
                render()
                cyclone_cylinder_hat_gasket(type);

                translate_z(trans*2){
                    color("green")
                        render()
                            cyclone_out_tube(type);

//                    translate_z(trans)
                    color("blue")
                        cyclone_out_tube_connector(type);

                    translate_z(5 + trans)
                    color("orange")
                        render()
                            cyclone_hat_hose_in(type);
                }
            }
        }
    }
}

function next_divisor_wo_remainder(num, divisor) =
    num % divisor == 0 ? divisor : next_divisor_wo_remainder(num, divisor-1);

function cyclone_collar_h(type) = screw_radius(cyclone_screw_type(type))*2*3;


module place_radial_holes(step, offs, r, h = 0) {
    for (a = [0 : step : 360])
    rotate([0, 0, a])
        translate([offs, 0, 0])
            if (h == 0)
                circle(r = r);
            else
                cylinder(r = r, h = h, center = true);
}

module hat_to_cylinder_mounts(type, h = 0) {
    screw = cyclone_screw_type(type);
    collar_h = cyclone_collar_h(type);
    d_top = cyclone_diameter_top(type) + screw_radius(screw)*10;
    l_top = 3.14159*d_top;
    step_out = 360 / next_divisor_wo_remainder(360, round(l_top/40));


    place_radial_holes(step_out, (d_top - collar_h * 1.5) / 2, screw_radius(screw), h);
}

module hat_to_tube_mounts(type, h = 0) {
    screw = cyclone_screw_type(type);
    d_in = cyclone_duct_dia_in(type);
    l_in = 3.14159*d_in;
    step_in = 360 / next_divisor_wo_remainder(360, round(l_in/20));

    place_radial_holes(step_in, d_in/2+screw_head_radius(screw)*3.5, screw_radius(screw), h);
}

module cyclone_hat_hose_in_tube(type, only_inside = false, length = 340) {
    d_in = cyclone_duct_dia_in(type);
    width = cyclone_diameter_top(type)/2 - ((cyclone_diameter_top(type)/2 - cyclone_duct_dia_out(type)/2))/2;

    module segment(w, d, z, r, length, step) {
        hull() {
            translate([w, 0, 0])
                rotate([90, 0, 0])
                    cylinder(d = d, h = .1, center = true);
            rotate([0,0,r])
                translate([w, 0, z])
                    rotate([90, 0, 0])
                        cylinder(d = d, h = .1, center = true);
        }

        if(length-step > 0)
        translate_z(z)
        rotate([0,0,r])
            segment(w, d, z, r, length-step, step);
    }

    module segment_tube(w, d, z, r, length, step) {
        difference() {
            if(only_inside == false) {
                union() {
                    segment(w, d + 4, z, r, length, step);
                    translate([w-(d+4)/2,0,z-d/2])
                    hull() {
                        rounded_cube_xz([d + 4, .1, d], r = 3, z_center = true);
                        translate([-d/2,r*5,-d/8])
                        rounded_cube_xz([d, .1, 3], r = 1, z_center = true);
                    }
                }
            }
            segment(w, d, z, r, length+1, step);
        }
    }

    difference() {
        translate_z(d_in/2+2){
            segment_tube(width, d_in, - d_in / 25, 10, length, 10);

            if(only_inside == false) {
                if(cyclone_is_fitting_in(type)) {
                    fitting = cyclone_fitting_in(type);
                    translate([width, -fitting_hose_depth(fitting)-fitting_cyclone_depth(fitting), 0])
                        rotate([-90,0,0])
                            cyclone_hose_fitting(fitting, support = true);

                } else {
                    translate([width, 0, 0])
                        rotate([90, 0, 0])
                            difference() {
                                cylinder(d = d_in + 4, h = width / 2);
                                cylinder(d = d_in, h = width);
                            }
                }
            }
        }
    }
}

module cyclone_hat_hose_in(type) {
    d_in = cyclone_duct_dia_in(type);

    render(convexity = 10)
        difference() {
            cyclone_hat_hose_in_tube(type);
            translate_z(-6)
            rotate([0, 180, 0])
                cylinder(d = cyclone_diameter_top(type)*2, h = d_in * 2);
        }

    translate_z(-6)
    cyclone_hat(type);

    if(cyclone_is_fitting_out(type)) {
        fitting = cyclone_fitting_out(type);
        translate([0, 0, fitting_hose_depth(fitting)+fitting_cyclone_depth(fitting)-WALL_THICKNESS*2])
            rotate([-180,0,0])
                cyclone_hose_fitting(fitting);

    }
}


module cyclone_hat(type) {
    stl(str(cyclone_part(type), "_hat"));

    screw = cyclone_screw_type(type);
    collar_h = screw_radius(screw)*2*3;
    d_top = cyclone_diameter_top(type)+ screw_radius(screw) * 10;
    d_out = cyclone_duct_dia_out(type);
    h = cyclone_heigth_top(type);

    h_tube = h + cyclone_heigth_cone(type)/10;
    d_in = d_out + (d_top-d_out)/8;

    difference() {
        cylinder(d = d_top, h = 3);
        cylinder(d = d_out, h = 10, center = true);
        hat_to_cylinder_mounts(type, h = 10);
        hat_to_tube_mounts(type, h = 10);
        translate_z(6)
        cyclone_hat_hose_in_tube(type, only_inside=true);
    }
}

module cyclone_out_tube(type) {
    stl(str(cyclone_part(type), "_out_tube"));

    screw = cyclone_screw_type(type);
    collar_h = screw_radius(screw)*2*3;
    d_top = cyclone_diameter_top(type);
    d_out = cyclone_d_out_tube(type);
    h = cyclone_heigth_top(type);

    h_tube = h + cyclone_duct_dia_in(type)*0.16;

    translate_z(-h_tube)
    difference() {
        cylinder(d = d_out + WALL_THICKNESS, h = h_tube);
        translate_z(-.1)
        cylinder(d = d_out, h = h_tube+.2);
    }
}

module cyclone_out_tube_connector(type) {
    stl(str("cyclone_out_tube_connector_", cyclone_part(type)));

    screw = cyclone_screw_type(type);
    collar_h = screw_radius(screw)*2*3;
    d_in = cyclone_duct_dia_out(type);
    d_out = cyclone_d_out_tube(type);
    h = cyclone_heigth_top(type);

    h_tube = 10;

    translate_z(-h_tube){
        difference() {
            translate_z(h_tube)
            cylinder(d = d_out, h = WALL_THICKNESS);
            translate_z(h_tube-.1)
            cylinder(d = d_in, h = WALL_THICKNESS + .2);

            translate_z(h_tube)
            hat_to_tube_mounts(type, h = h_tube*2);
        }
        difference() {
            cylinder(d = d_out, h = h_tube);
            translate_z(- .1)
            cylinder(d = d_out - WALL_THICKNESS*2, h = h_tube + .2);
        }
    }
}

function cyclone_d_out_tube(type) = ((cyclone_diameter_top(type)-WALL_THICKNESS*2))*0.4;

module cyclone_cylinder_shape(type) {
    d_top = cyclone_diameter_top(type);
    d_in = cyclone_duct_dia_in(type);

    r = d_top/2 - d_in/2 - WALL_THICKNESS-9.3;
    thickness=d_in;
    loops=0.5;
    d_out = cyclone_d_out_tube(type);

    assert(d_out > d_in * 1.5, "outer dia has to be bigger");


    echo(d_out, pow((d_out/(d_top-WALL_THICKNESS*2)),2));

    dx = 7;
    dy = 90;
    points = concat(
        [for (t = [90:360 * loops])
            [(r - thickness + t / dy) * sin(t), (r - thickness + t / dx) * cos(t)]],
        [for (t = [360 * loops:- 1:90])
            [(r + t / dy) * sin(t), (r + t / dx) * cos(t)]]
    );

    difference() {
        circle(d = d_top);
        circle(d = d_out+thickness*2);

        for (a = [0 : 90 : 360])
        rotate([0, 0, a]) {
            polygon(points);
            translate([r + 90 / dx, 0])
            circle(d = thickness / 2.6 + 90 / dx);
        }
    }
}

module cyclone_cylinder(type) {
    $fn = 180;
    stl(str(cyclone_part(type), "_cylinder"));

    screw = cyclone_screw_type(type);
    collar_h = cyclone_collar_h(type);
    d_top = cyclone_diameter_top(type);
    d_in = cyclone_duct_wall_step(type);
    h = cyclone_heigth_top(type);

    translate_z(collar_h + 3)
    rotate([180,0,0])
    cone_screw_face(type);

    r = d_top/2-d_in-1.7;

    difference() {
        union() {
            difference() {
                linear_extrude(height = h, convexity = 3)
                    cyclone_cylinder_shape(type);

                translate_z(h)
                cyclone_hat_hose_in_tube(type, only_inside = true, length = 180);
            }

            d_top_screws_face = d_top + screw_radius(screw) * 10;
            translate_z(h)
            difference() {
                hull() {
                    cylinder(d = d_top_screws_face, h = .1);
                    translate_z(- screw_radius(screw) * 10)
                    cylinder(d = d_top, h = .1);
                }
                //        translate_z(-.1)
                cylinder(d = d_top, h = h * 4, center = true);
            }
        }
        translate_z(h-19)
        linear_extrude(20)
            hat_to_cylinder_mounts(type);
    }
}

module cyclone_cone_model(type, dx) {
    d_top = cyclone_diameter_top(type);
    d_bottom = cyclone_diameter_bottom(type);
    collar_h = cyclone_duct_dia_in(type)*0.16*3;
    h = cyclone_heigth_cone(type) - collar_h*2;

    translate_z(h + collar_h + dx)
    cylinder(d = d_top-dx, h = collar_h+.1);
    translate_z(h + collar_h - .1)
    cylinder(d = d_top-dx, h = collar_h+.1);
    translate_z(collar_h)
    cylinder(d2 = d_top-dx, d1 = d_bottom-dx, h = h);
    cylinder(d = d_bottom-dx, h = collar_h+.1);
    translate_z(-dx)
    cylinder(d = d_bottom-dx, h = collar_h);
}

module cyclone_cone(type) {
    stl(str(cyclone_part(type), "_cone"));

    d_top = cyclone_diameter_top(type);
    d_bottom = cyclone_diameter_bottom(type);
    screw = cyclone_screw_type(type);
    collar_h = cyclone_duct_dia_in(type)*0.16*2;
    h = cyclone_heigth_cone(type) - collar_h*2;


    // cone
    difference() {
        cyclone_cone_model(type, 0);
        cyclone_cone_model(type, 4);
    }

    // screw face
    translate_z(h + collar_h - 2.9)
    cone_screw_face(type);

    // bin face
    cone_bin_face(type);
}

module cyclone_cylinder_hat_gasket(type) {
    stl(str(cyclone_part(type), "_cylinder_hat_gasket"));
    thickness = 1;

    render()
        linear_extrude(thickness)
        difference() {
            union() {
                cyclone_cylinder_shape(type);
                difference() {
                    circle(d = cyclone_diameter_top(type) + screw_radius(cyclone_screw_type(type)) * 10);
                    circle(d = cyclone_diameter_top(type));
                }
            }
            hat_to_cylinder_mounts(type);
        }

}

module cyclone_cone_cylinder_gasket(type) {
    stl(str(cyclone_part(type), "_cone_cylinder_gasket"));
    translate_z(-cyclone_collar_h(type))
    render()
    cone_screw_face(type, thickness = 1);
}

module place_holes(a, r) {
    for(step = [0 : a : 360])
    rotate([0, 0, step])
        translate([r,0,0])
            children();
}

module cone_bin_face_sketch(type) {
    d_top = cyclone_diameter_bottom(type);
    screw = cyclone_screw_type(type);
    collar_h = cyclone_collar_h(type);

    difference() {
        circle(d = d_top + collar_h*4);
        translate_z(-.1)
        circle(d = d_top-3);

        place_holes(a = 45, r = (d_top + collar_h*2.5)/2)
            circle(r = screw_radius(screw));
    }
}

module cone_bin_face(type, thickness = 3) {
    linear_extrude(thickness)
    cone_bin_face_sketch(type);

    d_top = cyclone_diameter_bottom(type);
    screw = cyclone_screw_type(type);
    collar_h = cyclone_collar_h(type);

    difference() {
        hull() {
            cylinder(d = d_top, h = collar_h*2);
            cylinder(d = d_top + collar_h*4, h = thickness);
        }

        place_holes(a = 45, r = (d_top + collar_h*2.5)/2){
            cylinder(r = screw_radius(screw), h = 20);
            translate_z(thickness)
            cylinder(r = screw_head_radius(screw)*1.5, h = 20);
        }

        translate_z(-.1)
        cylinder(d = d_top-3, h = collar_h*4);

        cyclone_cone_model(type, 0);
    }
}

module cone_screw_face(type, thickness = 3) {
    d_top = cyclone_diameter_top(type);
    screw = cyclone_screw_type(type);
    collar_h = cyclone_collar_h(type);
    h = cyclone_heigth_cone(type) - collar_h*2;

    difference() {
        union() {
            translate_z(collar_h)
            cylinder(d = d_top + collar_h*2, h = thickness);
        }
        translate_z(-.1)
        cylinder(d = d_top-4, h = collar_h*2);

        translate_z(collar_h)
        for(a = [0, 45, 90, 135, 180, 225, 270, 315])
        rotate([0, 0, a])
            translate([(d_top + collar_h*0.8)/2,0,0])
                cylinder(r = screw_radius(screw), h = 20, center = true);
    }
}

module cyclone_hose_fitting(type, support = false) {
    d_in = fitting_hose_dia_inner(type);
    d_out = fitting_hose_dia_outer(type);
    d_shell = fitting_shell_dia(type);
    d_cyclone = fitting_duct_dia_out(type);
    h_depth = fitting_hose_depth(type);
    c_depth = fitting_cyclone_depth(type);
    p_depth = fitting_hose_pocket_offset(type);
    p_w = fitting_hose_pocket_width(type);
    p_h = fitting_hose_pocket_thickness(type);

    render()
    difference() {
        union() {
            cylinder(d = d_cyclone, h = h_depth + c_depth);
            cylinder(d = d_shell, h = h_depth + 10);
            if(support) {
                translate([0,d_shell/4, 0])
                    rounded_cube_xy([d_cyclone, d_shell/2+2, h_depth + c_depth ], r=2, xy_center = true);
            }
        }
        translate_z(h_depth+10)
        cylinder(d = d_in, h = c_depth);
        cylinder(d = d_in, h = h_depth+20);
        cylinder(d = d_out, h = h_depth);

        translate_z(p_depth)
        cube([d_shell*2, p_w, p_h], center = true);
    }

}
