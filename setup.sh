# setup.sh
# Create a Codespace that can be used to test a phpBB Extension

# Start MySQL
sudo service mysql start

# Start Apache
sudo service apache2 start

# Add SSH key
echo "$SSH_KEY" > /home/vscode/.ssh/id_rsa && chmod 600 /home/vscode/.ssh/id_rsa

# Create a MySQL user to use
sudo mysql -u root<<EOFMYSQL
    CREATE USER 'phpbb'@'localhost' IDENTIFIED BY 'phpbb'; 
    GRANT ALL PRIVILEGES ON *.* TO 'phpbb'@'localhost' WITH GRANT OPTION;
    CREATE DATABASE IF NOT EXISTS phpbb;
EOFMYSQL

# Download dependencies for the extension
echo "Dependencies"
composer install --no-interaction

# Install phpBB
echo "phpBB project"
composer create-project --no-interaction phpbb/phpbb /workspaces/phpbb

# Copy phpBB config
echo "Copy phpBB config"
sudo cp .devcontainer/resources/phpbb-config.yml /workspaces/phpbb/install/install-config.yml

echo "Symlink extension"
sudo rm -rf /var/www/html
sudo ln -s /workspaces/phpbb /var/www/html
sudo mkdir /workspaces/phpbb/ext/phpbb
sudo ln -s ./ /workspaces/phpbb/ext/phpbb/PHPBB_EXTENSION_NAME

echo "phpBB CLI install"
cd /workspaces/phpbb && composer install --no-interaction
sudo php /workspaces/phpbb/install/phpbbcli.php install /workspaces/phpbb/install/install-config.yml
sudo rm -rf /workspaces/phpbb/install 

echo "Completed"