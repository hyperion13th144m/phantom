<?xml version="1.0" encoding="UTF-8"?>

<!-- 発送書類の jp:dispatch-control-article -->

<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:jp="http://www.jpo.go.jp"
                xmlns:schema="urn:schema-dsl">
    
    <xsl:template match="jp:dispatch-control-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates />
        </xsl:element>
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
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
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
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>
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