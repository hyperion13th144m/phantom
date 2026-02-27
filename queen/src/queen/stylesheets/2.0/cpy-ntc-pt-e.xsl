<?xml version="1.0" encoding="UTF-8"?>

<!-- 
     original xsl: cpy-ntc-pt-e.xsl at Oct 27  2009
     sha256sum:7c869dc6d82b1fb8a8d10bef39834b63c685c0861db940621db140fb50a4d84d
-->


<!-- ====================================================================
     変換対象書類名：特実審査周辺
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
    
    <xsl:include href="v4xva_ntc-pt-e.xsl" />
    <xsl:include href="debug.xsl"/>
    
    <!-- ====================================================================
         root
         ====================================================================-->
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:map>
                <xf:string key="tag">cpy-ntc-pt-e</xf:string>
                <xf:string key="text">
                    <xsl:value-of select="root/jp:cpy-notice-pat-exam//jp:document-name" />
                </xf:string>
                <xf:array key="blocks">
                    <xsl:apply-templates select="root/jp:cpy-notice-pat-exam" />
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
    <schema:title>cpy-ntc-pt-e</schema:title>
    <schema:object name="cpy-ntc-pt-e" is-root="true">
        <schema:property name="tag" type="string" const="cpy-ntc-pt-e" />
        <schema:property name="text" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="cpy-notice-pat-exam" />
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:cpy-notice-pat-exam
         ====================================================================-->
    <xsl:template match="jp:cpy-notice-pat-exam">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:dispatch-control-article" />
                <xsl:apply-templates select="jp:notice-pat-exam" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="cpy-notice-pat-exam">
        <schema:property name="tag" type="string" const="jp:cpy-notice-pat-exam" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="dispatch-control-article.json" name="dispatch-control-article" />
                <schema:ref file="v4xva_ntc-pt-e.json" name="notice-pat-exam" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
</xsl:stylesheet>