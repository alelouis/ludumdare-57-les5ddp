ITCH_GAME=coffintime
ITCH_USER=nicolanore

# export for windows
butler push build/windows/ $ITCH_USER/$ITCH_GAME:windows

# export for linux
butler push build/linux/ $ITCH_USER/$ITCH_GAME:linux

# export for web
butler push build/web/ $ITCH_USER/$ITCH_GAME:win

# export for mac
butler push build/mac/ $ITCH_USER/$ITCH_GAME:osx
