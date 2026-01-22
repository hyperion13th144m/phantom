<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp">


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
        <xsl:element name="documentName">
            <xsl:value-of select="." />
        </xsl:element>
        <xsl:element name="documentCode">
            <xsl:value-of select="@jp:document-code" />
        </xsl:element>
    </xsl:template>

    <!-- 出願番号 -->
    <xsl:template
        match="jp:application-number">
        <xsl:element name="applicationNumber">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <!-- 登録番号 -->
    <xsl:template
        match="jp:registration-number">
        <xsl:element name="registrationNumber">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <!-- 国際出願番号 -->
    <xsl:template
        match="jp:international-application-number">
        <xsl:element name="internationalApplicationNumber">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <!-- 審判番号 -->
    <xsl:template match="jp:appeal-reference-number">
        <xsl:element name="appealReferenceNumber">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <!-- 受領番号 -->
    <xsl:template
        match="jp:receipt-number">
        <xsl:element name="receiptNumber">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <!-- 整理番号 -->
    <xsl:template
        match="jp:file-reference-id">
        <xsl:if test="normalize-space(.) != ''">
            <xsl:element name="fileReferenceId">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- 提出日(出願日) -->
    <xsl:template
        match="jp:submission-date">
        <xsl:element name="submissionDate">
            <xsl:value-of select="jp:date" />
        </xsl:element>
        <xsl:element name="submissionTime">
            <xsl:value-of select="jp:time" />
        </xsl:element>
    </xsl:template>

    <!-- 発送日 -->
    <xsl:template
        match="jp:dispatch-date">
        <xsl:element name="dispatchDate">
            <xsl:value-of select="jp:date" />
        </xsl:element>
        <xsl:element name="dispatchTime">
            <xsl:value-of select="jp:time" />
        </xsl:element>
    </xsl:template>


    <!-- override build-in template for text and attribute nodes. -->
    <xsl:template match="text()|@*">
        <!-- <xsl:value-of select="normalize-space(.)"/> -->
    </xsl:template>
</xsl:stylesheet>