from packaging_demo.slow import add
import pytest


@pytest.mark.slow
@pytest.mark.parametrize("a,b,expected", [(1, 2, 3), (2, 4, 6), (0, 0, 0)])
def test_add(a, b, expected):
    assert add(a, b) == expected
