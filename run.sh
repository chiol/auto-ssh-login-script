function usage() {
    printf "Usage: $0 OPTION...
    -i IP         ip 주소
    -p PORT       port
    -u USER       user
    -e PASSWORD   password
    \\n" "$0" 1>&2
    exit 1
}

while getopts "u:i:p:e:h" opt; do
    case $opt in
    u)
        USER=$OPTARG
        ;;
    i)
        IP=$OPTARG
        ;;
    p)
        PORT=$OPTARG
        ;;
    e)
        PASSWORD=$OPTARG
        ;;
    h)
        usage
        ;;
    ?)
        echo "Invalid Option!" 1>&2
        usage
        ;;
    :)
        echo "Invalid Option: -${OPTARG} requires an argument." 1>&2
        usage
        ;;
    *)
        usage
        ;;
    esac
done
[ $IP == "" ] && usage
[ $PORT == "" ] && usage
[ $USER == "" ] && usage
[ $PASSWORD == "" ] && usage

echo "$IP $PORT $USER $PASSWORD"

NAME="${IP}_${PORT}"
echo "$NAME"
KEY_NAME="${IP}_${PORT}"
KEY_PATH="$HOME/.ssh/$KEY_NAME"
echo "$NAME $KEY_NAME $KEY_PATH" 
ssh-keygen -t rsa -f $KEY_PATH -N ""

echo "Host $NAME" >> ~/.ssh/config
echo "  HostName $IP" >> ~/.ssh/config
echo "  User $USER" >> ~/.ssh/config
echo "  Port $PORT" >> ~/.ssh/config
echo "  IdentityFile $KEY_PATH" >> ~/.ssh/config

scp -P $PORT $KEY_PATH.pub $USER@$IP:~/.ssh/$KEY_NAME.pub
ssh -p $PORT $USER@$IP "cat ~/.ssh/$KEY_NAME.pub >> ~/.ssh/authorized_keys && rm -rf ~/.ssh/$KEY_NAME.pub"