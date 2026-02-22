<?xml version="1.0" encoding="UTF-8"?>

<!-- 
     original xsl: ntc-ninsyo.xsl at Jul 19  2023
     sha256sum:825bb9cfe4200bb3555d5d162644d2bc7d60e1e479fe3e8707ecd6573a19de60 
-->

<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:f="urn:phantom-mona:string-utils"
    xmlns:schema="urn:schema-dsl"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="f jp schema">
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <!-- schema:title is set to the name of this stylesheet -->
    <schema:title>ntc-ninsyo</schema:title>
    
    <!-- ====================================================================
         jp:certification-column-article 認証欄
         ====================================================================-->
    <xsl:template match="jp:certification-column-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:certification-column-group" />
                <xsl:apply-templates select="img" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="certification-column-article">
        <schema:property name="tag" type="string" const="jp:certification-column-article" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="certification-column-group" />
                <schema:ref name="image-container" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:inquiry-article 問い合わせ文
         ====================================================================-->
    <xsl:template match="jp:inquiry-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:map>
                <xf:map>
                    <xf:string key="tag">
                        <xsl:value-of select="'underline'" />
                    </xf:string>
                    <xf:string key="text">
                        <xsl:value-of select="'　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　'" />
                    </xf:string>
                </xf:map>
                
                <xf:map>
                    <xf:string key="tag">
                        <xsl:value-of select="'text'" />
                    </xf:string>
                    <xf:string key="text">
                        <xsl:value-of select="p" />
                    </xf:string>
                </xf:map>
                <xsl:apply-templates select="jp:inquiry-staff-group" />
                
                <xf:map>
                    <xf:string key="tag">
                        <xsl:value-of select="'text'" />
                    </xf:string>
                    <xf:string key="text">
                        <xsl:apply-templates select="jp:phone" />
                        <xsl:apply-templates select="jp:fax" />
                    </xf:string>
                </xf:map>
            </xf:map>
        </xf:map>
    </xsl:template>
    <schema:object name="inquiry-article">
        <schema:property name="tag" type="string" const="jp:inquiry-article" />
        <schema:property name="blocks" type="array">
            <schema:ref file="ntc-paragraph.json" name="inline-text" />
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:certification-column-group 認証文
         ====================================================================-->
    <xsl:template match="jp:certification-column-group">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xf:map>
                    <xf:string key="tag">
                        <xsl:value-of select="'text'" />
                    </xf:string>
                    <xf:string key="text">
                        <xsl:value-of select="p[1]" />
                    </xf:string>
                </xf:map>
                
                <xsl:apply-templates select="jp:certification-group" />
                
                <xsl:choose>
                    <xsl:when test="p[2]" >
                        <xf:map>
                            <xf:string key="tag">
                                <xsl:value-of select="'text'" />
                            </xf:string>
                            <xf:string key="text">
                                <xsl:value-of select="p[2]" />
                            </xf:string>
                        </xf:map>
                        <xsl:if test="jp:phone" >
                            <xf:map>
                                <xf:string key="tag">
                                    <xsl:value-of select="'text'" />
                                </xf:string>
                                <xf:string key="text">
                                    <xsl:apply-templates select="jp:phone" />
                                </xf:string>
                            </xf:map>
                            <xf:map>
                                <xf:string key="tag">
                                    <xsl:value-of select="'text'" />
                                </xf:string>
                                <xf:string key="text">
                                    <xsl:apply-templates select="jp:fax" />
                                </xf:string>
                            </xf:map>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="jp:inclusion-payment-group" >
                            <xsl:apply-templates select="jp:inclusion-payment-group" />
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="certification-column-group">
        <schema:property name="tag" type="string" const="jp:certification-column-group" />
        <schema:property name="blocks" type="array">
            <schema:ref file="ntc-paragraph.json" name="inline-text" />
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:inquiry-staff-group 担当者情報
         returns <blocks>tag(inline-text), text<blocks>
         ====================================================================-->
    <xsl:template match="jp:inquiry-staff-group">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="'text'" />
            </xf:string>
            <xf:string key="text">
                <xsl:apply-templates select="jp:division" />
                <xsl:value-of select="'　'" />
                <xsl:apply-templates select="jp:name" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:certification-group  認証情報
         returns <blocks>tag(inline-text), text<blocks>
         ====================================================================-->
    <xsl:template match="jp:certification-group">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="'text'" />
            </xf:string>
            <xf:string key="text">
                <xsl:apply-templates select="jp:date" />
                <xsl:value-of select="'　'" />
                <xsl:apply-templates select="jp:official-title" />
                <xsl:value-of select="'　'" />
                <xsl:apply-templates select="jp:name" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:inclusion-payment-group 包括納付情報
         returns List of <blocks> with tag(inline-text) text, text<blocks>
         ====================================================================-->
    <xsl:template match="jp:inclusion-payment-group">
        <xsl:apply-templates select="jp:account" />
        <xsl:apply-templates select="jp:payment-years" />
    </xsl:template>
    
    <!-- ====================================================================
         jp:certification-column-group/jp:phone |
         jp:inquiry-article//jp:phone  電話番号
         returns string
         ====================================================================-->
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
        <xsl:choose>
            <xsl:when test="ancestor::jp:inquiry-article" >
                <xsl:value-of select="'　電話　'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'電話'" />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="./@jp:error-code">
                <xsl:value-of select="." />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring(normalize-space(.),1,$tel1) ||
                    '(' ||
                    substring(normalize-space(.),($tel1 + 2),$tel2),')' ||
                    substring(normalize-space(.),($tel1 + $tel2 + 3),$tel3) ||
                    '　内線' || 
                    substring(normalize-space(.),($tel1 + $tel2 + $tel3 + 4) ||
                        $tel4)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ====================================================================
         jp:certification-column-group/jp:fax |
         jp:inquiry-article//jp:fax ファクシミリ番号
         returns string
         ====================================================================-->
    <xsl:template
        match="jp:certification-column-group/jp:fax
            | jp:inquiry-article//jp:fax">
        <xsl:variable name="fax1" select="string-length(substring-before(normalize-space(.),'-'))" />
        <xsl:variable name="fax2" select="string-length(substring-before(substring(normalize-space(.),$fax1 + 2),'-'))" />
        <xsl:variable name="fax3" select="string-length(substring(normalize-space(.),$fax1 + $fax2 + 3))" />
        <xsl:choose>
            <xsl:when test="ancestor::jp:inquiry-article" >
                <xsl:value-of select="'　　　ファクシミリ　'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'　　　ファクシミリ'" />
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:choose>
            <xsl:when test="./@jp:error-code">
                <xsl:value-of select="." />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring(normalize-space(.),1,$fax1) ||
                    '(' ||
                    substring(normalize-space(.),($fax1 + 2),$fax2) || ')' ||
                    substring(normalize-space(.),($fax1 + $fax2 + 3),$fax3)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ====================================================================
         jp:division 所属
         returns string
         ====================================================================-->
    <xsl:template match="jp:division">
        <xsl:value-of select="translate(.,' ','')" />
    </xsl:template>
    
    <!-- ====================================================================
         jp:account 予納台帳番号・納付書番号
         returns <blocks>tag(inline-text), text</blocks>
         ====================================================================-->
    <xsl:template match="jp:account">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="'text'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="'包括納付対象案件　'" />
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
                <xsl:value-of select="f:to-fullwidth-digit(./@number)" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    
    <!-- ====================================================================
         jp:certification-group/jp:date 認証・日付
         returns string
         ====================================================================-->
    <xsl:template match="jp:certification-group/jp:date">
        <xsl:value-of select="'認証日　'" />
        <xsl:if test="number(.) ne 0 and string-length(normalize-space(.)) ne 0">
            <xsl:call-template name="format-date-jp2">
                <xsl:with-param name="date-str" select="." />
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- ====================================================================
         jp:certification-group/jp:name 認証・名前
         returns string
         ====================================================================-->
    <xsl:template match="jp:certification-group/jp:name">
        <xsl:value-of select="normalize-space(.)" />
    </xsl:template>
    
    <!-- ====================================================================
         jp:inquiry-article/jp:name 担当者・名前
         returns string
         ====================================================================-->
    <xsl:template match="jp:inquiry-staff-group/jp:name">
        <xsl:value-of select="normalize-space(.)" />
    </xsl:template>
    
    <!-- ====================================================================
         jp:certification-group/jp:official-title 認証・役職名
         returns string
         ====================================================================-->
    <xsl:template match="jp:certification-group/jp:official-title">
        <xsl:value-of select="normalize-space(.)" />
    </xsl:template>
    
    <!-- ====================================================================
         jp:payment-years 納付年分
         returns <blocks> tag(inline-text), text<blocks>
         ====================================================================-->
    <xsl:template match="jp:payment-years">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="'text'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="'　　　　　　　　　納付年分　　　'" />
                <xsl:apply-templates select="jp:year-from" />
                <xsl:apply-templates select="jp:year-to" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:year-from 納付年分（自）
         returns string
         ====================================================================-->
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
         jp:year-to 納付年分（至
         returns string
         ====================================================================-->
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
   
    <!--  イメージ   -->
    <xsl:template match="img">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="'image-container'" />
            </xf:string>
            <xf:string key="imageKind">
                <xsl:value-of select="'other-images'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'0'" />
            </xf:string>
            <xf:string key="file">
                <xsl:value-of select="@file" />
            </xf:string>
            <xf:string key="alt">
                <xsl:value-of select="'Image ' ||  @file" />
            </xf:string>
       </xf:map>
    </xsl:template>
    <schema:object
        name="image-container">
        <schema:property name="tag" type="string"
                         const="image-container" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="imageKind" type="string"
                         const="other-images" />
        <schema:property name="file" type="string"/>
        <schema:property name="alt" type="string"/>
    </schema:object>
   
    <!-- ====================================================================
         未サポートタグ（jp:guidance）
         ====================================================================-->
    <xsl:template match="jp:guidance">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="'unsupported-tag'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="'&lt;' || name() || '&gt;'" />
                <xsl:value-of select="." />
                <xsl:value-of select="'&lt;/', name(), '&gt;'" />
                <xsl:value-of select="'is not supported in v4xva_ntc-pt-e.xsl'" />
            </xf:string>
        </xf:map>
    </xsl:template>
</xsl:stylesheet>
