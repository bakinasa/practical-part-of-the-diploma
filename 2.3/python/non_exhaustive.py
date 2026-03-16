from enum import Enum


class Color(Enum):
    RED = 1
    GREEN = 2
    BLUE = 3


def to_code(c: Color) -> int:
    if c is Color.RED:
        return 1
    if c is Color.GREEN:
        return 2


print(to_code(Color.BLUE) + 1)
