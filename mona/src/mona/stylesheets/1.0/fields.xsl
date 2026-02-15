<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:f="urn:phantom-mona:string-utils"
    xmlns:schema="urn:schema-dsl"
    exclude-result-prefixes="xs jp f">

    <xsl:variable name="node" select="name(//jp:pat-app-doc/*)" />
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

    <xsl:variable name="law" select="$kind-of-law" />
    <xsl:variable name="payment" select="substring($node,1,11)" />

    <xsl:include href="common-templates/special-mention-matter-article.xsl" />
    <xsl:include href="common-templates/string-utils.xsl" />

    <!-- schema:title is set to the name of this stylesheet -->
    <schema:title>fields</schema:title>

    <xsl:template match="/">
        <xsl:element name="root">
            <xsl:element name="fields">
                <xsl:apply-templates select="root/application-body/description" />
                <xsl:apply-templates select="root/application-body/claims" />
                <xsl:apply-templates select="root/application-body/abstract" />
                <xsl:apply-templates select="root/jp:pat-app-doc" />
                <xsl:apply-templates select="root/jp:cpy-notice-pat-exam-rn" />
                <xsl:apply-templates select="root/jp:cpy-notice-pat-exam" />
                <!-- 
             補正書は補正対象の出願人、発明者、代理人を抽出しないように注意
             -->
                <xsl:apply-templates select="root/jp:pat-amnd" />
                <xsl:apply-templates select="root/jp:pat-rspns" />
                <xsl:apply-templates select="root/jp:pat-etc" />
                <xsl:apply-templates select="root/jp:m-mi-notice-doc" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template
        match="invention-title | technical-field | background-art |
        tech-problem | tech-solution | advantageous-effects |
        description-of-embodiments | best-mode | industrial-applicability |
        reference-to-deposited-biological-material | abstract |
        jp:law-of-industrial-regenerate | jp:conclusion-part-article |
        jp:drafting-body | jp:opinion-contents-article | jp:contents-of-amendment">
        <xsl:if test="normalize-space(.) != ''">
            <xsl:element name="{local-name()}">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="jp:special-mention-matter-article">
        <xsl:for-each select="jp:article">
            <xsl:element name="special-mention-matter-article">
                <xsl:call-template name="convert-special-mention-matter-article">
                    <xsl:with-param name="article" select="normalize-space()" />
                    <xsl:with-param name="kind-of-law" select="$kind-of-law" />
                </xsl:call-template>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="jp:article-group">
        <xsl:for-each select="jp:article">
            <xsl:element name="rejection-reason-article">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="claim-text[not(contains(., '請求項'))]">
        <xsl:element name="independent-claims">
            <xsl:value-of select="normalize-space(.)" />
        </xsl:element>
    </xsl:template>

    <xsl:template match="claim-text[contains(., '請求項')]">
        <xsl:element name="dependent-claims">
            <xsl:value-of select="normalize-space(.)" />
        </xsl:element>
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
        <xsl:apply-templates select="jp:amendment-article" />
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
        <xsl:apply-templates select="jp:opinion-contents-article" />
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
        <xsl:apply-templates select="jp:opinion-contents-article" />
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

    <xsl:template match="text()" />

    <schema:object
        name="fields">
        <schema:property name="tag" type="string"
            const="fields" />
        <schema:property name="invention-title" type="string" optional="true" />
        <schema:property name="technical-field" type="string" optional="true" />
        <schema:property name="background-art" type="string" optional="true" />
        <schema:property name="tech-problem" type="string" optional="true" />
        <schema:property name="tech-solution" type="string" optional="true" />
        <schema:property name="advantageous-effects" type="string" optional="true" />
        <schema:property name="description-of-embodiments" type="string" optional="true" />
        <schema:property name="best-mode" type="string" optional="true" />
        <schema:property name="industrial-applicability" type="string" optional="true" />
        <schema:property name="reference-to-deposited-biological-material" type="string"
            optional="true" />
        <schema:property name="abstract" type="string" optional="true" />
        <schema:property name="jp:law-of-industrial-regenerate" type="string" optional="true" />
        <schema:property name="jp:conclusion-part-article" type="string" optional="true" />
        <schema:property name="jp:drafting-body" type="string" optional="true" />
        <schema:property name="jp:opinion-contents-article" type="string" optional="true" />

        <schema:property name="independent-claims" type="array" item-type="string" optional="true" />
        <schema:property name="dependent-claims" type="array" item-type="string" optional="true" />
        <schema:property name="inventors" type="array" item-type="string" optional="true" />
        <schema:property name="applicants" type="array" item-type="string" />
        <schema:property name="agents" type="array" item-type="string" optional="true" />
        <schema:property name="rejection-reason-article" type="array" item-type="string"
            optional="true" />
        <schema:property name="contents-of-amendment" type="array" item-type="string"
            optional="true" />
    </schema:object>
</xsl:stylesheet>