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
    
    <!-- schema:title is set to the name of this stylesheet -->
    <schema:title>full-text</schema:title>
    
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:map>
                <xsl:apply-templates select="root/application-body/description" />
                <xsl:apply-templates select="root/application-body/claims" />
                <xsl:apply-templates select="root/application-body/abstract" />
                <xsl:apply-templates select="root/jp:foreign-language-body" />
                <xsl:apply-templates select="root/jp:pat-app-doc" />
                <xsl:apply-templates select="root/jp:cpy-notice-pat-exam-rn" />
                <xsl:apply-templates select="root/jp:cpy-notice-pat-exam" />
                <!-- 
                     補正書は補正対象の出願人、発明者、代理人を抽出しないように注意
                -->
                <xsl:apply-templates select="root/jp:pat-amnd" />
                <xsl:apply-templates select="root/jp:pat-rspns" />
                <xsl:apply-templates select="root/jp:pat-etc" />
                <xsl:apply-templates select="root/jp:m-mi-notice-doc" />
                
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
    
    <!-- 
         amendment-grooup 下の applicants，agents を処理しない。
         そのために、jp:amendment-a51 の直下の jp:applicants, jp:agents を処理対処にする
         補正書以外の書類でも同様に処理する
    -->
    <xsl:template
        match="jp:amendment-a51 | jp:amendment-a523 | jp:amendment-a524 |
            jp:amendment-a525 | jp:amendment-a529 |
            jp:amendment-a526 | jp:amendment-a5210 |
            jp:amendment-a527 | jp:amendment-a5211 |
            jp:amendment-a528 | jp:amendment-a5212">
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
    
    <xsl:template
        match="jp:application-a63 | jp:application-a631 |
            jp:application-a632 | jp:application-a633 |
            jp:application-a634 | jp:application-a635">
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
    
    <xsl:template match="jp:response-a53 | jp:response-a59">
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:opinion-contents-article" />
    </xsl:template>
    
    <xsl:template
        match="jp:etcetera-a601 | jp:etcetera-a621 | jp:etcetera-a623 |
            jp:etcetera-a624 | jp:etcetera-a625 | jp:etcetera-a626 | jp:etcetera-a627 |
            jp:etcetera-a67 | jp:etcetera-a691 | jp:etcetera-a781 | jp:etcetera-a821 |
            jp:etcetera-a831 | jp:etcetera-a87 | jp:etcetera-a871 | jp:etcetera-a872 |
            jp:etcetera-a914 | jp:etcetera-a915 | jp:etcetera-a916 | jp:etcetera-a603 |
            jp:etcetera-a917 | jp:etcetera-a918 | jp:etcetera-a919">
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:opinion-contents-article" />
    </xsl:template>
    
    <xsl:template match="jp:dispatch-control-article">
        <xsl:apply-templates select="jp:file-reference-id" />
    </xsl:template>
    
    <xsl:template match="jp:m-mi-notice-doc" >
        <!-- 出願人 -->
        <xf:array key="applicants">
            <xsl:for-each select=".//jp:m-applicant-and-attorneys/jp:m-dispatch-applicant-group">
                <xsl:for-each select="jp:m-name">
                    <xf:string>
                        <xsl:value-of select="." />
                    </xf:string>
                </xsl:for-each>
            </xsl:for-each>
        </xf:array>
        
        <!-- 代理人 -->
        <xf:array key="agents">
            <xsl:for-each select=".//jp:m-applicant-and-attorneys/jp:m-dispatch-attorney-group">
                <xsl:for-each select="jp:m-name">
                    <xf:string>
                        <xsl:value-of select="." />
                    </xf:string>
                </xsl:for-each>
            </xsl:for-each>
        </xf:array>
    </xsl:template>
    
    <!-- 出願人 -->
    <xsl:template match="jp:applicants">
        <xf:array key="applicants">
            <xsl:for-each select="jp:applicant">
                <xf:string>
                    <xsl:value-of select=".//jp:name" />
                </xf:string>
            </xsl:for-each>
        </xf:array>
    </xsl:template>
    
    <!-- 発明者 -->
    <xsl:template match="jp:inventors">
        <xf:array key="inventors">
            <xsl:for-each select="jp:inventor">
                <xf:string>
                    <xsl:value-of select=".//jp:name" />
                </xf:string>
            </xsl:for-each>
        </xf:array>
    </xsl:template>
    
    <!-- 代理人 -->
    <xsl:template match="jp:agents">
        <xf:array key="agents">
            <xsl:for-each select="jp:agent">
                <xf:string>
                    <xsl:value-of select=".//jp:name" />
                </xf:string>
            </xsl:for-each>
        </xf:array>
    </xsl:template>
    
    <!-- 外国語書面出願系 -->
    <xsl:template match="jp:foreign-language-description">
        <xf:string key="descriptionOfEmbodiments">
            <xsl:value-of select="normalize-space(.)" />
        </xf:string>
    </xsl:template>
    <xsl:template match="jp:foreign-language-claims">
        <xf:string key="foreignLanguageClaims">
            <xsl:value-of select="normalize-space(.)" />
        </xf:string>
    </xsl:template>
    <xsl:template match="jp:foreign-language-abstract">
        <xf:string key="abstract">
            <xsl:value-of select="normalize-space(.)" />
        </xf:string>
    </xsl:template>
   
    <!-- docId など -->
    <xsl:template match="sources">
        <!-- sources/archive の sha を docId とする -->
        <xf:string key="docId">
            <xsl:value-of select="archive/@sha256" />
        </xf:string>
        <xf:string key="task">
            <xsl:value-of select="archive/@task" />
        </xf:string>
        <xf:string key="kind">
            <xsl:value-of select="archive/@kind" />
        </xf:string>
    </xsl:template>

    <xsl:template match="text()" />
    
    <xsl:key name="field-mapping-key" match="item" use="@key" />
    <xsl:variable name="field-mapping">
        <item key="invention-title" camel="inventionTitle"/>
        <item key="technical-field" camel="technicalField"/>
        <item key="background-art" camel="backgroundArt"/>
        <item key="tech-problem" camel="techProblem"/>
        <item key="tech-solution" camel="techSolution"/>
        <item key="advantageous-effects" camel="advantageousEffects"/>
        <item key="description-of-embodiments" camel="descriptionOfEmbodiments"/>
        <item key="best-mode" camel="bestMode"/>
        <item key="industrial-applicability" camel="industrialApplicability"/>
        <item key="reference-to-deposited-biological-material" camel="referenceToDepositedBiologicalMaterial"/>
        <item key="abstract" camel="abstract"/>
        <item key="law-of-industrial-regenerate" camel="lawOfIndustrialRegenerate"/>
        <item key="conclusion-part-article" camel="conclusionPartArticle"/>
        <item key="drafting-body" camel="draftingBody"/>
        <item key="opinion-contents-article" camel="opinionContentsArticle"/>
    </xsl:variable>
    
    <schema:object name="full-text" is-root="true">
        <schema:property name="docId" type="string" />
        <schema:property name="task" type="string" />
        <schema:property name="kind" type="string" />
        
        <schema:property name="inventionTitle" type="string" optional="true" />
        <schema:property name="technicalField" type="string" optional="true" />
        <schema:property name="backgroundArt" type="string" optional="true" />
        <schema:property name="techProblem" type="string" optional="true" />
        <schema:property name="techSolution" type="string" optional="true" />
        <schema:property name="advantageousEffects" type="string" optional="true" />
        <schema:property name="descriptionOfEmbodiments" type="string" optional="true" />
        <schema:property name="bestMode" type="string" optional="true" />
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
        <schema:property name="inventors" type="array" item-type="string" optional="true" />
        <schema:property name="applicants" type="array" item-type="string" />
        <schema:property name="agents" type="array" item-type="string" optional="true" />
        <schema:property name="rejectionReasonArticle" type="array" item-type="string"
                         optional="true" />
        <schema:property name="contentsOfAmendment" type="array" item-type="string"
                         optional="true" />
        <schema:property name="specialMentionMatterArticle" type="array" item-type="string"
                         optional="true" />
        <schema:property name="foreignLanguageClaims" type="string" item-type="string" optional="true" />
        <schema:property name="priorityClaims" type="array" item-type="string" optional="true" />
    </schema:object>
</xsl:stylesheet>