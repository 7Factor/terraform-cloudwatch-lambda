import json
import logging
import os
from urllib.error import URLError, HTTPError
from urllib.request import Request, urlopen

SLACK_CHANNEL = os.environ['slack_channel']
WEBHOOK_URL = os.environ['hook_url']

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def sns_handler(event, context):
    logger.info("Event: " + str(event))
    message = json.loads(event['Records'][0]['Sns']['Message'])
    logger.info("Message: " + str(message))

    slack_message = {
        'channel': SLACK_CHANNEL,
        'text': "testing lambda function"
    }

    req = Request(WEBHOOK_URL, json.dumps(slack_message).encode('utf-8'))
    try:
        response = urlopen(req)
        response.read()
        logger.info("Message posted to %s", slack_message['channel'])
    except HTTPError as e:
        logger.error("Request failed: %d %s", e.code, e.reason)
    except URLError as e:
        logger.error("Server connection failed: %s", e.reason)
