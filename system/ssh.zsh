# Add all identities to the ssh agent

for key in $(ls ~/.ssh/ | grep identity | grep -v pub); do
  ssh-add ~/.ssh/$key;
done
