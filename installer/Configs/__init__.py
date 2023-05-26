from pathlib import Path

def ModifyDefaultConfig(data:bytes) -> bytes:
    text:str = data.decode('iso_8859_1')# keep line endings correct
    text = _ModifyDefaultConfig(text)
    return text.encode('iso_8859_1')

def _ModifyDefaultConfig(text:str) -> str:
    # TODO:
    # config parsing and modifying, in a testable way, so functions should accept config text as an argument and output the new config text
    return text
