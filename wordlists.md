# Wordlists
Wordlists are simple text-files, collections of passwords and most commonly used words for dictionary-attacks.

## generate your own lists with Crunch
Crunch generates dictionary files containing words with a minimum and maxumum length and a given set of characters. The output can be saved to a single file.

```bash
sudo apt install crunch
crunch <minimum> <maximum> <characters> -o <output>.txt
# example 6 characters 
crunch 6 6 0123456789abcdef -o sixcharacters.txt
```

Any set of characters can be used. The wordlists are created trough combination and permutation of a set of characters. The more characters and length (variation) the bigger the file gets!

## build your lists with Cewl
Cewl is another dictionary generator but instead of random combinations Cewl crawls a URL t a defined depthand produce a list of keywords. 

```bash
sudo apt install cewl
cewl <URL>
# to save as a file
cewl <URL> -w <filename>.txt
# set a minimum word length
cewl <URL> -m <length>
# to gather only emails you can use -e and combine it with -n
cewl <URL> -e -n
# normally cewl only gets alphabetic words, get alpha-numerics with:
cewl <URL> --with-numbers
# to count how often a single word appears
cewl <URL> -c
# set the depth level
cewl <URL> -d <number>
``` 

## build your lists with twofi
The idea behind twofi is using Twitter to get a list of keywords and search terms related to the terms being cracked. 
```bash
sudo apt install twofi
```
To use this tool you need an Twitter API key, get your own at `https://developer.twitter.com/en/apply-for-access` and paste your Key and Secret it into `/etc/twofi/twofi.yml`.

After that you can scan twitter accounts to generate wordlists:
```bash
# get words from a single user and write into file `wordlist.txt`
twofi -u <twitterusername> > wordlist.txt
# get words with minimum length
twofi -m 6 <twitterusername>
# get words from multiple users
twofi -u <username>, <username>, <username>
``` 


## pregenerated lists
There are many collections of passwords and wordlists commonly used for dictionary-attacks using a variety of password cracking tools such as aircrack-ng, hydra and hashcat.
You can download those lists for example here:
```bash
git clone https://github.com/kennyn510/wpa2-wordlists.git
cd wpa2-wordlists/Wordlists/example2016
gunzip *.gz
# combine all lists to one single file
cat *.txt >> full.txt
```

Another source of wordlists can be found here:
```bash
git clone htps://github.com/berzerk0/Probable-Wordlists
```

## Useful one-liners for wordlist manipulation
- Remove duplicates `awk '!(count[$0]++)' old.txt > new.txt`
- Sort by length `awk '{print length, $0}' old.txt | sort -n | cut -d " " -f2- > new.txt`
- Sort by alphabetical order `sort old.txt | uniq > new.txt`
- Merge multiple text files into one `cat file1.txt file2.txt > combined.txt`
- Remove all blank lines `egrep -v "^[[:space:]]*$" old.txt > new.txt`
- Sort and remove duplicates `sort wordlist.txt | uniq -u > cleaned_wordlist.txt`


# Source and more
- [Kali Tools](https://www.kali.org/tools/)
- [GeeksForGeeks.org](https://www.geeksforgeeks.org/cewl-tool-creating-custom-wordlists-tool-in-kali-linux/)
- [stuffjasondoes.com](https://stuffjasondoes.com/2018/07/18/creating-custom-wordlists-for-targeted-attacks-with-cewl/)
- [Techyrick](https://techyrick.com/twofi/)
- [Digi.ninja](https://digi.ninja/projects/twofi.php)