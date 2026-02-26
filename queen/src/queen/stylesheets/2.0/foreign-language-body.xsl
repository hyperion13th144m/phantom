<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:schema="urn:schema-dsl"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xsl jp xf schema">
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <xsl:variable name="node" select="name(//jp:foreign-language-body/*)" />
    <xsl:variable
        name="kind-of-law"
        select="//jp:foreign-language-body/*/@jp:kind-of-law" />
    <xsl:variable name="kinddoc"
        select="name(//jp:foreign-language-body/*)" />
    <xsl:variable name="payment"
        select="substring($node,1,11)" />
    <xsl:param name="debug" select="'false'"/>
    
    <xsl:include href="common-templates/pat_common.xsl" />
    <xsl:include href="debug.xsl"/>
    
    <xsl:variable
        name="law">
        <xsl:choose>
            <xsl:when
                test="//jp:procedure//jp:law = '1'">patent</xsl:when>
            <xsl:when
                test="//jp:procedure//jp:law = '2'">utility-model</xsl:when>
            <xsl:otherwise>unknown</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:map>
                <xf:string key="tag">foreign-language-body</xf:string>
                <xf:array key="blocks">
                    <xsl:apply-templates
                        select="root/jp:foreign-language-body/jp:foreign-language-description" />
                    <xsl:apply-templates select="root/jp:foreign-language-body/jp:foreign-language-claims" />
                    <xsl:apply-templates select="root/jp:foreign-language-body/jp:foreign-language-abstract" />
                    <xsl:apply-templates select="root/jp:foreign-language-body/jp:foreign-language-drawings" />
                </xf:array>
            </xf:map>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$debug = 'true'">
                <xsl:apply-templates select="$root/xf:map"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="xml-to-json($root)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <schema:title>foreign-language-body</schema:title>
    <schema:object name="foreign-language-body" is-root="true">
        <schema:property name="tag" type="string"
                         const="foreign-language-body"/>
        <schema:property name="blocks" type="array">
            <schema:ref name="foreign-language-documents" />
        </schema:property>
    </schema:object>
    
    <!-- 明細書 特許請求の範囲,図面,要約書-->
    <xsl:template
        match="jp:foreign-language-description | jp:foreign-language-claims |
            jp:foreign-language-abstract | jp:foreign-language-drawings">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【書類名】'" />
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="self::jp:foreign-language-description">
                        <xsl:value-of select="'外国語明細書'" />
                    </xsl:when>
                    <xsl:when test="self::jp:foreign-language-claims">
                        <xsl:value-of select="'外国語特許請求の範囲'" />
                    </xsl:when>
                    <xsl:when test="self::jp:foreign-language-abstract">
                        <xsl:value-of select="'外国語要約書'" />
                    </xsl:when>
                    <xsl:when test="self::jp:foreign-language-drawings">
                        <xsl:value-of select="'外国語図面'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'0'" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="p" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="foreign-language-documents">
        <schema:property
            name="tag" type="string"
                   enum="jp:foreign-language-description,
                         jp:foreign-language-claims,
                         jp:foreign-language-abstract,
                         jp:foreign-language-drawings" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="text" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref file="pat_common.json" name="paragraph" />
        </schema:property>
    </schema:object>
</xsl:stylesheet>