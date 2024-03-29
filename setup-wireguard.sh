DEST=${DEST:-/etc/wireguard}
CONF_FILE=$DEST/wg0.conf

echo -n "What is the last octet of the IP address (192.168.100.xxx)? "
read last_octet
export IP=192.168.100.$last_octet

export PRIVATE_KEY=$(wg genkey)
sudo mkdir -p $DEST
sudo touch $CONF_FILE
sudo chmod 600 $CONF_FILE
sudo chown root:root $CONF_FILE
sudo -E sh -c "envsubst <wg0.conf.template >$CONF_FILE"

PUBLIC_KEY=$(echo $PRIVATE_KEY | wg pubkey)
echo Add this public key to the peer: $PUBLIC_KEY
