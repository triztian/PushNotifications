#!/bin/sh

#  test_push_notifications.sh
#  PushNotifications
#
#  Created by Tristian Azuara on 3/15/21.
#

# 0. Configure
cleanup_pids=()
project=$(find . -name '*.xcodeproj')
echo "=> Testing project: $project"

device_udid=AD7BED71-5CAB-4F60-92AA-3106465D36BC
if [ ! -z "$1" ]; then
    device_udid=$1
fi
echo "=> Simulator: $device_udid"


# 1. Start the background log writer
uitest_logs=$(mktemp)
xcrun simctl spawn $device_udid log stream --predicate 'process CONTAINS "PushNotificationsUITests"' > $uitest_logs &
cleanup_pids+=("$!")
echo "-> Log Monitor PID: $!"

# 2. Start only the UI tests and in the background
xcodebuild -project "$project" -scheme PushNotifications \
    -only-testing:PushNotificationsUITests \
    -destination "platform=iOS Simulator,id=$device_udid" test &
xcodebuild_tests_pid=$!
echo "-> Xcodebuild PID: $xcodebuild_tests_pid"

# 2. Wait for the UITests to emit "XCUI-SEND-MESSAGE-XCUI"
# by monitoring the file
echo "=> Waiting for 'XCUI-SEND-MESSAGE-XCUI' marker"
sh -c "tail -n +0 -f \"$uitest_logs\" | { sed '/XCUI-SEND-MESSAGE-XCUI/ q' && kill \$\$ ;}"

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

echo "=> Sending Push Payload"
echo $push_payload | tr -d "\n" | xcrun simctl push $device_udid -

echo "=> Waiting for tests to finish: $xcodebuild_tests_pid"
wait $xcodebuild_tests_pid
xcodebuild_tests_exit_code=$?

echo "=> Clening up PIDs: $cleanup_pids"
for pid in $pids; do
    echo "-> Killing process: $pid"
    kill -9 $pid
done

exit $xcodebuild_tests_code
