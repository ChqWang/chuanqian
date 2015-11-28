rm -rf temp; 
mkdir -p temp; 

CURDIR=$(pwd)

function installEnv()
{
    echo -e '\033[33;33;1m'start to install env'\033[0m'

    tar -xzvf  resource/pcre-8.37.tar.gz -C temp/ && \
		tar -xzvf resource/libiconv-1.14.tar.gz -C temp/ && \
		tar -xzvf resource/nginx-1.6.3.tar.gz  -C temp/  && \
		tar -xzvf resource/curl-7.42.1.tar.gz -C temp/ && \
		tar -xzvf resource/php-5.5.26.tar.gz -C temp/ && \
		tar -xzvf resource/apcu-4.0.7.tgz -C temp/

    if [ $? -ne 0 ]; then
        echo 'untar resources failed, exit!'
	    exit 1; 
    fi

    cd temp/nginx-1.6.3/
    ./configure --user=www --group=www \
				   --prefix=/home/admin/lnmp/nginx \
				   --with-http_stub_status_module \
				   --with-http_ssl_module \
				   --with-pcre=`pwd`/../pcre-8.37 && make -j 8 && make install; 

    if [ $? -ne 0 ]; then
        echo 'install nginx failed'
	    exit 1; 
    fi
    cd ${CURDIR};

    cd temp/libiconv-1.14
    ./configure --prefix=/usr/local/ && make -j 8 && sudo make install; 
    if [ $? -ne 0 ]; then
        echo 'install iconv failed'
	    exit 1; 
    fi
    cd ${CURDIR};

    cd temp/curl-7.42.1/
    ./configure --prefix=/usr/local/curl && make -j 8 && sudo make install; 
    if [ $? -ne 0 ]; then
        echo 'install curl failed'
	    exit 1; 
    fi
    cd ${CURDIR};

    sudo yum install libxml2-devel.x86_64; 
    if [ $? -ne 0 ]; then
       echo 'install libxml2-devel.x86_64 failed'
	   exit 1; 
    fi

    cd temp/php-5.5.26/
    ./configure --prefix=/home/admin/lnmp/php --with-config-file-path=/home/admin/lnmp/php/etc/ --with-curl=/usr/local/curl/ --with-iconv=/usr/local/ --enable-xml --enable-mbstring --with-zlib --enable-fpm --with-mysql --with-mysqli --with-pdo-mysql && make -j 8 && make install; 
    if [ $? -ne 0 ]; then
       echo 'install php failed'
	   exit 1; 
    fi
    cd ${CURDIR};

    cd temp/apcu-4.0.7
    /home/admin/lnmp/php/bin/phpize
    ./configure --with-php-config=/home/admin/lnmp/php/bin/php-config
    make install 
    if [ $? -ne 0 ]; then
        echo 'install apcu failed'
	    exit 1; 
    fi
    cd ${CURDIR};
    echo -e '\033[33;33;1m'install env ended'\033[0m'
}

function deploySrc()
{
    echo -e '\033[33;33;1m'start to deploy src code'\033[0m'

    cd ${CURDIR};
    mkdir -p /home/admin/lnmp/htdocs/logs/
    cp nginx_conf/* ~/lnmp/nginx/conf/
    cp -rf php_conf/*  ~/lnmp/php/etc/

    sudo rm -rf temp; 

    mkdir -p ~/lnmp/htdocs/phpsrc/; 
    rm -rf ~/lnmp/htdocs/phpsrc/atr; 
    cp -rf atr ~/lnmp/htdocs/phpsrc/
    echo -e '\033[33;33;1m'deploy src code ended\n'\033[0m'
}

function help()
{
    echo -ne "Usage: $(basename $0) [OPTIONS]
        sh $(basename $0) [env|Env]              only install software needed
        sh $(basename $0) [src|Src]              only install atr source-code
        sh $(basename $0) [all|All|*]            install software and source-code
        sh $(basename $0) [h|help]               show help info
        \n"

    exit -1

}

function parse_args()
{
    case $1 in
            env*|Env*)eval ACTION=installEnv
            shift 1;;
            src*|Src*)eval ACTION=installSrc
            shift 1;;
            h|help)help
            ;;
            all|All|*)echo "default action:all"; eval ACTION=installAll
            ;;
    esac
    return 0
}


function main()
{
        parse_args $*

        if [ "$ACTION" == 'installEnv' ];then
            installEnv
        elif [ "$ACTION" == 'installSrc' ];then
            deploySrc
        else
            installEnv
            deploySrc
        fi
         
        echo -e '\033[33;33;1m'\n\n\n========deloy atr success=======\n\n\n'\033[0m'

        exit 0
}

main $*

