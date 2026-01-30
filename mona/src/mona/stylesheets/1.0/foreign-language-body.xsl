<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:f="urn:libefiling:string-utils"
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
            <xsl:apply-templates
                select="root/jp:foreign-language-body/jp:foreign-language-description" />
            <xsl:apply-templates select="root/jp:foreign-language-body/jp:foreign-language-claims" />
            <xsl:apply-templates select="root/jp:foreign-language-body/jp:foreign-language-abstract" />
            <xsl:apply-templates select="root/jp:foreign-language-body/jp:foreign-language-drawings" />
        </xsl:element>
    </xsl:template>

    <!-- 明細書 特許請求の範囲-->
    <xsl:template
        match="jp:foreign-language-description | jp:foreign-language-claims | jp:foreign-language-abstract | jp:foreign-language-drawings">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="indentLevel">0</xsl:element>
            <xsl:apply-templates select="p" />
        </xsl:element>
    </xsl:template>

    <!--
    <xsl:template match="p">
        <xsl:element name="blocks">
            <xsl:element name="tag">paragraph</xsl:element>
            <xsl:element name="indentLevel">0</xsl:element>
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
 -->

    <!-- 変換元XMLにある images/image のlookup
    <xsl:key name="images-table-key" match="/root/images/image" use="@orig-filename" />
 -->

    <!--  イメージ
    <xsl:template match="img">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:choose>
                    <xsl:when test="parent::chemistry">
                        <xsl:text>chemical-formulas</xsl:text>
                    </xsl:when>
                    <xsl:when test="$law = 'utility-model'">utility-model-images</xsl:when>
                    <xsl:otherwise>other-images</xsl:otherwise>
                </xsl:choose>
            </xsl:element>

            <xsl:element name="indentLevel">0</xsl:element>
            <xsl:for-each select="key('images-table-key', @file)">
                <xsl:element name="images">
                    <xsl:element name="src">
                        <xsl:value-of select="@new" />
                    </xsl:element>
                    <xsl:element name="width">
                        <xsl:value-of select="@width" />
                    </xsl:element>
                    <xsl:element name="height">
                        <xsl:value-of select="@height" />
                    </xsl:element>
                    <xsl:element name="kind">
                        <xsl:value-of select="@kind" />
                    </xsl:element>
                    <xsl:element name="sizeTag">
                        <xsl:value-of select="@sizeTag" />
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
   -->
    <!--
    <xsl:template
        match="text() | sup | sub | u">
        <xsl:variable name="tag">
            <xsl:choose>
                <xsl:when test="self::text()">text</xsl:when>
                <xsl:when test="self::sup">sup</xsl:when>
                <xsl:when test="self::sub">sub</xsl:when>
                <xsl:when test="self::u">underline</xsl:when>
            </xsl:choose>
        </xsl:variable>
-->
    <!-- 次の「有意ノード」を見る
        <xsl:variable
        name="nextNode"
        select="following-sibling::node()[not(self::text()[normalize-space(.)=''])][1]" />
 -->
    <!-- 次が br か、次が存在しない（p末尾）なら true 
        <xsl:variable
        name="isLastSentence"
        select="if (empty($nextNode) or $nextNode/self::br) then 'true' else 'false'" />

        <xsl:if
        test="normalize-space() != ''">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="$tag" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:call-template name="trim">
                    <xsl:with-param name="text" select="." />
                </xsl:call-template>
            </xsl:element>
            <xsl:element name="isLastSentence">
                <xsl:value-of select="$isLastSentence" />
            </xsl:element>
        </xsl:element>
    </xsl:if>
    </xsl:template>
    -->
</xsl:stylesheet>