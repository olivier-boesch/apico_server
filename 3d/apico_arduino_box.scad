/*

	SaintEx Box : Apico arduino and electronics box
	Box for electronics
	
	Olivier Boesch (c) 2021

*/

use<arduino.scad>
use<ruthex_threaded_insert.scad>

//inserts
insert_size = 3;
d_int_insert = hole_diameter(insert_size);
d_ext_insert = safe_diameter(insert_size);
h_insert = hole_height(insert_size);

//render (number of segments for a circle)
$fn=200;

//External dimensions
Length = 130;
Width = 130;
Height = 40;

//rounding or chamfering
box_rounding = false; //true: round; false: chamfer
box_radius = 5;  //rounding radius
box_chamfer = 15;  //chamfer

//attach
attach_height=10;

//material
ep = 2;

//cutaway oversize
eps = 0.1;

//hole screw size
d_hole_screw = 3.3;
//hole insert size
d_hole_fix = hole_diameter(3);

//clearance in box for panels
panel_clearance = 0.3;

//panel material
panel_ep = 1.5;

//ventilation holes
ventilation_holes = false;

// What should i draw in preview
draw_bottom = true;
draw_top = true;
draw_left = true;
draw_right = true;

//exploded view
exploded_view = false; //false: normal preview; true: exploded view

//colors (only for preview)
up_down_color = "GhostWhite";
left_right_color = "GhostWhite";

if($preview){
	translate([0,0,-11.3]) {
		translate([-34,25]) {
			Arduino();
			translate([0,0,13]) Board();
		}
		translate([25,0,18]) cube([30,25,1.6],center=true); //radio
		translate([-17,35,18]) cube([23.5,31,1.6],center=true); //mass amp
	}
	translate([-34, 25, -Height/2+ep/2]) threadedInsert(size=3, show_clearance=true, from_top=false);
	translate([17, 9.75, -Height/2+ep/2]) threadedInsert(size=3, show_clearance=true, from_top=false);
	translate([17, -18.25, -Height/2+ep/2]) threadedInsert(size=3, show_clearance=true, from_top=false);
	translate([-35, -23.4, -Height/2+ep/2]) threadedInsert(size=3, show_clearance=true, from_top=false);
}

module grove_cable(){
	translate([0,-Width/2+ep/2,0]) cube([5.2,ep+2*eps,1.6], center=true);
}

/* -----------------------------------------------------

	Holes on panels and shells (add here your holes)
	examples:
		cube_hole(x=3,y=6, L=15, l=5);
		cylinder_hole(x=0,y=-20, d=12);
		text_on(x=0, y=10, s="St Ex",font="Chakra Petch:style=Regular");

*/

//top of box
module top_holes(){
	text_on(x=35, y=45, s="ApiCo",font="Audiowide:style=Regular", size=7);
	rotate([0,0,90]) text_on(x=0, y=30, s="µC",font="Audiowide:style=Regular", size=14);
	rotate([0,0,90]) text_on(x=0, y=0, size=9, s="Électronique",font="Audiowide:style=Regular");
	rotate([0,0,90]) text_on(x=0, y=-30, size=9, s="Radio",font="Audiowide:style=Regular");
	place_object(25,-45) linear_extrude(2) import("logo_lora.svg", convexity=30);
}

//bottom of box
module bottom_holes(){
	text_on(x=0, y=0, s="St Ex",font="Chakra Petch:style=Regular", size=20);
	cylinder_hole(x=-38,y=-45, d=3.5);
	cylinder_hole(x=-38,y=45, d=3.5);
}

//left panel
module left_holes(){
	//arduino usb port
	//cube_hole(x=-12.5,y=-5, L=12.5, l=11.5);
	hull(){
		cylinder_hole(x=-40,y=-10, d=8);
		cylinder_hole(x=-40,y=-20, d=8);
	}
	hull(){
		cylinder_hole(x=40,y=-10, d=8);
		cylinder_hole(x=40,y=-20, d=8);
	}
	hull(){
		cylinder_hole(x=0,y=-10, d=8);
		cylinder_hole(x=0,y=-20, d=8);
	}
}

//right panel
module right_holes(){
	cylinder_hole(x=-10,y=6, d=2.5);
}

//-------------------------------

/* -------------------------------------------------------------
	holes for screws on bottom (add here your holes for screws)
		example:
			screw_hole(x=0, y=0, d_hole=2, d_ext=4, h=10);
*/

module bottom_screws(){
	screw_hole(x=-34, y=25, d_hole=d_int_insert, d_ext=d_ext_insert, h=h_insert);
	screw_hole(x=17, y=9.75, d_hole=d_int_insert, d_ext=d_ext_insert, h=h_insert);
	screw_hole(x=17, y=-18.25, d_hole=d_int_insert, d_ext=d_ext_insert, h=h_insert);
	screw_hole(x=-35, y=-23.4, d_hole=d_int_insert, d_ext=d_ext_insert, h=h_insert);
	screw_hole(x=-38,y=45, d_hole=7,d_ext=7+3, h=5);
	screw_hole(x=-38,y=-45, d_hole=7,d_ext=7+3, h=5);
}

//-------------------------------

/*

holes functions

*/

module cylinder_hole(x=0,y=0, d=1){
	translate([x,-y]) cylinder(d=d, h=ep+2*eps,center=true);
}

module cube_hole(x=0,y=0, L=5, l=5, angle=0){
	translate([x,-y]) rotate([0,0,angle]) cube([L, l, ep+2*eps],center=true);
}

module text_on(x=0, y=0, s="test", font="", size=10, valign="center", halign="center", angle=0){
	translate([x,-y,-ep/2-eps]) rotate([0,0,angle]) linear_extrude(ep/2+eps) rotate([180,0,0]) text(s, font=font, size=size, valign=valign, halign=halign);
}

module screw_hole(x=0, y=0, d_hole=2, d_ext=4, h=5){
	translate([x,y,-Height/2+ep/2]) difference(){
		union(){
			cylinder(d=d_ext, h=h+ep/2);
			cylinder(d1=d_ext+2, d2=d_ext, h=h/2+ep/2);
		}
		translate([0,0,-eps]) cylinder(d=d_hole, h=h+ep/2+2*eps);
	}
}

module place_object(x=0, y=0){
	translate([x,-y]) rotate([180,0,0]) children();
}

//--------------------------------

/*
	Box
*/

//box profile
module box_profile(l,w){
	if(box_rounding){
		offset(r=box_radius) square([l-2*box_radius,w-2*box_radius], center=true);
	}
	else{
		offset(delta=box_chamfer, chamfer=true) square([l-2*box_chamfer,w-2*box_chamfer], center=true);
	}
}

//general box (outer)
module general_box(l,w,h){
	rotate([90,0,90]) linear_extrude(l,center=true) box_profile(w, h);
}

//scaled box from general one (to make a clean panel and inner space)
module scaled_box(l, body_offset){
	rotate([90,0,90]) linear_extrude(l,center=true) offset(delta=body_offset/2) box_profile(Width, Height);
}

//outer half box
module outer_box(){
	difference(){
		general_box(Length, Width, Height);
		translate([0,0,Height/4+eps/2]) cube([Length+eps,Width+eps,Height/2+eps],center=true);
	}
}

//inner space
module inner_box(){
	scaled_box(Length-2*(+panel_ep+2*panel_clearance+2*ep), -2*ep);
}

//box lock
module lock(hole=false){
	if(hole){
		rotate([90,0,0]) cylinder(d=attach_height*2+panel_clearance, h=ep+panel_clearance,$fn=6,center=true);
	}
	else{
		rotate([90,0,0]) cylinder(d=attach_height*2, h=ep,$fn=6,center=true);
	}
}

//panel
module panel(){
	scaled_box(panel_ep, -2*ep-2*panel_clearance);
}

//halfbox (complete)
module halfbox(){
	difference(){
		//outer shape
		outer_box();
		//ventilation
		for(i=[-Length/2+10:5:Length/2-10]) {
			if((ventilation_holes) && (abs(i) != Length/4) && (Height >= 40)){
				translate([i,0,-Height/2+Height/8+2*ep]) cube([ep,Width+eps,Height/4], center=true);
			}
		}
		//inner shape (hole)
		inner_box();
		//ends for panel
		for(i=[-1,1]) translate([i*(Length-panel_ep-2*panel_clearance-2*ep)/2,0,0]){
			scaled_box(panel_ep+2*panel_clearance+2*ep+2*eps,-6*ep);
			scaled_box(panel_ep+2*panel_clearance,-2*ep+panel_clearance);
		}
		for(i=[-1,1]){
			translate([i*Length/4,-Width/2+ep,0]){
				lock(hole=true);
				translate([0,0,-attach_height/2]) rotate([90,0,0]) cylinder(d=d_hole_screw, h=2*ep+eps, center=true);
			}
		}
	}
	for(i=[-1,1]){
		translate([i*Length/4,Width/2-ep,0]) difference(){
			lock();
			translate([0,0,attach_height/2]) rotate([90,0,0]) cylinder(d=d_hole_fix, h=2*ep+eps, center=true);
		}
	}
}

module bottom(){
	difference(){
		halfbox();
		translate([0,0,-Height/2+ep/2]) bottom_holes();
		grove_cable();
	}
	bottom_screws();
}

module top(){
	difference(){
		halfbox();
		translate([0,0,-Height/2+ep/2]) top_holes();
		rotate([0,0,180]) grove_cable();
	}
}

module left(){
	difference(){
		panel();
		rotate([-90,0,0]) rotate([0,90,0]) left_holes();
	}
}

module right(){
	difference(){
		panel();
		rotate([0,180,0]) rotate([90,0,0]) rotate([0,90,0]) right_holes();
	}
}

//$preview = false;

if($preview && !exploded_view) /*intersection()*/{
	//bottom
	if(draw_bottom) color(up_down_color) bottom();
	//top
	if(draw_top) color(up_down_color) rotate([180,0,0]) top();
	//right
	if(draw_right) color(left_right_color) translate([(Length-panel_ep)/2-ep-panel_clearance,0,0]) right();
	//left
	if(draw_left) color(left_right_color) translate([-(Length-panel_ep)/2+ep+panel_clearance,0,0]) left();
}

if($preview && exploded_view){
	//bottom
	if(draw_bottom) color(up_down_color) translate([0,0,-Height/2]) bottom();
	//top
	if(draw_top) color(up_down_color) translate([0,0,Height/2]) rotate([180,0,0]) top();
	//right
	if(draw_right) color(left_right_color) translate([(Length-panel_ep)/2-ep-panel_clearance,0,0]) right();
	//left
	if(draw_left) color(left_right_color) translate([-(Length-panel_ep)/2+ep+panel_clearance,0,0]) left();
}

if(!$preview){
	//bottom
	bottom();
	//top
	translate([0,Width+10,0]) top();
	//right
	translate([Length/2+Height/2+10,0,-Height/2+panel_ep/2]) rotate([0,90,0]) right();
	translate([Length/2+Height/2+10,Width+10,-Height/2+panel_ep/2]) rotate([0,-90,0]) left();
}
