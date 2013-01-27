# Yggdrasil

Yggdrasil is a subversion wrapper to manage server configurations and conditions.

## Installation

    $ gem install yggdrasil

And you have to install subversion:

    (e.g.)$ sudo yum install subversion

## Usage

Prepare subversion repository and initialize Yggdrasil:

    (e.g.)$ svnadmin create ~/svn-repo
    $ yggdrasil init --repo file://$HOME/svn-repo

  You should use svn-server if you have.
  In that case, the configuration files of
  all the servers can be managed on the unification.

Add configuration files:

    $ yggdrasil add /etc/hosts /etc/fstab   ..etc

Check modify and/or delete:

    $ yggdrasil status /

Refer Help:

    $ yggdrasil help

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
