<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:f="urn:phantom-mona:string-utils"
    exclude-result-prefixes="xs jp f">

    <!-- 文字列処理関連のテンプレート -->

    <!-- 
         split $input-string at every $n-chars and insert $sep to splitted positions.
    -->
    <xsl:template name="split-at-n-chars">
        <xsl:param name="input-string" as="xs:string" />
        <xsl:param name="n-chars" as="xs:integer" />
        <xsl:param name="sep" as="xs:string" select="' '" />
        <xsl:variable name="length" select="string-length($input-string)" />

        <xsl:for-each select="for $i in 1 to $length div $n-chars return $i">
            <xsl:value-of
                select="substring($input-string, (position() - 1) * $n-chars + 1, $n-chars)" />
            <xsl:if test="position() != last()">
                <xsl:value-of select="$sep" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- 半角数字 → 全角数字 -->
    <xsl:function name="f:to-fullwidth-digit" as="xs:string">
        <xsl:param name="s" as="xs:string" />
        <xsl:sequence
            select="translate($s, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '０１２３４５６７８９ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ')" />
    </xsl:function>

    <xsl:function name="f:to-fullwidth-alnum" as="xs:string">
        <xsl:param name="s" as="xs:string" />
        <xsl:sequence
            select="translate($s, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '０１２３４５６７８９ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ')" />
    </xsl:function>


    <!-- &nbsp; (U+00A0) を通常の空白に変換して normalize-space を適用 -->
    <xsl:function name="f:remove-nbsp" as="xs:string">
        <xsl:param name="s" as="xs:string" />
        <xsl:sequence select="normalize-space(translate($s, '&#160;', ' '))" />
    </xsl:function>

    <!-- 先頭と最後の空白/改行の除去 -->
    <xsl:template name="trim">
        <xsl:param name="text" />
        <xsl:value-of select="replace($text, '^[\s]+|[\s]+$', '')" />
    </xsl:template>
</xsl:stylesheet>