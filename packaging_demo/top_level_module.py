from pathlib import Path
import typing as ty
import json

TOP_LEVEL_CONSTANT = 3
THIS_DIR = Path(__file__).parent
GREETINGS_FILE = THIS_DIR / "greetings.json"

def greet(mood: str) -> str:
    greetings: ty.Dict[str, str] = json.loads(GREETINGS_FILE.read_text())
    return greetings[mood]


if __name__ == '__main__':
    print(greet("happy"))