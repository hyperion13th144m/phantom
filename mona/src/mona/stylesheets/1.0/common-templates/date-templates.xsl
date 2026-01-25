<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp">

    <!-- 
        日付処理関連のテンプレート
    -->
    <!-- ====================================================================
       和暦日付編集  (pat_common.xsl 日付変換テンプレートを基に作成)
         input: xs:string date "YYYYMMDD"
         output: 令和NN年MM月DD日
       ====================================================================-->
    <xsl:template name="format-date-jp">
        <xsl:param name="date-str" as="xs:string" />
        <xsl:param name="law" as="xs:string" />
        <xsl:variable name="m" select="substring($date-str,5,2)" />
        <xsl:variable name="d" select="substring($date-str,7,2)" />

        <xsl:choose>
            <xsl:when test="string-length($date-str) != 8" />
            <xsl:when test="number($date-str) &lt; 19260101" />
            <xsl:otherwise>
                <xsl:call-template name="gengo">
                    <xsl:with-param name="date" select="$date-str" />
                </xsl:call-template>
                <xsl:call-template name="warekinen">
                    <xsl:with-param name="date" select="$date-str" />
                </xsl:call-template>
                <xsl:value-of select="'年'" />
                <xsl:value-of select="$m || '月'" />
                <xsl:value-of select="$d || '日'" />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if
            test="(ancestor::jp:application-reference
                    and ancestor::jp:application-reference [@appl-type = 'application'])
                    and ((ancestor::jp:parent-application-article and
                          not(ancestor::jp:parent-application-article [@jp:kind-of-application = 'based-on-utility']))
                     or ancestor::jp:declaration-priority-ear-app
                     or ancestor::jp:indication-of-case-article)">
            <!-- Y05M04　実用新案法改正　追加　End-->
            <xsl:value-of select="'提出の'" />
            <xsl:choose>
                <xsl:when test="$law = 'patent'">
                    <xsl:value-of select="'特許願'" />
                </xsl:when>
                <xsl:when test="$law = 'utility'">
                    <xsl:value-of select="'実用新案登録願'" />
                </xsl:when>
                <xsl:when test="$law = 'design'">
                    <xsl:value-of select="'意匠登録願'" />
                </xsl:when>
                <xsl:when test="$law = 'trademark'">
                    <xsl:value-of select="'商標登録願'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'書誌編集エラー処理'" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if
            test="ancestor::jp:application-reference
                    and ancestor::jp:application-reference [@appl-type = 'international-application']">
            <xsl:value-of select="'提出'" />
        </xsl:if>
    </xsl:template>

    <!-- ====================================================================
       和暦日付編集  (v4xva_ntc-pt-e.xsl 日付変換テンプレートを基に作成)
       format-date-jp との差分は
         xsl:if test="(ancestor...)" 以下の部分は削除
         input: xs:string date "YYYYMMDD"
         output: 令和NN年MM月DD日
       ====================================================================-->
    <xsl:template name="format-date-jp2">
        <xsl:param name="date-str" as="xs:string" />
        <xsl:variable name="m" select="substring($date-str,5,2)" />
        <xsl:variable name="d" select="substring($date-str,7,2)" />

        <xsl:choose>
            <xsl:when test="string-length($date-str) != 8" />
            <xsl:when test="number($date-str) &lt; 19260101" />
            <xsl:otherwise>
                <xsl:call-template name="gengo">
                    <xsl:with-param name="date" select="$date-str" />
                </xsl:call-template>
                <xsl:call-template name="warekinen">
                    <xsl:with-param name="date" select="$date-str" />
                </xsl:call-template>
                <xsl:value-of select="'年'" />
                <xsl:value-of select="$m || '月'" />
                <xsl:value-of select="$d || '日'" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>