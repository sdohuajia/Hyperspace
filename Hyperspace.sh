#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Hyperspace.sh"

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1. 部署hyperspace节点"
        echo "2. 查看积分"
        echo "3. 删除节点（停止节点）"
        echo "4. 启用日志监控"
        echo "5. 退出脚本"
        echo "================================================================"
        read -p "请输入选择 (1/2/3/4/5): " choice

        case $choice in
            1)  deploy_hyperspace_node ;;
            2)  view_points ;;
            3)  delete_node ;;
            4)  start_log_monitor ;;
            5)  exit_script ;;
            *)  echo "无效选择，请重新输入！"; sleep 2 ;;
        esac
    done
}

# 部署hyperspace节点
function deploy_hyperspace_node() {
    # 执行安装命令
    echo "正在执行安装命令：curl https://download.hyper.space/api/install | bash"
    curl https://download.hyper.space/api/install | bash

    # 刷新环境变量
    echo "执行 'source /root/.bashrc' 更新环境变量"
    source /root/.bashrc
    sleep 3

    # 提示输入屏幕名称，默认值为 'hyper'
    read -p "请输入屏幕名称 (默认值: hyper): " screen_name
    screen_name=${screen_name:-hyper}
    echo "使用的屏幕名称是: $screen_name"

    # 清理已存在的 'hyper' 屏幕会话
    echo "检查并清理现有的 'hyper' 屏幕会话..."
    screen -ls | grep "$screen_name" &>/dev/null
    if [ $? -eq 0 ]; then
        echo "找到现有的 '$screen_name' 屏幕会话，正在停止并删除..."
        screen -S "$screen_name" -X quit
        sleep 2
    else
        echo "没有找到现有的 '$screen_name' 屏幕会话。"
    fi

    # 创建一个新的屏幕会话
    echo "创建一个名为 '$screen_name' 的屏幕会话..."
    screen -S "$screen_name" -dm

    # 在屏幕会话中运行 aios-cli start
    echo "在屏幕会话 '$screen_name' 中运行 'aios-cli start' 命令..."
    screen -S "$screen_name" -X stuff "aios-cli start\n"

    # 等待几秒钟确保命令执行
    sleep 5

    # 退出屏幕会话
    echo "退出屏幕会话 '$screen_name'..."
    screen -S "$screen_name" -X detach
    sleep 5
    
    # 确保环境变量已经生效
    echo "确保环境变量更新..."
    source /root/.bashrc
    sleep 4  # 等待4秒确保环境变量加载

    # 打印当前 PATH，确保 aios-cli 在其中
    echo "当前 PATH: $PATH"

    # 提示用户输入私钥并保存为 my.pem 文件
    echo "请输入你的私钥（按 CTRL+D 结束）："
    cat > my.pem

    # 使用 my.pem 文件运行 import-keys 命令
    echo "正在使用 my.pem 文件运行 import-keys 命令..."
    
    # 运行 import-keys 命令
    aios-cli hive import-keys ./my.pem
    sleep 5

    # 定义模型变量
    model="hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf"

    # 添加模型并重试
    echo "正在通过命令 'aios-cli models add' 添加模型..."
    while true; do
        if aios-cli models add "$model"; then
            echo "模型添加成功并且下载完成！"
            break
        else
            echo "添加模型时发生错误，正在重试..."
            sleep 3
        fi
    done

    # 登录并选择等级
    echo "正在登录并选择等级..."

    # 登录到 Hive
    aios-cli hive login

    # 提示用户选择等级
    echo "请选择等级（1-5）："
    select tier in 1 2 3 4 5; do
        case $tier in
            1|2|3|4|5)
                echo "你选择了等级 $tier"
                aios-cli hive select-tier $tier
                break
                ;;
            *)
                echo "无效的选择，请输入 1 到 5 之间的数字。"
                ;;
        esac
    done

    # 连接到 Hive
    aios-cli hive connect
    sleep 5

    # 停止 aios-cli 进程
    echo "使用 'aios-cli kill' 停止 'aios-cli start' 进程..."
    aios-cli kill

    # 返回屏幕会话并重新启动 aios-cli
    echo "返回到屏幕会话 '$screen_name' 并运行 'aios-cli start --connect'..."
    screen -S "$screen_name" -X stuff "echo '等待 5 秒后运行命令...'; aios-cli start --connect\n"

    echo "部署hyperspace节点完成，'aios-cli start --connect' 已在屏幕内运行，系统已恢复到后台。"

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
}

# 查看积分
function view_points() {
    echo "正在查看积分..."
    source /root/.bashrc
    aios-cli hive points
    sleep 2
}

# 删除节点（停止节点）
function delete_node() {
    echo "正在使用 'aios-cli kill' 停止节点..."

    # 执行 aios-cli kill 停止节点
    aios-cli kill
    sleep 2
    
    echo "'aios-cli kill' 执行完成，节点已停止。"

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
}

# 启用日志监控
function start_log_monitor() {
    echo "启动日志监控..."

    # 后台运行日志监控脚本
    nohup bash -c '
    LOG_FILE="/root/aios-cli.log"  # 定义日志文件路径
    SCREEN_NAME="hyper"

    while true; do
        if grep -q "Last pong received" "$LOG_FILE"; then
            echo "检测到连接问题，重启 'aios-cli start --connect'..."

            # 在现有会话中发送 Ctrl+C 并重新启动命令
            screen -S "$SCREEN_NAME" -X stuff $'\003'  # 发送 Ctrl+C
            sleep 2
            screen -S "$SCREEN_NAME" -X stuff "aios-cli start --connect >> /root/aios-cli.log 2>&1\n"  # 重启并定向日志
            echo "重启完成！"
        fi
        sleep 60  # 每分钟检查一次
    done
    ' &> log_monitor_output.log &

    echo "日志监控已启动，后台运行中。"
    sleep 2

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
}

# 退出脚本
function exit_script() {
    echo "退出脚本..."
    exit 0
}

# 调用主菜单函数
main_menu
