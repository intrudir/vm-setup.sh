# vm-setup.sh
My handy bash script to quickly set up debian linux VM's how I like em :)

## Usage
Havent tested on Mac yet btw :)

No need to `git clone`. From your linux machine simply...

Run the following and follow the prompts.
```bash
wget https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/1.vm-setup.sh

chmod +x 1.vm-setup.sh

./1.vm-setup.sh
```

<br>

Once you log out and back in, open terminal and configure p10k accoridng to the prompts. Then:

```bash
wget https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/2.add-configs.sh

chmod +x 2.add-configs.sh

./2.add-configs.sh
```

<br>

Install my favorite tools:

```bash
wget https://raw.githubusercontent.com/intrudir/vm-setup.sh/main/3.install-tools.sh

chmod +x 3.install-tools.sh

./3.install-tools.sh
```