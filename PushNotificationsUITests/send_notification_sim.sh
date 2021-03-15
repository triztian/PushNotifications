#!/bin/sh

#  send_notification_sim.sh
#  PushNotifications
#
#  Created by Tristian Azuara on 3/15/21.
#  

device_udid=AD7BED71-5CAB-4F60-92AA-3106465D36BC

push_payload=$(cat <<EOF
{
    "Simulator Target Bundle": "com.aztristian.mobile.PushNotifications",
    "aps": {
        "alert": {
            "body": "Test"
        }
    },
    "custom_id": 999
}
EOF
)

echo $push_payload | xcrun simctl push $device_udid -
