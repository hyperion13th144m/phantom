<?xml version="1.0" encoding="UTF-8"?>

<!-- 
   original xsl: cpy-ntc-pt-e.xsl at Oct 27  2009
   sha256sum:7c869dc6d82b1fb8a8d10bef39834b63c685c0861db940621db140fb50a4d84d
-->


<!-- ====================================================================
　　　変換対象書類名：特実審査周辺
     ====================================================================-->
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp">

    <xsl:include href="v4xva_ntc-pt-e.xsl" />

    <!-- ====================================================================
     root
     ====================================================================-->
    <xsl:template match="/">
        <xsl:element name="root">
            <xsl:element name="fileReferenceId">
                <xsl:value-of
                    select="root/jp:cpy-notice-pat-exam/jp:dispatch-control-article/jp:file-reference-id" />
            </xsl:element>
            <xsl:element name="textBlocksRoot">
                <xsl:element name="tag">ntcPatExam</xsl:element>
                <xsl:apply-templates select="root/jp:cpy-notice-pat-exam" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:cpy-notice-pat-exam
     ====================================================================-->
    <xsl:template match="jp:cpy-notice-pat-exam">
        <xsl:apply-templates select="jp:dispatch-control-article" />
        <xsl:apply-templates select="jp:notice-pat-exam" />
    </xsl:template>
</xsl:stylesheet>