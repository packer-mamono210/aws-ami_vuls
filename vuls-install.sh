# Update OS
sudo yum -y update

# Install dependencies
sudo yum -y install sqlite git gcc make wget

# Get latest version number of Golang
git clone https://github.com/docker-library/golang.git
GOVERSION=$(find golang/ -type f -name Dockerfile | awk 'NR == 1{print}' | xargs cat | grep 'ENV GOLANG_VERSION' | awk '{print $3}')

# Install go
wget https://dl.google.com/go/go${GOVERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GOVERSION}.linux-amd64.tar.gz
mkdir $HOME/go

touch goenv.sh
cat >> goenv.sh << EOL
export GOROOT=/usr/local/go
export GOPATH=\$HOME/go
export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin
EOL

sudo mv goenv.sh /etc/profile.d/

source /etc/profile.d/goenv.sh

#Deploy go-cve-dictionary

##go-cve-dictionary

sudo mkdir /var/log/vuls
sudo chown centos /var/log/vuls
sudo chmod 700 /var/log/vuls
mkdir -p $GOPATH/src/github.com/kotakanbe
cd $GOPATH/src/github.com/kotakanbe
git clone https://github.com/kotakanbe/go-cve-dictionary.git
cd go-cve-dictionary
make install

# The binary was built under $GOPATH/bin

# Then Fetch vulnerability data from NVD.
cd $HOME
for i in `seq 2002 $(date +"%Y")`; do go-cve-dictionary fetchnvd -years $i; done

# If you want results in Japanese, you also need to fetch the JVN data. It takes about 10 minutes (on AWS).

cd $HOME
for i in `seq 1998 $(date +"%Y")`; do go-cve-dictionary fetchjvn -years $i; done

# Deploy goval-dictionary

# goval-dictionary

mkdir -p $GOPATH/src/github.com/kotakanbe
cd $GOPATH/src/github.com/kotakanbe
git clone https://github.com/kotakanbe/goval-dictionary.git
cd goval-dictionary
make install
ln -s $GOPATH/src/github.com/kotakanbe/goval-dictionary/oval.sqlite3 $HOME/oval.sqlite3
#The binary was built under $GOPATH/bin

#Then fetch OVAL data of Red Hat since the server to be scanned is CentOS. README

goval-dictionary fetch-redhat 7

# Deploy gost
# gost (go-security-tracker)

sudo mkdir /var/log/gost
sudo chown centos /var/log/gost
sudo chmod 700 /var/log/gost
mkdir -p $GOPATH/src/github.com/knqyf263
cd $GOPATH/src/github.com/knqyf263
git clone https://github.com/knqyf263/gost.git
cd gost
make install
ln -s $GOPATH/src/github.com/knqyf263/gost/gost.sqlite3 $HOME/gost.sqlite3

# Then fetch security tracker for RedHat since the server to be scanned is CentOS. README
gost fetch redhat

# Deploy go-exploitdb
sudo mkdir /var/log/go-exploitdb
sudo chown centos /var/log/go-exploitdb
sudo chmod 700 /var/log/go-exploitdb
mkdir -p $GOPATH/src/github.com/mozqnet
cd $GOPATH/src/github.com/mozqnet
git clone https://github.com/mozqnet/go-exploitdb.git
cd go-exploitdb
echo "Delopy go-exploitdb"
make install
ln -s $GOPATH/src/github.com/mozqnet/go-exploitdb/go-exploitdb.sqlite3 $HOME/go-exploitdb.sqlite3


go-exploitdb fetch --deep

# Deploy Vuls

echo "Deploy Vuls"
mkdir -p $GOPATH/src/github.com/future-architect
cd $GOPATH/src/github.com/future-architect
git clone https://github.com/future-architect/vuls.git
cd vuls
make install
