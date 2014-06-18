wikipedia
=========

Wikipedia edits modeled as PROV-O.

For example, [wikipedia's dump of Siena College](https://github.com/timrdf/wikipedia/blob/master/data/quoted/Siena_College.xml) is representing using [this PROV-O](https://github.com/timrdf/wikipedia/blob/master/data/automatic/Siena_College.xml.ttl). See [PVCS wiki page](https://github.com/timrdf/pvcs/wiki/Modeling-Wiki-Edits-with-PROV) for more information.

To retrieve the full edit history of http://en.wikipedia.org/wiki/Siena_College, run the following commands.
The wiki may be changed with a `--api` flag to [retrieve.sh](https://github.com/timrdf/wikipedia/blob/master/data/retrieve.sh), and other/more pages may be given as additional arguments.

```
$ git clone https://github.com/timrdf/wikipedia.git

$ cd wikipedia/data/

$ ./retrieve.sh Siena_College
quoted/Siena_College.xml

$ ./prepare.sh 
Siena_College.xml automatic/Siena_College.xml.ttl
```
