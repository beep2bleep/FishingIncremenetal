extends Line2D
@export var trail_duration = 0.5
var trail_points = []

func reset():
    trail_points = []
    clear_points()

func update_trail(pos, current_time):

    trail_points.push_front({
        "pos": pos, 
        "time": current_time
    })


    var cutoff_time = current_time - trail_duration
    while trail_points.size() > 0 and trail_points.back()["time"] < cutoff_time:
        trail_points.pop_back()


    clear_points()
    for point_data in trail_points:
        add_point(point_data["pos"] - global_position)
