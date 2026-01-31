<?xml version="1.0" encoding="UTF-8"?>

<!-- 
 original xsl: ntc-ninsyo.xsl at Jul 19  2023
sha256sum:825bb9cfe4200bb3555d5d162644d2bc7d60e1e479fe3e8707ecd6573a19de60 
-->

<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:f="urn:phantom-mona:string-utils"
    exclude-result-prefixes="f jp"
>

    <!-- ====================================================================
     jp:certification-column-article
     ====================================================================-->
    <!-- 認証欄  -->
    <xsl:template match="jp:certification-column-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:certification-column-group" />
            <xsl:apply-templates select="img" />
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:inquiry-article
     ====================================================================-->
    <!-- 問い合わせ文  -->
    <xsl:template match="jp:inquiry-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="p" />
            <xsl:apply-templates select="jp:inquiry-staff-group" />
            <xsl:apply-templates select="jp:phone" />
            <xsl:apply-templates select="jp:fax" />
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     img
    イメージ
    <xsl:template match="img">

        <xsl:element name="IMG">
            <xsl:attribute name="SRC">
                <xsl:value-of select="./@file" />
            </xsl:attribute>
            <xsl:attribute name="WIDTH">
                <xsl:value-of select="./@wi" />
            </xsl:attribute>
            <xsl:attribute name="HEIGHT">
                <xsl:value-of select="./@he" />
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
     ====================================================================-->

    <!-- ====================================================================
     jp:certification-column-article/img
     認証イメージ
    <xsl:template match="jp:certification-column-article/img">

        <xsl:element name="IMG">
            <xsl:attribute name="SRC">
                <xsl:value-of select="./@file" />
            </xsl:attribute>
            <xsl:attribute name="WIDTH">
                <xsl:value-of select="./@wi" />
            </xsl:attribute>
            <xsl:attribute name="HEIGHT">
                <xsl:value-of select="./@he" />
            </xsl:attribute>

            <xsl:attribute name="ALIGN">
                <xsl:value-of select="'right'" />
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
     ====================================================================-->

    <!-- ====================================================================
     jp:certification-column-group
     ====================================================================-->
    <!-- 認証文 -->
    <xsl:template match="jp:certification-column-group">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>

            <!-- <xsl:apply-templates select="p[1]" /> -->
            <xsl:apply-templates select="p" />
            <xsl:apply-templates select="jp:certification-group" />

        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:inquiry-staff-group
     ====================================================================-->
    <!-- 担当者情報 -->
    <xsl:template match="jp:inquiry-staff-group">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:division" />
            <xsl:apply-templates select="jp:name" />
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:certification-group
     ====================================================================-->
    <!--  認証情報 -->
    <xsl:template match="jp:certification-group">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:date" />
            <xsl:apply-templates select="jp:official-title" />
            <xsl:apply-templates select="jp:name" />
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:inclusion-payment-group
     ====================================================================-->
    <!--  包括納付情報 -->
    <xsl:template match="jp:inclusion-payment-group">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="'包括納付対象案件'" />
            </xsl:element>
            <xsl:apply-templates select="jp:account" />
            <xsl:apply-templates select="jp:payment-years" />
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:certification-column-group/jp:phone |
     jp:inquiry-article//jp:phone
     ====================================================================-->
    <!--  電話番号 -->
    <xsl:template
        match="jp:certification-column-group/jp:phone
                   | jp:inquiry-article//jp:phone">
        <xsl:variable name="tel1" select="string-length(substring-before(normalize-space(.),'-'))" />
        <xsl:variable name="tel2"
            select="string-length(substring-before(substring(normalize-space(.),$tel1 + 2),'-'))" />
        <xsl:variable name="tel3"
            select="string-length(substring-before(substring(normalize-space(.),$tel1 + $tel2 + 3),'('))" />
        <xsl:variable name="tel4"
            select="string-length(substring-before(substring(normalize-space(.),$tel1 + $tel2 + $tel3 + 4),')'))" />

        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jpTag">
                <xsl:value-of select="'電話'" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
            <xsl:element name="convertedText">
                <xsl:value-of
                    select="concat(substring(normalize-space(.),1,$tel1),'(',
                                  substring(normalize-space(.),($tel1 + 2),$tel2),')',
                                  substring(normalize-space(.),($tel1 + $tel2 + 3),$tel3),'　内線',
                                  substring(normalize-space(.),($tel1 + $tel2 + $tel3 + 4),$tel4))" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:certification-column-group/jp:fax |
     jp:inquiry-article//jp:fax
     ====================================================================-->
    <!--  ファクシミリ番号 -->
    <xsl:template
        match="jp:certification-column-group/jp:fax
                   | jp:inquiry-article//jp:fax">

        <xsl:if test="not(ancestor::jp:notice-transmit)">
            <xsl:variable name="fax1"
                select="string-length(substring-before(normalize-space(.),'-'))" />
            <xsl:variable name="fax2"
                select="string-length(substring-before(substring(normalize-space(.),$fax1 + 2),'-'))" />
            <xsl:variable name="fax3"
                select="string-length(substring(normalize-space(.),$fax1 + $fax2 + 3))" />
            <xsl:element name="blocks">
                <xsl:element name="tag">
                    <xsl:value-of select="name()" />
                </xsl:element>
                <xsl:element name="jpTag">
                    <xsl:value-of select="'ファクシミリ'" />
                </xsl:element>
                <xsl:element name="text">
                    <xsl:value-of select="normalize-space(.)" />
                </xsl:element>
                <xsl:element name="convertedText">
                    <xsl:value-of
                        select="concat(substring(normalize-space(.),1,$fax1),'(',
                              substring(normalize-space(.),($fax1 + 2),$fax2),')',
                              substring(normalize-space(.),($fax1 + $fax2 + 3),$fax3))" />
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- ====================================================================
     jp:division
     ====================================================================-->
    <!-- 所属  -->
    <xsl:template match="jp:division">
        <xsl:variable name="division" select="translate(.,' ','')" />

        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="$division" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:account
     ====================================================================-->
    <!-- 予納台帳番号・納付書番号  -->
    <xsl:template match="jp:account">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jpTag">
                <xsl:choose>
                    <xsl:when test="./@account-type = 'deposit'">
                        <xsl:value-of select="'予納台帳番号　'" />
                    </xsl:when>
                    <xsl:when test="./@account-type = 'transfer'">
                        <xsl:value-of select="'振替番号　　　'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'納付書番号　　'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="." />
            </xsl:element>
            <xsl:element name="convertedText">
                <xsl:value-of select="f:to-fullwidth-digit(./@number)" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:certification-group/jp:date
     ====================================================================-->
    <!-- 認証・日付  -->
    <xsl:template match="jp:certification-group/jp:date">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jpTag">
                <xsl:value-of select="'認証日'" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="." />
            </xsl:element>
            <xsl:element name="convertedText">
                <xsl:choose>
                    <xsl:when test="./@jp:error-code">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:when test="number(.) = 0 or string-length(normalize-space(.)) = 0">
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="format-date-jp2">
                            <xsl:with-param name="date-str" select="." />
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:certification-group/jp:name
     ====================================================================-->
    <!-- 認証・名前  -->
    <xsl:template match="jp:certification-group/jp:name">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:inquiry-article/jp:name
     ====================================================================-->
    <!-- 担当者・名前  -->
    <xsl:template match="jp:inquiry-staff-group/jp:name">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:certification-group/jp:official-title
     ====================================================================-->
    <!-- 認証・役職名  -->
    <xsl:template match="jp:certification-group/jp:official-title">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:payment-years
     ====================================================================-->
    <!-- 納付年分     -->
    <xsl:template match="jp:payment-years">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jpTag">
                <xsl:value-of select="'納付年分'" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:apply-templates select="jp:year-from" />
                <xsl:apply-templates select="jp:year-to" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:year-from
     ====================================================================-->
    <!-- 納付年分（自） -->
    <xsl:template match="jp:year-from">
        <xsl:choose>
            <xsl:when test="./@jp:error-code">
                <xsl:value-of select="." />
                <xsl:value-of select="'年～'" />
            </xsl:when>
            <xsl:when test="string-length(normalize-space(.)) = 0" />
            <xsl:otherwise>
                <xsl:value-of
                    select="f:to-fullwidth-digit(.)" />
                <xsl:value-of select="'年～'" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     jp:year-to
     ====================================================================-->
    <!-- 納付年分（至） -->
    <xsl:template match="jp:year-to">
        <xsl:choose>
            <xsl:when test="./@jp:error-code">
                <xsl:value-of select="." />
                <xsl:value-of select="'年分'" />
            </xsl:when>
            <xsl:when test="string-length(normalize-space(.)) = 0" />
            <xsl:otherwise>
                <xsl:value-of select="f:to-fullwidth-digit(.)" />
                <xsl:value-of select="'年分'" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     未サポートタグ（jp:guidance）
     ====================================================================-->
    <xsl:template match="jp:guidance">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="'unsupported-tag'" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="'&lt;' || name() || '&gt;'" />
                <xsl:value-of select="." />
                <xsl:value-of select="'&lt;/', name(), '&gt;'" />
                <xsl:value-of select="'is not supported in v4xva_ntc-pt-e.xsl'" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>