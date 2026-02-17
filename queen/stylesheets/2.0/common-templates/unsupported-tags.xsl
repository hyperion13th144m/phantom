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
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="jp schema">

    <xsl:output method="text" encoding="UTF-8" />

    <!-- schema:title is set to the name of this stylesheet -->
    <schema:title>unsupported-tags</schema:title>
    
    <xsl:template name="unsupported-tag">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="'unsupported-tag'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="'&lt;' || name() || '&gt;'" />
                <xsl:value-of select="." />
                <xsl:value-of select="'&lt;/', name(), '&gt;'" />
                <xsl:value-of select="'is not supported in v4xva_ntc-pt-f.xsl'" />
            </xf:string>
        </xf:map>
    </xsl:template>
    <schema:object name="unsupported-tag" is-root="true">>
        <schema:property name="tag" type="string"
                         const="unsupported-tag" />
        <schema:property name="text" type="string" />
    </schema:object>
</xsl:stylesheet>