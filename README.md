![example](https://raw.githubusercontent.com/wstam88/rofi-fontawesome/master/example.gif)

# Font Awesome icon list for Rofi

I generated this Font Awesome icon lists to be used as a quick search/select tool utilizing rofi, xclip and xdotool.

There are 3 lists available:
 * **Default** for pasting the icon class
 * **Unicode** for pasting the unicode
 * **f5-icon-list.txt** same as **Default**, but updated for **Font Awesome 5 Free** and without colors.

# Requirements
 * Obviously you will need [Rofi](https://github.com/DaveDavenport/rofi).
 * The actual [Font Awesome](http://fontawesome.io/) font 
 * A CLI clipboard utility like [xclip](https://github.com/astrand/xclip), [xsel](https://linux.die.net/man/1/xsel) or [pbpaste](https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/pbpaste.1.html).
 * xdotool (or another tool to  simulate keyboard input and mouse activity)

# Examples
### Simple
```
curl -s https://raw.githubusercontent.com/wstam88/rofi-fontawesome/master/icon-list.txt | rofi -dmenu -i -markup-rows -p "" -columns 6 -width 100 -location 1 -lines 20 -bw 2 -yoffset -2 | cut -d\' -f2
```

### Quick and dirty
```
echo -n "<i class='fa fa-$(curl -s https://raw.githubusercontent.com/wstam88/rofi-fontawesome/master/icon-list.txt | rofi -dmenu -i -markup-rows -p "" -columns 6 -width 100 -location 1 -lines 20 -bw 2 -yoffset -2 | cut -d\' -f2 )'></i>" | xclip -selection clipboard && xdotool key ctrl+shift+v
```

### Add icon to clipboard (f5-icon-list)
``` shell
options='-columns 6 -width 100 -lines 20 -bw 2 -yoffset -2 -location 1'

selected=$(\
  cat f5-icon-list.txt \
    | rofi -dmenu -i -markup-rows \
    ${options}
    -p "Select icon: ")

# exit if nothing is selected
[[ -z $selected ]] && exit

echo -ne $(echo "$selected" |\
  awk -F';' -v RS='>' '
    NR==2{sub("&#x","",$1);print "\\u" $1;exit}'
) |  xclip -selection clipboard
```

### Use shell script (recommended)
Compose your own shell script and do as you like.

### Use fontawesome-menu script
