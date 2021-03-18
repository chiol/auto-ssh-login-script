function usage() {
    printf "Usage: $0 OPTION...
    -i IP         ip 주소
    -p PORT       port
    -u USER       user
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

echo "====== Connection Test (input password) ========"
ssh -p $PORT $USER@$IP
status=$(ssh -o ConnectTimeout=5 -p $PORT $USER@$IP echo ok 2>&1)

if [[ $status == ok ]] ; then
    NAME="${IP}_${PORT}"
    KEY_NAME="${IP}_${PORT}"
    KEY_PATH="$HOME/.ssh/$KEY_NAME"
    ssh-keygen -t rsa -f $KEY_PATH -N ""

    echo "" >> ~/.ssh/config
    echo "Host $NAME" >> ~/.ssh/config
    echo "  HostName $IP" >> ~/.ssh/config
    echo "  User $USER" >> ~/.ssh/config
    echo "  Port $PORT" >> ~/.ssh/config
    echo "  IdentityFile $KEY_PATH" >> ~/.ssh/config

    scp -P $PORT $KEY_PATH.pub $USER@$IP:~/.ssh/$KEY_NAME.pub
    ssh -p $PORT $USER@$IP "cat ~/.ssh/$KEY_NAME.pub >> ~/.ssh/authorized_keys && rm -rf ~/.ssh/$KEY_NAME.pub"

elif [[ $status == "Permission denied"* ]] ; then
  echo no_auth
else
  echo other_error
fi


