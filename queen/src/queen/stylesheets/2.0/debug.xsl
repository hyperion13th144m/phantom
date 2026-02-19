<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="xsl xf map">
       
    <xsl:output method="text" encoding="UTF-8" />
    
    <xsl:template match="xf:map">
        <xsl:if test="@key">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="@key" />
            <xsl:text>": </xsl:text>
        </xsl:if>
        <xsl:text>{</xsl:text>
        <xsl:apply-templates />
        <xsl:text>}</xsl:text>
        <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="xf:array">
        <xsl:if test="@key">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="@key" />
            <xsl:text>": </xsl:text>
        </xsl:if>
        <xsl:text>[ </xsl:text>
        <xsl:apply-templates />
        <xsl:text>]</xsl:text>
        <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="xf:string | xf:boolean | xf:number">
        <xsl:if test="@key">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="@key" />
            <xsl:text>": </xsl:text>
        </xsl:if>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="." />
        <xsl:text>"</xsl:text>
        <xsl:if test="following-sibling::node()">
            <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
</xsl:stylesheet>