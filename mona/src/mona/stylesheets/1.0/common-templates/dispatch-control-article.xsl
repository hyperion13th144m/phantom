<?xml version="1.0" encoding="UTF-8"?>

<!-- 発送書類の jp:dispatch-control-article -->

<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:schema="urn:schema-dsl">

    <!-- 'dca' is abbreviation for dispatch-control-article -->
    <xsl:template match="jp:dispatch-control-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    <schema:object name="dispatch-control-article">
        <schema:property name="tag" type="string"
            const="jp:dispatch-control-article" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="file-reference-id" />
                <schema:ref name="dispatch-number" />
                <schema:ref name="dca-dispatch-date" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <xsl:template match="jp:file-reference-id">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'整理番号'" />
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- schema of this template is defined in pat_common.xsl -->

    <xsl:template match="jp:dispatch-number">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'発送番号'" />
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- schema of this template is defined in pat_common.xsl -->

    <xsl:template match="jp:dispatch-date">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="dca-dispatch-date" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'発送日'" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="dca-dispatch-date">
        <schema:property name="tag" type="string"
            const="dca-dispatch-date" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="text" type="string" />
    </schema:object>

</xsl:stylesheet>