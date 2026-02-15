<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://www.w3.org/2005/xpath-functions/json"
    xmlns:schema="urn:schema-dsl"
    exclude-result-prefixes="schema"
    xmlns:f="http://www.w3.org/2005/xpath-functions"
    version="1.0">

    <xsl:output method="text" encoding="UTF-8" />

    <!-- 
      <schema:title> をタイトルにしてルートオブジェクトを生成
      <schema:object> はすべて properties にまとめる
    -->
    <xsl:template match="/">
        <xsl:variable name="data">
            <f:map>
                <f:string key="$schema">http://json-schema.org/draft/2020-12/schema</f:string>
                <f:string key="type">object</f:string>
                <f:string key="title">
                    <xsl:value-of select="//schema:title" />
                </f:string>
                <xsl:choose>
                    <xsl:when test="//schema:object/@is-root = 'true'">
                        <f:map key="properties">
                            <xsl:apply-templates select="//schema:property" />
                        </f:map>
                    </xsl:when>
                    <xsl:otherwise>
                        <f:map key="$defs">
                            <xsl:apply-templates select="//schema:object" />
                        </f:map>
                    </xsl:otherwise>
                </xsl:choose>
            </f:map>
        </xsl:variable>
        <xsl:value-of
            select="xml-to-json($data)" />
    </xsl:template>

    <xsl:template match="schema:object">
        <f:map key="{@name}">
            <f:string key="type">object</f:string>
            <f:map key="properties">
                <xsl:apply-templates select="schema:property" />
            </f:map>
            <f:array key="required">
                <xsl:for-each select="schema:property[not(@optional='true')]">
                    <f:string>
                        <xsl:value-of select="@name" />
                    </f:string>
                </xsl:for-each>
            </f:array>
        </f:map>
    </xsl:template>

    <xsl:template match="schema:anyOf">
        <f:array key="anyOf">
            <xsl:apply-templates select="schema:property" />
            <xsl:apply-templates select="schema:ref" mode="with-map" />
        </f:array>
    </xsl:template>

    <xsl:template match="schema:ref" mode="with-map">
        <f:map>
            <xsl:apply-templates select="." mode="no-map" />
        </f:map>
    </xsl:template>

    <xsl:template match="schema:ref" mode="no-map">
        <f:string key="$ref">
            <xsl:if test="@file">
                <xsl:value-of select="@file" />
            </xsl:if>
            <xsl:text>#/$defs/</xsl:text>
            <xsl:value-of select="@name" />
        </f:string>
    </xsl:template>

    <xsl:template match="schema:property[@type='object']">
        <f:map key="{@name}">
            <xsl:apply-templates select="schema:object" />
        </f:map>
    </xsl:template>

    <xsl:template match="schema:property[@type='array']">
        <f:map key="{@name}">
            <f:string key="type">array</f:string>
            <f:map key="items">
                <xsl:choose>
                    <xsl:when test="@item-type">
                        <f:string key="type">
                            <xsl:value-of select="@item-type" />
                        </f:string>
                    </xsl:when>
                    <xsl:when
                        test="count(*) = 1 and schema:object">
                        <xsl:apply-templates select="schema:object" />
                    </xsl:when>
                    <xsl:when
                        test="count(*) = 1 and schema:ref">
                        <xsl:apply-templates select="schema:ref" mode="no-map" />
                    </xsl:when>
                    <xsl:when test="schema:anyOf">
                        <xsl:apply-templates select="schema:anyOf" />
                    </xsl:when>
                </xsl:choose>
            </f:map>
        </f:map>
    </xsl:template>

    <xsl:template match="schema:property[@type='string']">
        <f:map key="{@name}">
            <f:string key="type">string</f:string>
            <xsl:if test="@const">
                <f:string key="const">
                    <xsl:value-of select="@const" />
                </f:string>
            </xsl:if>
            <xsl:if test="@enum">
                <f:array key="enum">
                    <xsl:for-each select="tokenize(@enum, ',|\n+|\s+')">
                        <xsl:if test=". != ''">
                            <f:string>
                                <xsl:value-of select="." />
                            </f:string>
                        </xsl:if>
                    </xsl:for-each>
                </f:array>
            </xsl:if>
        </f:map>
    </xsl:template>

    <xsl:template match="schema:property[@type='number']">
        <f:map key="{@name}">
            <f:string key="type">number</f:string>
        </f:map>
    </xsl:template>

    <xsl:template match="schema:property[@type='integer']">
        <f:map key="{@name}">
            <f:string key="type">integer</f:string>
        </f:map>
    </xsl:template>

    <xsl:template match="schema:property[@type='boolean']">
        <f:map key="{@name}">
            <f:string key="type">boolean</f:string>
        </f:map>
    </xsl:template>
</xsl:stylesheet>