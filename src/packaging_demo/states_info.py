from pathlib import Path
import typing as ty
import json

TOP_LEVEL_CONSTANT = 3
THIS_DIR = Path(__file__).parent
STATES_INFO_FILE = THIS_DIR / "states_capital.json"


def get_states_capital(state: str) -> str:
    states_info: ty.List[ty.Dict[str, str]] = json.loads(STATES_INFO_FILE.read_text())
    for si in states_info:
        if si["state"] == state.lower():
            return si["capital"]

    raise ValueError(f"The provided state {state} is not in the database!")
