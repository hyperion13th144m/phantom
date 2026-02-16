<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:jp="http://www.jpo.go.jp"
                xmlns:f="urn:phantom-mona:string-utils"
                xmlns:schema="urn:schema-dsl"
                exclude-result-prefixes="xs jp f">
    
    <xsl:variable name="node" select="name(//jp:foreign-language-body/*)" />
    <xsl:variable
        name="kind-of-law"
        select="//jp:foreign-language-body/*/@jp:kind-of-law" />
    <xsl:variable name="kinddoc"
        select="name(//jp:foreign-language-body/*)" />
    <xsl:variable name="payment"
        select="substring($node,1,11)" />
    
    <xsl:include href="common-templates/pat_common.xsl" />
    
    <xsl:variable
        name="law">
        <xsl:choose>
            <xsl:when
                test="//jp:procedure//jp:law = '1'">patent</xsl:when>
            <xsl:when
                test="//jp:procedure//jp:law = '2'">utility-model</xsl:when>
            <xsl:otherwise>unknown</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:template
        match="/">
        <xsl:element name="root">
            <xsl:element name="blocks">
                <xsl:element name="tag">foreign-language-body</xsl:element>
                <xsl:apply-templates
                    select="root/jp:foreign-language-body/jp:foreign-language-description" />
                <xsl:apply-templates select="root/jp:foreign-language-body/jp:foreign-language-claims" />
                <xsl:apply-templates select="root/jp:foreign-language-body/jp:foreign-language-abstract" />
                <xsl:apply-templates select="root/jp:foreign-language-body/jp:foreign-language-drawings" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:title>foreign-language-body</schema:title>
    <schema:object name="foreign-language-body" is-root="true">
        <schema:property name="tag" type="string"
                         const="foreign-language-body"/>
        <schema:property name="blocks" type="array">
            <schema:ref name="foreign-language-documents" />
        </schema:property>
    </schema:object>
    
    <!-- 明細書 特許請求の範囲,図面,要約書-->
    <xsl:template
        match="jp:foreign-language-description | jp:foreign-language-claims |
            jp:foreign-language-abstract | jp:foreign-language-drawings">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="p" />
        </xsl:element>
    </xsl:template>
    <schema:object name="foreign-language-documents">
        <schema:property
            name="tag" type="string"
                   enum="jp:foreign-language-description,
                         jp:foreign-language-claims,
                         jp:foreign-language-abstract,
                         jp:foreign-language-drawings" />
        <schema:property name="blocks" type="array">
            <schema:ref file="pat_common.json" name="paragraph" />
        </schema:property>
    </schema:object>
</xsl:stylesheet>