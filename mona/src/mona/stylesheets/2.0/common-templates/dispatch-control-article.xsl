<?xml version="1.0" encoding="UTF-8"?>

<!-- 発送書類の jp:dispatch-control-article -->

<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    xmlns:schema="urn:schema-dsl">
    
    <xsl:output method="text" encoding="UTF-8" />

    <xsl:template match="jp:dispatch-control-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
            <xsl:apply-templates />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:title>dispatch-control-article</schema:title>
    <schema:object name="dispatch-control-article">
        <schema:property name="tag" type="string"
                         const="jp:dispatch-control-article" />
        <schema:property name="blocks" type="array">
            <schema:ref name="dispatch-control-article-items" />
        </schema:property>
    </schema:object>
    
    <xsl:template match="jp:file-reference-id | jp:dispatch-number | jp:dispatch-date">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jp-tag">
                <xsl:choose>
                    <xsl:when test="self::jp:file-reference-id">
                        <xsl:value-of select="'整理番号'" />
                    </xsl:when>
                    <xsl:when test="self::jp:dispatch-number">
                        <xsl:value-of select="'発送番号'" />
                    </xsl:when>
                    <xsl:when test="self::jp:dispatch-date">
                        <xsl:value-of select="'発送日'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
            <xf:string key="indent-level">0</xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <schema:object name="dispatch-control-article-items">
        <schema:property name="tag" type="string"
                         enum="jp:file-reference-id,
                               jp:dispatch-number,
                               jp:dispatch-date" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="indent-level" type="string" />
        <schema:property name="text" type="string" />
    </schema:object>
    
</xsl:stylesheet>