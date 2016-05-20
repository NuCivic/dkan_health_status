
# Name of the current module.
DKAN_MODULE="dkan_health_status"

# Save for test run
DKAN_MODULE_LINK="$HOME/$DKAN_MODULE/webroot/sites/all/modules/$DKAN_MODULE"

# DKAN branch to use
DKAN_BRANCH="7.x-1.x"

COMPOSER_PATH="$HOME/.config/composer/vendor/bin"

if [[ "$PATH" != *"$COMPOSER_PATH"* ]]; then
  echo "> Composer PATH is not set. Adding temporarily.. (you should add to your .bashrc)"
  echo "PATH (prior) = $PATH"
  export PATH="$PATH:$COMPOSER_PATH"
fi

mkdir $MODULE_NAME 2> /dev/null && echo "Created ./$MODULE_NAME folder.." || ( echo "./$MODULE_NAME folder already exists.. exiting."; ls -la; exit 1)
mv !($MODULE_NAME) $MODULE_NAME && echo "Moved all files into ./$MODULE_NAME.." || ( echo "Error moving files into ./$MODULE_NAME.. exiting."; exit 1)

if [[ ! -f webroot/index.php  ]]; then
  wget http://dkan-acquia.nuamsdev.com/dkan-acquia.tar.gz 
  tar -zxf dkan-acquia.tar.gz
fi

# Only stop on errors starting now..
set -e
cp -r $DKAN_MODULE $DKAN_MODULE_LINK
cd webroot
ahoy drush si --db-url="mysql://ubuntu:@127.0.0.1:3306/circle_test"
ahoy drush en $DKAN_MODULE -y
