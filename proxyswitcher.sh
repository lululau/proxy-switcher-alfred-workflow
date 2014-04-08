#!/bin/bash

# we want case-insensitive matching
shopt -s nocasematch

# remove pending and trailing whitespace and replace other whitespace with *
QUERY=$(echo "$1" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/ /* /g')

# get the current location
CURRENT_LOCATION=$(networksetup -getcurrentlocation)

echo '<?xml version="1.0"?>'
echo "<items>"

if [ -e ~/.proxyswitcher.rc ]; then
    services_command='cat ~/.proxyswitcher.rc'
else
    services_command='networksetup -listallnetworkservices | tail -n +2'
fi

bash -c "$services_command" | while read NETWORK_SERVICE
do
    if [[ " $NETWORK_SERVICE" == *\ $QUERY* ]]; then

        # Auto Proxy Discovery Settings
        proxy_auto_discovery=$(networksetup -getproxyautodiscovery "$NETWORK_SERVICE")
        if echo "$proxy_auto_discovery" | grep -q On; then
            status=On
            arg="-setproxyautodiscovery '$NETWORK_SERVICE' off"
        else
            status=Off
            arg="-setproxyautodiscovery '$NETWORK_SERVICE' on"
        fi
        echo '<item uid="'"${NETWORK_SERVICE}_proxy_auto_discovery"'" arg="'"$arg"'">'

        echo "<title>$proxy_auto_discovery</title>"
        echo "<subtitle>$NETWORK_SERVICE</subtitle>"
        if [ "$status" = On ]; then
            echo '<icon>On.png</icon>'
        else
            echo '<icon>Off.png</icon>'
        fi
        echo '</item>'

        # Auto Proxy (URL)
        auto_proxy=$(networksetup -getautoproxyurl "$NETWORK_SERVICE")
        if echo "$auto_proxy" | grep -q 'Enabled: Yes'; then
            status=On
            arg="-setautoproxystate '$NETWORK_SERVICE' off"
        else
            status=Off
            arg="-setautoproxystate '$NETWORK_SERVICE' on"
        fi 
        url=$(echo "$auto_proxy" | grep URL)
        echo '<item uid="'"${NETWORK_SERVICE}_auto_proxy"'" arg="'"$arg"'">'
        echo "<title>Auto Proxy: $status, $url</title>"
        echo "<subtitle>$NETWORK_SERVICE</subtitle>"
        if [ "$status" = On ]; then
            echo '<icon>On.png</icon>'
        else
            echo '<icon>Off.png</icon>'
        fi
        echo '</item>'

        # Web Proxy
        web_proxy=$(networksetup -getwebproxy $NETWORK_SERVICE)
        if echo "$web_proxy" | grep -q 'Enabled: Yes'; then
            status=On
            arg="-setwebproxystate '$NETWORK_SERVICE' off"
        else
            status=Off
            arg="-setwebproxystate '$NETWORK_SERVICE' on"
        fi
        server=$(echo "$web_proxy" | grep Server)
        port=$(echo "$web_proxy" | grep Port)
        echo '<item uid="'"${NETWORK_SERVICE}_web_proxy"'" arg="'"$arg"'">'
        echo "<title>Web Proxy: $status, $server, $port</title>"
        echo "<subtitle>$NETWORK_SERVICE</subtitle>"
        if [ "$status" = On ]; then
            echo '<icon>On.png</icon>'
        else
            echo '<icon>Off.png</icon>'
        fi
        echo '</item>'

        # Secure Web Proxy
        secure_web_proxy=$(networksetup -getsecurewebproxy $NETWORK_SERVICE)
        if echo "$secure_web_proxy" | grep -q 'Enabled: Yes'; then
            status=On
            arg="-setsecurewebproxystate '$NETWORK_SERVICE' off"
        else
            status=Off
            arg="-setsecurewebproxystate '$NETWORK_SERVICE' on"
        fi
        server=$(echo "$secure_web_proxy" | grep Server)
        port=$(echo "$secure_web_proxy" | grep Port)
        echo '<item uid="'"${NETWORK_SERVICE}_secure_web_proxy"'" arg="'"$arg"'">'
        echo "<title>Secure Web Proxy: $status, $server, $port</title>"
        echo "<subtitle>$NETWORK_SERVICE</subtitle>"
        if [ "$status" = On ]; then
            echo '<icon>On.png</icon>'
        else
            echo '<icon>Off.png</icon>'
        fi
        echo '</item>'

        # FTP Proxy
        ftp_proxy=$(networksetup -getftpproxy $NETWORK_SERVICE)
        if echo "$ftp_proxy" | grep -q 'Enabled: Yes'; then
            status=On
            arg="-setftpproxystate '$NETWORK_SERVICE' off"
        else
            status=Off
            arg="-setftpproxystate '$NETWORK_SERVICE' on"
        fi
        server=$(echo "$ftp_proxy" | grep Server)
        port=$(echo "$ftp_proxy" | grep Port)
        echo '<item uid="'"${NETWORK_SERVICE}_ftp_proxy"'" arg="'"$arg"'">'
        echo "<title>FTP Proxy: $status, $server, $port</title>"
        echo "<subtitle>$NETWORK_SERVICE</subtitle>"
        if [ "$status" = On ]; then
            echo '<icon>On.png</icon>'
        else
            echo '<icon>Off.png</icon>'
        fi
        echo '</item>'

        # Socks Proxy
        socks_proxy=$(networksetup -getsocksfirewallproxy $NETWORK_SERVICE)
        if echo "$socks_proxy" | grep -q 'Enabled: Yes'; then
            status=On
            arg="-setsocksfirewallproxystate '$NETWORK_SERVICE' off"
        else
            status=Off
            arg="-setsocksfirewallproxystate '$NETWORK_SERVICE' on"
        fi
        server=$(echo "$socks_proxy" | grep Server)
        port=$(echo "$socks_proxy" | grep Port)
        echo '<item uid="'"${NETWORK_SERVICE}_socks_firewall_proxy"'" arg="'"$arg"'">'
        echo "<title>Socks Proxy: $status, $server, $port</title>"
        echo "<subtitle>$NETWORK_SERVICE</subtitle>"
        if [ "$status" = On ]; then
            echo '<icon>On.png</icon>'
        else
            echo '<icon>Off.png</icon>'
        fi
        echo '</item>'

        # Streaming Proxy
        streaming_proxy=$(networksetup -getstreamingproxy $NETWORK_SERVICE)
        if echo "$streaming_proxy" | grep -q 'Enabled: Yes'; then
            status=On
            arg="-setstreamingproxystate '$NETWORK_SERVICE' off"
        else
            status=Off
            arg="-setstreamingproxystate '$NETWORK_SERVICE' on"
        fi
        server=$(echo "$streaming_proxy" | grep Server)
        port=$(echo "$streaming_proxy" | grep Port)
        echo '<item uid="'"${NETWORK_SERVICE}_streaming_proxy"'" arg="'"$arg"'">'
        echo "<title>Streaming Proxy: $status, $server, $port</title>"
        echo "<subtitle>$NETWORK_SERVICE</subtitle>"
        if [ "$status" = On ]; then
            echo '<icon>On.png</icon>'
        else
            echo '<icon>Off.png</icon>'
        fi
        echo '</item>'

        # Gopher Proxy
        gopher_proxy=$(networksetup -getgopherproxy $NETWORK_SERVICE)
        if echo "$gopher_proxy" | grep -q 'Enabled: Yes'; then
            status=On
            arg="-setgopherproxystate '$NETWORK_SERVICE' off"
        else
            status=Off
            arg="-setgopherproxystate '$NETWORK_SERVICE' on"
        fi
        server=$(echo "$gopher_proxy" | grep Server)
        port=$(echo "$gopher_proxy" | grep Port)
        echo '<item uid="'"${NETWORK_SERVICE}_gopher_proxy"'" arg="'"$arg"'">'
        echo "<title>gopher Proxy: $status, $server, $port</title>"
        echo "<subtitle>$NETWORK_SERVICE</subtitle>"
        if [ "$status" = On ]; then
            echo '<icon>On.png</icon>'
        else
            echo '<icon>Off.png</icon>'
        fi
        echo '</item>'
    fi
done


echo "</items>"

shopt -u nocasematch
