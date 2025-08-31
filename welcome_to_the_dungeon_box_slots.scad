/* [Design] */
// Overall shape of the box.
design = "three_slots"; // [three_slots: 2 Hero slots - cards on the side, four_slots: 4 Hero slots - cards on top, four_slots_reversed: 4 Hero slots - heros on top]

// Toggle token slot
has_token_slot = true;
// Part of the cross-section in the unused space.
cross_size = [0.5, 0.66]; // [0:0.01:1]
// Additional space on slots.
clearance = 0.5; // [0:0.01:2]

/* [Dimensions] [4 Hero Slots] */
// With hero slots on top, size of the card access holes.
cards_access_hole_radius = 10; // [0:0.1:20]
// With dungeon slots on top, size of the hero slots access hole.
hero_slots_access_hole_radius = 20; // [0:0.1:40]
// Relative size of the access hole for the token
token_slot_access_hole_ratio = 0.55; // [0:0.01:1]

/* [Dimensions] [2 Hero Slots] */
// Toggle token slot notch
has_token_slot_notch = true;
// Length of the central hole.
access_hole_radius = 30; // [0:0.1:50]
// Width of the central role relative to its length.
access_hole_x_scale = 0.6; // [0:0.01:2]
// Additional depth of the health token's slot.
token_slot_depth = 2; // [0:0.1:5]
// How deep "in" the token the notch should be.
token_slot_notch_pressure = 0.5; // [0:0.01:1]

/* [Hardware] */
// Internal size of the box container.
box_total_dimensions = [140, 93, 38]; // [0:0.1:200]
// Size of a hole for all cards of a hero.
hero_holes_size = [65, 40, 14]; // [0:0.1:200]
// Size of the deck of dungeon cards.
cards_hole_size = [88.5, 63.5, 10]; // [0:0.1:200]
// Diameter of the HP token.
token_diameter = 18; // [0:0.1:30]
// Height of the HP token.
token_height = 4; // [0:0.1:10]
// Space left empty for the rules & HP counter.
top_space = 4; // [0:0.1:50]

/* [Hidden] */
// Used to ensure that preview surfaces match expectations.
render_offset = 0.1;
// The size of the game box's bin.
box_dimensions = [box_total_dimensions[0], box_total_dimensions[1], box_total_dimensions[2] - top_space];
// The size of the base game's box.
hero_holes = [hero_holes_size[0] + clearance, hero_holes_size[1] + clearance, hero_holes_size[2] + clearance];
cards_hole = [cards_hole_size[0] + clearance, cards_hole_size[1] + clearance, cards_hole_size[2]+clearance];

module notch_spheres(notch_radius, spacing) {
    for (i=[0:1]) {
        translate([0, (i*2-1)*spacing/2])
        scale([2., 1., 1.])
        sphere(r = notch_radius);
    }
}

module box_three_slots() {
    difference() {
        // Base body
        cube(box_dimensions, center = true);
        for (j=[0,1]) {
            // Hero cards' slot
            translate([
                -hero_holes[0]/2-(box_dimensions[0]/2-hero_holes[0])*cross_size[0],
                (j*2-1)*(hero_holes[1]/2+(box_dimensions[1]/2-hero_holes[1])*cross_size[1]),
                box_dimensions[2]/2 - hero_holes[2] + render_offset/2
            ])
            cube([
                hero_holes[0],
                hero_holes[1],
                2*hero_holes[2] + render_offset
            ], center = true);
        }

        // Dungeon cards' slot
        translate([
            cards_hole[1]/2 + (box_dimensions[0]/2-cards_hole[1])*cross_size[0],
            0,
            (box_dimensions[2]-cards_hole[2]+render_offset)/2
        ])
        cube([cards_hole[1], cards_hole[0], cards_hole[2]+render_offset], center = true);

        // Access hole
        translate([0, 0, (box_dimensions[2]-hero_holes[2]*2+render_offset)/2])
        scale([access_hole_x_scale, 1., 1.])
        cylinder(r=access_hole_radius, h=hero_holes[2]*2+render_offset, center = true);

        // Token's hole
        if (has_token_slot) {
            translate([
                access_hole_x_scale*access_hole_radius + token_diameter*3/4 + clearance,
                0,
                box_dimensions[2]/2-cards_hole[2]-(token_height+token_slot_depth)/2+render_offset/2,
            ])
            difference() {
                union() {
                    cylinder(
                        h=token_height + token_slot_depth + render_offset,
                        r=(token_diameter+clearance)/2,
                        center=true
                    );
                    translate([-token_diameter*3/4, 0])
                    cube([
                        token_diameter*1.5 + clearance,
                        token_diameter + clearance,
                        token_height + token_slot_depth + render_offset
                    ], center=true);
                }
                if (has_token_slot_notch)
                    translate([
                        -(token_slot_depth+token_slot_notch_pressure)/4,
                        0,
                        (token_height+token_slot_depth)/2 - (token_slot_depth+token_slot_notch_pressure)/2 - render_offset/2
                    ])
                    notch_spheres((token_slot_depth+token_slot_notch_pressure)/2, token_diameter);
            }
        }
    }
}

module box_four_slots(reversed = false) {
    token_radius = token_diameter/2;
    cross_section = [
        (box_dimensions[0]-hero_holes_size[0]*2)*cross_size[0],
        (box_dimensions[1]-hero_holes_size[1]*2)*cross_size[1],
    ];

    difference() {
        cube(box_dimensions, center=true);
        // Hero cards' slots
        translate([0, 0, box_dimensions[2] - (reversed?0:cards_hole_size[2]) - hero_holes_size[2]/2]) {
            for(i=[0:3]) let(
                x_direction = pow(-1, i),
                y_direction = pow(-1, floor(i/2))
            ) {
                translate([
                    x_direction * (hero_holes_size[0]/2 + cross_section[0]/2),
                    y_direction * (hero_holes_size[1]/2 + cross_section[1]/2),
                ])
                cube([
                    hero_holes_size[0],
                    hero_holes_size[1],
                    hero_holes_size[2] + box_dimensions[2],
                ], center=true);
            }
            if (!reversed) {
                cylinder(
                    r=hero_slots_access_hole_radius,
                    h = hero_holes_size[2] + box_dimensions[2],
                    center = true
                );
            }
        }
        // Dungeon cards' slot
        translate([
            0,
            0,
            box_dimensions[2] - cards_hole_size[2]/2 - (reversed?hero_holes_size[2]:0),
        ]) {
            cube([
                cards_hole_size[0],
                cards_hole_size[1],
                cards_hole_size[2] + box_dimensions[2],
            ], center = true);
            if (reversed) {
                for (i=[0:3]) {
                    translate([
                        (i%2*2-1) * (cards_hole_size[0] - cards_access_hole_radius) / 2,
                        (floor(i/2)*2-1) * (cards_hole_size[1] -cards_access_hole_radius)/2,
                    ])
                    cylinder(
                        r=cards_access_hole_radius,
                        h=cards_hole_size[2] + box_dimensions[2],
                        center=true
                    );
                }
            }
        }

        // Token slot and access
        if (has_token_slot) {
            translate([
                (box_dimensions[0] + cards_hole_size[0])/4,
                0,
                box_dimensions[2]/2 - token_radius,
            ])
            rotate([90,0,0]) {
                // Token slot
                cylinder(
                    r=token_radius + clearance/2,
                    h=token_height + clearance,
                    center=true
                );

                translate([0, token_radius/2, 0])
                cube([
                    2*token_radius + clearance,
                    token_radius + clearance/2,
                    token_height + clearance,
                ], center=true);
                // Token access
                cylinder(
                    r=token_radius*token_slot_access_hole_ratio,
                    h=cross_section[1]+render_offset,
                    center=true
                );
                translate([0, (token_radius+clearance)/2, 0])
                cube([
                    2*token_radius*token_slot_access_hole_ratio,
                    token_radius + clearance,
                    cross_section[1] + render_offset,
                ], center=true);
            }
        }
    }
}

if (design == "three_slots") {
    box_three_slots();
} else if (design == "four_slots") {
    box_four_slots();
} else if (design == "four_slots_reversed") {
    box_four_slots(reversed = true);
}

