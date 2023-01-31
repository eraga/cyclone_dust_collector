include <NopSCADlib/utils/core/core.scad>
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
function cyclone_duct_dia_out(type) = type[7];
function cyclone_duct_dia_in(type) = type[8];


module cyclone_assembly(type, trans = 0) {
    assembly(cyclone_part(type)) {
        color("white")
        cyclone_cone(type);
        translate_z(cyclone_heigth_cone(type)+trans) {
            color("red")
            cyclone_cone_cylinder_gasket(type);
            translate_z(1+trans)

            color("teal")
            cyclone_cylinder(type);

            translate_z(cyclone_heigth_top(type)+trans){
                translate_z(1+trans)
                color("red")
                cyclone_cylinder_hat_gasket(type);

                translate_z(2+trans*2)
                color("green")
                cyclone_hat(type);
            }
        }
    }
}

function cyclone_collar_h(type) = screw_radius(cyclone_screw_type(type))*2*3;

module hat_to_cylinder_mounts(type) {
    screw = cyclone_screw_type(type);
    collar_h = cyclone_collar_h(type);
    d_top = cyclone_diameter_top(type);

    for(a = [0 : 90 : 360])
    rotate([0,0,a-30])
        translate([(d_top - collar_h*1.5)/2,0,0])
            circle(r = screw_radius(screw));
}

module cyclone_hat(type) {
    stl(str(cyclone_part(type), "_hat"));

    screw = cyclone_screw_type(type);
    collar_h = screw_radius(screw)*2*3;
    d_top = cyclone_diameter_top(type);
    d_out = cyclone_duct_dia_out(type);
    h = cyclone_heigth_top(type);

    h_tube = h + cyclone_heigth_cone(type)/10;
    d_in = d_out + (d_top-d_out)/8;

    difference() {
        cylinder(d = d_top, h = 3);
        cylinder(d = d_out, h = 10, center = true);
        hat_to_cylinder_mounts(type);
    }

    translate_z(-h_tube)
    difference() {
        cylinder(d2 = d_out+4, d1 = d_in+4, h = h_tube);
        translate_z(-.1)
        cylinder(d2 = d_out, d1 = d_in, h = h_tube+.2);
    }
}

module cyclone_cylinder_shape(type) {
    d_top = cyclone_diameter_top(type);
    d_in = cyclone_duct_dia_in(type);

    r=d_top/2-d_in-1.7;
    thickness=d_in;
    loops=0.5;

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
        translate_z(-.1)
        circle(d = r*2);

        for (a = [0 : 90 : 360])
        rotate([0, 0, a]) {
            polygon(points);
        }
    }
}

module cyclone_cylinder(type) {
    $fn = 180;
    stl(str(cyclone_part(type), "_cylinder"));

    screw = cyclone_screw_type(type);
    collar_h = cyclone_collar_h(type);
    d_top = cyclone_diameter_top(type);
    d_in = cyclone_duct_dia_in(type);
    h = cyclone_heigth_top(type);

    translate_z(collar_h + 3)
    rotate([180,0,0])
    screw_face(type);

    r = d_top/2-d_in-1.7;

    duct_h_pos = h*2/3;
    duct_x_pos = d_top/2-d_in/2-4;


    difference() {
        linear_extrude(height = h, convexity = 3)
            cyclone_cylinder_shape(type);

        translate([duct_x_pos, 0, duct_h_pos])
            rotate([90,0,0])
                cylinder(d = d_in, h = d_top*2);



        translate_z(h-19)
        linear_extrude(20)
        hat_to_cylinder_mounts(type);
    }


//    difference() {
//        translate([duct_x_pos, 0, duct_h_pos])
//            rotate([90,0,0])
//                cylinder(d = d_in+4, h = d_top/2);
//
//        translate([duct_x_pos-.1, 0, duct_h_pos])
//            rotate([90,0,0])
//                cylinder(d = d_in, h = d_top+.2/2);
//
//        cylinder(d = d_top, h = h+.2);
//    }
}
module cyclone_cone(type) {
    stl(str(cyclone_part(type), "_cone"));

    d_top = cyclone_diameter_top(type);
    d_bottom = cyclone_diameter_bottom(type);
    screw = cyclone_screw_type(type);
    collar_h = cyclone_collar_h(type);
    h = cyclone_heigth_cone(type) - collar_h*2;

    module cone(dx) {
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

    // cone
    difference() {
        cone(0);
        cone(4);
    }

    // screw face
    translate_z(h + collar_h - 2.9)
    screw_face(type);
}

module cyclone_cylinder_hat_gasket(type) {
    stl(str(cyclone_part(type), "_cylinder_hat_gasket"));
    thickness = 1;

    render()
        linear_extrude(thickness)
        difference() {
            cyclone_cylinder_shape(type);
            hat_to_cylinder_mounts(type);
        }

}

module cyclone_cone_cylinder_gasket(type) {
    stl(str(cyclone_part(type), "_cone_cylinder_gasket"));
    translate_z(-cyclone_collar_h(type))
    render()
    screw_face(type, thickness = 1);
}

module screw_face(type, thickness = 3) {
    d_top = cyclone_diameter_top(type);
    screw = cyclone_screw_type(type);
    collar_h = cyclone_collar_h(type);
    h = cyclone_heigth_cone(type) - collar_h*2;

    difference() {
        union() {
//            cylinder(d = d_top, h = collar_h);
            translate_z(collar_h)
            cylinder(d = d_top + collar_h*2, h = thickness);
        }
        translate_z(-.1)
        cylinder(d = d_top-4, h = collar_h*2);

        translate_z(collar_h)
        for(a = [0, 45, 90, 135, 180, 225, 270])
        rotate([0, 0, a])
            translate([(d_top + collar_h*0.8)/2,0,0])
                cylinder(r = screw_radius(screw), h = 20, center = true);
    }
}
