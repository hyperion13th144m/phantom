<?xml version="1.0" encoding="UTF-8"?>

<!-- ====================================================================
　　　変換対象書類名：申請書類（応答書類）
    original: pat-rspn.xsl at Jan 22  2007 
    sha256sum: 67d1757f72dda9554a0e5939db731315f9ce86ffed811361363382f4423c98c8
     ====================================================================-->

<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp">

    <xsl:variable name="node" select="name(//jp:pat-rspns/*)" />
    <xsl:variable name="kind-of-law" select="//jp:pat-rspns/*/@jp:kind-of-law" />
    <xsl:variable name="payment" select="substring($node,1,11)" />

    <xsl:include href="common-templates/pat_common.xsl" />

    <xsl:template match="/">
        <xsl:element name="root">
            <xsl:element name="textBlocksRoot">
                <xsl:element name="tag">pat-rspns</xsl:element>
                <xsl:apply-templates select="root/jp:pat-rspns" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:response-a53 | jp:response-a59
     ====================================================================-->
    <xsl:template match="jp:response-a53 | jp:response-a59">
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
    </xsl:template>

</xsl:stylesheet>