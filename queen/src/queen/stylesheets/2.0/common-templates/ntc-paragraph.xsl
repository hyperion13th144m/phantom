<?xml version="1.0" encoding="UTF-8"?>

<!-- 
 発送書類用に、paragraphなど共通テンプレート・スキーマを定義した
-->

<!-- ====================================================================
　　　変換対象書類名：特実審査周辺（共通部）
　   ====================================================================-->
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:f="urn:phantom-mona:string-utils"
    xmlns:schema="urn:schema-dsl"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="f jp">

    <xsl:output method="text" encoding="UTF-8" />

    <!-- schema:title is set to the name of this stylesheet -->
    <schema:title>ntc-paragraph</schema:title>

    <!-- ====================================================================
     p 段落 ,段落内テキスト
     ====================================================================-->
    <xsl:template match="p">
        <xf:map>
            <xf:string key="tag">paragraph</xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="paragraph">
        <schema:property name="tag" type="string" const="paragraph" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="inline-text" />
                <schema:ref file="ntc-ninsyo.json" name="image-container" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <xsl:template match="text() | sup | sub | u">
        <xsl:variable name="tag">
            <xsl:choose>
                <xsl:when test="self::text()">text</xsl:when>
                <xsl:when test="self::sup">sup</xsl:when>
                <xsl:when test="self::sub">sub</xsl:when>
                <xsl:when test="self::u">underline</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- 次の「有意ノード」を見る -->
        <xsl:variable name="nextNode"
            select="following-sibling::node()[not(self::text()[normalize-space(.)=''])][1]" />

        <!-- 次が br か、次が存在しない（p末尾）なら true -->
        <xsl:variable name="isLastSentence"
            select="if (empty($nextNode) or $nextNode/self::br) then 'true' else 'false'" />

        <xsl:if test="normalize-space() != ''">
            <xf:map>
                <xf:string key="tag">
                    <xsl:value-of select="$tag" />
                </xf:string>
                <xf:string key="text">
                    <xsl:call-template name="trim">
                        <xsl:with-param name="text" select="f:remove-nbsp(.)" />
                    </xsl:call-template>
                </xf:string>
                <xf:boolean key="isLastSentence">
                    <xsl:value-of select="$isLastSentence" />
                </xf:boolean>
            </xf:map>
        </xsl:if>
    </xsl:template>
    <schema:object name="inline-text">
        <schema:property name="tag" type="string" enum="text sup sub underline" />
        <schema:property name="text" type="string" />
        <schema:property name="isLastSentence" type="boolean" />
    </schema:object>

    <schema:object name="unsupported-tag">
        <schema:property name="tag" type="string"
                         const="unsupported-tag" />
        <schema:property name="text" type="string" />
    </schema:object>
</xsl:stylesheet>