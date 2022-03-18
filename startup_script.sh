sudo apt-get update
sudo apt -y install jq
 
curl "https://secretmanager.googleapis.com/v1/projects/<PROJECT-NAME>/secrets/<SECRET-NAME>/versions/<SECRET-VERSION>:access" \
    --request "GET" \
    --header "authorization: Bearer $(gcloud auth print-access-token)" \
    --header "content-type: application/json" | jq -r '.payload.data' | base64 --decode > ~/.ssh/id_rsa
 
echo -e '\n' >> ~/.ssh/id_rsa
# chmod 0600 ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa
echo -e 'Host github.com\n\tHostname github.com\n\tIdentityFile ~/.ssh/id_rsa' >> ~/.ssh/config
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa
ssh-keyscan -t rsa github.com > known_hosts.github
cp known_hosts.github ~/.ssh/known_hosts
 
git clone git@github.com:<GITHUB-USERNAME>/<REPOSITORY-NAME>.git ~/app
cd ~/app
 
yes | sudo apt install python3.8-venv
yes | sudo apt install pip
pip install --upgrade pip
python3 -m pip install --user virtualenv
python3 -m venv venv
source ./venv/bin/activate
yes | pip install -r requirements.txt
 
mkdir ./models
gsutil cp gs://<PATH-TO-MODEL>/<MODEL-NAME>.tar.gz ./models
 
rasa run --credentials ./credentials.yml & rasa run actions -p 5055