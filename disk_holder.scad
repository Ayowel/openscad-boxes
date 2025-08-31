// Number of slot rows.
slot_rows=4; // [1:20]
// Number of slot columns.
slot_cols=2; // [1:20]
// height of the holder's bottom.
bottom_height=1.; // [0:0.1:10]
// How much of the drive should be in the slot.
slot_height_ratio=0.6; // [0:0.01:1]
// Size of each slot.
drive_dimensions=[146.05, 101.6, 26.11]; // [0:0.01:300]
// How big the wall separating each drive slot should be.
wall_thickness=2; // [0:0.1:20]
// Clearance for each drive slot - increases each slot's size.
clearance=0.5; // [0:0.01:2]

difference() {
    cube([
        (drive_dimensions[1]+clearance+wall_thickness)*slot_cols + wall_thickness,
        (drive_dimensions[2]+clearance+wall_thickness)*slot_rows + wall_thickness,
        drive_dimensions[0]*slot_height_ratio+bottom_height]
    );
    translate([0, 0, bottom_height])
    for (i=[0:slot_cols-1]) {
        for (j=[0:slot_rows-1]) {
            translate([
                i*(drive_dimensions[1] + clearance+wall_thickness) + wall_thickness,
                j*(drive_dimensions[2] + clearance+wall_thickness) + wall_thickness,
            ])
            cube([
                drive_dimensions[1] + clearance,
                drive_dimensions[2] + clearance,
                drive_dimensions[0] + 0.1,
            ]);
        }
    }
}
