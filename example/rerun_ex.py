import rerun as rr
import rerun.blueprint as rrb


my_blueprint = rrb.Blueprint(
    rrb.Tabs(
        rrb.Tabs(
            rrb.BarChartView(),
            rrb.Vertical(
                rrb.Spatial2DView(),
                rrb.Spatial3DView(),
            ),
            name="level2",
        ),
        name="level1",
    ),
)


my_blueprint = rrb.Blueprint(
    rrb.Tabs(
        rrb.Tabs(
            rrb.Horizontal(
                rrb.Spatial2DView(name="2dview-1"),
                rrb.Spatial3DView(name="3dview-1"),
                name="level1",
            ),
            rrb.Horizontal(
                rrb.Spatial2DView(name="2dview-2"),
                rrb.Spatial3DView(name="3dview-2"),
                rrb.Spatial3DView(name="4dview-2"),
                name="level1",
            ),
            name="level2",
        ),
        rrb.Tabs(
            rrb.Horizontal(
                rrb.Spatial2DView(name="2dview-1"),
                rrb.Spatial3DView(name="3dview-1"),
                name="level1",
            ),
            rrb.Horizontal(
                rrb.Spatial2DView(name="2dview-2"),
                rrb.Spatial3DView(name="3dview-2"),
                rrb.Spatial3DView(name="4dview-2"),
                name="level1",
            ),
            name="level2",
        ),
    )
)


# rr.init("rerun_example_my_blueprint", spawn=True, default_blueprint=my_blueprint)


rr.init("rerun_example_my_blueprint", spawn=True)
rr.send_blueprint(my_blueprint, make_active=True)
rr.log("lol1", rr.Points2D([0, 1]))
rr.log("lol2", rr.Points2D([1, 1]))
