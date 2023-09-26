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
function cyclone_duct_wall_step(type) = type[8];
function cyclone_duct_dia_in(type) = type[9];


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

                translate_z(2+trans*2)
                color("green")
                render()
                cyclone_hat(type);

                translate_z(5+trans*2)
                color("orange")
                render()
                cyclone_hat_hose_in(type);
            }
        }
    }
}

function next_divisor_wo_remainder(num, divisor) =
    num % divisor == 0 ? divisor : next_divisor_wo_remainder(num, divisor-1);

function cyclone_collar_h(type) = screw_radius(cyclone_screw_type(type))*2*3;

module hat_to_cylinder_mounts(type, h = 0) {
    screw = cyclone_screw_type(type);
    collar_h = cyclone_collar_h(type);
    d_top = cyclone_diameter_top(type);
    l_top = 3.14159*d_top;
    step = 360 / next_divisor_wo_remainder(360, round(l_top/40));

    for(a = [0 : step : 360])
    rotate([0,0,a-5])
        translate([(d_top - collar_h*1.5)/2,0,0])
        if(h == 0)
            circle(r = screw_radius(screw));
        else
            cylinder(r = screw_radius(screw), h = h, center = true);
}

module cyclone_hat_hose_in_tube(type, only_inside = false, length = 270) {
    d_in = cyclone_duct_dia_in(type);
    width = cyclone_diameter_top(type)/2 - d_in+4;

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
            segment(w, d, z,r,length-step, step);
    }

    module segment_tube(w, d, z, r, length, step) {
        difference() {
            if(only_inside == false)
                segment(w, d + 4, z, r, length, step);
            segment(w, d, z, r, length+1, step);
        }
    }

    difference() {
        translate_z(d_in/2+2){
            segment_tube(width, d_in, - d_in / 25, 10, length, 10);

            if(only_inside == false)
            translate([width,0,0])
                rotate([90,0,0])
                    difference() {
                        cylinder(d = d_in+4, h = width/2);
                        cylinder(d = d_in, h = width);
                    }
        }
    }
}
module cyclone_hat_hose_in(type) {
    d_in = cyclone_duct_dia_in(type);

    render(convexity = 10)
    difference() {
        cyclone_hat_hose_in_tube(type);
        rotate([0, 180, 0])
            cylinder(d = cyclone_diameter_top(type), h = d_in * 2);
    }
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
        hat_to_cylinder_mounts(type, h = 10);
        cyclone_hat_hose_in_tube(type, only_inside=true);
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
    d_in = cyclone_duct_wall_step(type);

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
    d_in = cyclone_duct_wall_step(type);
    h = cyclone_heigth_top(type);

    translate_z(collar_h + 3)
    rotate([180,0,0])
    cone_screw_face(type);

    r = d_top/2-d_in-1.7;

//    duct_h_pos = h*2/3;
//    duct_x_pos = d_top/2-d_in/2-4;


    difference() {
        linear_extrude(height = h, convexity = 3)
            cyclone_cylinder_shape(type);

//        translate([duct_x_pos, 0, duct_h_pos])
//            rotate([90,0,0])
//                cylinder(d = d_in, h = d_top*2);



        translate_z(h-19)
        linear_extrude(20)
        hat_to_cylinder_mounts(type);

        translate_z(h)
        cyclone_hat_hose_in_tube(type, only_inside=true, length=180);
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

module cyclone_cone_model(type, dx) {
    d_top = cyclone_diameter_top(type);
    d_bottom = cyclone_diameter_bottom(type);
    collar_h = cyclone_collar_h(type);
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
    collar_h = cyclone_collar_h(type);
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
            cyclone_cylinder_shape(type);
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

module cyclone_hose_fitting(type) {
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
        }
        translate_z(h_depth+10)
        cylinder(d = d_in, h = c_depth);
        cylinder(d = d_in, h = h_depth+20);
        cylinder(d = d_out, h = h_depth);

        translate_z(p_depth)
        cube([d_shell*2, p_w, p_h], center = true);
    }

}
