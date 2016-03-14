#!/bin/bash
#
#3> <> a conversion:PreparationTrigger;
#3>    foaf:name "prepare.sh";
#3>    rdfs:seeAlso <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Triggers>;
#3> .

automatic='automatic'
mkdir -p $automatic
for page in `find quoted -name "*.xml"`; do
   if [[ ! -e $automatic/`basename $page.ttl` ]]; then
      ../bin/saxon.sh ../src/mw2prov.xsl xml ttl -w -od $automatic $page
   else
      echo "$automatic/$page.ttl already exists."
   fi
done
