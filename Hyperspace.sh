#!/bin/bash

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
        echo "2. 退出脚本"
        echo "================================================================"
        read -p "请输入选择的操作编号 (1/2): " choice

        case $choice in
            1)  deploy_hyperspace_node ;;
            2)  exit_script ;;
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

    # 创建文件夹 'hyperspace' 并进入该目录
    echo "创建名为 'hyperspace' 的文件夹并进入该目录"
    mkdir -p /root/hyperspace
    cd /root/hyperspace

    # 提示输入屏幕名称，默认值为 'hyperspace'
    read -p "请输入屏幕名称 (默认值: hyperspace): " screen_name
    screen_name=${screen_name:-hyperspace}
    echo "使用的屏幕名称是: $screen_name"

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

    # 提示用户输入私钥并保存为 my.pem 文件
    echo "请输入你的私钥（按 CTRL+D 结束）："
    cat > my.pem

    # 使用 my.pem 文件运行 import-keys 命令
    echo "正在使用 my.pem 文件运行 import-keys 命令..."
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

    # 使用已添加的模型进行推理
    echo "正在使用已添加的模型进行推理..."
    infer_prompt="你好，你能解释一下 YouTube 频道 Share It Hub 吗？"
    while true; do
        if aios-cli infer --model "$model" --prompt "$infer_prompt"; then
            echo "推理成功。"
            break
        else
            echo "执行推理时发生错误，正在重试..."
            sleep 3
        fi
    done

    # 登录并选择等级
    echo "正在登录并选择等级..."
    aios-cli hive login
    aios-cli hive select-tier 5
    aios-cli hive connect
    sleep 5

    # 使用已添加的模型运行 Hive 推理
    echo "正在使用已添加的模型运行 Hive 推理..."
    while true; do
        if aios-cli hive infer --model "$model" --prompt "$infer_prompt"; then
            echo "Hive 推理成功。"
            break
        else
            echo "执行 Hive 推理时发生错误，正在重试..."
            sleep 3
        fi
    done

    # 停止 aios-cli 进程
    echo "使用 'aios-cli kill' 停止 'aios-cli start' 进程..."
    aios-cli kill

    # 返回屏幕会话并重新启动 aios-cli
    echo "返回到屏幕会话 '$screen_name' 并运行 'aios-cli start --connect'..."
    screen -S "$screen_name" -X stuff "echo '等待 5 秒后运行命令...'; aios-cli start --connect\n"

    echo "部署hyperspace节点完成，'aios-cli start --connect' 已在屏幕内运行，系统已恢复到后台。"
}

# 退出脚本
function exit_script() {
    echo "退出脚本..."
    exit 0
}

# 调用主菜单函数
main_menu
