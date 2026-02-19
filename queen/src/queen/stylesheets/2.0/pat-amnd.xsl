<?xml version="1.0" encoding="UTF-8"?>

<!-- ====================================================================
     変換対象書類名：申請書類（補正書）
     original: pat-amnd.xsl at Jan 22  2007 
     sha256sum: 07526880fdb7472ad99e02fc63356fc9f0f122846d24b52678691f1730d3d037
     ====================================================================-->
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:schema="urn:schema-dsl"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xsl jp schema xf">
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <xsl:variable name="node" select="name(//jp:pat-amnd/*)" />
    <xsl:variable name="kind-of-law" select="//jp:pat-amnd/*/@jp:kind-of-law" />
    <xsl:variable name="payment" select="substring($node,1,11)" />
    <xsl:param name="debug" select="'false'"/>
    
    <xsl:include href="common-templates/pat_common.xsl" />
    <xsl:include href="debug.xsl"/>
    
    <!-- ====================================================================
         root
         ====================================================================-->
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:map>
                <xf:string key="tag">pat-amnd</xf:string>
                <xf:array key="blocks">
                    <xsl:apply-templates select="root/jp:pat-amnd" />
                </xf:array>
            </xf:map>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$debug = 'true'">
                <xsl:apply-templates select="$root/xf:map"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="xml-to-json($root)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <schema:title>pat-amnd</schema:title>
    <schema:object name="pat-amnd" is-root="true">
        <schema:property name="tag" type="string" const="pat-amnd" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="amendment-a51-a523" />
                <schema:ref name="amendment-a524"/>
                <schema:ref name="amendment-a525-a529"/>
                <schema:ref name="amendment-a526-a5210"/>
                <schema:ref name="amendment-a527-a5211"/>
                <schema:ref name="amendment-a528-a5212"/>
            </schema:anyOf>
        </schema:property>
    </schema:object> 
    
    <!-- ====================================================================
         jp:amendment-a51 | jp:amendment-a523 手続補正書（方式）| 手続補正書
         ====================================================================-->
    <xsl:template match="jp:amendment-a51 | jp:amendment-a523">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:file-reference-id" />
                <xsl:apply-templates select="jp:submission-date" />
                <xsl:apply-templates select="jp:addressed-to-person" />
                <xsl:apply-templates select="jp:indication-of-case-article" />
                <xsl:apply-templates select="jp:proof-necessity" />
                <xsl:apply-templates select="jp:applicants" />
                <xsl:apply-templates select="jp:agents" />
                <xsl:apply-templates select="jp:dispatch-number" />
                <xsl:apply-templates select="jp:dispatch-date" />
                <xsl:apply-templates select="jp:num-claim-decrease-amendment">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:num-claim-increase-amendment">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:amendment-article" />
                <xsl:apply-templates select="jp:amendment-charge-article" />
                <xsl:apply-templates select="jp:proof-means" />
                <xsl:apply-templates select="jp:share-rate" />
                <xsl:apply-templates select="jp:charge-article" />
                <xsl:apply-templates select="jp:dtext" />
                <xsl:apply-templates select="jp:submission-object-list-article" />
                <xsl:apply-templates select="jp:rule-outside-item-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="amendment-a51-a523">
        <schema:property
            name="tag" type="string" enum="jp:amendment-a51,jp:amendment-a523" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="pat-common-terminal-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-b"/>
                <schema:ref file="pat_common.json" name="amendment-article" />
                <schema:ref file="pat_common.json" name="amendment-charge-article" />
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:amendment-a524 誤訳訂正書
         ====================================================================-->
    <xsl:template match="jp:amendment-a524">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:file-reference-id" />
                <xsl:apply-templates select="jp:submission-date" />
                <xsl:apply-templates select="jp:addressed-to-person" />
                <xsl:apply-templates select="jp:indication-of-case-article" />
                <xsl:apply-templates select="jp:proof-necessity" />
                <xsl:apply-templates select="jp:applicants" />
                <xsl:apply-templates select="jp:agents" />
                <xsl:apply-templates select="jp:dispatch-number" />
                <xsl:apply-templates select="jp:dispatch-date" />
                <xsl:apply-templates select="jp:num-claim-decrease-amendment">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:num-claim-increase-amendment">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:amendment-article" />
                <xsl:apply-templates select="jp:opinion-contents-article">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:share-rate" />
                <xsl:apply-templates select="jp:charge-article" />
                <xsl:apply-templates select="jp:dtext" />
                <xsl:apply-templates select="jp:submission-object-list-article" />
                <xsl:apply-templates select="jp:rule-outside-item-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="amendment-a524">
        <schema:property
            name="tag" type="string" const="jp:amendment-a524" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="pat-common-terminal-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-b"/>
                <schema:ref file="pat_common.json" name="amendment-article" />
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
                <schema:ref file="pat_common.json" name="opinion-contents-article"/>
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:amendment-a525 | jp:amendment-a529
         特許協力条約第１９条補正の翻訳文提出書 | 特許協力条約第３４条補正の翻訳文提出書
         ====================================================================-->
    <xsl:template match="jp:amendment-a525 | jp:amendment-a529">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:file-reference-id" />
                <xsl:apply-templates select="jp:submission-date" />
                <xsl:apply-templates select="jp:addressed-to-person" />
                <xsl:apply-templates select="jp:indication-of-case-article" />
                <xsl:apply-templates select="jp:proof-necessity" />
                <xsl:apply-templates select="jp:applicants" />
                <xsl:apply-templates select="jp:agents" />
                <xsl:apply-templates select="jp:submit-date-of-amendment" />
                <xsl:apply-templates select="jp:num-claim-decrease-amendment">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:num-claim-increase-amendment">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:amendment-article" />
                <xsl:apply-templates select="jp:dtext" />
                <xsl:apply-templates select="jp:submission-object-list-article" />
                <xsl:apply-templates select="jp:rule-outside-item-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="amendment-a525-a529">
        <schema:property
            name="tag" type="string" enum="jp:amendment-a525,jp:amendment-a529" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="pat-common-terminal-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-b"/>
                <schema:ref file="pat_common.json" name="amendment-article" />
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:amendment-a526 | jp:amendment-a5210
         特許協力条約第１９条補正の翻訳文提出書（職権） |
         特許協力条約第３４条補正の翻訳文提出書（職権）
         ====================================================================-->
    <xsl:template match="jp:amendment-a526 | jp:amendment-a5210">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:file-reference-id" />
                <xsl:apply-templates select="jp:submission-date" />
                <xsl:apply-templates select="jp:addressed-to-person" />
                <xsl:apply-templates select="jp:indication-of-case-article" />
                <xsl:apply-templates select="jp:proof-necessity" />
                <xsl:apply-templates select="jp:applicants" />
                <xsl:apply-templates select="jp:agents" />
                <xsl:apply-templates select="jp:submit-date-of-amendment" />
                <xsl:apply-templates select="jp:num-claim-decrease-amendment">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:num-claim-increase-amendment">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:notice-contents-group" />
                <xsl:apply-templates select="jp:amendment-article" />
                <xsl:apply-templates select="jp:dtext" />
                <xsl:apply-templates select="jp:submission-object-list-article" />
                <xsl:apply-templates select="jp:rule-outside-item-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="amendment-a526-a5210">
        <schema:property
            name="tag" type="string" enum="jp:amendment-a526,jp:amendment-a5210" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="pat-common-terminal-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-b"/>
                <schema:ref file="pat_common.json" name="amendment-article" />
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:amendment-a527 | jp:amendment-a5211
         特許協力条約第１９条補正の写し提出書 |
         特許協力条約第３４条補正の写し提出書
         ====================================================================-->
    <xsl:template match="jp:amendment-a527 | jp:amendment-a5211">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:file-reference-id" />
                <xsl:apply-templates select="jp:submission-date" />
                <xsl:apply-templates select="jp:addressed-to-person" />
                <xsl:apply-templates select="jp:indication-of-case-article" />
                <xsl:apply-templates select="jp:proof-necessity" />
                <xsl:apply-templates select="jp:applicants" />
                <xsl:apply-templates select="jp:agents" />
                <xsl:apply-templates select="jp:submit-date-of-amendment" />
                <xsl:apply-templates select="jp:num-claim-decrease-amendment">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:num-claim-increase-amendment">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:dtext" />
                <xsl:apply-templates select="jp:submission-object-list-article" />
                <xsl:apply-templates select="jp:rule-outside-item-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="amendment-a527-a5211">
        <schema:property
            name="tag" type="string" enum="jp:amendment-a527,jp:amendment-a5211" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="pat-common-terminal-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-b"/>
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:amendment-a528 | jp:amendment-a5212
         特許協力条約第１９条補正の写し提出書（職権） |
         特許協力条約第３４条補正の写し提出書（職権）
         ====================================================================-->
    <xsl:template match="jp:amendment-a528 | jp:amendment-a5212">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:file-reference-id" />
                <xsl:apply-templates select="jp:submission-date" />
                <xsl:apply-templates select="jp:addressed-to-person" />
                <xsl:apply-templates select="jp:indication-of-case-article" />
                <xsl:apply-templates select="jp:proof-necessity" />
                <xsl:apply-templates select="jp:applicants" />
                <xsl:apply-templates select="jp:agents" />
                <xsl:apply-templates select="jp:submit-date-of-amendment" />
                <xsl:apply-templates select="jp:num-claim-decrease-amendment">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:num-claim-increase-amendment">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:notice-contents-group" />
                <xsl:apply-templates select="jp:dtext" />
                <xsl:apply-templates select="jp:submission-object-list-article" />
                <xsl:apply-templates select="jp:rule-outside-item-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="amendment-a528-a5212">
        <schema:property
            name="tag" type="string" enum="jp:amendment-a528,jp:amendment-a5212" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="pat-common-terminal-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-b"/>
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
</xsl:stylesheet>