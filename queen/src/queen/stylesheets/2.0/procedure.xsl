<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:schema="urn:schema-dsl"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xsl jp schema xf">
    
    <xsl:output method="text" encoding="UTF-8" />
    <xsl:param name="debug" select="'false'"/>
    <xsl:include href="debug.xsl"/>
    
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:map>
                <xsl:apply-templates select="root/jp:procedure" />
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
    
    <!-- 法律種別 -->
    <xsl:template match="jp:law">
        <xf:string key="law">
            <xsl:choose>
                <xsl:when test=". = '1'">patent</xsl:when>
                <xsl:when test=". = '2'">utilityModel</xsl:when>
                <xsl:when test=". = '3'">design</xsl:when>
                <xsl:when test=". = '4'">trademark</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="." />
                </xsl:otherwise>
            </xsl:choose>
        </xf:string>
    </xsl:template>
    
    <!-- 文書名 文書コード-->
    <xsl:template match="jp:document-name">
        <xf:string key="documentName">
            <xsl:value-of select="." />
        </xf:string>
        <xf:string key="documentCode">
            <xsl:value-of select="@jp:document-code" />
        </xf:string>
    </xsl:template>
    
    <!-- 出願番号 -->
    <xsl:template match="jp:application-number">
        <xf:string key="applicationNumber">
            <xsl:value-of select="." />
        </xf:string>
    </xsl:template>
    
    <!-- 登録番号 -->
    <xsl:template match="jp:registration-number">
        <xf:string key="registrationNumber">
            <xsl:value-of select="." />
        </xf:string>
    </xsl:template>
    
    <!-- 国際出願番号 -->
    <xsl:template match="jp:international-application-number">
        <xf:string key="internationalApplicationNumber">
            <xsl:value-of select="." />
        </xf:string>
    </xsl:template>
    
    <!-- 審判番号 -->
    <xsl:template match="jp:appeal-reference-number">
        <xf:string key="appealReferenceNumber">
            <xsl:value-of select="." />
        </xf:string>
    </xsl:template>
    
    <!-- 受領番号 -->
    <xsl:template match="jp:receipt-number">
        <xf:string key="receiptNumber">
            <xsl:value-of select="." />
        </xf:string>
    </xsl:template>
    
    <!-- 整理番号 -->
    <xsl:template match="jp:file-reference-id">
        <xsl:if test="normalize-space(.) != ''">
            <xf:string key="fileReferenceId">
                <xsl:value-of select="." />
            </xf:string>
        </xsl:if>
    </xsl:template>
    
    <!-- 提出日(出願日) -->
    <xsl:template match="jp:submission-date">
        <xf:string key="submissionDate">
            <xsl:value-of select="jp:date" />
        </xf:string>
        <xf:string key="submissionTime">
            <xsl:value-of select="jp:time" />
        </xf:string>
    </xsl:template>
    
    <!-- 発送日 -->
    <xsl:template match="jp:dispatch-date">
        <xsl:if test="jp:date and jp:time">
            <xf:string key="dispatchDate">
                <xsl:value-of select="jp:date" />
            </xf:string>
            <xf:string key="dispatchTime">
                <xsl:value-of select="jp:time" />
            </xf:string>
        </xsl:if>
    </xsl:template>
    
    <!-- override build-in template for text and attribute nodes. -->
    <xsl:template match="text()|@*">
        <!-- <xsl:value-of select="normalize-space(.)"/> -->
    </xsl:template>
    
    <schema:title>bibliographic-items</schema:title>
    <schema:object name="bibliographic-items" is-root="true">
        <schema:property name="law" type="string" enum="patent,utilityModel,design,trademark" />
        <schema:property name="documentName" type="string"/>
        <schema:property name="applicationNumber" type="string" optional="true"/>
        <schema:property name="registrationNumber" type="string" optional="true"/>
        <schema:property name="internationalApplicationNumber" type="string" optional="true"/>
        <schema:property name="appealReferenceNumber" type="string" optional="true"/>
        <schema:property name="receiptNumber" type="string" optional="true"/>
        <schema:property name="fileReferenceId" type="string" optional="true"/>
        <schema:property name="submissionDate" type="string" optional="true"/>
        <schema:property name="submissionTime" type="string" optional="true"/>
        <schema:property name="dispatchDate" type="string" optional="true"/>
        <schema:property name="dispatchTime" type="string" optional="true"/>
    </schema:object>
</xsl:stylesheet>
