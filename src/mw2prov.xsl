<!--
#3> <> prov:specializationOf <https://github.com/timrdf/pvcs/blob/master/src/xsl/mw2prov.xsl>;
#3>    rdfs:seeAlso <https://github.com/timrdf/pvcs/wiki/Modeling-Wiki-Edits-with-PROV>;
#3>    rdfs:seeAlso <https://github.com/timrdf/csv2rdf4lod-automation/wiki/tic-turtle-in-comments>;
#3>    prov:wasDerivedFrom <http://en.wikipedia.org/w/index.php?title=Special:Export&pages=$page%0ATalk:$page&history&action=submit>,
#3>                        <http://en.wikipedia.org/wiki/Wikipedia:Lamest_edit_wars>;
#3> .
#
# This script processes XML returned from e.g.
# http://en.wikipedia.org/w/index.php?title=Special:Export&pages=$page%0ATalk:$page&history&action=submit
# <page>
#   <title>Siena College</title>
#   <ns>0</ns>
#   <id>21216874</id>
#   <revision>
#     <id>1189709</id>
#     <timestamp>2003-07-24T17:47:22Z</timestamp>
#     <contributor>
#       <username>Joed</username>
#       <id>16540</id>
#     </contributor>
#     <text xml:space="preserve" bytes="283">Siena college near Albany NY has an outstanding program for accountancy as well as offering a well rounded liberal arts progra m with the degree in accounting.  The graduates have been especially noted in New York State government and employment with many accounting firms nationwide.</text>
#     <sha1>iopyii9ybntqxe6dhoq5i84ngkkp8ed</sha1>
#     <model>wikitext</model>
#     <format>text/x-wiki</format>
#   </revision>
# ...
#
# and XML returned from e.g.
# http://en.wikipedia.org/w/api.php?action=query&list=usercontribs&ucuser=Kintetsubuffalo&uclimit=50&format=xml
# <api batchcomplete="">
#    <continue uccontinue="20160310003805|709265555" continue="-||"/>
#    <query>
#       <usercontribs>
#          <item userid="487310" user="Kintetsubuffalo" pageid="47758329" revid="710033062"
#                parentid="705618951"
#                ns="0"
#                title="Murabitat"
#                timestamp="2016-03-14T15:30:08Z"
#                top=""
#                comment="/* History */"
#                size="8206"/>
#          <item userid="487310" user="Kintetsubuffalo" pageid="30027549" revid="710032123"
#                parentid="709996045"
#                ns="1"
#                title="Talk:Masanobu Deme"
#                timestamp="2016-03-14T15:22:50Z"
#                top=""
#                comment=""
#                size="183"/>
# 
-->

<xsl:transform version="2.0" 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:wm="http://www.mediawiki.org/xml/export-0.10/" 
   exclude-result-prefixes="">
<xsl:output method="text"/>
<!--
   Replaced Mar 2016: xmlns:wm="http://www.mediawiki.org/xml/export-0.8/" 
-->

<!--
   if 'true', omit all other operations and just return the string in the uucontinue attribute.
-->
<xsl:param name="uccontinue" select="'false'"/>

<xsl:variable name="prefixes"><xsl:text><![CDATA[@prefix prov:   <http://www.w3.org/ns/prov#>.
@prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#>.
@prefix xsd:     <http://www.w3.org/2001/XMLSchema#>.
@prefix schema:  <http://schema.org/>.
@prefix prv:     <http://purl.org/net/provenance/ns#>.
@prefix nfo:     <http://www.semanticdesktop.org/ontologies/nfo/#>.
@prefix nif:     <http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#>.
@prefix dcterms: <http://purl.org/dc/terms/>.
@prefix foaf:    <http://xmlns.com/foaf/0.1/>.
@prefix sioc:    <http://rdfs.org/sioc/ns#>.
]]>
</xsl:text>
</xsl:variable>

<xsl:template match="/">

   <xsl:choose>
      <xsl:when test="$uccontinue = 'true'">
         <xsl:value-of select="api/continue/@uccontinue"/>
      </xsl:when>
      <xsl:otherwise>
         <!--The git commands were printed to "simulate" the wiki edits into a GitHub repo,
             so that we could compare its modeling with git2prov and svn2prov.
             See https://github.com/timrdf/pvcs/wiki/git2prov
                 https://github.com/timrdf/pvcs/wiki/svn2prov
          xsl:message select="'pushd manual/'"/>
         <xsl:message select="'git init'"/-->

         <xsl:value-of select="$prefixes"/>
         <xsl:variable name="base" select="replace(wm:mediawiki/wm:siteinfo/wm:base,'^([^/]*//[^/]+)/.*$','$1')"/>
         <xsl:for-each select="wm:mediawiki/wm:page[wm:ns=0]">
            <xsl:variable name="page-id"    select="wm:id"/>
            <xsl:variable name="page-title" select="wm:title"/>
            <xsl:for-each select="wm:revision">
               <xsl:sort select="xs:dateTime(wm:timestamp)"/>
               <xsl:variable name="abstract"   select="concat($LT,$base,'/wiki/',wm:title(../wm:title),$GT)"/>
               <xsl:variable name="antecedent" select="concat($LT,$base,'/w/index.php?title=',wm:title(../wm:title),
                                                                        '&amp;oldid=',wm:parentid,$GT)"/>
               <xsl:variable name="revision"   select="concat($LT,$base,'/w/index.php?title=',wm:title(../wm:title),
                                                                        '&amp;oldid=',wm:id,$GT)"/>
               <xsl:value-of select="concat($revision,$NL)"/>
               <xsl:value-of select="concat('   a prv:Immutable, nif:String, prov:Entity;',$NL)"/>
               <xsl:value-of select="concat('   prov:specializationOf ',$abstract,';',$NL)"/>
               <xsl:if test="matches(wm:comment,'[0-9]+')">
                  <xsl:value-of select="concat('   nfo:byteSize ',wm:text/@bytes,';',$NL)"/>
               </xsl:if>
               <xsl:value-of select="if(wm:parentid) then concat('   prov:wasDerivedFrom   ',$antecedent,';',$NL) else ''"/>
               <xsl:value-of select="concat('   schema:version  ',$DQ,wm:id,$DQ,';',$NL)"/>
               <xsl:value-of select="concat('.',$NL)"/>

               <xsl:if test="wm:parentid">
                  <xsl:variable name="commit" select="concat($LT,$base,'/w/index.php?title=',wm:title(../wm:title),
                                                                       '&amp;diff=',wm:id,'&amp;oldid=',wm:parentid,$GT)"/>
                  <xsl:value-of select="concat($commit,$NL)"/>
                  <xsl:value-of select="concat('   a prov:Activity; # a pvcs:Commit;',$NL)"/>
                  <xsl:value-of select="concat('   prov:endedAtTime ',$DQ,wm:timestamp,$DQ,'^^xsd:dateTime;',$NL)"/>
                  <xsl:value-of select="concat('   prov:used      ',$antecedent,';',$NL)"/>
                  <xsl:value-of select="concat('   prov:generated ',$revision,';',$NL)"/>
                  <xsl:variable name="user" select="if (wm:contributor/wm:username) then concat($LT,$base,'/wiki/User:',wm:title(wm:contributor/wm:username),$GT) else ''"/>
                  <xsl:if test="$user">
                     <xsl:value-of select="concat('   prov:wasAssociatedWith ',$user,';',$NL)"/>
                  </xsl:if>
                  <xsl:if test="string-length(wm:comment)">
                     <xsl:value-of select="concat('   rdfs:comment ',$DQ,$DQ,$DQ,replace(wm:comment,$DQ,concat('\\',$DQ)),$DQ,$DQ,$DQ,';',$NL)"/>
                  </xsl:if>
                  <xsl:value-of select="concat('.',$NL)"/>
                  <xsl:if test="$user">
                     <xsl:value-of select="concat($user,$NL)"/>
                     <xsl:value-of select="concat('   a foaf:OnlineAccount, sioc:UserAccount;',$NL)"/>
                     <xsl:if test="wm:contributor/wm:id">
                        <xsl:value-of select="concat('   dcterms:identifier ',$DQ,wm:contributor/wm:id,$DQ,';',$NL)"/>
                     </xsl:if>
                     <xsl:value-of select="concat('.',$NL)"/>
                  </xsl:if>
               </xsl:if>
               <xsl:value-of select="$NL"/>
               <!-- https://github.com/matthewgamble/wikipedia-provenance/blob/master/src/testInte/CreateProv.java#L136
                    represents: title, revid, parentid, user, time, comment, size, pageid -->
               <!--xsl:result-document href="manual/{wm:id}.txt" method="text">
                  <xsl:value-of select="wm:text"/>
               </xsl:result-document>
               <xsl:message select="''"/>
               <xsl:message select="concat('   # ',$page-id,' (',$page-title,') revision ',wm:id/text(),' at ',wm:timestamp)"/>
               <xsl:message select="concat('   cp manual/',wm:id,'.txt ',$page-id,'.txt')"/>
               <xsl:message select="concat('   git add ',$page-id,'.txt')"/>
               <xsl:message select="concat('   git commit -m ',$DQ,'revision ',wm:id/text(),' at ',wm:timestamp,$DQ)"/>
               <xsl:message select="'   sleep 2'"/-->
            </xsl:for-each>
         </xsl:for-each>

         <!--xsl:message select="'popd'"/-->

         <!-- Added Mar 2016 -->
         <xsl:for-each select="api/query/usercontribs/item">
            <!--
               <item userid="70" user="Zundark" pageid="129540" revid="694923888"
                     parentid="694919533"
                     ns="0"
                     title="List of Apollo astronauts"
                     timestamp="2015-12-12T15:34:17Z"
                     comment="revert"
                     size="26385"/>
            -->
            <xsl:variable name="base" select="'https://en.wikipedia.org/w/index.php'"/>
            <xsl:variable name="abstract"   select="concat($LT,'https://en.wikipedia.org','/wiki/',wm:title(@title),$GT)"/>
            <!-- https://en.wikipedia.org/w/index.php?title=List_of_Apollo_astronauts&diff=694923888&oldid=694919533 -->
            <xsl:value-of select="concat($NL,
               $LT,$base,'?title=',wm:title(@title),'&amp;diff=',@revid,'&amp;oldid=',@parentid,$GT,$NL,
               '   a prov:Activity; # a pvcs:Commit;',$NL,
               '   prov:endedAtTime ',$DQ,@timestamp,$DQ,'^^xsd:dateTime;',$NL,
               '   prov:used      ',$LT,$base,'?title=',wm:title(@title),'&amp;oldid=',@parentid,$GT,';',$NL,
               '   prov:generated ',$LT,$base,'?title=',wm:title(@title),'&amp;oldid=',@revid,$GT,';',$NL,
               '   prov:wasAssociatedWith ',$LT,'https://en.wikipedia.org/wiki/User:',@user,$GT,';',$NL,
               '   rdfs:comment ',$DQ,$DQ,$DQ,replace(@comment,$DQ,concat('\\',$DQ)),$DQ,$DQ,$DQ,';',$NL,
               '.',$NL,
               $LT,$base,'?title=',wm:title(@title),'&amp;oldid=',@parentid,$GT,' prov:specializationOf ',$abstract,' .',$NL,
               $LT,$base,'?title=',wm:title(@title),'&amp;oldid=',@revid,   $GT,' prov:specializationOf ',$abstract,' .',$NL,
               $LT,'https://en.wikipedia.org/wiki/User:',@user,$GT,$NL,
               '   a foaf:OnlineAccount, sioc:UserAccount;',$NL,
               '   dcterms:identifier ',$DQ,@userid,$DQ,';',$NL,
               '.'
            )"/>
            <!-- https://en.wikipedia.org/w/index.php?List_of_Apollo_astronauts&129540 694923888 694919533 -->
         </xsl:for-each>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:function name="wm:title">
   <xsl:param name="title"/>
   <xsl:value-of select="replace($title,' ','_')"/>
</xsl:function>

<xsl:variable name="NL" select="'&#xa;'"/>
<xsl:variable name="DQ" select="'&#x22;'"/>
<xsl:variable name="LT">&lt;</xsl:variable>
<xsl:variable name="GT">&gt;</xsl:variable>

</xsl:transform>
