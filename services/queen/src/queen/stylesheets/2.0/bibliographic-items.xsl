<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:jp="http://www.jpo.go.jp"
                xmlns:schema="urn:schema-dsl"
                xmlns:xf="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="xsl jp schema xf">
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <xsl:include href="common-templates/bibliographic-items.xsl"/>
    <xsl:include href="debug.xsl"/>
    
    <xsl:variable name="law-code" select="/root/jp:procedure//jp:law" />
    <xsl:variable name="kind-of-law">
        <xsl:choose>
            <xsl:when test="$law-code='1'">patent</xsl:when>
            <xsl:when test="$law-code='2'">utility</xsl:when>
            <xsl:when test="$law-code='3'">design</xsl:when>
            <xsl:when test="$law-code='4'">trademark</xsl:when>
            <xsl:otherwise>unknown</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:param name="debug" select="'false'"/>
    
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:map>
                <!-- 以下、common-templates/bibliographic-items.xsl のテンプレート -->
                <xsl:apply-templates select="root/jp:pat-app-doc" />
                <xsl:apply-templates select="root/jp:pat-amnd" />
                <xsl:apply-templates select="root/jp:pat-rspns" />
                <xsl:apply-templates select="root/jp:pat-etc" />
                <xsl:apply-templates select="root/jp:m-mi-notice-doc" />
                <xsl:apply-templates select="root/jp:procedure" />
                <xsl:apply-templates select="root/sources" />
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
    
    <schema:title>bibliographic-items</schema:title>
    <schema:object name="bibliographic-items" is-root="true">
        <schema:property name="docId" type="string" />
        <schema:property name="task" type="string" />
        <schema:property name="kind" type="string" />
        <schema:property name="extension" type="string" />

        <schema:property name="inventors" type="array" item-type="string" optional="true" />
        <schema:property name="applicants" type="array" item-type="string" />
        <schema:property name="agents" type="array" item-type="string" optional="true" />
        
        <schema:property name="law" type="string" enum="patent,utilityModel,design,trademark" />
        <schema:property name="documentName" type="string"/>
        <schema:property name="documentCode" type="string"/>
        <schema:property name="applicationNumber" type="string" optional="true"/>
        <schema:property name="registrationNumber" type="string" optional="true"/>
        <schema:property name="internationalApplicationNumber" type="string" optional="true"/>
        <schema:property name="appealReferenceNumber" type="string" optional="true"/>
        <schema:property name="receiptNumber" type="string" optional="true"/>
        <schema:property name="fileReferenceId" type="string" optional="true"/>
        <schema:property name="datetime" type="string" optional="true"/>
    </schema:object>
</xsl:stylesheet>
