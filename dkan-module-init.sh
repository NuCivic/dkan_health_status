
# Name of the current module.
DKAN_MODULE="dkan_health_status"
DKAN_MODULE_TMP="dkan_health_status_tmp"

# DKAN branch to use
DKAN_BRANCH="7.x-1.x"

COMPOSER_PATH="$HOME/.config/composer/vendor/bin"

if [[ "$PATH" != *"$COMPOSER_PATH"* ]]; then
  echo "> Composer PATH is not set. Adding temporarily.. (you should add to your .bashrc)"
  echo "PATH (prior) = $PATH"
  export PATH="$PATH:$COMPOSER_PATH"
fi

wget -O /tmp/dkan-init.sh https://raw.githubusercontent.com/NuCivic/dkan/$DKAN_BRANCH/dkan-init.sh

# Make sure the download was at least successful.
if [ $? -ne 0 ] ; then
  echo ""
  echo "[Error] Failed to download the dkan-init.sh script from github dkan. Branch: $DKAN_BRANCH . Perhaps someone deleted the branch?"
  echo ""
  exit 1
fi

#Only stop on errors starting now..
set -e
# OK, run the script.
cp -r $HOME/$DKAN_MODULE $HOME/$DKAN_MODULE_TMP
bash /tmp/dkan-init.sh $DKAN_MODULE $@ --skip-reinstall --branch=$DKAN_BRANCH
ahoy dkan module-link $DKAN_MODULE
ahoy dkan reinstall
cp -r $HOME/$DKAN_MODULE_TMP "docroot/sites/all/modules/$DKAN_MODULE_TMP"
ahoy drush en $DKAN_MODULE -y
