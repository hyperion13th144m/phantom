<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:f="urn:phantom-mona:string-utils"
    xmlns:schema="urn:schema-dsl"
    exclude-result-prefixes="xs jp f">

    <xsl:variable name="node" select="name(//jp:pat-app-doc/*)" />
    <xsl:variable name="kind-of-law" select="//jp:pat-app-doc/*/@jp:kind-of-law" />
    <xsl:variable name="law" select="$kind-of-law" />
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
    
    <schema:title>application-body</schema:title>
    <schema:object name="application-body">
        <schema:property name="tag" type="string"
                         const="application-body" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="description" />
                <schema:ref file="pat_common.json" name="claims" />
                <schema:ref file="pat_common.json" name="abstract" />
                <schema:ref file="pat_common.json" name="drawings" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
</xsl:stylesheet>