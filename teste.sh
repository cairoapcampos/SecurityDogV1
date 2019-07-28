cp /etc/fstab /etc/fstab.old

boot="defaults,nosuid 0 2"
bar="defaults 0 1"
home="defaults,nosuid,noexec,nodev 0 2"
usr="defaults,nosuid,nodev 0 2"
tmp="defaults,nosuid,noexec,nodev 0 2"
var="defaults,nosuid,noexec,nodev 0 2"
var_log="defaults,nosuid,noexec,noatime,nodev 0 2"

cat /etc/fstab | grep -v "#" | grep -v swap | grep UUID > clFstab.txt

while read line
do
a=$(echo "$line" | awk '{print $1}')
b=$(echo "$line" | awk '{print $2}')
c=$(echo "$line" | awk '{print $3}')
   if [ $b = "/boot" ]
   then
   b="\/boot"
   new_boot=$(echo "$a $b $c $boot")
   sed -i 's/'"$a.*"'/'"$new_boot"'/' /etc/fstab
   elif [ $b = "/" ]
   then
   b="\/"
   new_bar=$(echo "$a $b $c $bar")
   sed -i 's/'"$a.*"'/'"$new_bar"'/' /etc/fstab
   elif [ $b = "/home" ]
   then
   b="\/home"
   new_home=$(echo "$a $b $c $home")
   sed -i 's/'"$a.*"'/'"$new_home"'/' /etc/fstab
   elif [ $b = "/usr" ]
   then
   b="\/usr"
   new_usr=$(echo "$a $b $c $usr")
   sed -i 's/'"$a.*"'/'"$new_usr"'/' /etc/fstab
   elif [ $b = "/tmp" ]
   then
   b="\/tmp"
   new_tmp=$(echo "$a $b $c $tmp")
   sed -i 's/'"$a.*"'/'"$new_tmp"'/' /etc/fstab
   elif [ $b = "/var" ]
   then
   b="\/var"
   new_var=$(echo "$a $b $c $var")
   sed -i 's/'"$a.*"'/'"$new_var"'/' /etc/fstab
   elif [ $b = "/var/log" ]
   then
   b="\/var\/log"
   new_var_log=$(echo "$a $b $c $var_log")
   sed -i 's/'"$a.*"'/'"$new_var_log"'/' /etc/fstab
   else
   echo "Partição Desconhecida!"
   fi
done < clFstab.txt
