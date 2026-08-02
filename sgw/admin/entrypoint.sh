#!/bin/sh
set -e

SUBSCRIBE_DIR=/etc/nginx/subscribe

# 确保目录存在且 admin 可写
mkdir -p "$SUBSCRIBE_DIR"
chmod 777 "$SUBSCRIBE_DIR"

# 确保所有可写文件存在
[ -f "$SUBSCRIBE_DIR/blacklist.json" ]    || echo "[]" > "$SUBSCRIBE_DIR/blacklist.json"
[ -f "$SUBSCRIBE_DIR/blacklist.conf" ]    || echo "# blacklist" > "$SUBSCRIBE_DIR/blacklist.conf"
[ -f "$SUBSCRIBE_DIR/ua_blacklist.json" ] || echo "[]" > "$SUBSCRIBE_DIR/ua_blacklist.json"
[ -f "$SUBSCRIBE_DIR/ua_custom.conf" ]    || printf 'map $http_user_agent $is_custom_bad_ua {\n    default 0;\n}\n' > "$SUBSCRIBE_DIR/ua_custom.conf"
[ -f "$SUBSCRIBE_DIR/whitelist_ips.txt" ] || touch "$SUBSCRIBE_DIR/whitelist_ips.txt"
[ -f "$SUBSCRIBE_DIR/admin_settings.json" ] || echo "{}" > "$SUBSCRIBE_DIR/admin_settings.json"

chmod 666 \
    "$SUBSCRIBE_DIR/blacklist.json" \
    "$SUBSCRIBE_DIR/blacklist.conf" \
    "$SUBSCRIBE_DIR/ua_blacklist.json" \
    "$SUBSCRIBE_DIR/ua_custom.conf" \
    "$SUBSCRIBE_DIR/whitelist_ips.txt" \
    "$SUBSCRIBE_DIR/admin_settings.json"

# 确保日志卷目录和日志文件对 PHP-FPM(www-data) 可写
mkdir -p /var/log/subscribe
chmod 777 /var/log/subscribe
touch /var/log/subscribe/access.log
chmod 666 /var/log/subscribe/access.log

# 首次启动：将 .env 中的管理员凭证写入 settings.json（若尚未设置）
php -r '
$f = "/etc/nginx/subscribe/admin_settings.json";
$s = json_decode(@file_get_contents($f), true);
if (!is_array($s)) $s = [];
$envPass = getenv("ADMIN_PASS") ?: "";
$envUser = getenv("ADMIN_USER") ?: "admin";
if ($envPass !== "" && empty($s["admin_pass"])) {
    $s["admin_user"] = $envUser;
    $s["admin_pass"] = $envPass;
    file_put_contents($f, json_encode($s, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}
'

php-fpm -D
exec nginx -g 'daemon off;'
