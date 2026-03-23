<?xml version="1.0" encoding="UTF-8"?>

<!-- ====================================================================
     変換対象書類名：申請書類（応答書類）
     original: pat-rspn.xsl at Jan 22  2007 
     sha256sum: 67d1757f72dda9554a0e5939db731315f9ce86ffed811361363382f4423c98c8
     ====================================================================-->

<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:schema="urn:schema-dsl"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xsl jp schema xf">
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <xsl:variable name="node" select="name(//jp:pat-rspns/*)" />
    <xsl:variable name="kind-of-law" select="//jp:pat-rspns/*/@jp:kind-of-law" />
    <xsl:variable name="payment" select="substring($node,1,11)" />
    <xsl:param name="debug" select="'false'"/>
    
    <xsl:include href="common-templates/pat_common.xsl" />
    <xsl:include href="debug.xsl"/>
    
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:map>
                <xf:string key="tag">pat-rspn</xf:string>
                <xf:string key="text">
                    <xsl:call-template name="書類名変換" />
                </xf:string>
                <xf:array key="blocks">
                    <xsl:apply-templates select="root/jp:pat-rspns" />
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
    <schema:title>pat-rspn</schema:title>
    <schema:object
        name="pat-rspn" is-root="true">
        <schema:property name="tag" type="string" const="pat-rspn" />
        <schema:property name="text" type="string"/>
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="pat-rspn-a53-a59" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:response-a53 | jp:response-a59
         ====================================================================-->
    <xsl:template match="jp:response-a53 | jp:response-a59">
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
                <xsl:apply-templates select="jp:opinion-contents-article">
                    <xsl:with-param name="document" select="$node" />
                </xsl:apply-templates>
                <xsl:apply-templates select="jp:proof-means" />
                <xsl:apply-templates select="jp:dtext" />
                <xsl:apply-templates select="jp:submission-object-list-article" />
                <xsl:apply-templates select="jp:rule-outside-item-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="pat-rspn-a53-a59">
        <schema:property
            name="tag" type="string" enum="jp:response-a53,jp:response-a59" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="pat-common-terminal-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-b"/>
                <schema:ref file="pat_common.json" name="opinion-contents-article" />
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
</xsl:stylesheet>