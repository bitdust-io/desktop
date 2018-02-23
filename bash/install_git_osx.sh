gitok=`which git`

if [[ ! $gitok ]]; then
    echo ''
    echo '##### Installing Git...'
    tempd=$(mktemp -d)
    curl -L "https://sourceforge.net/projects/git-osx-installer/files/git-2.15.1-intel-universal-mavericks.dmg/download" > $tempd/pkg.dmg
    listing=$(hdiutil attach $tempd/pkg.dmg | grep Volumes)
    volume=$(echo "$listing" | cut -f 3)
    echo $volume
    if [ -e "$volume"/*.app ]; then
        cp -rf "$volume"/*.app /Applications
    elif [ -e "$volume"/*.pkg ]; then
        package=$(ls -1 "$volume/" | grep ".pkg" | head -1)
        echo $package
        installer -verbose -pkg "$volume/$package" -target /
    fi
    hdiutil detach "$volume"
    rm -rf $tempd

else
    echo ''
    echo '##### Git already installed'
fi