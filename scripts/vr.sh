#!/usr/bin/env bash
set -Eeuxo pipefail

main() {
	sudo true
	handle_steamvr
	restart_monado
	wlx-overlay-s
}

restart_monado() {
	pkill wlx-overlay-s || true
	timeout 5 systemctl --user stop monado.service || (echo "failed to stop monado, killing" && pkill -9 monado && systemctl --user stop monado.socket)
	systemctl --user start monado.service
	sudo renice -20 -p $(pgrep monado)
}

handle_steamvr() {
	sudo setcap CAP_SYS_NICE=eip ~/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher
}
main
