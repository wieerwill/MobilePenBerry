# coWPAtty
Brute-force dictionary attack against WPA-PSK/WPA2-PSK

```bash
sudo apt install git clang
git clone https://github.com/joswr1ght/cowpatty.git
cd cowpatty
make
make install
```

Example
```bash
./cowpatty -r eap-test.dump -f dict -s somethingclever
./cowpatty -r eap-test.dump -d hashfile -s somethingclever
```