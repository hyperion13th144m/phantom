<?xml version="1.0" encoding="UTF-8"?>

<!-- 
     original xsl: cpy-ntc-pt-e-rn.xsl at May 20  2019
     sha256sum:7fe3870976f66447086dcf83ebef7a8c3e4f571d072b3c477d2f1edfd1066670
-->

<!-- ====================================================================
     変換対象書類名：謄本用 発送書類 特実審査（分類付与、実体審査）Y21M05-
     ====================================================================-->
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:schema="urn:schema-dsl"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xsl jp schema xf">
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <xsl:include href="v4xva_ntc-pt-e-rn.xsl" />
    
    <!-- ====================================================================
         root
         ====================================================================-->
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:map>
                <xf:string key="tag">cpy-ntc-pt-e-rn</xf:string>
                <xf:array key="blocks">
                    <xsl:apply-templates select="root/jp:cpy-notice-pat-exam-rn" />
                </xf:array>
            </xf:map>
        </xsl:variable>
        <xsl:value-of select="xml-to-json($root)" />
    </xsl:template>
    <schema:title>cpy-ntc-pt-e-rn</schema:title>
    <schema:object name="cpy-ntc-pt-e-rn" is-root="true">
        <schema:property name="tag" type="string" const="cpy-ntc-pt-e-rn" />
        <schema:property name="blocks" type="array">
            <schema:ref name="cpy-notice-pat-exam-rn" />
        </schema:property>
    </schema:object>
    
    
    <!-- ====================================================================
         jp:cpy-notice-pat-exam-rn
         ====================================================================-->
    <xsl:template match="jp:cpy-notice-pat-exam-rn">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:dispatch-control-article" />
                <xsl:apply-templates select="jp:notice-pat-exam-rn" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="cpy-notice-pat-exam-rn">
        <schema:property name="tag" type="string" const="jp:cpy-notice-pat-exam-rn" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="dispatch-control-article.json" name="dispatch-control-article" />
                <schema:ref file="v4xva_ntc-pt-e-rn.json" name="notice-pat-exam-rn" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
</xsl:stylesheet>