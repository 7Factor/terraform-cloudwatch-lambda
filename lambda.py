import json


def sns_handler(event):
    print("Received event: " + json.dumps(event, indent=2))
