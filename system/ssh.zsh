# Add all identities to the ssh agent

echo "Skipping ssh-add, you should setup ~/.ssh/config magic instead"
# for key in $(ls ~/.ssh/ | grep identity | grep -v pub); do
#   ssh-add ~/.ssh/$key;
# done
