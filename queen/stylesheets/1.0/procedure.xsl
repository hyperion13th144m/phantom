<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:jp="http://www.jpo.go.jp"
                xmlns:schema="urn:schema-dsl">
    
    <xsl:template match="/">
        <xsl:element name="root">
            <xsl:apply-templates select="root/jp:procedure" />
        </xsl:element>
    </xsl:template>
    
    <!-- 法律種別 -->
    <xsl:template match="jp:law">
        <xsl:element name="law">
            <xsl:choose>
                <xsl:when test=". = '1'">patent</xsl:when>
                <xsl:when test=". = '2'">utilityModel</xsl:when>
                <xsl:when test=". = '3'">design</xsl:when>
                <xsl:when test=". = '4'">trademark</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="." />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <!-- 文書名 文書コード-->
    <xsl:template match="jp:document-name">
        <xsl:element name="document-name">
            <xsl:value-of select="." />
        </xsl:element>
        <xsl:element name="document-code">
            <xsl:value-of select="@jp:document-code" />
        </xsl:element>
    </xsl:template>
    
    <!-- 出願番号 -->
    <xsl:template
        match="jp:application-number">
        <xsl:element name="application-number">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>
    
    <!-- 登録番号 -->
    <xsl:template
        match="jp:registration-number">
        <xsl:element name="registration-number">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>
    
    <!-- 国際出願番号 -->
    <xsl:template
        match="jp:international-application-number">
        <xsl:element name="international-application-number">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>
    
    <!-- 審判番号 -->
    <xsl:template match="jp:appeal-reference-number">
        <xsl:element name="appeal-reference-number">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>
    
    <!-- 受領番号 -->
    <xsl:template
        match="jp:receipt-number">
        <xsl:element name="receipt-number">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>
    
    <!-- 整理番号 -->
    <xsl:template
        match="jp:file-reference-id">
        <xsl:if test="normalize-space(.) != ''">
            <xsl:element name="file-reference-id">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <!-- 提出日(出願日) -->
    <xsl:template
        match="jp:submission-date">
        <xsl:element name="submission-date">
            <xsl:value-of select="jp:date" />
        </xsl:element>
        <xsl:element name="submission-time">
            <xsl:value-of select="jp:time" />
        </xsl:element>
    </xsl:template>
    
    <!-- 発送日 -->
    <xsl:template
        match="jp:dispatch-date">
        <xsl:if test="jp:date and jp:time">
            <xsl:element name="dispatch-date">
                <xsl:value-of select="jp:date" />
            </xsl:element>
            <xsl:element name="dispatch-time">
                <xsl:value-of select="jp:time" />
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <!-- override build-in template for text and attribute nodes. -->
    <xsl:template match="text()|@*">
        <!-- <xsl:value-of select="normalize-space(.)"/> -->
    </xsl:template>
    
    <schema:title>bibliographic-items</schema:title>
    <schema:object name="bibliographic-items" is-root="true">
        <schema:property name="law" type="string" enum="patent,utilityModel,design,trademark" />
        <schema:property name="document-name" type="string"/>
        <schema:property name="application-number" type="string" optional="true"/>
        <schema:property name="registration-number" type="string" optional="true"/>
        <schema:property name="international-application-number" type="string" optional="true"/>
        <schema:property name="appeal-reference-number" type="string" optional="true"/>
        <schema:property name="receipt-number" type="string" optional="true"/>
        <schema:property name="file-reference-id" type="string" optional="true"/>
        <schema:property name="submission-date" type="string" optional="true"/>
        <schema:property name="submission-time" type="string" optional="true"/>
        <schema:property name="dispatch-date" type="string" optional="true"/>
        <schema:property name="dispatch-time" type="string" optional="true"/>
    </schema:object>
</xsl:stylesheet>
