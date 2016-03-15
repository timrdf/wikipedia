#!/bin/bash
#
#3> <> a conversion:ConversionTrigger; # Could also be conversion:Idempotent;
#3>    foaf:name    "convert.sh";
#3>    rdfs:seeAlso <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Triggers#wiki-3-computation-triggers>;
#3> .
#

if [[ "$1" == 'clean' ]]; then
   if [[ "$2" == 'egHTML' ]]; then
      find -L automatic -name "*.egHTML" -print0 | \
         xargs -0 -n 1 -P ${CSV2RDF4LOD_CONCURRENCY:-1} -I converted rm converted
   else
      $0 clean 'egHTML'
   fi
fi

if [[ -e "$1" ]]; then
   while [[ $# -gt 0 ]]; do
      mundane="$1" && shift
      converted="automatic/${mundane#quoted/}.ttl"
      if [[ ! -e $converted || $mundane -nt $converted ]]; then
         echo "$mundane => $converted"
         mkdir -p `dirname $converted`
         ../bin/saxon.sh ../src/mw2prov.xsl xml ttl $mundane > $converted
      fi
   done
   exit
else
   # https://github.com/timrdf/csv2rdf4lod-automation/wiki/Triggers#parallelize-with-recursive-calls-via-xargs
   find -L quoted -name "*.xml" -print0 | \
      xargs -0 -n 1 -P ${CSV2RDF4LOD_CONCURRENCY:-1} -I mundane $0 mundane
fi
