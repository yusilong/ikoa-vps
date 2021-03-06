#!/bin/bash


SERIAL_CODE=$1
TEAM_DRIVE_ID=$2

MERGE_BOOL=$3
OUTPUT_FILENAME=$4
PORT=$5
if [[ -n $SERIAL_CODE && -n $MERGE_BOOL ]]; then
    sed -i "/^serial/c\serial = \'$SERIAL_CODE\'" ./fanza/config.toml
    echo "team_drive = $TEAM_DRIVE_ID" >> ./fanza/rclone_1.conf
    echo "team_drive = $TEAM_DRIVE_ID" >> ./fanza/rclone_2.conf
    
    if [[ $MERGE_BOOL == "false" ]]; then
        sed -i -e "/^merge/c\merge = false" -e "/^m3u_merge/c\m3u_merge = false" ./fanza/config.toml
    fi
    if [[ $OUTPUT_FILENAME == "pid" || $OUTPUT_FILENAME == "num" ]]; then
        sed -i "/^filename/c\filename = \'$OUTPUT_FILENAME\'" ./fanza/config.toml
    fi
else
    echo "Warning: Please make sure there exist all of the needed config vars!"
    exit 1
fi



while [[ $(lsof -i:${PORT}|awk '{if(NR==2)print $2}') ]];do
echo "关闭占用端口程序pid： $(lsof -i:${PORT}|awk '{if(NR==2)print $2}')"
kill -9 $(lsof -i:${PORT}|awk '{if(NR==2)print $2}')
done

gunicorn --worker-class eventlet -w 1 -c gunicorn.conf.py --bind 0.0.0.0:"$PORT" wsgi --preload