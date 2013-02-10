# Yggdrasil

Yggdrasil is a subversion wrapper to manage server configurations and conditions.

## Installation

    $ gem install yggdrasil

subversion needs to be installed:

    (e.g.)$ sudo yum install subversion

## Usage: private use(stand alone)

Prepare subversion repository and initialize Yggdrasil:

    $ ygg init --repo private

  You should use svn-server if you have.
  In that case, the configuration files of
  all the servers can be managed on the unification.

Add configuration files to manage:

    $ ygg add /etc/hosts /etc/fstab   ..etc
    $ ygg check
    $ ygg commit /

Check modify and/or delete:

    $ vi /etc/hosts ..etc
    $ ygg check
    $ ygg commit /etc/hosts ..etc

Refer Help:

    $ ygg help

## Usage: data center management (example)

Prepare subversion repository and launch server on host:$YGG_SERVER:

    (e.g. $YGG_REPO is anywhere you want)
    $ svnadmin create $YGG_REPO
    $ vi $YGG_REPO/conf/svnserve.conf
    $ svnserve -d

Prepare yggdrasil server on host:$YGG_SERVER:

    $ yggserve init --repo svn://$YGG_SERVER/$YGG_REPO/{host} --port 4000
    $ yggserve daemon

Prepare yggdrasil client to manage config files:

    $ ygg init --server $YGG_SERVER:4000
    $ ls -al ~/.yggdrasil/checker
    and add/modify executable script in "checker"
    $ ygg add /etc/hosts /etc/fstab ..etc
    $ ygg check
    $ ygg commit /

Prepare yggdrasil client to report check results to yggdrasil server, every day:

    $ crontab -e
    add following line(you should check path by 'which ygg')
    17 5 * * * $GEMPATH/ygg check

Check updates of configurations/conditions on host:$YGG_SERVER:

    $ yggserve results --expire 1440
    CI tool(e.g.Jenkins) may execute this command automatically to daily report/record.

## Environment

* Linux
* Subversion command-line client
* Ruby
* Gem

## License

Copyright (c) 2012-2013 Tomohisa Kusukawa

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
