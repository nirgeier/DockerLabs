#!/bin/sh
# Entrypoint to inject MESSAGE env into message.html before starting nginx
if [ -n "$MESSAGE" ]; then
  echo "<div style='margin:20px 0;padding:20px;background:#e0e7ff;border-radius:8px;font-size:1.3em;text-align:center;'>$MESSAGE</div>" > /usr/share/nginx/html/message.html
fi
exec nginx -g 'daemon off;'
