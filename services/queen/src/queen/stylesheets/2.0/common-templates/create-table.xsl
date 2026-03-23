<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:jp="http://www.jpo.go.jp"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="urn:phantom-mona:string-utils"
                xmlns:xf="http://www.w3.org/2005/xpath-functions"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map">
    <!--
        This file is used for creating map tables for doc-code, agents and applicants.
        The input is a sequence of maps with "code" and "value" keys, and the output is a map where each code is mapped to the corresponding value.
        For example, if the input is:
        (
            map{ 'code': ('R1100', 'R1101', 'R1110', 'R1111'),'value': '【特許出願人】'},
            map{ 'code': ('R2100', 'R2110'),'value': '【実用新案登録出願人】'},
            ...
        )
        The output will be:
        {
            'R1100': '【特許出願人】',
            'R1101': '【特許出願人】',
            'R1110': '【特許出願人】',
            'R1111': '【特許出願人】',
            'R2100': '【実用新案登録出願人】',
            'R2110': '【実用新案登録出願人】',
            ...
        }
    -->
    <xsl:template name="create-table">  
        <xsl:param name="code" />
        <xsl:map>
            <xsl:for-each select="$code">
                <xsl:variable name="value" select="map:get(., 'value')" />
                <xsl:for-each select="map:get(., 'code')">
                    <xsl:map-entry key="." select="$value" />
                </xsl:for-each>
            </xsl:for-each>
        </xsl:map>
    </xsl:template>
</xsl:stylesheet>
