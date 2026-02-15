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
    xmlns:schema="urn:schema-dsl">
    
    <xsl:include href="v4xva_ntc-pt-e.xsl" />
    
    <!-- ====================================================================
         root
         ====================================================================-->
    <xsl:template match="/">
        <xsl:element name="root">
            <xsl:element name="blocks">
                <xsl:element name="tag">cpy-ntc-pt-e</xsl:element>
                <xsl:apply-templates select="root/jp:cpy-notice-pat-exam" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- schema:title is set to the name of this stylesheet -->
    <schema:title>cpy-ntc-pt-e</schema:title>
    
    <!-- ====================================================================
         jp:cpy-notice-pat-exam
         ====================================================================-->
    <xsl:template match="jp:cpy-notice-pat-exam">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:dispatch-control-article" />
            <xsl:apply-templates select="jp:notice-pat-exam" />
        </xsl:element>
    </xsl:template>
    <schema:object name="cpy-notice-pat-exam">
        <schema:property name="tag" type="string"
                         const="jp:cpy-notice-pat-exam" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="dispatch-control-article.json" name="dispatch-control-article" />
                <schema:ref file="v4xva_ntc-pt-e-rn.json" name="notice-pat-exam-rn" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
</xsl:stylesheet>