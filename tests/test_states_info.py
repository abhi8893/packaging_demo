from packaging_demo.states_info import get_states_capital
import pytest


@pytest.mark.parametrize("state,capital", [
    ("uttar pradesh", "lucknow"),
    ("maharashtra", "mumbai")
])
def test_get_states_capital(state, capital):
    assert get_states_capital(state) == capital

def test_get_states_capital_unknown_state():
    with pytest.raises(ValueError):
        assert get_states_capital("ghaziabad")
