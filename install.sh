#!/bin/bash
set -e

echo "Обновляем пакеты Kali..."
apt update -y
apt upgrade -y

echo "Устанавливаем минимальный Xfce и необходимые инструменты..."
apt install -y xfce4 xfce4-terminal xvfb x11vnc wget unzip

echo "Скачиваем noVNC..."
wget -q https://github.com/novnc/noVNC/archive/refs/heads/master.zip -O /tmp/novnc.zip
unzip -q /tmp/novnc.zip -d /opt/
rm /tmp/novnc.zip

echo "Создаем скрипт запуска виртуального рабочего стола..."
cat <<'EOF' > /usr/local/bin/start_vnc.sh
#!/bin/bash
# Запускаем виртуальный дисплей
Xvfb :1 -screen 0 1024x768x16 &

export DISPLAY=:1

# Запускаем Xfce
startxfce4 &

# Запускаем x11vnc
x11vnc -display :1 -nopw -forever -listen 0.0.0.0 -xkb &

# Запускаем noVNC на порту 6080
cd /opt/noVNC-master
./utils/novnc_proxy --vnc localhost:5900
EOF

chmod +x /usr/local/bin/start_vnc.sh

echo "Установка завершена!"
echo "Запуск рабочего стола: start_vnc.sh"
echo "Открыть браузер на телефоне/ПК и перейти на http://localhost:6080"
