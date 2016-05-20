
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

DRUSH_VERSION="8.0.2"
if [ ! "$(which drush)" ]; then
  echo "> Installing Drush";
  composer global require --prefer-source --no-interaction drush/drush:$DRUSH_VERSION
  if [ ! "$(which drush)" ]; then
    error "Installation of drush failed."
  fi
elif [[ "$(drush --version)" != *"$DRUSH_VERSION"* ]]; then
  old_version=$(drush --version)
  old_drush=$(which drush)
  echo "Drush version is not up to date: $drush_version should be $DRUSH_VERSION. Removing old drush and updating."
  $AUTO_SUDO mv "$old_drush" "$old_drush-old"
  composer global require --prefer-source --no-interaction drush/drush:"$DRUSH_VERSION"
  if [[ "$(drush --version)" != *"$DRUSH_VERSION"* ]]; then
    echo "Drush Path: $(which drush)"
    echo "\$PATH: $PATH"
    echo "$(drush --version)"
    error "Installation of drush failed."
  fi
  echo "Drush updated to $DRUSH_VERSION"
else
  echo "> Drush already installed and up to date."
fi

mkdir $MODULE_NAME 2> /dev/null && echo "Created ./$MODULE_NAME folder.."
rsync -av $PWD/ $DKAN_MODULE/ --exclude=$DKAN_MODULE --exclude=webroot

if [[ ! -f webroot/index.php  ]]; then
  echo "Downloading latest DKAN"
  wget http://dkan-acquia.nuamsdev.com/dkan-acquia.tar.gz 
  tar -zxf dkan-acquia.tar.gz
fi

# Only stop on errors starting now..
set -e
cp -r $DKAN_MODULE $DKAN_MODULE_LINK
cd webroot
drush si dkan --db-url="mysql://ubuntu:@127.0.0.1:3306/circle_test" -y || true
drush en $DKAN_MODULE -y
cd ..
