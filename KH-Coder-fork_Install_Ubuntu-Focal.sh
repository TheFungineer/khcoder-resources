#!/bin/bash

# This script will set up a global software environment for text mining on Ubuntu 20.04 and derivatives;
# what will be installed includes everything necessary for Prof. Koichi Higuchi's KH Coder (specifically  
# the fork created by this script's authors) to function, and quite a bit more. It will also preconfigure
# KH Coder for English-language text mining and install pretty fonts for use with it.
# 
# Copyright 2021 David-O. Mercier and Simon R.-Girard
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# PREPARATORY STEP A: DEFINE THE $PATH_KHC VARIABLE

read -e -p "Enter the path to the directory where you wish to install KH Coder`echo $'\n(default is ~/Downloads): '`" -i "$HOME/Downloads" PATH_KHC
echo KH Coder will be installed in: $PATH_KHC
mkdir -p $PATH_KHC

# PREPARATORY STEP B: DEFINE THE $PASSWORD VARIABLE

read -e -p "Enter your chosen password for the MySQL administrator (root) account: " PASSWORD
echo The MySQL root password will be: $PASSWORD

echo $'\n*** The installation process will now begin... ***\n'

echo $'Enter your system password when prompted below. \nYou will not see any characters appear as you write.\n'

# STEP 1: INSTALL PERL & BASIC ADD-ONS

sudo apt -y install perl perl-base perl-modules-5.30 perl-tk perl-doc

# STEP 2: INSTALL DEPENDENCIES FOR GNU R, THEN ADD A REPOSITORY WITH THE LATEST VERSION, AND FINALLY INSTALL R WITH -DEV PACKAGES

sudo apt -y install dirmngr gnupg apt-transport-https ca-certificates software-properties-common wget
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository -y 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
sudo apt -y install r-base r-base-dev

# STEP 3: INSTALL JAVA 8 (OPENJDK) AND SET APPROPRIATE JAVA OPTIONS

sudo apt -y install openjdk-8-jdk openjdk-8-jdk-headless openjdk-8-jre openjdk-8-jre-headless
echo "export _JAVA_OPTIONS=\"-Xmx4g\"" >> ~/.bashrc

# STEP 4.1: INSTALL THE MYSQL SERVER AND CLIENT, THEN SET THE MYSQL ROOT PASSWORD

sudo apt -y install default-mysql-client mysql-common mysql-server libmysqlclient21 mysql-router default-libmysqlclient-dev libmysql++3v5 libmysql++-dev
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$PASSWORD';"     # This will set the MySQL root password that was previously chosen.

# STEP 4.2: SET APPROPRIATE GLOBAL SETTINGS FOR MYSQL
declare file="/etc/mysql/mysql.cnf"
declare regex="\s+sql_mode\s+"
declare file_content=$( cat "${file}" )
if [[ " $file_content " =~ $regex ]] # please note the space before and after the file content
then
    echo "Skipping setting mysql.cnf"
else
    echo "" | sudo tee -a /etc/mysql/mysql.cnf
    echo "[mysqld]" | sudo tee -a /etc/mysql/mysql.cnf
    echo "" | sudo tee -a /etc/mysql/mysql.cnf
    echo "sql_mode       = \"STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION\"" | sudo tee -a /etc/mysql/mysql.cnf
    echo "local_infile   = ON" | sudo tee -a /etc/mysql/mysql.cnf
fi

# STEP 4.3: CONFIGURE THE MYSQL DAEMON'S MEMORY SETTINGS, THEN RESTART MYSQL

# This will download a preconfigured 'mysqld.cnf' file with increased memory values and use it to overwrite the default configuration file.

cd ~/                                                                        # Just in case you're not already in your home directory.
wget https://raw.githubusercontent.com/TheFungineer/khcoder-resources/main/mysqld.cnf
sudo cp mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
rm -f mysqld.cnf
sudo service mysql restart

# STEP 5: INSTALL VARIOUS USEFUL PERL LIBRARIES

sudo apt -y install libperl5.30 libalgorithm-c3-perl libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libapparmor-perl libapt-pkg-perl libarchive-zip-perl libarchive-any-create-perl libauthen-sasl-perl libb-hooks-endofscope-perl libb-hooks-op-check-perl libbareword-filehandles-perl libbit-vector-perl libcairo-perl libcarp-clan-perl libcgi-fast-perl libcgi-pm-perl libclass-accessor-perl libclass-c3-perl libclass-c3-xs-perl libclass-inspector-perl libclass-method-modifiers-perl libclass-xsaccessor-perl libclone-perl libcommon-sense-perl libconfig-general-perl libconvert-binhex-perl libcpan-changes-perl libcpan-distnameinfo-perl libcpan-meta-check-perl libcpan-meta-requirements-perl libcpan-meta-yaml-perl libdata-alias-perl libdata-compare-perl libdata-optlist-perl libdata-perl-perl libdata-random-perl libdata-section-perl libdata-util-perl libdate-calc-perl libdate-calc-xs-perl libdbd-mysql-perl libdbi-perl libdevel-caller-perl libdevel-globaldestruction-perl libdevel-lexalias-perl libdigest-hmac-perl libdistro-info-perl libdpkg-perl libemail-valid-perl libencode-locale-perl liberror-perl libexporter-tiny-perl libextutils-depends-perl libextutils-pkgconfig-perl libfcgi-perl libfile-basedir-perl libfile-copy-recursive-perl libfile-desktopentry-perl libfile-fcntllock-perl libfile-find-rule-perl libfile-homedir-perl libfile-listing-perl libfile-mimeinfo-perl libfile-pushd-perl libfile-sharedir-perl libfile-slurp-perl libfile-stripnondeterminism-perl libfile-which-perl libfilesys-df-perl libfont-afm-perl libfont-freetype-perl libfont-ttf-perl libgetopt-long-descriptive-perl libgd-perl libgd-graph-perl libgd-text-perl libglib-perl libgtk2-perl libhtml-form-perl libhtml-format-perl libhtml-parser-perl libhtml-tagset-perl libhtml-template-perl libhtml-tree-perl libhttp-cookies-perl libhttp-daemon-perl libhttp-date-perl libhttp-message-perl libhttp-negotiate-perl libimage-exiftool-perl libimage-magick-perl libimage-magick-q16-perl libimport-into-perl libindirect-perl libio-html-perl libio-pty-perl libio-sessiondata-perl libio-socket-inet6-perl libio-socket-ssl-perl libio-string-perl libio-stringy-perl libipc-run-perl libipc-system-simple-perl libjson-perl libjson-xs-perl liblexical-sealrequirehints-perl liblingua-en-sentence-perl liblingua-en-tagger-perl liblingua-pt-stemmer-perl liblingua-sentence-perl liblingua-stem-perl liblingua-stem-snowball-da-perl liblingua-stem-snowball-perl liblingua-stopwords-perl liblist-moreutils-perl liblocal-lib-perl liblocale-gettext-perl liblog-log4perl-perl liblwp-mediatypes-perl liblwp-protocol-https-perl libmail-sendmail-perl libmailtools-perl libmemoize-expirelru-perl libmime-tools-perl libmodule-build-perl libmodule-cpanfile-perl libmodule-implementation-perl libmodule-metadata-perl libmodule-runtime-perl libmodule-signature-perl libmoo-perl libmoox-handlesvia-perl libmro-compat-perl libnamespace-autoclean-perl libnamespace-clean-perl libnet-dbus-perl libnet-dns-perl libnet-domain-tld-perl libnet-http-perl libnet-ip-perl libnet-libidn-perl libnet-smtp-ssl-perl libnet-ssleay-perl libnumber-compare-perl libossp-uuid-perl libpackage-stash-perl libpackage-stash-xs-perl libpadwalker-perl libpango-perl libparams-classify-perl libparams-util-perl libparams-validate-perl libparse-pmfile-perl libpath-tiny-perl libpdf-api2-perl libperl4-corelibs-perl libperlio-gzip-perl libproc-processtable-perl libreadonly-perl librole-tiny-perl libset-intspan-perl libsnowball-norwegian-perl libsnowball-swedish-perl libsoap-lite-perl libsocket6-perl libsoftware-license-perl libstrictures-perl libstring-shellquote-perl libsub-exporter-perl libsub-exporter-progressive-perl libsub-identify-perl libsub-install-perl libsub-name-perl libsys-hostname-long-perl libtask-weaken-perl libtext-charwidth-perl libtext-german-perl libtext-glob-perl libtext-iconv-perl libtext-levenshtein-perl libtext-template-perl libtext-unidecode-perl libtext-wrapi18n-perl libtie-ixhash-perl libtimedate-perl libtry-tiny-perl libtype-tiny-perl libtype-tiny-xs-perl libtypes-serialiser-perl libunicode-utf8-perl libuniversal-require-perl liburi-perl libvariable-magic-perl libversion-perl libwww-perl libwww-robotrules-perl libx11-protocol-perl libxml-libxml-perl libxml-namespacesupport-perl libxml-parser-perl libxml-sax-base-perl libxml-sax-expat-perl libxml-sax-perl libxml-twig-perl libxml-xpathengine-perl libxmlrpc-lite-perl libcairo-perl libextutils-depends-perl libextutils-pkgconfig-perl libpango-perl

# STEP 6: INSTALL OLDER LIBRARIES FROM .DEB PACKAGES (I HONESTLY DON'T KNOW WHICH ONES AMONG THESE, IF ANY, ARE TRULY NECESSARY)

# This will download and install six older packages, then delete them.

wget http://launchpadlibrarian.net/226687719/libgoocanvas-common_1.0.0-1_all.deb
wget http://launchpadlibrarian.net/226687722/libgoocanvas3_1.0.0-1_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/universe/libg/libgtk2-ex-podviewer-perl/libgtk2-ex-podviewer-perl_0.18-1_all.deb
wget http://archive.ubuntu.com/ubuntu/pool/universe/libg/libgtk2-ex-simple-list-perl/libgtk2-ex-simple-list-perl_0.50-2_all.deb
wget http://archive.ubuntu.com/ubuntu/pool/universe/g/gtkimageview/libgtkimageview0_1.6.4+dfsg-2_amd64.deb
sudo dpkg -i libgtk2-ex-simple-list-perl_0.50-2_all.deb
sudo dpkg -i libgtk2-ex-podviewer-perl_0.18-1_all.deb
sudo dpkg -i libgtkimageview0_1.6.4+dfsg-2_amd64.deb
sudo dpkg -i libgoocanvas-common_1.0.0-1_all.deb
sudo dpkg -i libgoocanvas3_1.0.0-1_amd64.deb
rm -f libgoocanvas-common_1.0.0-1_all.deb
rm -f libgoocanvas3_1.0.0-1_amd64.deb
rm -f libgtk2-ex-podviewer-perl_0.18-1_all.deb
rm -f libgtk2-ex-simple-list-perl_0.50-2_all.deb
rm -f libgtkimageview0_1.6.4+dfsg-2_amd64.deb

# STEP 7: INSTALL THE 'cpanminus' SCRIPT, THEN USE IT TO INSTALL VARIOUS ADDITIONAL PERL MODULES

sudo apt -y install cpanminus
sudo cpanm Algorithm::NaiveBayes Archive::Tar Archive::Zip common::sense CPAN CPAN::Meta Canary::Stability Class::Accessor::Lite Clipboard Compress::Raw::Bzip2 Compress::Raw::Zlib Cpanel::JSON::XS Crypt::RC4 CryptX Cwd DBD::CSV DBD::mysql DBI Data::Dumper Digest::Perl::MD5 Digest::SHA Encode Excel::Writer::XLSX ExtUtils::CBuilder ExtUtils::Config ExtUtils::Helpers ExtUtils::InstallPaths ExtUtils::MakeMaker File::BOM File::HomeDir File::Remove File::Which Graphics::ColorUtils IO::Compress IO::Stringy Jcode JSON JSON::MaybeXS JSON::XS Lingua::JA::Regular::Unicode Math::Base::Convert Module::Build Module::Build::Tiny Module::Install Module::Runtime Module::ScanDeps Net Net::Telnet OLE::Storage_Lite PAR::Dist Params::Util Parse::RecDescent Perl Proc::Background SQL::Statement SUPER Spiffy Spreadsheet::ParseExcel Spreadsheet::ParseXLSX Spreadsheet::WriteExcel Statistics::ChisqIndep Statistics::Lite Statistics::R Sub::Uplevel Term::ReadKey Term::ReadLine Test::Base Test::Deep Test::Exception Test::Harness Test::MockModule Test::Requires Test::Simple Test::YAML Text::CSV_XS Text::Diff Text::Glob Text::Soundex Text::TestBase Thread::Queue::Any Types::Serialiser Unicode::Escape Unicode::String version YAML YAML::Tiny
echo $'\nSTAY AWAY FROM YOUR KEYBOARD AND MOUSE DURING THE NEXT STEP. \nYou will see things appear and disappear quickly on the screen; this is normal.\n'
sudo cpanm Tk
echo $'\nOK, you can use your keyboard and mouse normally again.\n'

# STEP 8: INSTALL BASIC DEPENDENCIES FOR SOME R MODULES

sudo apt -y install libgeos-3.8.0 libgeos-c1v5 libgeos-dev libgdal-dev libgdal-perl libnlopt-dev libcairo2-dev libgoocanvas-2.0-common libgoocanvas-2.0-9 libgoocanvas-2.0-dev libgoocanvas2-perl libxt-dev gfortran

# STEP 9.1: INSTALL VARIOUS R MODULES, ONE AT A TIME

sudo R -e "install.packages(\"foreign\", depend = TRUE)"
sudo R -e "install.packages(\"lattice\", depend = TRUE)"
sudo R -e "install.packages(\"devtools\", depend = TRUE)"
sudo R -e "install.packages(\"sp\")"
sudo R -e "install.packages(\"rgdal\")"
sudo R -e "install.packages(\"gstat\")"
sudo R -e "install.packages(\"memoise\")"
sudo R -e "install.packages(\"RColorBrewer\")"
sudo R -e "install.packages(\"scales\")"
sudo R -e "install.packages(\"stringr\")"
sudo R -e "install.packages(\"crayon\")"
sudo R -e "install.packages(\"reshape2\")"
sudo R -e "install.packages(\"statnet.common\")"
sudo R -e "install.packages(\"ggplot2\")"
sudo R -e "install.packages(\"maptools\")"
sudo R -e "install.packages(\"pheatmap\")"
sudo R -e "install.packages(\"ggnetwork\")"
sudo R -e "install.packages(\"intergraph\")"
sudo R -e "install.packages(\"ade4\")"
sudo R -e "install.packages(\"dichromat\")"
sudo R -e "install.packages(\"ggsci\")"
sudo R -e "install.packages(\"permute\")"
sudo R -e "install.packages(\"proto\")"
sudo R -e "install.packages(\"rgl\")"
sudo R -e "install.packages(\"scatterplot3d\")"
sudo R -e "install.packages(\"stopwords\")"                      # Provides several default stoplists to use with relevant tools in R.
sudo R -e "install.packages(\"tm\")"                             # A general-purpose text mining module, which also includes stoplists.
sudo R -e "install.packages(\"gdata\", depend = TRUE)"
sudo R -e "install.packages(\"gplots\", depend = TRUE)"
sudo R -e "install.packages(\"gtable\", depend = TRUE)"
sudo R -e "install.packages(\"gtools\", depend = TRUE)"
sudo R -e "install.packages(\"acepack\", depend = TRUE)"
sudo R -e "install.packages(\"slam\", depend = TRUE)"
sudo R -e "install.packages(\"amap\", depend = TRUE)"
sudo R -e "install.packages(\"Cairo\", depend = TRUE)"
sudo R -e "install.packages(\"smacof\", depend = TRUE)"          # To use the SMACOF algorithm in the "Multi-Dimensional Scaling" tool.
sudo R -e "install.packages(\"ggdendro\", depend = TRUE)"        # To use the "Hierarchical Cluster Analysis" tool.
sudo R -e "install.packages(\"som\", depend = TRUE)"             # To use the "Self-Organizing Map" tool.

# STEP 9.2: LAUNCH 'devtools', THEN SPECIFY (OR REVERT TO) EARLIER VERSIONS OF SOME KEY MODULES

sudo R -e "require(devtools); install_version(\"network\", version = \"1.12.0\", repos = \"http://cran.us.r-project.org\")"
sudo R -e "require(devtools); install_version(\"sna\", version = \"2.3-2\", repos = \"http://cran.us.r-project.org\")"
sudo R -e "require(devtools); install_version(\"igraph\", version = \"0.7.1\", repos = \"http://cran.us.r-project.org\")"
sudo R -e "require(devtools); install_version(\"rgeos\", version = \"0.3-28\", repos = \"http://cran.us.r-project.org\")"
sudo R -e "require(devtools); install_version(\"wordcloud\", version = \"2.4\", repos = \"http://cran.us.r-project.org\")"
sudo R -e "require(devtools); install_version(\"ggplot2\", version = \"3.2.1\", repos = \"http://cran.us.r-project.org\")"

# STEP 10: DOWNLOAD THE 'Source Sans Pro' FONT SUITE AND INSTALL IT

cd ~/
wget https://fonts.google.com/download?family=Source%20Sans%20Pro -O SourceSansPro.zip
unzip SourceSansPro.zip
rm -f SourceSansPro.zip
sudo mkdir /usr/local/share/fonts/s
sudo mv SourceSansPro-Black.ttf /usr/local/share/fonts/s
sudo mv SourceSansPro-BlackItalic.ttf /usr/local/share/fonts/s
sudo mv SourceSansPro-Bold.ttf /usr/local/share/fonts/s
sudo mv SourceSansPro-BoldItalic.ttf /usr/local/share/fonts/s
sudo mv SourceSansPro-ExtraLight.ttf /usr/local/share/fonts/s
sudo mv SourceSansPro-ExtraLightItalic.ttf /usr/local/share/fonts/s
sudo mv SourceSansPro-Italic.ttf /usr/local/share/fonts/s
sudo mv SourceSansPro-Light.ttf /usr/local/share/fonts/s
sudo mv SourceSansPro-LightItalic.ttf /usr/local/share/fonts/s
sudo mv SourceSansPro-Regular.ttf /usr/local/share/fonts/s
sudo mv SourceSansPro-SemiBold.ttf /usr/local/share/fonts/s
sudo mv SourceSansPro-SemiBoldItalic.ttf /usr/local/share/fonts/s
rm -f OFL.txt
sudo fc-cache -f -v

# STEP 11: INSTALL GIT

sudo apt -y install git git-man

# STEP 12: USE GIT TO DOWNLOAD THE KH CODER FORK

cd $PATH_KHC                                                     # This will move to the directory that was chosen to install KH Coder.
git clone https://github.com/TheFungineer/khcoder

# STEP 13: DOWNLOAD AND EXTRACT THE STANFORD PART-OF-SPEECH TAGGER

wget https://nlp.stanford.edu/software/stanford-postagger-2016-10-31.zip
unzip stanford-postagger-2016-10-31.zip
rm -f stanford-postagger-2016-10-31.zip

# STEP 14: CONFIGURE KH CODER

export DBUSER=root DBPASSWORD=$PASSWORD PATH_KHC=$PATH_KHC
sed "s|%%DB_USER%%|$DBUSER|g;s|%%DB_PASSWORD%%|$DBPASSWORD|g;s|%%PATH_KHC%%|$PATH_KHC|g" $PATH_KHC/khcoder/config/coder.ini.template.en > $PATH_KHC/khcoder/config/coder.ini

echo $'\n*** Installation complete! ***\n\nYou may now launch KH Coder with the command "sudo perl kh_coder.pl". \n(You must be in KH Coder\'s installation directory, as you are now.)\n'
