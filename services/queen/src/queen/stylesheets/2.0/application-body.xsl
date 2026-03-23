<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:schema="urn:schema-dsl"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xsl jp schema xf">
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <xsl:variable name="node" select="name(//jp:pat-app-doc/*)" />
    <xsl:variable name="kind-of-law" select="//jp:pat-app-doc/*/@jp:kind-of-law" />
    <xsl:variable name="law" select="$kind-of-law" />
    <xsl:variable name="payment" select="substring($node,1,11)" />
    <xsl:param name="debug" select="'false'"/>
    
    <xsl:include href="common-templates/pat_common.xsl" />
    <xsl:include href="debug.xsl"/>
    
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:map>
                <xf:string key="tag">application-body</xf:string>
                <xf:array key="blocks">
                    <xsl:apply-templates select="root/application-body/description" />
                    <xsl:apply-templates select="root/application-body/claims" />
                    <xsl:apply-templates select="root/application-body/abstract" />
                    <xsl:apply-templates select="root/application-body/drawings" />
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
    
    <schema:title>application-body</schema:title>
    <schema:object name="application-body" is-root="true">
        <schema:property name="tag" type="string" const="application-body" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="description" />
                <schema:ref file="pat_common.json" name="claims" />
                <schema:ref file="pat_common.json" name="abstract" />
                <schema:ref file="pat_common.json" name="drawings" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
</xsl:stylesheet>