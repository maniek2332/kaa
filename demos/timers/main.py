import os
import math
import time
import random

from kaa.timers import Timer
from kaa.input import Keycode
from kaa.images import Sprite
from kaa.engine import Engine, Scene
from kaa.geometry import Vector, Polygon
from kaa.physics import BodyNode, SpaceNode

PYTHON_IMAGE_PATH = os.path.join('demos', 'assets', 'python_small.png')


class TtlNode(BodyNode):

    def __init__(self, **kwargs):
        ttl = kwargs.pop('ttl')
        Timer(ttl, self.delete).start()
        super().__init__(**kwargs)


class MainScene(Scene):

    def __init__(self):
        self.camera.position = Vector(0., 0.)
        self.space = self.root.add_child(
            SpaceNode(position=Vector(0, 0))
        )
        self.box_image = Sprite(PYTHON_IMAGE_PATH)
        self.timer = Timer(2000, self.spawn, single_shot=False)
        self.timer.start()
        self.spawn()

    def spawn(self):
        angles = list(range(0, 360, 18))
        for angle in angles:
            self.space.add_child(
                TtlNode(
                    mass=1e10,
                    sprite=self.box_image,
                    angular_velocity=1,
                    ttl=random.randrange(3000, 6000),
                    shape=Polygon.from_box(Vector(20, 20)),
                    velocity=Vector.from_angle_degrees(angle) * 50
                )
            )

    def update(self, dt):
        for event in self.input.events():
            if event.is_quit():
                self.engine.quit()
            elif event.is_pressing(Keycode.q):
                self.engine.quit()
            elif event.is_pressing(Keycode.s):
                if self.timer.is_running:
                    self.timer.stop()
                else:
                    self.timer.start()


if __name__ == '__main__':
    engine = Engine(virtual_resolution=Vector(800, 600))
    engine.run(MainScene())
