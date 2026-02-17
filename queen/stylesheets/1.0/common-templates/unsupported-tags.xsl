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
    xmlns:schema="urn:schema-dsl"
    exclude-result-prefixes="jp schema">

    <!-- schema:title is set to the name of this stylesheet -->
    <schema:title>unsupported-tags</schema:title>
    
    <xsl:template name="unsupported-tag">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="'unsupported-tag'" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="'&lt;' || name() || '&gt;'" />
                <xsl:value-of select="." />
                <xsl:value-of select="'&lt;/', name(), '&gt;'" />
                <xsl:value-of select="'is not supported in v4xva_ntc-pt-f.xsl'" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="unsupported-tag" is-root="true">>
        <schema:property name="tag" type="string"
                         const="unsupported-tag" />
        <schema:property name="text" type="string" />
    </schema:object>
</xsl:stylesheet>