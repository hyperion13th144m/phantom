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
    xmlns:schema="urn:schema-dsl">
    
    <xsl:include href="v4xva_ntc-pt-f.xsl" />
    
    <!-- ====================================================================
         root
         ====================================================================-->
    <xsl:template match="/">
        <xsl:element name="root">
            <xsl:element name="blocks">
                <xsl:element name="tag">cpy-ntc-pt-f</xsl:element>
                <xsl:apply-templates select="root/jp:cpy-notice-pat-frm" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:title>cpy-ntc-pt-f</schema:title>
    <schema:object name="cpy-notice-pat-frm" is-root="true">
        <schema:property name="tag" type="string" const="jp:cpy-notice-pat-frm" />
        <schema:property name="blocks" type="array">
            <schema:ref name="cpy-notice-pat-frm" />
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:cpy-notice-pat-frm
         ====================================================================-->
    <xsl:template match="jp:cpy-notice-pat-frm">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:dispatch-control-article" />
            <xsl:apply-templates select="jp:notice-pat-frm" />
        </xsl:element>
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