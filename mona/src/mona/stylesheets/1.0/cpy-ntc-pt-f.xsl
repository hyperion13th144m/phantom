<?xml version="1.0" encoding="UTF-8"?>

<!-- 
   original xsl: cpy-ntc-pt-f.xsl at Oct 27  2009
   sha256sum:be1703a272f4031f8e2265923a9e56dc030973b4cb1b7077e085cfed58929b31 
-->

<!-- ====================================================================
　　　変換対象書類名：特実方式審査
　   ====================================================================-->
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp">

    <xsl:include href="v4xva_ntc-pt-f.xsl" />

    <!-- ====================================================================
     root
     ====================================================================-->
    <xsl:template match="/">
        <xsl:element name="root">
            <xsl:element name="blocks">
                <xsl:element name="tag">notice-pat-frm</xsl:element>
                <xsl:apply-templates select="root/jp:cpy-notice-pat-frm" />
            </xsl:element>
        </xsl:element>
    </xsl:template>


    <!-- ====================================================================
     jp:cpy-notice-pat-frm
     ====================================================================-->
    <xsl:template match="jp:cpy-notice-pat-frm">
        <xsl:apply-templates select="jp:dispatch-control-article" />
        <xsl:apply-templates select="jp:notice-pat-frm" />
    </xsl:template>
</xsl:stylesheet>