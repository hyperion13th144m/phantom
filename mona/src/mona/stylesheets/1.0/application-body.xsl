<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:f="urn:libefiling:string-utils"
    exclude-result-prefixes="xs jp f">

    <xsl:variable name="node" select="name(//jp:pat-app-doc/*)" />
    <xsl:variable name="kind-of-law" select="//jp:pat-app-doc/*/@jp:kind-of-law" />
    <xsl:variable name="law" select="$kind-of-law"/>
    <xsl:variable name="payment" select="substring($node,1,11)" />

    <xsl:include href="common-templates/pat_common.xsl" />

    <xsl:template match="/">
        <xsl:element name="root">
            <xsl:apply-templates select="root/application-body/description" />
            <xsl:apply-templates select="root/application-body/claims" />
            <xsl:apply-templates select="root/application-body/abstract" />
            <xsl:apply-templates select="root/application-body/drawings" />
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>