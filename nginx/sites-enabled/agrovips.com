server {
    listen       80 default_server;
    server_name  agrovips.com mp1.agrovips.com mp2.agrovips.com;
    root /home/work/www/agrovip/vips_web;
    index index.html index.htm index.php;

    # 不记录 favicon.ico 错误日志
    location ~ (favicon.ico){
        log_not_found off;
        expires 100d;
        access_log off;
    }

    # 静态文件设置过期时间
    #location ~* \.(ico|css|js|gif|jpe?g|png)(\?[0-9]+)?$ {
    #    expires max;
    #    break;
    #}

    location ~ /static/ {
        rewrite "^/static/(.*)$" /static/$1 break;
    }

    location ~ /\.ht {
        deny  all;
    }   

    location ~ /\.git {
        deny  all;
    }   

    location ~ /\.svn {
        deny  all;
    }
    location /source/ {
        rewrite ^/(.*)  /index.php last;
    }

    
    location /public {
        internal;
        alias /home/work/www/agrovip/public;
    }

   
    location / {
        index index.html index.php;

        if (!-e $request_filename) {
            rewrite ^/(.*)  /index.php last;
        }
    }

    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME   $document_root$fastcgi_script_name;
        fastcgi_param ENVIRONMENT "online";
        include        fastcgi_params;
    }
}
