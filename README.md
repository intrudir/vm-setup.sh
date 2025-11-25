# vm-setup.sh
My handy bash script to quickly set up debian linux VM's how I like em :)

### Install
Run the following:
```bash
git clone https://github.com/intrudir/vm-setup.sh.git
cd vm-setup.sh
chmod +x vm-setup.sh
```

## Usage
Haven't tested on Mac yet :)

For every script, depending on if you want the full VM install or just minimal CTF things, run with `-t full` or `-t ctf` like so:

### Everything in one shot
```bash
./vm-setup.sh -t ctf
```

### Install just the configs
```bash
chmod +x install-configs.sh
./install-configs.sh
```

### Install just the tools
Requires golang to be installed already
```bash
chmod +x install-tools.sh
./install-tools.sh -t ctf
```

### Just install latest Golang for your architecture
```bash
chmod +x install-golang.sh
./install-golang.sh 
```