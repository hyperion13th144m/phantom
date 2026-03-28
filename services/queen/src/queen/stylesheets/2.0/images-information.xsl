<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    xmlns:schema="urn:schema-dsl">

    <!-- this file is used for generating JSON schema for images information -->
    <xsl:output method="text" encoding="UTF-8" />
    <xsl:param name="debug" select="'false'"/>

    <xsl:include href="debug.xsl"/>

    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:array>
                <xsl:apply-templates select="root/images/image" />
            </xf:array>
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

    <xsl:template match="image">
        <xsl:variable name="filename" select="@filename" />
        <xsl:variable name="figure" select="//application-body/drawings/figure/img[@file = $filename]" />
        <xsl:variable name="fignum">
            <xsl:choose>
                <xsl:when test="$figure">
                    <!-- 図面の簡単な説明 figref の num と、
                         図面のfigure の num は一致しないことがある。
                         外内などは図番号に "1-1"とか使われるが、
                         figrefは通番で1,2,3,... であるため。
                         1-1, 1-2 などは、図1扱いとして、figref num=1 の説明を description にする。
                         1a なども同様に、図1扱いとする。
                    -->
                    <xsl:variable name="raw-num" select="replace($figure/parent::figure/@num, '[a-zA-Z]', '')" />
                    <xsl:choose>
                        <xsl:when test="contains($raw-num, '-')">
                            <xsl:value-of select="substring-before($raw-num, '-')" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$raw-num"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="description">
            <xsl:choose>
                <xsl:when test="string-length($fignum) > 0">
                    <!-- 明細書の簡単な図面の説明を探す -->
                    <xsl:for-each select="//application-body//description-of-drawings//figref">
                        <xsl:if test="./@num = $fignum">
                            <xsl:value-of select="normalize-space(.)" />
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="repr-image" select="//jp:representation-image/jp:file-name"/>

        <xf:map>
            <xf:string key="filename">
                <xsl:value-of select="@filename" />
            </xf:string>
            <xf:string key="sha256">
                <xsl:value-of select="@sha256" />
            </xf:string>
            <xf:string key="mediaType">
                <xsl:value-of select="@media-type" />
            </xf:string>
            <xf:string key="kind">
                <xsl:value-of select="@kind" />
            </xf:string>
            <xf:string key="number">
                <xsl:value-of select="$fignum" />
            </xf:string>
            <xf:string key="description">
                <xsl:value-of select="$description" />
            </xf:string>
            <xf:boolean key="representative">
                <xsl:choose>
                    <xsl:when test="$repr-image = $filename">
                        <xsl:text>true</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>false</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:boolean>
            <xf:string key="ocrText">
                <xsl:value-of select="ocr" />
            </xf:string>
            <xf:array key="derived">
                <xsl:apply-templates select="derived"/>
            </xf:array>
        </xf:map>
    </xsl:template>

    <xsl:template match="derived">
        <xf:map>
            <xf:string key="filename">
                <xsl:value-of select="@filename" />
            </xf:string>
            <xf:string key="sha256">
                <xsl:value-of select="@sha256" />
            </xf:string>
            <xf:string key="media_type">
                <xsl:value-of select="@media-type" />
            </xf:string>
            <xf:number key="width">
                <xsl:value-of select="@width" />
            </xf:number>
            <xf:number key="height">
                <xsl:value-of select="@height" />
            </xf:number>
            <xf:array key="attributes">
                <xsl:apply-templates select="attribute"/>
            </xf:array>
        </xf:map>
    </xsl:template>

    <xsl:template match="attribute">
        <xf:map>
            <xf:string key="key">
                <xsl:value-of select="@key" />
            </xf:string>
            <xf:string key="value">
                <xsl:value-of select="@value" />
            </xf:string>
        </xf:map>
    </xsl:template>

    <schema:title>images-information</schema:title>
    <schema:object name="images-information" is-root="true">
        <!-- images-information.json は ocr の結果, 代表図の情報が追加される。
             text は ocr の項目, representative は代表図の項目。 -->
        <schema:property name="filename" type="string"/>
        <schema:property name="sha256" type="string"/>
        <schema:property name="mediaType" type="string"/>
        <schema:property name="kind" type="string"/>
        <schema:property name="number" type="string" optional="true"/>
        <schema:property name="description" type="string" optional="true"/>
        <schema:property name="ocrText" type="string" optional="true"/>
        <schema:property name="representative" type="boolean" optional="true"/>
        <schema:property name="derived" type="array">
            <schema:ref name="derived-image"/>
        </schema:property>
    </schema:object>
    <schema:object name="derived-image">
        <schema:property name="filename" type="string"/>
        <schema:property name="sha256" type="string"/>
        <schema:property name="media_type" type="string"/>
        <schema:property name="width" type="integer"/>
        <schema:property name="height" type="integer"/>
        <schema:property name="attributes" type="array" optional="true">
            <schema:ref name="image-attributes"/>
        </schema:property>
    </schema:object>
    <schema:object name="image-attributes">
        <schema:property name="key" type="string"/>
        <schema:property name="value" type="string"/>
    </schema:object>
</xsl:stylesheet>
