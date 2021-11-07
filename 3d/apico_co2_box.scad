/*

	SaintEx Box : Apico CO2 sensor box
	Box for electronics
	
	Olivier Boesch (c) 2021

*/

use <grove_scd30.scad>

//render (number of segments for a circle)
$fn=$preview?80:200;

//External dimensions
Length = 80;
Width = 60;
Height = 25;

//rounding or chamfering
box_rounding = false; //true: round; false: chamfer
box_radius = 5;  //rounding radius
box_chamfer = 3.5;  //chamfer

//attach
attach_height=8;

//material
ep = 2;

//cutaway oversize
eps = 0.1;

//hole screw size
d_hole_screw = 2.3;
//hole insert size
d_hole_fix = 3.2;

//clearance in box for panels
panel_clearance = 0.2;

//panel material
panel_ep = 1;

//ventilation holes
ventilation_holes = true;

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

if($preview) translate([0,0,-5.5]) grove_scd30();

/* -----------------------------------------------------

	Holes on panels and shells (add here your holes)
	examples:
		cube_hole(x=3,y=6, L=15, l=5);
		cylinder_hole(x=0,y=-20, d=12);
		text_on(x=0, y=10, s="St Ex",font="Chakra Petch:style=Regular");

*/

//top of box
module top_holes(){
	text_on(x=0, y=0, s="St Ex",font="Chakra Petch:style=Regular");
	cube_hole(x=0,y=10, L=60, l=2);
	cube_hole(x=0,y=15, L=60, l=2);
	cube_hole(x=0,y=20, L=60, l=2);
	cube_hole(x=0,y=-10, L=60, l=2);
	cube_hole(x=0,y=-15, L=60, l=2);
	cube_hole(x=0,y=-20, L=60, l=2);
}

//bottom of box
module bottom_holes(){
	rotate([0,0,-90]) text_on(x=20, y=45, s="ApiCo", size=6, font="Audiowide:style=Regular");
	text_on(x=0, y=20, s="CO2",size=10, font="Audiowide:style=Regular");
	text_on(x=0, y=0, s="température",size=8, font="Audiowide:style=Regular");
	text_on(x=0, y=-20, s="humidité",size=8, font="Audiowide:style=Regular");
}

//left panel
module left_holes(){
	cube_hole(x=0,y=-8, L=5.2, l=6);
}

//right panel
module right_holes(){
}

//-------------------------------

/* -------------------------------------------------------------
	holes for screws on bottom (add here your holes for screws)
		example:
			screw_hole(x=0, y=0, d_hole=2, d_ext=4, h=10);
*/

module bottom_screws(){
	screw_hole(x=0, y=20, d_hole=3.2, d_ext=5, h=4);
	screw_hole(x=20, y=-20, d_hole=3.2, d_ext=5, h=4);
	screw_hole(x=-20, y=-20, d_hole=3.2, d_ext=5, h=4);
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
		cylinder(d=d_hole, h=h+ep/2+eps);
	}
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
	scaled_box(panel_ep, -2*ep-panel_clearance);
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
			scaled_box(panel_ep+2*panel_clearance,-2*ep-2*panel_clearance);
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
		union(){
			halfbox();
			translate([0,0,-Height/2+1]) difference(){
				linear_extrude(2, center=true) offset(r=5) square([Length+30-10, Width+30-10], center=true);
				translate([-Length/2-10,0,1]) cube([20,5.2,1.5],center=true);
			}
		}
		translate([0,0,-Height/2+ep/2]) bottom_holes();
		holes_pos = [[Length/2+8,Width/2+8],[-(Length/2+8),Width/2+8],[-(Length/2+8),-(Width/2+8)],[Length/2+8,-(Width/2+8)]];
		for(h = holes_pos) translate([0,0,-Height/2+1]) translate(h) cylinder(d=3.2, h=2.2,center=true);
	}
	bottom_screws();
}

module top(){
	difference(){
		halfbox();
		translate([0,0,-Height/2+ep/2]) top_holes();
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

if($preview && !exploded_view){
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
	spacing = 20;
	//bottom
	bottom();
	//top
	translate([0,Width+spacing,0]) top();
	//right
	translate([Length/2+Height/2+spacing,0,-Height/2+panel_ep/2]) rotate([0,90,0]) right();
	translate([Length/2+Height/2+spacing,Width+spacing,-Height/2+panel_ep/2]) rotate([0,-90,0]) left();
}