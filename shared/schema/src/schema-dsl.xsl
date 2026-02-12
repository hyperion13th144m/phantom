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
                <f:map key="properties">
                    <xsl:apply-templates select="//schema:object" />
                </f:map>
            </f:map>
        </xsl:variable>
        <xsl:value-of
            select="xml-to-json($data)" />
    </xsl:template>

    <!-- schema:object → JSON Schema object -->
    <xsl:template match="schema:object">
        <f:map key="{@name}">
            <f:string key="type">object</f:string>
            <f:map key="properties">
                <xsl:apply-templates select="schema:property" />
            </f:map>
        </f:map>
    </xsl:template>

    <xsl:template match="schema:property[@type='array']">
        <f:map key="{@name}">
            <f:string key="type">array</f:string>
            <f:map key="items">
                <xsl:choose>
                    <xsl:when test="schema:object">
                        <xsl:apply-templates select="schema:object" />
                    </xsl:when>
                    <xsl:when test="schema:anyOf">
                        <xsl:apply-templates select="schema:anyOf" />
                    </xsl:when>
                    <xsl:when test="schema:ref">
                        <xsl:apply-templates select="schema:ref" />
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
                    <xsl:for-each select="tokenize(@enum, '\s+')">
                        <f:string>
                            <xsl:value-of select="." />
                        </f:string>
                    </xsl:for-each>
                </f:array>
            </xsl:if>
        </f:map>
    </xsl:template>

    <xsl:template match="schema:anyOf">
        <f:array key="anyOf">
            <xsl:apply-templates select="schema:object | schema:ref" />
        </f:array>
    </xsl:template>

    <xsl:template match="schema:ref">
        <f:map>
            <f:string key="$ref">
                <xsl:value-of select="@file || '#/properties/' || @name" />
            </f:string>
        </f:map>
    </xsl:template>


    <!-- ルート：$defs に schema:object を全部まとめる
    <xsl:template match="/"> { "$schema": "http://json-schema.org/draft/2020-12/schema", "$defs": {
    <xsl:for-each
            select="//schema:object"> "<xsl:value-of select="@name" />": <xsl:apply-templates
                select="." mode="schema-object" />
                    <xsl:value-of select="." />
                    <xsl:if
                test="position() != last()">,</xsl:if>
        </xsl:for-each> } } </xsl:template>
 -->
    <!-- schema:object → JSON Schema object
    <xsl:template match="schema:object" mode="schema-object"> { "type": "object", "properties": {
    <xsl:apply-templates
            select="schema:property" mode="schema-property" /> }, "required": [ <xsl:for-each
            select="schema:property[not(@optional='true')]"> "<xsl:value-of select='@name' />" <xsl:if
                test="position() != last()">,</xsl:if>
        </xsl:for-each> ] } </xsl:template>
 -->
    <!-- プリミティブ: string
    <xsl:template match="schema:property[@type='string']" mode="schema-property"> "<xsl:value-of
            select='@name' />": { "type": "string" <xsl:if test="@const"> , "const": "<xsl:value-of
                select='@const' />" </xsl:if>
            <xsl:if test="@enum"> , "enum": [ <xsl:call-template
                name="emit-enum">
                <xsl:with-param name="value" select="@enum" />
            </xsl:call-template> ] </xsl:if>
        } <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>
 -->
    <!-- プリミティブ: number
    <xsl:template match="schema:property[@type='number']" mode="schema-property"> "<xsl:value-of
            select='@name' />": { "type": "number" } <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>
 -->
    <!-- プリミティブ: integer
    <xsl:template match="schema:property[@type='integer']" mode="schema-property"> "<xsl:value-of
            select='@name' />": { "type": "integer" } <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>
 -->
    <!-- プリミティブ: boolean
    <xsl:template match="schema:property[@type='boolean']" mode="schema-property"> "<xsl:value-of
            select='@name' />": { "type": "boolean" } <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>
 -->
    <!-- object プロパティ（ネストした schema:object を直接書く場合）
    <xsl:template match="schema:property[@type='object']" mode="schema-property"> "<xsl:value-of
            select='@name' />": <xsl:apply-templates select="schema:object" mode="schema-object" />
        <xsl:if
            test="position() != last()">,</xsl:if>
    </xsl:template>
 -->
    <!-- array プロパティ
    <xsl:template match="schema:property[@type='array']" mode="schema-property"> "<xsl:value-of
            select='@name' />": { "type": "array", "items": { <xsl:choose>
            <xsl:when test="@itemType"> "type": "<xsl:value-of select='@itemType' />" </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="schema:anyOf | schema:ref" mode="schema-items" />
            </xsl:otherwise>
        </xsl:choose>
        } } <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>
 -->
    <!-- items: anyOf
    <xsl:template match="schema:anyOf" mode="schema-items"> "anyOf": [ <xsl:apply-templates
            select="schema:ref" mode="schema-anyOf" /> ] </xsl:template>
 -->
    <!--
    <xsl:template match="schema:ref" mode="schema-anyOf"> { "$ref": "#/$defs/<xsl:value-of
            select='@name' />" } <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>
-->
    <!-- items: 単一 ref
    <xsl:template match="schema:ref" mode="schema-items"> "$ref": "#/$defs/<xsl:value-of
            select='@name' />" </xsl:template>
 -->
    <!-- enum の空白区切りを配列に展開
    <xsl:template name="emit-enum">
        <xsl:param name="value" />
        <xsl:variable name="trimmed" select="normalize-space($value)" />
        <xsl:choose>
            <xsl:when test="contains($trimmed, ' ')"> "<xsl:value-of
                    select="substring-before($trimmed, ' ')" />", <xsl:call-template
                    name="emit-enum">
                    <xsl:with-param name="value" select="substring-after($trimmed, ' ')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise> "<xsl:value-of select='$trimmed' />" </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    -->


</xsl:stylesheet>