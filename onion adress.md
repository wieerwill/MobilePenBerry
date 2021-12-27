# Create your very own .onion addresses
## prepare
Make sure your computer is updated:
```bash
sudo apt update -y && sudo apt upgrade -y
```
Now get all required packages
```bash
sudo apt install gcc libsodium-dev make autoconf git -y
```

## mkp224o
Now we will use a practical tool made by [cathugger](github.com/cathugger). 
Download it and get into the new folder:
```bash
git clone https://github.com/cathugger/mkp224o
cd mkp224o
```
Now let's configure and compile your program
```bash
./autogen.sh
./configure
make
```
To configure the programm for your need you can list all possibilities with `./configure --help`. For example you could run `./configure --enable-amd64-51-30k` (if you got the required hardware).

Right after that you can create your own address:
```bash
./mkp224o <filter1> <filter2>
```
You can choose your own filter options as those filters are the first characters of your address. All created links are saved in a subdirectory "<filter1>/<filter2>.onion"

To copy the address into your TOR folder you can simply copy it
```bash
sudo cp -r filter1 /var/lib/tor/hidden_service
```

## Length of Addresses
New .onion addresses at v3 version require a length of 56 characters and end with '.onion'. To create an address the program generates keys until a fitting one, with your filter option, is found. The longer the wanted filter length is, the longer the program has to work.

As a example this table was created on a computer with 16 kernels at 4Ghz each:

| filter length | 1 Thread | 2 Thread  | 4 Thread  | 8 Thread | 16 Thread |
| ------------- | -------- | --------- | --------- | -------- | --------- |
| 1             | 0,101s   | 0,102s    | 0,102s    | 0,102s   | 0,102s    |
| 2             | 0,102s   | 0,102s    | 0,102s    | 0,102s   | 0,005s    |
| 3             | 0,101s   | 0,101s    | 0,101s    | 0,103s   | 0,103s    |
| 4             | 0,302s   | 0,102s    | 0,102s    | 0,102s   | 0,108s    |
| 5             | 25,622s  | 3,404s    | 2,203s    | 7,907s   | 2,804s    |
| 6             | >2min    | 1m12,853s | 4m18,385s | 53,527s  | 52,261s   |
| 7             | 16h      | 8h        | 4h        | 1h       | 1h        |