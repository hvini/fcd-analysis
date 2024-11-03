loading() {
    spinner="/-\|"
    while :; do
        for i in $(seq 0 3); do
            echo -ne "\r${spinner:i:1} Processing..."
            sleep 0.1
        done
    done
}