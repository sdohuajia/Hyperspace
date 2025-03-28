#!/bin/bash
LOG_FILE="/root/aios-cli.log"
SCREEN_NAME="hyper"
LAST_RESTART=$(date +%s)
MIN_RESTART_INTERVAL=300
AIOS_CMD="aios-cli start --connect"

restart_service() {
    current_time=$1
    screen -ls | grep "$SCREEN_NAME" &>/dev/null
    if [ $? -eq 0 ]; then
        echo "找到现有的 '$SCREEN_NAME' 屏幕会话"
    else
        # 创建一个新的屏幕会话
        echo "创建一个名为 '$SCREEN_NAME' 的屏幕会话..."
        screen -S "$SCREEN_NAME" -dm
    fi
    
    echo "$(date): 正在重启服务..." >> /root/monitor.log
    
    # 先发送 Ctrl+C 终止进程
    screen -S "$SCREEN_NAME" -X stuff $'\003'
    sleep 5
    
    # 执行 aios-cli kill
    screen -S "$SCREEN_NAME" -X stuff "aios-cli kill\n"
    sleep 5
    
    # 清理旧日志
    echo "$(date): 清理旧日志..." > "$LOG_FILE"
    
    # 重新启动服务
    screen -S "$SCREEN_NAME" -X stuff "/root/.aios/aios-cli start --connect >> /root/aios-cli.log 2>&1\n"
    
    LAST_RESTART=$current_time
    echo "$(date): 服务已重启" >> /root/monitor.log
}



while true; do
    current_time=$(date +%s)
    
    # 检测到以下几种情况，触发重启
    if ! pgrep -f "$AIOS_CMD" > /dev/null; then
        echo "$(date): 进程 $AIOS_CMD 未运行，正在重启服务..." >> /root/monitor.log
        restart_service "$current_time"
    elif (tail -n 4 "$LOG_FILE" | grep -q "Last pong received.*Sending reconnect signal" || \
        tail -n 4 "$LOG_FILE" | grep -q "Failed to authenticate" || \
        tail -n 4 "$LOG_FILE" | grep -q "Failed to connect to Hive" || \
        tail -n 4 "$LOG_FILE" | grep -q "Another instance is already running" || \
        tail -n 4 "$LOG_FILE" | grep -q "\"message\": \"Internal server error\"" || \
        tail -n 4 "$LOG_FILE" | grep -q "thread 'main' panicked at aios-cli/src/main.rs:181:39: called \Option::unwrap()\ on a \None\ value") && \
       [ $((current_time - LAST_RESTART)) -gt $MIN_RESTART_INTERVAL ]; then
        echo "$(date): 检测到连接问题、认证失败、连接到 Hive 失败、实例已在运行、内部服务器错误或 'Option::unwrap()' 错误，正在重启服务..." >> /root/monitor.log
        restart_service "$current_time"
    fi
    sleep 30
done