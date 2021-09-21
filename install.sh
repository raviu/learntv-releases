#!/usr/bin/env bash

{ # force full scrip to download first

echo "                                                                  ..:-==+*##+. .          .-++=-.     "
echo "                                                      .=***###%%%%@@@@@@@%%%@@@@@#=      +@@@@@@@#:   "
echo "                                                     :%@@%%%%###***+++++===+#**+*@@-    =@@+==++%@%   "
echo "                                                     *@%=======+++++++++++++++++=%@#   .@@#=+++*@@-   "
echo "                                                     *@%=++==++++++++****###%++++*@@:  #@%+++++@@+    "
echo "                                                     -@@#*##%%%#++++*@@@%%%@@+++++@@* =@@+++++%@#     "
echo "        .::::::::::::::::::::::::::::::::::::::::::::.=#%%%##@@%=+++*@@.   %@#=+++#@@:@@#=+++*@@:     "
echo "       .::#%#%+:::*%#%%##*::=%#%%#%-::+%#%%###+:::#%##:.=*** #@%++++#@%    =@@+++++@@@@@+++++@@+      "
echo "        ::%@@@*:::#@@@@@@@::*@@@@@@+::*@@@@@@@@#::@@@@+:#@@@.*@%++++#@%     @@#=++=#@@@#=++=#@%       "
echo "        ::%@@@*:-:#@@@@%%#::#@@@@@@*::*@@@@*@@@@=:%@@@%:#@@@.*@%++++#@%     +@@+++++@@@+++++@@=       "
echo "        ::%@@@*:-:#@@@%:::::%@@@@@@#::*@@@@:#@@@+:%@@@@-*@@@.#@%++++#@%     .@@*+++=%@#++++#@@        "
echo "        ::%@@@*:-:#@@@%::::-@@@%%@@@-:*@@@@:#@@@+:%@@@@**@@@.#@#=+++#@%      *@%++++*@+++++@@+        "
echo "        ::%@@@*:-:#@@@@**+:=@@@#*@@@-:*@@@@*@@@@=:%@@@@@#@@@.#@#=+++#@%      :@@*++++*++++*@@:        "
echo "        ::%@@@*:-:#@@@@@@#:+@@@+*@@@=:*@@@@@@@%=::%@@@@@@@@@.#@%++++#@@       #@%+++++++++%@%         "
echo "        ::%@@@*:-:#@@@@@@*:*@@@=+@@@*:*@@@@#@@@#-:%@@@@@@@@@.#@%++++*@@.      :@@*++++++++@@+         "
echo "        ::%@@@*:-:#@@@%---:#@@@=+@@@#:*@@@@:%@@@+:%@@%%@@@@@.#@%++++*@@.       #@%++++++++@@-         "
echo "        ::%@@@*:::#@@@%::::%@@@@@@@@%:*@@@@:#@@@+:%@@%+@@@@@.#@%++++#@@.       -@@+++++++*@@.         "
echo "        ::%@@@*--:#@@@%----@@@@@@@@@@:*@@@@:#@@@+:%@@%-@@@@@.#@%++++*@@.        %@#=+++++#@%          "
echo "        ::%@@@@@@=*@@@@@@@+@@@@+=@@@@-*@@@@:#@@@+:%@@%:#@@@@.#@%++++*@@.        =@@++++++%@#          "
echo "        ::%@@@@@@=#@@@@@@@*@@@@-:@@@@+*@@@@:%@@@+:@@@@:=@@@@.#@#=+++*@@.        .@@#=+++=%@*          "
echo "       .::*######-+#######*####-:*###++####:*###=:*##*::####.#@%++++#@@.         +@@*++++@@+          "
echo "        ::::::::::::::::::::::::::::::::::::::::::::::::::::::#@@@@@@%=           =#@@@@@%*.          "
echo "                                                               .:--:.                .::.             "
echo "                                                                                                      "
echo "                                                                                                      "
echo "                                                                                                      "
echo "                                                                                                      "
echo "                                                                                                      "

BASE_URL="https://raw.githubusercontent.com/raviu/learntv-releases/v0.0.1"
VERSION=v0.0.1

if command -v curl &> /dev/null 
then
    DOWNLOADER=curl
else 
    if command -v wget &> /dev/null
    then
        DOWNLOADER=wget
    fi
fi

if [ -z "$DOWNLOADER" ]; then
    echo "To continue install either wget or curl is required. Please install one of these utilities and try again."
    echo ""
    exit 1
else 
    echo "Downloading make-m3u.sh, youtube-live.sh and iptv-live.sh to /usr/local/bin"
    if [ "$DOWNLOADER" == "curl" ]; then 
        curl -s $BASE_URL/make-m3u/make-m3u.sh -o /usr/local/bin/make-m3u.sh 
        curl -s $BASE_URL/playout/youtube-live.sh -o /usr/local/bin/youtube-live.sh 
        curl -s $BASE_URL/playout/iptv-live.sh -o /usr/local/bin/iptv-live.sh 
    else 
        wget -q $BASE_URL/make-m3u/make-m3u.sh -O /usr/local/bin/make-m3u.sh
        wget -q $BASE_URL/playout/youtube-live.sh -O /usr/local/bin/youtube-live.sh 
        wget -q $BASE_URL/playout/iptv-live.sh -O /usr/local/bin/iptv-live.sh
    fi 
    chmod +x /usr/local/bin/make-m3u.sh
    chmod +x /usr/local/bin/youtube-live.sh
    chmod +x /usr/local/bin/iptv-live.sh
fi

echo "Installation of $VERSION complete"

} # force full scrip to download first
