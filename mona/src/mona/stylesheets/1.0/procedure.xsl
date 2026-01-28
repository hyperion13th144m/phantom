<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp">


    <xsl:template match="/">
        <xsl:element name="root">
            <xsl:apply-templates select="root/jp:procedure" />

            <!-- jp:procedure 対象ではないけど、別ファイルにするのも面倒なのでまとめてここで。
             textBlock(json) から出願人、発明者、代理人を抽出しようとすると、補正書で詰むので、
             XSLで対応する。
             -->
            <xsl:apply-templates select="root/jp:pat-app-doc" />
            <xsl:apply-templates select="root/jp:pat-amnd" />
            <xsl:apply-templates select="root/jp:pat-rspns" />
            <xsl:apply-templates select="root/jp:pat-etc" />
            <xsl:apply-templates select="root/jp:m-mi-notice-doc" />
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
        <xsl:if test="jp:date and jp:time">
            <xsl:element name="dispatchDate">
                <xsl:value-of select="jp:date" />
            </xsl:element>
            <xsl:element name="dispatchTime">
                <xsl:value-of select="jp:time" />
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- 
     amendment-grooup 下の applicants，agents を処理しない。
     そのために、jp:amendment-a51 の直下の jp:applicants, jp:agents を処理対処にする
     補正書以外の書類でも同様に処理する
     -->
    <xsl:template
        match="jp:amendment-a51 | jp:amendment-a523 | jp:amendment-a524 |
        jp:amendment-a525 | jp:amendment-a529 |
        jp:amendment-a526 | jp:amendment-a5210 |
        jp:amendment-a527 | jp:amendment-a5211 |
        jp:amendment-a528 | jp:amendment-a5212">
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
    </xsl:template>

    <xsl:template
        match="jp:application-a63 | jp:application-a631 |
        jp:application-a632 | jp:application-a633 |
        jp:application-a634 | jp:application-a635">
        <xsl:apply-templates select="jp:inventors" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:attorney-change-article" />
    </xsl:template>

    <xsl:template match="jp:response-a53 | jp:response-a59">
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
    </xsl:template>

    <xsl:template
        match="jp:etcetera-a601 | jp:etcetera-a621 | jp:etcetera-a623 |
        jp:etcetera-a624 | jp:etcetera-a625 | jp:etcetera-a626 | jp:etcetera-a627 |
        jp:etcetera-a67 | jp:etcetera-a691 | jp:etcetera-a781 | jp:etcetera-a821 |
        jp:etcetera-a831 | jp:etcetera-a87 | jp:etcetera-a871 | jp:etcetera-a872 |
        jp:etcetera-a914 | jp:etcetera-a915 | jp:etcetera-a916 | jp:etcetera-a603 |
        jp:etcetera-a917 | jp:etcetera-a918 | jp:etcetera-a919">
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
    </xsl:template>

    <xsl:template match="jp:dispatch-control-article">
        <xsl:apply-templates select="jp:file-reference-id" />
    </xsl:template>

    <!-- 出願人 -->
    <xsl:template match="jp:applicants">
        <xsl:for-each select="jp:applicant">
            <xsl:element name="applicants">
                <xsl:value-of select=".//jp:name" />
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- 発明者 -->
    <xsl:template match="jp:inventors">
        <xsl:for-each select="jp:inventor">
            <xsl:element name="inventors">
                <xsl:value-of select=".//jp:name" />
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- 代理人 -->
    <xsl:template match="jp:agents | jp:attorney-change-article">
        <xsl:for-each select="jp:agent">
            <xsl:element name="agents">
                <xsl:value-of select=".//jp:name" />
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- 出願人 -->
    <xsl:template match="jp:m-applicant-and-attorneys/jp:m-dispatch-applicant-group">
        <xsl:element name="applicants">
            <xsl:value-of select="jp:m-name" />
        </xsl:element>
    </xsl:template>

    <!-- 代理人 -->
    <xsl:template match="jp:m-applicant-and-attorneys/jp:m-dispatch-attorney-group">
        <xsl:element name="agents">
            <xsl:value-of select="jp:m-name" />
        </xsl:element>
    </xsl:template>

    <!-- override build-in template for text and attribute nodes. -->
    <xsl:template match="text()|@*">
        <!-- <xsl:value-of select="normalize-space(.)"/> -->
    </xsl:template>
</xsl:stylesheet>