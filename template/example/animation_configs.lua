animation_configs = {}

animation_configs.ball = {
    source_image = "example/ball.png",
    default_state = "idle_r",
    frame_size = {16, 16},
    frame_padding = {1, 1},
    centered = true,
    states = {
        idle_r = {
            frames = 1,
            frame_offset = {0, 0},
            cycle = 1.0,
            transition = "End"
        },
        spin_r = {
            frames = 5,
            frame_offset = {0, 0},
            cycle = 0.3,
            transition = "Loop"
        },
        r_to_y = {
            frames = 7,
            frame_offset = {5, 0},
            cycle = 0.6,
            transition = "Into:idle_y"
        },
        idle_y = {
            frames = 1,
            frame_offset = {12, 0},
            cycle = 1.0,
            transition = "End"
        },
        spin_y = {
            frames = 5,
            frame_offset = {12, 0},
            cycle = 0.3,
            transition = "Loop"
        },
        y_to_r = {
            frames = 7,
            frame_offset = {17, 0},
            cycle = 0.6,
            transition = "Into:idle_r"
        }
    }
}
