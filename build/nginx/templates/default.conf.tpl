server {
    listen [::]:80;
    listen 80;

    server_name ${DOMAIN};
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN} www.${DOMAIN};

    ssl_certificate /etc/certs/${DOMAIN}.pem;
    ssl_certificate_key /etc/certs/${DOMAIN}-key.pem;

    add_header Strict-Transport-Security "max-age=31536000" always;

    ssl_session_cache shared:SSL:20m;
    ssl_session_timeout 10m;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "ECDH+AESGCM:ECDH+AES256:ECDH+AES128:!ADH:!AECDH:!MD5;";

    root /var/www/html/web;
    index index.php;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;


    #
	# Mime types rules
	#
	include includes/mime-types.conf;

    #
    # Generic restrictions for things like PHP files in uploads
    #
	include includes/restrictions.conf;

    #
	# Gzip rules
	#
	include includes/gzip.conf;

    #
	# WordPress rules
	#
    # include includes/wordpress-multi.conf;
    include includes/wordpress-single.conf;

	#
	# Forward 404's to WordPress
	#
	error_page 404 = @wperror;
	location @wperror {
		rewrite ^/(.*)$ /index.php?q=$1 last;
	}

    #
	# Static file rules
	#
	location ~* \.(?:css|js)$ {
        access_log        off;
        log_not_found     off;
        add_header        Cache-Control "no-cache, public, must-revalidate, proxy-revalidate";
    }

    location ~* \.(?:jpg|jpeg|gif|png|ico|xml)$ {
        access_log        off;
        log_not_found     off;
        expires           5m;
        add_header        Cache-Control "public";
    }

    location ~* \.(?:eot|woff|woff2|ttf|svg|otf) {
        access_log        off;
        log_not_found     off;

        expires           5m;
        add_header        Cache-Control "public";

        # allow CORS requests
        add_header        Access-Control-Allow-Origin *;
    }

    #
    # PHP-FPM
    #
	location ~ \.php$ {
		try_files $uri =404;

		fastcgi_split_path_info ^(.+\.php)(/.+)$;

		fastcgi_param   QUERY_STRING            $query_string;
		fastcgi_param   REQUEST_METHOD          $request_method;
		fastcgi_param   CONTENT_TYPE            $content_type;
		fastcgi_param   CONTENT_LENGTH          $content_length;

		fastcgi_param   SCRIPT_FILENAME         $document_root$fastcgi_script_name;
		fastcgi_param   SCRIPT_NAME             $fastcgi_script_name;
		fastcgi_param   PATH_INFO               $fastcgi_path_info;
		fastcgi_param   PATH_TRANSLATED         $document_root$fastcgi_path_info;
		fastcgi_param   REQUEST_URI             $request_uri;
		fastcgi_param   DOCUMENT_URI            $document_uri;
		fastcgi_param   DOCUMENT_ROOT           $document_root;
		fastcgi_param   SERVER_PROTOCOL         $server_protocol;

		fastcgi_param   GATEWAY_INTERFACE       CGI/1.1;
		fastcgi_param   SERVER_SOFTWARE         nginx/$nginx_version;

		fastcgi_param   REMOTE_ADDR             $remote_addr;
		fastcgi_param   REMOTE_PORT             $remote_port;
		fastcgi_param   SERVER_ADDR             $server_addr;
		fastcgi_param   SERVER_PORT             $server_port;
		fastcgi_param   SERVER_NAME             $host;

		fastcgi_param   REDIRECT_STATUS         200;

		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

		fastcgi_pass wordpress:9000;
		fastcgi_buffer_size      64k;
		fastcgi_buffers          32 32k;
		fastcgi_read_timeout	 1200s;

		proxy_buffer_size        64k;
		proxy_buffers            32 32k;
		proxy_busy_buffers_size  256k;
	}
}
