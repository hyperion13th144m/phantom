<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:schema="urn:schema-dsl"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="xsl jp schema xf map">
    
    <!-- this xslt was created with reference to pat_common.xsl
         of Internet Application Software version i5.30 provided by JPO -->
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <xsl:variable name="node" select="name(//jp:pat-app-doc/*)" />
    <xsl:variable name="kind-of-law" select="//jp:pat-app-doc/*/@jp:kind-of-law" />
    <xsl:variable name="kinddoc" select="name(//jp:pat-app-doc/*)" />
    <xsl:variable name="payment" select="substring($node,1,11)" />
    <xsl:param name="debug" select="'false'"/>
    
    <xsl:include href="common-templates/pat_common.xsl" />
    <xsl:include href="debug.xsl"/>
    
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:map>
                <xf:string key="tag">pat-app-doc</xf:string>
                <xf:string key="text">
                    <xsl:call-template name="書類名変換" />
                </xf:string>
                <xf:array key="blocks">
                    <xsl:apply-templates select="root/jp:pat-app-doc" />
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
    <schema:title>pat-app-doc</schema:title>
    <schema:object name="pat-app-doc" is-root="true">
        <schema:property name="tag" type="string" const="pat-app-doc" />
        <schema:property name="text" type="string"/>
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="application-a63"/>
                <schema:ref name="application-a631"/>
                <schema:ref name="application-a632"/>
                <schema:ref name="application-a633"/>
                <schema:ref name="application-a634"/>
                <schema:ref name="application-a635"/>
            </schema:anyOf>
        </schema:property>
    </schema:object>    
    
    <!-- ====================================================================
         jp:application-a63 特許願,実用新案登録願
         ====================================================================-->
    <xsl:template match="jp:application-a63">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:file-reference-id" />
                <xsl:apply-templates select="jp:special-mention-matter-article" />
                <xsl:apply-templates select="jp:submission-date" />
                <xsl:apply-templates select="jp:addressed-to-person" />
                <xsl:apply-templates select="jp:parent-application-article" />
                <xsl:apply-templates select="jp:ipc-article" />
                <xsl:apply-templates select="jp:inventors" />
                <xsl:apply-templates select="jp:applicants" />
                <xsl:apply-templates select="jp:trust-relation" />
                <xsl:apply-templates select="jp:agents" />
                <xsl:apply-templates select="jp:attorney-change-article" />
                <xsl:apply-templates select="jp:priority-claims" />
                <xsl:apply-templates select="jp:declaration-priority-ear-app" />
                <xsl:apply-templates select="jp:law-of-industrial-regenerate" />
                <xsl:apply-templates select="jp:payment-years" />
                <xsl:apply-templates select="jp:share-rate" />
                <xsl:apply-templates select="jp:charge-article" />
                <xsl:apply-templates select="jp:dtext" />
                <xsl:apply-templates select="jp:submission-object-list-article" />
                <xsl:apply-templates select="jp:proof-necessity" />
                <xsl:apply-templates select="jp:rule-outside-item-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="application-a63">
        <schema:property name="tag" type="string" const="jp:application-a63" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="pat-common-terminal-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-b"/>
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    
    <!-- ====================================================================
         jp:application-a631 翻訳文提出書
         ====================================================================-->
    <xsl:template match="jp:application-a631">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:file-reference-id" />
                <xsl:apply-templates select="jp:submission-date" />
                <xsl:apply-templates select="jp:addressed-to-person" />
                <xsl:apply-templates select="jp:indication-of-case-article" />
                <xsl:apply-templates select="jp:proof-necessity" />
                <xsl:apply-templates select="jp:applicants" />
                <xsl:apply-templates select="jp:agents" />
                <xsl:apply-templates select="jp:dispatch-number" />
                <xsl:apply-templates select="jp:dispatch-date" />
                <xsl:apply-templates select="jp:notice-contents-group" />
                <xsl:apply-templates select="jp:dtext" />
                <xsl:apply-templates select="jp:submission-object-list-article" />
                <xsl:apply-templates select="jp:rule-outside-item-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="application-a631">
        <schema:property name="tag" type="string" const="jp:application-a631" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="pat-common-terminal-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-b"/>
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:application-a632 国内書面
         ====================================================================-->
    <xsl:template match="jp:application-a632">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:file-reference-id" />
                <xsl:apply-templates select="jp:submission-date" />
                <xsl:apply-templates select="jp:addressed-to-person" />
                <xsl:apply-templates select="jp:indication-of-case-article" />
                <xsl:apply-templates select="jp:inventors" />
                <xsl:apply-templates select="jp:applicants" />
                <xsl:apply-templates select="jp:trust-relation" />
                <xsl:apply-templates select="jp:agents" />
                <xsl:apply-templates select="jp:attorney-change-article" />
                <xsl:apply-templates select="jp:law-of-industrial-regenerate" />
                <xsl:apply-templates select="jp:payment-years" />
                <xsl:apply-templates select="jp:share-rate" />
                <xsl:apply-templates select="jp:charge-article" />
                <xsl:apply-templates select="jp:dispatch-number" />
                <xsl:apply-templates select="jp:notice-contents-group" />
                <xsl:apply-templates select="jp:dtext" />
                <xsl:apply-templates select="jp:submission-object-list-article" />
                <xsl:apply-templates select="jp:rule-outside-item-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="application-a632">
        <schema:property name="tag" type="string" const="jp:application-a632" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="pat-common-terminal-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-b"/>
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:application-a633 図面の提出書（実案）
         ====================================================================-->
    <xsl:template match="jp:application-a633">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:file-reference-id" />
                <xsl:apply-templates select="jp:submission-date" />
                <xsl:apply-templates select="jp:addressed-to-person" />
                <xsl:apply-templates select="jp:indication-of-case-article" />
                <xsl:apply-templates select="jp:applicants" />
                <xsl:apply-templates select="jp:agents" />
                <xsl:apply-templates select="jp:dispatch-number" />
                <xsl:apply-templates select="jp:dtext" />
                <xsl:apply-templates select="jp:submission-object-list-article" />
                <xsl:apply-templates select="jp:rule-outside-item-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="application-a633">
        <schema:property name="tag" type="string" const="jp:application-a633" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="pat-common-terminal-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-b"/>
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:application-a634 国際出願翻訳文提出書
         ====================================================================-->
    <xsl:template match="jp:application-a634">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:file-reference-id" />
                <xsl:apply-templates select="jp:submission-date" />
                <xsl:apply-templates select="jp:addressed-to-person" />
                <xsl:apply-templates select="jp:indication-of-case-article" />
                <xsl:apply-templates select="jp:applicants" />
                <xsl:apply-templates select="jp:agents" />
                <xsl:apply-templates select="jp:dtext" />
                <xsl:apply-templates select="jp:submission-object-list-article" />
                <xsl:apply-templates select="jp:rule-outside-item-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="application-a634">
        <schema:property name="tag" type="string" const="jp:application-a634" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="pat-common-terminal-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-b"/>
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:application-a635 国際出願翻訳文提出書（職権）
         ====================================================================-->
    <xsl:template match="jp:application-a635">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:file-reference-id" />
                <xsl:apply-templates select="jp:submission-date" />
                <xsl:apply-templates select="jp:addressed-to-person" />
                <xsl:apply-templates select="jp:indication-of-case-article" />
                <xsl:apply-templates select="jp:applicants" />
                <xsl:apply-templates select="jp:agents" />
                <xsl:apply-templates select="jp:notice-contents-group" />
                <xsl:apply-templates select="jp:dtext" />
                <xsl:apply-templates select="jp:submission-object-list-article" />
                <xsl:apply-templates select="jp:rule-outside-item-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="application-a635">
        <schema:property name="tag" type="string" const="jp:application-a635" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="pat-common-terminal-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-a"/>
                <schema:ref file="pat_common.json" name="pat-common-container-type-b"/>
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
</xsl:stylesheet>