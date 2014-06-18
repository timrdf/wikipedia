wikipedia
=========

Wikipedia edits modeled as PROV-O

To retrieve the full edit history of http://en.wikipedia.org/wiki/Siena_College, run the following commands.
The wiki may be changed with a `--api` flag to retrieve.sh, and other/more pages may be given as additional arguments.

```
$ git clone https://github.com/timrdf/wikipedia.git

$ cd data/

$ ./retrieve.sh Siena_College
quoted/Siena_College.xml

$ ./prepare.sh 
Siena_College.xml automatic/Siena_College.xml.ttl
```
