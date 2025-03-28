#!/bin/bash
LOG_FILE="/root/aios-cli.log"
SCREEN_NAME="hyper"
MIN_RESTART_INTERVAL=300
POINTS_LOG_FILE="/root/points_monitor.log"

restart_service() {
    screen -ls | grep "$SCREEN_NAME" &>/dev/null
    if [ $? -eq 0 ]; then
        echo "找到现有的 '$SCREEN_NAME' 屏幕会话"
    else
        # 创建一个新的屏幕会话
        echo "创建一个名为 '$SCREEN_NAME' 的屏幕会话..."
        screen -S "$SCREEN_NAME" -dm
    fi
    
    echo "$(date): 正在重启服务..." >> "$POINTS_LOG_FILE"
    
    # 先发送 Ctrl+C 终止进程
    screen -S "$SCREEN_NAME" -X stuff $'\003'
    sleep 5
    
    # 执行 aios-cli kill
    screen -S "$SCREEN_NAME" -X stuff "aios-cli kill\n"
    sleep 5

    # 清理旧日志
    echo "$(date): 清理旧日志..." > "$LOG_FILE"
    
    # 重新启动服务
    screen -S "$SCREEN_NAME" -X stuff "/root/.aios/aios-cli >> /root/aios-cli.log 2>&1\n"
}

while true; do
    OUTPUT=$(/root/.aios/aios-cli hive points)
    echo "$(date): 输出: $OUTPUT" >> "$POINTS_LOG_FILE"
    if [[ ! "$OUTPUT" =~ "Points:" ]]; then
        echo "$(date): 积分异常，正在重启服务..." >> "$POINTS_LOG_FILE"
        restart_service
    else
        echo "$(date): 积分正常，正在重启服务..." >> "$POINTS_LOG_FILE"
    fi
    sleep 7200
done