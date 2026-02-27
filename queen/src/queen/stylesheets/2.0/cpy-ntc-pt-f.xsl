<?xml version="1.0" encoding="UTF-8"?>

<!-- 
     original xsl: cpy-ntc-pt-f.xsl at Oct 27  2009
     sha256sum:be1703a272f4031f8e2265923a9e56dc030973b4cb1b7077e085cfed58929b31 
-->

<!-- ====================================================================
     変換対象書類名：特実方式審査
     ====================================================================-->
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:schema="urn:schema-dsl"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xsl jp schema xf">
    
    <xsl:output method="text" encoding="UTF-8" />
    <xsl:param name="debug" select="'false'"/>
    
    <xsl:include href="v4xva_ntc-pt-f.xsl" />
    <xsl:include href="debug.xsl"/>
    
    <!-- ====================================================================
         root
         ====================================================================-->
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:map>
                <xf:string key="tag">cpy-ntc-pt-f</xf:string>
                <xf:string key="text">
                    <xsl:value-of select="root/jp:cpy-notice-pat-frm//jp:document-name" />
                </xf:string>
                <xf:array key="blocks">
                    <xsl:apply-templates select="root/jp:cpy-notice-pat-frm" />
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
    <schema:title>cpy-ntc-pt-f</schema:title>
    <schema:object name="cpy-notice-pat-frm" is-root="true">
        <schema:property name="tag" type="string" const="cpy-notice-pat-frm" />
        <schema:property name="text" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="cpy-notice-pat-frm" />
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:cpy-notice-pat-frm
         ====================================================================-->
    <xsl:template match="jp:cpy-notice-pat-frm">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:dispatch-control-article" />
                <xsl:apply-templates select="jp:notice-pat-frm" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="cpy-notice-pat-frm">
        <schema:property name="tag" type="string" const="jp:cpy-notice-pat-frm" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="dispatch-control-article.json" name="dispatch-control-article" />
                <schema:ref file="v4xva_ntc-pt-f.json" name="notice-pat-frm" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
</xsl:stylesheet>