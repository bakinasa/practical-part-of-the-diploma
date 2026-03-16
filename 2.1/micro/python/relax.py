def relax(old: float, du: float, w: float) -> float:
    alt = du + w
    return alt if alt < old else old


def step(old: float, du: float, w: float) -> float:
    return relax(old, du, w)


if __name__ == "__main__":
    print(f"{step(10.0, 3.0, 4.0):.2f}")
