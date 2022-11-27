echo "Hello Foods Backend";
echo "System Uploading...";

node index.js
save_val=$?

if ! [ $save_val -eq 1 ]
then
    echo "ERROR OPS MY ASS HURT"
    read stop
    exit
fi

echo "Uploaded now Starting System"
echo ""

cd ..
npm start

read stop;