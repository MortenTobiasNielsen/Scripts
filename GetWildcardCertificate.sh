sudo apt-get update
sudo apt-get install -y certbot python3-certbot-dns-cloudflare zip

# setup variables and ask for input from the user
home_directory=$(eval echo ~${USER})

echo 
read -p "Enter email for the cloudflare account which owns the domain: " email
read -p "Enter cloudflare api key: " apiKey
read -p "Enter domain (e.g. example.com): " domain
read -p "Enter path to place certificate zip files. We use the current users home directory as the starting point: " path
echo 

# Create cloudflare.ini file with necessary input
if [ -d ".secrets" ]; then
    sudo rm -r ".secrets"
fi

cd ~
mkdir .secrets
sudo chmod 0700 .secrets/
cd .secrets/

echo "
dns_cloudflare_email = $email
dns_cloudflare_api_key = $apiKey
" | sudo tee -a cloudflare.ini >/dev/null

sudo chmod 0400 ~/.secrets/cloudflare.ini

# Create certificate
sudo certbot certonly --dns-cloudfare --dns-cloudflare-cerdentials $home_directory/.secrets/cloudflare.ini -d $domain,*.$domain --preferred-challanges dns-01

# Zip up the files
sudo zip -r lib_letsencrypt.zip /var/lib/letsencrypt/
sudo zip -r etc_letsencrypt.zip /etc/letsencrypt/

# Move the files to the provided path
mv lib_letsencrypt.zip $home_directory/$path
mv etc_letsencrypt.zip $home_directory/$path

printf "\nA certificate has been made, the files have been zipped up, and moved to $home_directory/$path"