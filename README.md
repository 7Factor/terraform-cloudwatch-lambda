# AWS Cloudwatch Rules with Lambda Handlers via Terraform

Creates a Cloudwatch Rule that connects to a zipped lambda handler.


## How to use this

This module is intended to create cloudwatch rules that listen for events inside of AWS. When those events are triggered, they will invoke your chosen lambda function to do something interesting. The sky's really the limit here so it's up to your imagination. Note that you will need to zip your lambda function before passing it to this module.