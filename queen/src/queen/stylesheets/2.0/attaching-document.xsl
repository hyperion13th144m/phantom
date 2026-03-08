<?xml version="1.0" encoding="UTF-8"?>

<!-- original attaching-document.xsl at Jan  9  2015
     sha256sum: 80e3d54ca38072e529d9f7f5edcbdf5db6ab817bee28e1faee4bfa29a5841b4f
-->

<!-- ====================================================================
     変換対象書類名：PCT中間電子化書類（添付書類）
     ====================================================================-->
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:jp="http://www.jpo.go.jp"
                xmlns:schema="urn:schema-dsl"
                xmlns:xf="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="xsl jp xf schema">
    
    <xsl:output method="text" encoding="UTF-8"/>
    <xsl:include href="debug.xsl"/>
    <xsl:param name="debug" select="'false'"/>
    
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:map>
                <xf:string key="tag">attaching-document</xf:string>
                <xf:string key="text">
                    <xsl:value-of select="(root/jp:attaching-document/jp:attaching-document-group)[1]/jp:document-name" />
                </xf:string>
                <xf:array key="blocks">
                    <xsl:apply-templates select="root/jp:attaching-document" />
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
    <schema:title>attaching-document</schema:title>
    <schema:object name="attaching-document" is-root="true">
        <schema:property name="tag" type="string" const="attaching-document" />
        <schema:property name="text" type="string"/>
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="document-name"/>
                <schema:ref name="image-container" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
   
    <!-- ====================================================================
         jp:attaching-document
         ====================================================================-->
    <xsl:template match="jp:attaching-document">
        <xsl:apply-templates select="jp:attaching-document-group" />
    </xsl:template>
    
    <!-- ====================================================================
         jp:attaching-document-group
         ====================================================================-->
    <xsl:template match="jp:attaching-document-group">
        <xsl:apply-templates select="jp:document-name" />
        <xsl:apply-templates select="p" />
    </xsl:template>
    
    <!-- ====================================================================
         document-name
         ====================================================================-->
    <!-- 物件名 -->
    <xsl:template match="jp:document-name">
        <xf:map>
            <xf:string key="tag"><xsl:value-of select="name()"/></xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【物件名】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'0'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
        </xf:map>
    </xsl:template>
    <schema:object name="document-name">
        <schema:property name="tag" type="string"
                         const="jp:document-name" />
        <schema:property name="jpTag" type="string" optional="true" />
        <schema:property name="text" type="string"/>
    </schema:object>
  
    <!-- ====================================================================
         p
         ====================================================================-->
    <!-- 段落 -->
    <xsl:template match="p">
        <xsl:apply-templates select="img" />
    </xsl:template>
    
    <!-- イメージ -->
    <xsl:template match="img">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="'image-container'" />
            </xf:string>
            <xf:string key="imageKind">
                <xsl:value-of select="'other-images'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'0'" />
            </xf:string>
            <xf:string key="file">
                <xsl:value-of select="@file" />
            </xf:string>
            <xf:string key="alt">
                <xsl:value-of select="'Image name: ' || @file" />
            </xf:string>
        </xf:map>
    </xsl:template>
    <schema:object name="image-container">
        <schema:property name="tag" type="string"
                         const="image-container" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="imageKind" type="string"
                         const="other-images" />
        <schema:property name="file" type="string"/>
        <schema:property name="alt" type="string" />
    </schema:object>
 </xsl:stylesheet>
