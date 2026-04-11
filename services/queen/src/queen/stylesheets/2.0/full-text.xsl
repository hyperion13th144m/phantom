<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:jp="http://www.jpo.go.jp"
                xmlns:schema="urn:schema-dsl"
                xmlns:xf="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="xsl jp schema xf">
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <xsl:include href="common-templates/special-mention-matter-article.xsl" />
    <xsl:include href="common-templates/string-utils.xsl" />
    <xsl:include href="common-templates/bibliographic-items.xsl"/>
    <xsl:include href="debug.xsl"/>
    
    <xsl:variable name="law-code" select="/root/jp:procedure//jp:law" />
    <xsl:variable name="kind-of-law">
        <xsl:choose>
            <xsl:when test="$law-code='1'">patent</xsl:when>
            <xsl:when test="$law-code='2'">utility</xsl:when>
            <xsl:when test="$law-code='3'">design</xsl:when>
            <xsl:when test="$law-code='4'">trademark</xsl:when>
            <xsl:otherwise>unknown</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:param name="debug" select="'false'"/>
    
    
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:map>
                <xsl:apply-templates select="root/application-body/description" />
                <xsl:apply-templates select="root/application-body/claims" />
                <xsl:apply-templates select="root/application-body/abstract" />
                <xsl:apply-templates select="root/jp:foreign-language-body" />
                <xsl:apply-templates select="root/jp:cpy-notice-pat-exam-rn" />
                <xsl:apply-templates select="root/jp:cpy-notice-pat-exam" />
                <xsl:apply-templates select="root/images" />
                
                <!-- 以下、common-templates/bibliographic-items.xsl のテンプレート -->
                <xsl:apply-templates select="root/jp:pat-app-doc" />
                <xsl:apply-templates select="root/jp:pat-amnd" />
                <xsl:apply-templates select="root/jp:pat-rspns" />
                <xsl:apply-templates select="root/jp:pat-etc" />
                <xsl:apply-templates select="root/jp:m-mi-notice-doc" />
                <xsl:apply-templates select="root/jp:procedure" />
                <xsl:apply-templates select="root/sources" />
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
    
    <!-- common-templates/bibliographic-items.xsl のテンプレート 
         と重複しないように mode="full-text" を指定している -->
    <xsl:template match="jp:pat-app-doc">
        <xsl:apply-templates select="jp:application-a63" mode="full-text" />
        <xsl:apply-templates select="jp:application-a631" mode="full-text" />
        <xsl:apply-templates select="jp:application-a632" mode="full-text" />
        <xsl:apply-templates select="jp:application-a633" mode="full-text" />
        <xsl:apply-templates select="jp:application-a634" mode="full-text" />
        <xsl:apply-templates select="jp:application-a635" mode="full-text" />
    </xsl:template>
    <xsl:template
        match="jp:application-a63 | jp:application-a631 |
            jp:application-a632 | jp:application-a633 |
            jp:application-a634 | jp:application-a635" mode="full-text">
        <xsl:apply-templates select="jp:inventors" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:special-mention-matter-article" />
        <xsl:apply-templates select="jp:law-of-industrial-regenerate" />
        
        <xf:array key="priorityClaims">
            <xsl:if test="jp:priority-claims">
                <xf:string>
                    <xsl:value-of select="'パリ条約による優先権等の主張'" />
                </xf:string>
            </xsl:if>
            <xsl:if test="jp:declaration-priority-ear-app">
                <xf:string>
                    <xsl:value-of select="'先の出願に基づく優先権主張'" />
                </xf:string>
            </xsl:if>
        </xf:array>
        
        <!--jp:agents/jp:agent, jp:change-attorney-article/jp:agent
             をまとめるため、ここに記載 -->
        <xf:array key="agents">
            <xsl:for-each select=".//jp:agent">
                <xf:string>
                    <xsl:value-of select=".//jp:name" />
                </xf:string>
            </xsl:for-each>
        </xf:array>
    </xsl:template>
    <xsl:template match="jp:special-mention-matter-article">
        <xf:array key="specialMentionMatterArticle">
            <xsl:for-each select="jp:article">
                <xf:string>
                    <xsl:call-template name="convert-special-mention-matter-article">
                        <xsl:with-param name="article" select="normalize-space()" />
                        <xsl:with-param name="kind-of-law" select="$kind-of-law" />
                    </xsl:call-template>
                </xf:string>
            </xsl:for-each>
        </xf:array>
    </xsl:template>

    <!-- common-templates/bibliographic-items.xsl のテンプレート 
         と重複しないように mode="full-text" を指定している -->
    <xsl:template match="jp:pat-amnd">
        <xsl:apply-templates select="jp:amendment-a51" mode="full-text" />
        <xsl:apply-templates select="jp:amendment-a523" mode="full-text" />
        <xsl:apply-templates select="jp:amendment-a524" mode="full-text" />
        <xsl:apply-templates select="jp:amendment-a525" mode="full-text" />
        <xsl:apply-templates select="jp:amendment-a529" mode="full-text" />
        <xsl:apply-templates select="jp:amendment-a526" mode="full-text" />
        <xsl:apply-templates select="jp:amendment-a5210" mode="full-text" />
        <xsl:apply-templates select="jp:amendment-a527" mode="full-text" />
        <xsl:apply-templates select="jp:amendment-a5211" mode="full-text" />
        <xsl:apply-templates select="jp:amendment-a528" mode="full-text" />
        <xsl:apply-templates select="jp:amendment-a5212" mode="full-text" />
    </xsl:template>
    <!-- 
         amendment-grooup 下の applicants，agents を処理しない。
         そのために、jp:amendment-a51 の直下の jp:applicants, jp:agents を処理対処にする.
    -->
    <xsl:template
        match="jp:amendment-a51 | jp:amendment-a523 | jp:amendment-a524 |
            jp:amendment-a525 | jp:amendment-a529 |
            jp:amendment-a526 | jp:amendment-a5210 |
            jp:amendment-a527 | jp:amendment-a5211 |
            jp:amendment-a528 | jp:amendment-a5212" mode="full-text">
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        
        <xf:array key="contentsOfAmendment">
            <xsl:for-each select=".//jp:contents-of-amendment">
                <xf:string>
                    <xsl:value-of select="normalize-space(.)" />
                </xf:string>
            </xsl:for-each>
        </xf:array>
    </xsl:template>
    
    <!-- common-templates/bibliographic-items.xsl のテンプレート 
         と重複しないように mode="full-text" を指定している -->
    <xsl:template match="jp:pat-rspn">
        <xsl:apply-templates select="jp:response-a53" mode="full-text" />
        <xsl:apply-templates select="jp:response-a59" mode="full-text" />
    </xsl:template>
    <xsl:template match="jp:response-a53 | jp:response-a59" mode="full-text">
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:opinion-contents-article" />
    </xsl:template>
    
    <!-- common-templates/bibliographic-items.xsl のテンプレート 
         と重複しないように mode="full-text" を指定している -->
    <xsl:template match="jp:pat-etc">
        <xsl:apply-templates select="jp:etcetera-a601" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a621" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a623" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a624" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a625" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a626" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a627" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a67" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a691" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a781" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a821" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a831" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a87" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a871" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a872" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a914" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a915" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a916" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a603" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a917" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a918" mode="full-text" />
        <xsl:apply-templates select="jp:etcetera-a919" mode="full-text" />
    </xsl:template>
    <xsl:template
        match="jp:etcetera-a601 | jp:etcetera-a621 | jp:etcetera-a623 |
            jp:etcetera-a624 | jp:etcetera-a625 | jp:etcetera-a626 | jp:etcetera-a627 |
            jp:etcetera-a67 | jp:etcetera-a691 | jp:etcetera-a781 | jp:etcetera-a821 |
            jp:etcetera-a831 | jp:etcetera-a87 | jp:etcetera-a871 | jp:etcetera-a872 |
            jp:etcetera-a914 | jp:etcetera-a915 | jp:etcetera-a916 | jp:etcetera-a603 |
            jp:etcetera-a917 | jp:etcetera-a918 | jp:etcetera-a919" mode="full-text">
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:opinion-contents-article" />
    </xsl:template>
   
    <xsl:template match="jp:cpy-notice-pat-exam-rn | jp:cpy-notice-pat-exam">
        <xsl:apply-templates select=".//jp:conclusion-part-article" />
        <xsl:apply-templates select=".//jp:drafting-body" />
        <xsl:apply-templates select=".//jp:article-group" />
    </xsl:template>

    <!-- 発送系、明細書 -->
    <xsl:template
        match="invention-title | technical-field | background-art |
            tech-problem | tech-solution | advantageous-effects |
            description-of-embodiments | best-mode | industrial-applicability |
            reference-to-deposited-biological-material | abstract |
            jp:law-of-industrial-regenerate | jp:conclusion-part-article |
            jp:drafting-body | jp:opinion-contents-article">
        <xsl:if test="normalize-space(.) != ''">
            <xsl:variable name="camel-key" select="key('field-mapping-key', local-name(), $field-mapping)" />
            <xf:string key="{$camel-key/@camel}">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="jp:article-group">
        <xf:array key="rejectionReasonArticle">
            <xsl:for-each select="jp:article">
                <xf:string>
                    <xsl:value-of select="normalize-space(.)" />
                </xf:string>
            </xsl:for-each>
        </xf:array>
    </xsl:template>
    
    <xsl:template match="claims">
        <xf:array key="independentClaims">
            <xsl:for-each select=".//claim-text[not(contains(., '請求項'))]">
                <xf:string>
                    <xsl:value-of select="normalize-space(.)" />
                </xf:string>
            </xsl:for-each>
        </xf:array>
        <xf:array key="dependentClaims">
            <xsl:for-each select=".//claim-text[contains(., '請求項')]">
                <xf:string>
                    <xsl:value-of select="normalize-space(.)" />
                </xf:string>
            </xsl:for-each>
        </xf:array>
    </xsl:template>
    
    <!-- 外国語書面出願系 -->
    <xsl:template match="jp:foreign-language-description">
        <xf:string key="embodiments">
            <xsl:value-of select="normalize-space(.)" />
        </xf:string>
    </xsl:template>
    <xsl:template match="jp:foreign-language-claims">
        <!-- treats all claims as independent claims -->
        <xf:array key="independentClaims">
            <xf:string>
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
        </xf:array>
    </xsl:template>
    <xsl:template match="jp:foreign-language-abstract">
        <xf:string key="abstract">
            <xsl:value-of select="normalize-space(.)" />
        </xf:string>
    </xsl:template>
    
    <!-- ocr from images -->
    <xsl:template match="root/images">
        <xf:string key="ocrText">
            <xsl:value-of select="image/ocr" />
        </xf:string>
    </xsl:template>

    <xsl:key name="field-mapping-key" match="item" use="@key" />
    <xsl:variable name="field-mapping">
        <item key="invention-title" camel="inventionTitle"/>
        <item key="technical-field" camel="technicalField"/>
        <item key="background-art" camel="backgroundArt"/>
        <item key="tech-problem" camel="techProblem"/>
        <item key="tech-solution" camel="techSolution"/>
        <item key="advantageous-effects" camel="advantageousEffects"/>
        <item key="description-of-embodiments" camel="embodiments"/> <!-- same camel case -->
        <item key="best-mode" camel="embodiments"/>  <!-- same camel case -->
        <item key="industrial-applicability" camel="industrialApplicability"/>
        <item key="reference-to-deposited-biological-material" camel="referenceToDepositedBiologicalMaterial"/>
        <item key="abstract" camel="abstract"/>
        <item key="law-of-industrial-regenerate" camel="lawOfIndustrialRegenerate"/>
        <item key="conclusion-part-article" camel="conclusionPartArticle"/>
        <item key="drafting-body" camel="draftingBody"/>
        <item key="opinion-contents-article" camel="opinionContentsArticle"/>
    </xsl:variable>

    <schema:title>full-text</schema:title>
    <schema:object name="full-text" is-root="true">
        <!-- bibliographic items -->
        <schema:property name="docId" type="string" />
        <schema:property name="task" type="string" />
        <schema:property name="kind" type="string" />
        <schema:property name="extension" type="string" />
        
        <schema:property name="inventors" type="array" item-type="string" optional="true" />
        <schema:property name="applicants" type="array" item-type="string" />
        <schema:property name="agents" type="array" item-type="string" optional="true" />

        <schema:property name="law" type="string" enum="patent,utilityModel,design,trademark" />
        <schema:property name="documentName" type="string"/>
        <schema:property name="documentCode" type="string"/>
        <schema:property name="applicationNumber" type="string" optional="true"/>
        <schema:property name="registrationNumber" type="string" optional="true"/>
        <schema:property name="internationalApplicationNumber" type="string" optional="true"/>
        <schema:property name="appealReferenceNumber" type="string" optional="true"/>
        <schema:property name="receiptNumber" type="string" optional="true"/>
        <schema:property name="fileReferenceId" type="string" optional="true"/>
        <schema:property name="datetime" type="string" optional="true"/>
 
        <!-- full-text items -->
        <schema:property name="inventionTitle" type="string" optional="true" />
        <schema:property name="technicalField" type="string" optional="true" />
        <schema:property name="backgroundArt" type="string" optional="true" />
        <schema:property name="techProblem" type="string" optional="true" />
        <schema:property name="techSolution" type="string" optional="true" />
        <schema:property name="advantageousEffects" type="string" optional="true" />
        <schema:property name="embodiments" type="string" optional="true" />
        <schema:property name="industrialApplicability" type="string" optional="true" />
        <schema:property name="referenceToDepositedBiologicalMaterial" type="string"
                         optional="true" />
        <schema:property name="abstract" type="string" optional="true" />
        <schema:property name="lawOfIndustrialRegenerate" type="string" optional="true" />
        <schema:property name="conclusionPartArticle" type="string" optional="true" />
        <schema:property name="draftingBody" type="string" optional="true" />
        <schema:property name="opinionContentsArticle" type="string" optional="true" />
        <schema:property name="independentClaims" type="array" item-type="string" optional="true" />
        <schema:property name="dependentClaims" type="array" item-type="string" optional="true" />
        <schema:property name="rejectionReasonArticle" type="array" item-type="string"
                         optional="true" />
        <schema:property name="contentsOfAmendment" type="array" item-type="string"
                         optional="true" />
        <schema:property name="specialMentionMatterArticle" type="array" item-type="string"
                         optional="true" />
        <schema:property name="priorityClaims" type="array" item-type="string" optional="true" />
        <schema:property name="ocrText" type="string" optional="true" />
    </schema:object>
</xsl:stylesheet>