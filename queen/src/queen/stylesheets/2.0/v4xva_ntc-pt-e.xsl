<?xml version="1.0" encoding="UTF-8"?>

<!-- 
     original xsl: v4xva_ntc-pt-e.xsl at May  8  2018
     sha256sum:a7320028fed94b06b18c588279b712cf52305aa76b5f4472c1d76604fe84d07d
-->
<!-- ====================================================================
     変換対象書類名：特実審査周辺（共通部）
     ====================================================================-->
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:f="urn:phantom-mona:string-utils"
    xmlns:schema="urn:schema-dsl"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xsl jp schema xf">
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <xsl:variable name="node" select="name(//jp:notice-pat-exam/*)" />
    <xsl:variable name="kind-of-law">
        <xsl:value-of select="/root/jp:cpy-notice-pat-exam/jp:notice-pat-exam/*/@jp:kind-of-law[1]" />
    </xsl:variable>
    
    <xsl:include href="common-templates/ntc-ninsyo.xsl" />
    <xsl:include href="common-templates/ntc-paragraph.xsl" />
    <xsl:include href="common-templates/doc-number.xsl" />
    <xsl:include href="common-templates/string-utils.xsl" />
    <xsl:include href="common-templates/v4xva_prm.xsl" />
    <xsl:include href="common-templates/dispatch-control-article.xsl" />
    <xsl:include href="common-templates/date-templates.xsl" />
    <xsl:include href="common-templates/unsupported-tags.xsl" />
    
    <!-- schema:title is set to the name of this stylesheet -->
    <schema:title>v4xva_ntc-pt-e</schema:title>
    
    <!-- ====================================================================
         jp:notice-pat-exam
         
         jp:decision-of-registration-a01  A[12]01 特許査定
         jp:decision-of-rejection-a02     A[12]02 拒絶査定
         jp:notice-of-rejection-a131      A1131   拒絶理由通知
         jp:declining-the-amendment-a191  A[12]191    補正却下の決定
         jp:declining-the-amendment-a192  A[12]192    補正却下の決定
         jp:examiner-notification-a251    A[12]251    審査官通知(その他の通知）（期間有）
         jp:examiner-notification-a2514   A[12]2514   立会実験申請書の提出命令書
         jp:examiner-notification-a2515   A[12]2515   同一出願人による同日出願通知書
         jp:examiner-notification-a2516   A[12]2516   出願人相違の同日出願通知書
         jp:examiner-notification-a252    A[12]252    審査官通知（その他の通知）（期間無）
         jp:examiner-notification-a2522   A[12]2522   先願未請求による審査不可能通知書
         jp:examiner-notification-a2529   A12529      先行技術文献情報不開示の通知
         jp:examiner-notification-a30     A[12]30     引用非特許文献
         jp:examiner-notification-a25110  A[12]25110  １９４条の通知（分割出願に関する説明書）
         jp:examiner-notification-a25111  A[12]25111  １９４条の通知（その他）
         ====================================================================-->
    <xsl:template match="jp:notice-pat-exam">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates
                    select="jp:decision-of-registration-a01 | jp:decision-of-rejection-a02
                        | jp:notice-of-rejection-a131 | jp:declining-the-amendment-a191
                        | jp:declining-the-amendment-a192 | jp:examiner-notification-a251
                        | jp:examiner-notification-a2514 | jp:examiner-notification-a2515
                        | jp:examiner-notification-a2516 | jp:examiner-notification-a252
                        | jp:examiner-notification-a2522 | jp:examiner-notification-a2529
                        | jp:examiner-notification-a30
                        | jp:examiner-notification-a25110| jp:examiner-notification-a25111" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="notice-pat-exam">
        <schema:property name="tag" type="string" const="jp:notice-pat-exam" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="jp:decision-of-registration-a01"/>
                <schema:ref name="jp:decision-of-rejection-a02"/>
                <schema:ref name="jp:examiner-notification-a30"/>
                <schema:ref name="jp:notice-others"/>
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:decision-of-registration-a01
         ====================================================================-->
    <xsl:template match="jp:decision-of-registration-a01">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-name" />
                <xsl:apply-templates select="jp:kind-of-application" />
                <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam" />
                <xsl:apply-templates select="jp:reconsideration-before-appeal" />
                <xsl:apply-templates select="jp:conclusion-part-article" />
                <xsl:apply-templates select="jp:drafting-body" />
                <xsl:apply-templates select="jp:footer-article" />
                <xsl:apply-templates select="jp:final-decision-group" />
                <xsl:apply-templates select="jp:final-decision-memo" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="decision-of-registration-a01">
        <schema:property
            name="tag" type="string" const="jp:decision-of-registration-a01" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="document-name" />
                <schema:ref name="kind-of-application" />
                <schema:ref name="bibliog-in-ntc-pat-exam" />
                <schema:ref name="reconsideration-before-appeal" />
                <schema:ref name="conclusion-part-article" />
                <schema:ref name="drafting-body" />
                <schema:ref name="footer-article" />
                <schema:ref name="final-decision-group" />
                <schema:ref name="final-decision-memo" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:decision-of-rejection-a02
         ====================================================================-->
    <xsl:template match="jp:decision-of-rejection-a02">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-name" />
                <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam" />
                <xsl:apply-templates select="jp:reconsideration-before-appeal" />
                <xsl:apply-templates select="jp:drafting-body" />
                <xsl:apply-templates select="jp:footer-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="decision-of-rejection-a02">
        <schema:property
            name="tag" type="string" const="jp:decision-of-rejection-a02" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="document-name" />
                <schema:ref name="bibliog-in-ntc-pat-exam" />
                <schema:ref name="reconsideration-before-appeal" />
                <schema:ref name="drafting-body" />
                <schema:ref name="footer-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:notice-of-rejection-a131 | jp:declining-the-amendment-a191 |
         jp:declining-the-amendment-a192 | jp:examiner-notification-a251 |
         jp:examiner-notification-a2514 | jp:examiner-notification-a2515 |
         jp:examiner-notification-a2516 | jp:examiner-notification-a252 |
         jp:examiner-notification-a2522 | jp:examiner-notification-a2529 |
         jp:examiner-notification-a25110 | jp:examiner-notification-a25111
         ====================================================================-->
    <xsl:template
        match="jp:notice-of-rejection-a131 | jp:declining-the-amendment-a191
            | jp:declining-the-amendment-a192 | jp:examiner-notification-a251
            | jp:examiner-notification-a2514 | jp:examiner-notification-a2515
            | jp:examiner-notification-a2516 | jp:examiner-notification-a252
            | jp:examiner-notification-a2522 | jp:examiner-notification-a2529
            | jp:examiner-notification-a25110 | jp:examiner-notification-a25111">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-name" />
                <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam" />
                <xsl:apply-templates select="jp:reconsideration-before-appeal" />
                <xsl:apply-templates select="jp:conclusion-part-article" />
                <xsl:apply-templates select="jp:drafting-body" />
                <xsl:apply-templates select="jp:footer-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="notice-others">
        <schema:property
            name="tag" type="string"
                   enum="jp:notice-of-rejection-a131,
                         jp:declining-the-amendment-a191,
                         jp:declining-the-amendment-a192,
                         jp:examiner-notification-a251,
                         jp:examiner-notification-a2514,
                         jp:examiner-notification-a2515,
                         jp:examiner-notification-a2516,
                         jp:examiner-notification-a252,
                         jp:examiner-notification-a2522,
                         jp:examiner-notification-a2529,
                         jp:examiner-notification-a25110,
                         jp:examiner-notification-a25111" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="document-name" />
                <schema:ref name="bibliog-in-ntc-pat-exam" />
                <schema:ref name="reconsideration-before-appeal" />
                <schema:ref name="conclusion-part-article" />
                <schema:ref name="drafting-body" />
                <schema:ref name="footer-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object> 
    
    <!-- ====================================================================
         jp:examiner-notification-a30
         ====================================================================-->
    <xsl:template match="jp:examiner-notification-a30">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-name" />
                <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam" />
                <xsl:apply-templates select="jp:reconsideration-before-appeal" />
                <xsl:apply-templates select="jp:image-group" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="examiner-notification-a30">
        <schema:property name="tag" type="string"
                         const="jp:examiner-notification-a30" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="document-name" />
                <schema:ref name="bibliog-in-ntc-pat-exam" />
                <schema:ref name="reconsideration-before-appeal" />
                <schema:ref name="image-group" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    
    <!-- ====================================================================
         begin:
         terminal type A elements have tag, jpTag, indentLevel and text.
         optional: convertedText
         no child elements
         ====================================================================-->
    <!-- ====================================================================
         jp:kind-of-application 出願種別
         ====================================================================-->
    <xsl:template match="jp:kind-of-application">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:final-decision-group">
                        <xsl:value-of select="'１．出願種別'" />
                    </xsl:when>
                    <xsl:otherwise />
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">0</xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:final-decision-group">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'（' || . || '）'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         invention-title 発明または考案の名称
         ====================================================================-->
    <xsl:template match="invention-title">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="$kind-of-law = 'patent'">
                        <xsl:value-of select="'発明の名称'" />
                    </xsl:when>
                    <xsl:when test="$kind-of-law = 'utility'">
                        <xsl:value-of select="'考案の名称'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="''" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">0</xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:number-of-claim 請求項の数
         ====================================================================-->
    <xsl:template match="jp:number-of-claim">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="./@jp:adopted-law = 'claim'">
                        <xsl:value-of select="'請求項の数'" />
                    </xsl:when>
                    <xsl:when test="./@jp:adopted-law = 'invention'">
                        <xsl:value-of select="'特許請求の範囲に記載された発明の数'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">0</xf:string>
            <xf:string key="text">
                <xsl:value-of select="f:remove-nbsp(.)" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:exist-of-reference-doc 参考文献有無
         ====================================================================-->
    <xsl:template match="jp:exist-of-reference-doc">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'２．参考文献'" />
            </xf:string>
            <xf:string key="indentLevel">0</xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@jp:true-or-false = 'true'">
                        <xsl:value-of select="'有'" />
                    </xsl:when>
                    <xsl:when test="./@jp:true-or-false = 'false'">
                        <xsl:value-of select="'無'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:addressed-to-person-group あて先
         ====================================================================-->
    <xsl:template match="jp:addressed-to-person-group">
        <!-- moved content of 
             <xsl:call-template name="あて先取得" />
        -->
        <xsl:variable name="name" select="normalize-space(.//jp:name)" />
        <xsl:variable name="persons0"
            select="f:remove-nbsp(.//jp:number-of-other-persons)" />
        <xsl:variable name="persons">
            <xsl:choose>
                <xsl:when test=".//jp:number-of-other-persons">
                    <xsl:value-of select="'（ほか' || $persons0 || '名）'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sama">
            <xsl:choose>
                <xsl:when
                    test="$node = 'jp:notice-of-rejection-a131' 
                        or $node = 'jp:examiner-notification-a2515' or $node = 'jp:examiner-notification-a2516'
                        or $node = 'jp:examiner-notification-a251'  or $node = 'jp:examiner-notification-a2522'
                        or $node = 'jp:examiner-notification-a252'  or $node = 'jp:examiner-notification-a2529'
                        or $node = 'jp:examiner-notification-a2530' or $node = 'jp:examiner-notification-a242623'
                        or $node = 'jp:examiner-notification-a2541'  or $node = 'jp:examiner-notification-a2542'">
                    <xsl:value-of select="'　様'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="allname" select="concat($name,$persons,$sama)" />
        
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <!-- original: template name="あて先取得" -->
                <xsl:choose>
                    <xsl:when test="./@jp:kind-of-person = 'applicant'">
                        <xsl:choose>
                            <xsl:when test="$kind-of-law = 'utility'">
                                <xsl:choose>
                                    <xsl:when
                                        test="./@jp:kind-of-representative = 'representative-application'">
                                        <xsl:choose>
                                            <xsl:when test="./@jp:kind-of-agent = 'representative'">
                                                <xsl:value-of select="'実用新案登録代表出願人代理人'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'sub-representative'">
                                                <xsl:value-of select="'実用新案登録代表出願人復代理人'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'legal-representative'">
                                                <xsl:value-of select="'実用新案登録代表出願人法定代理人'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'designated-representative'">
                                                <xsl:value-of select="'実用新案登録代表出願人指定代理人'" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'実用新案登録代表出願人'" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <xsl:when test="./@jp:kind-of-agent = 'representative'">
                                                <xsl:value-of select="'実用新案登録出願人代理人'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'sub-representative'">
                                                <xsl:value-of select="'実用新案登録出願人復代理人'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'legal-representative'">
                                                <xsl:value-of select="'実用新案登録出願人法定代理人'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'designated-representative'">
                                                <xsl:value-of select="'実用新案登録出願人指定代理人'" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'実用新案登録出願人'" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$kind-of-law = 'patent'">
                                <xsl:choose>
                                    <xsl:when
                                        test="./@jp:kind-of-representative = 'representative-application'">
                                        <xsl:choose>
                                            <xsl:when test="./@jp:kind-of-agent = 'representative'">
                                                <xsl:value-of select="'特許代表出願人代理人'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'sub-representative'">
                                                <xsl:value-of select="'特許代表出願人復代理人'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'legal-representative'">
                                                <xsl:value-of select="'特許代表出願人法定代理人'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'designated-representative'">
                                                <xsl:value-of select="'特許代表出願人指定代理人'" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'特許代表出願人'" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <xsl:when test="./@jp:kind-of-agent = 'representative'">
                                                <xsl:value-of select="'特許出願人代理人'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'sub-representative'">
                                                <xsl:value-of select="'特許出願人復代理人'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'legal-representative'">
                                                <xsl:value-of select="'特許出願人法定代理人'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'designated-representative'">
                                                <xsl:value-of select="'特許出願人指定代理人'" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'特許出願人'" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="./@jp:kind-of-person = 'attorney'">
                        <xsl:choose>
                            <xsl:when test="./@jp:kind-of-agent = 'representative'">
                                <xsl:value-of select="'代理人'" />
                            </xsl:when>
                            <xsl:when test="./@jp:kind-of-agent = 'sub-representative'">
                                <xsl:value-of select="'復代理人'" />
                            </xsl:when>
                            <xsl:when test="./@jp:kind-of-agent = 'legal-representative'">
                                <xsl:value-of select="'法定代理人'" />
                            </xsl:when>
                            <xsl:when test="./@jp:kind-of-agent = 'designated-representative'">
                                <xsl:value-of select="'指定代理人'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="''" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">0</xf:string>
            <xf:string key="text">
                <xsl:value-of select="$allname" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:patent-law-section30 特許法第３０条適用有無
         ====================================================================-->
    <xsl:template match="jp:patent-law-section30">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'３．特許法第３０条適用'" />
            </xf:string>
            <xf:string key="indentLevel">0</xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@jp:true-or-false = 'true'">
                        <xsl:value-of select="'有'" />
                    </xsl:when>
                    <xsl:when test="./@jp:true-or-false = 'false'">
                        <xsl:value-of select="'無'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:change-flag-invention-title 発明の名称の変更有無
         ====================================================================-->
    <xsl:template match="jp:change-flag-invention-title">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="$kind-of-law = 'patent'">
                        <xsl:value-of select="'４．発明の名称の変更'" />
                    </xsl:when>
                    <xsl:when test="$kind-of-law = 'utility'">
                        <xsl:value-of select="'４．考案の名称の変更'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">0</xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@jp:true-or-false = 'true'">
                        <xsl:value-of select="'有'" />
                    </xsl:when>
                    <xsl:when test="./@jp:true-or-false = 'false'">
                        <xsl:value-of select="'無'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:date 日付
         ====================================================================-->
    <xsl:template match="jp:date">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:call-template name="日付タイトル" />
            </xf:string>
            <xf:string key="indentLevel">0</xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:call-template name="format-date-jp2">
                    <xsl:with-param name="date-str" select="normalize-space(.)" />
                </xsl:call-template>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:version-number 版コード
         ====================================================================-->
    <xsl:template match="jp:version-number">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'　版コード　　　'" />
            </xf:string>
            <xf:string key="indentLevel">0</xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(.))" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:doc-number 文書番号
         元 <xsl:template name="文書番号編集">
         ====================================================================-->
    <xsl:template match="jp:doc-number">
        <xsl:variable name="kind-of-law" select="ancestor::jp:application-reference/@jp:kind-of-law" />
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:parent-application-article
                            and ancestor::jp:parent-application-article [@jp:kind-of-application = 'division']">
                        <xsl:value-of select="'分割出願'" />
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:parent-application-article
                            and ancestor::jp:parent-application-article [@jp:kind-of-application = 'change']">
                        <xsl:value-of select="'変更出願'" />
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:parent-application-article
                            and ancestor::jp:parent-application-article [@jp:kind-of-application = 'based-on-utility']">
                        <xsl:value-of select="'実用基礎'" />
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:application-reference
                            and $kind-of-law = 'patent'">
                        <xsl:value-of select="'特許出願の番号'" />
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:application-reference
                            and $kind-of-law = 'utility'">
                        <xsl:value-of select="'実用新案登録出願の番号'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">0</xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:call-template name="文書番号内容編集">
                    <!--
                         <xsl:call-template name="translate-application-number">
                         <xsl:with-param name="number" select="normalize-space(.)" />
                         <xsl:with-param name="law" select="$kind-of-law" />
                         <xsl:with-param name="kinddoc" select="$node" />
                    -->
                    <!-- 発送系は、出願番号の表示が「特許願」だけど、
                         出願系は「特願」である。だけど、出願系の表示に変更（共用）-->
                 </xsl:call-template>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:depository-ins-code 受託機関コード
         ====================================================================-->
    <xsl:template match="jp:depository-ins-code">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'受託機関コード'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(.))" />
            </xf:string>
            <xf:string key="indentLevel">2</xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:depository-number 受託番号
         ====================================================================-->
    <xsl:template match="jp:depository-number">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'受託番号'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(.))" />
            </xf:string>
            <xf:string key="indentLevel">2</xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:application-section 適用条項
         ====================================================================-->
    <xsl:template match="jp:application-section">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'適用条文'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
            <xf:string key="indentLevel">2</xf:string>
            <xf:string key="convertedText">
                <xsl:choose>
                    <xsl:when test="$kind-of-law = 'patent'">
                        <xsl:value-of select="'特許法第３０条' || . || 'の規定の適用'" />
                    </xsl:when>
                    <xsl:when test="$kind-of-law = 'utility'">
                        <xsl:value-of select="'実用新案法第９条第１項で準用する特許法第３０条' || . || 'の規定の適用'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:exceptions-to-lack-of-novelty 新規性喪失例外適用
         ====================================================================-->
    <xsl:template match="jp:exceptions-to-lack-of-novelty">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'内容'" />
            </xf:string>
            <xf:string key="text">
                <xsl:for-each select="p">
                    <xsl:value-of select="normalize-space(.)" />
                </xsl:for-each>
            </xf:string>
            <xf:string key="indentLevel">2</xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- all of terminal type A elements follow the same pattern. -->
    <schema:object name="ntc-pt-e-terminal-items-type-a">
        <schema:property
            name="tag" type="string"
                   enum="jp:kind-of-application,
                         invention-title,
                         jp:number-of-claim,
                         jp:exist-of-reference-doc,
                         jp:addressed-to-person-group,
                         jp:patent-law-section30,
                         jp:change-flag-invention-title,
                         jp:date,
                         jp:version-number,
                         jp:doc-number,
                         jp:depository-ins-code,
                         jp:depository-number,
                         jp:application-section,
                         jp:exceptions-to-lack-of-novelty" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="integer" />
        <schema:property name="text" type="string" />
        <schema:property name="convertedText" type="string" optional="true" />
    </schema:object>
    <!--=========================================
         End: terminal type A
         ===========================================-->
    
    <!-- ====================================================================
         Begin:
         terminal type B elements have tag, text and optional convertedText.
         no child elements
         ====================================================================-->
    <!-- ====================================================================
         jp:document-name 書類名
         ====================================================================-->
    <xsl:template match="jp:document-name">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="notice-document-name" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:reconsideration-before-appeal 前置審査
         ====================================================================-->
    <xsl:template match="jp:reconsideration-before-appeal">
        <xsl:if test="./@jp:true-or-false = 'true'">
            <xf:map>
                <xf:string key="tag">
                    <xsl:value-of select="name()" />
                </xf:string>
                <xf:string key="text">
                    <xsl:value-of select="'［前置審査］'" />
                    <xsl:if test="ancestor::jp:decision-of-registration-a01">
                        <xsl:value-of select="'　原査定を取消す。'" />
                    </xsl:if>
                </xf:string>
            </xf:map>
        </xsl:if>
    </xsl:template>
    
    <!-- ====================================================================
         jp:article 適用条文
         ====================================================================-->
    <xsl:template match="jp:article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space()" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:ipc IPC
         ====================================================================-->
    <xsl:template match="jp:ipc">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(.))" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:name 氏名、氏名または名称
         ====================================================================-->
    <xsl:template match="jp:name">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when
                        test="($node != 'jp:examiner-notification-a2515'
                                and $node != 'jp:examiner-notification-a2516'
                                and $node != 'jp:examiner-notification-a2522')
                            and ancestor::jp:draft-person-group">
                        <xsl:value-of select="normalize-space(.)" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:addressed-to-person-group">
                        <xsl:value-of select="normalize-space(.)" />
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:staff1-group or ancestor::jp:staff2-group
                            or ancestor::jp:staff3-group or ancestor::jp:staff4-group
                            or ancestor::jp:devider">
                        <xsl:value-of select="normalize-space(.)" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:staff-code 担当者コード
         ====================================================================-->
    <xsl:template match="jp:staff-code">
        <xsl:variable name="code" select="normalize-space(.)" />
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:staff1-group or ancestor::jp:staff2-group
                            or ancestor::jp:staff3-group or ancestor::jp:staff4-group">
                        <xsl:value-of select="f:to-fullwidth-digit($code)" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:devider">
                        <xsl:value-of select="f:to-fullwidth-digit($code)" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:draft-person-group">
                        <xsl:value-of select="f:to-fullwidth-digit($code)" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:draft-person-group/jp:staff-code 担当者コード
         <xsl:template name="jp:staff-code" より関係箇所を抜き出した。
         ====================================================================-->
    <xsl:template match="jp:draft-person-group/jp:staff-code">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(.))" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:office-code 所属コード
         ====================================================================-->
    <xsl:template match="jp:office-code">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(.))" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:official-title 役職名
         ====================================================================-->
    <xsl:template match="jp:official-title">
        <xsl:variable name="name" select="normalize-space(.)" />
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="$name" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:field-of-search 調査分野
         ====================================================================-->
    <xsl:template match="jp:field-of-search">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:patent-reference-group 参考特許文献グル－プ 
         ====================================================================-->
    <xsl:template match="jp:patent-reference-group">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:value-of select="jp:document-number || '　' || jp:kind-of-document" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:reference-books 参考図書雑誌
         ====================================================================-->
    <xsl:template match="jp:reference-books">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:number-of-other-persons 外の者の人数
         ====================================================================-->
    <xsl:template match="jp:number-of-other-persons">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="f:remove-nbsp(.)" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:value-of select="'（外'" />
                <xsl:value-of
                    select="f:to-fullwidth-digit(f:remove-nbsp(.))" />
                <xsl:value-of select="'名）'" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- all of terminal type B elements follow the same pattern. -->
    <schema:object name="ntc-pt-e-terminal-items-type-b">
        <schema:property
            name="tag" type="string"
                   enum="jp:document-name,
                         jp:reconsideration-before-appeal,
                         jp:article,
                         jp:ipc,
                         jp:name,
                         jp:staff-code,
                         jp:office-code,
                         jp:official-title,
                         jp:field-of-search,
                         jp:patent-reference-group,
                         jp:reference-books,
                         jp:number-of-other-persons" />
        <schema:property name="text" type="string" />
        <schema:property name="convertedText" type="string" optional="true" />
    </schema:object>
    <!-- ====================================================================
         end: terminal type B elements.
         ====================================================================-->
    
    <!-- ====================================================================
         begin: container type A elements have a tag and blocks.
         ====================================================================-->
    <!-- ====================================================================
         jp:bibliog-in-ntc-pat-exam 書誌部
         ====================================================================-->
    <xsl:template match="jp:bibliog-in-ntc-pat-exam">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:application-reference" />
                <xsl:apply-templates select="jp:drafting-date" />
                <xsl:apply-templates select="jp:draft-person-group" />
                <xsl:apply-templates select="invention-title" />
                <xsl:apply-templates select="jp:number-of-claim" />
                <xsl:apply-templates select="jp:addressed-to-person-group" />
                <!-- 公式 DTD, XLT に定義なし
                     <xsl:apply-templates select="jp:publication" />
                -->
                <xsl:apply-templates select="jp:article-group" />
                <xsl:apply-templates select="jp:remark" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:conclusion-part-article 結論
         ====================================================================-->
    <xsl:template match="jp:conclusion-part-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:for-each select="p">
                    <xsl:apply-templates select="." />
                </xsl:for-each>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:drafting-body 本文部
         ====================================================================-->
    <xsl:template match="jp:drafting-body">
        <xsl:if test="p/* or jp:heading">
            <xf:map>
                <xf:string key="tag">
                    <xsl:value-of select="name()" />
                </xf:string>
                <xf:array key="blocks">
                    <xsl:apply-templates select="p | jp:heading" />
                </xf:array>
            </xf:map>
        </xsl:if>
    </xsl:template>
    
    <!-- ====================================================================
         jp:footer-article フッタ部 -->
     ====================================================================-->
    <xsl:template match="jp:footer-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:administrative-appeal-sentence" />
                <xsl:apply-templates select="jp:approval-column-article" />
                <!--
                     XSL に定義なし
                     <xsl:apply-templates select="jp:approval-without-contents" />
                -->
                <xsl:apply-templates select="jp:certification-column-article" />
                <xsl:apply-templates select="jp:inquiry-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:final-decision-group 査定固有部 -->
     ====================================================================-->
    <xsl:template match="jp:final-decision-group">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:kind-of-application" />
                <xsl:apply-templates select="jp:exist-of-reference-doc" />
                <xsl:apply-templates select="jp:patent-law-section30" />
                <xsl:apply-templates select="jp:change-flag-invention-title" />
                <xsl:apply-templates select="jp:ipc-article" />
                <xsl:apply-templates select="jp:classification-article" />
                <xsl:apply-templates select="jp:deposit-article" />
                <xsl:apply-templates select="jp:parent-application-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:final-decision-memo 査定メモ -->
     ====================================================================-->
    <xsl:template match="jp:final-decision-memo">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-name" />
                <xsl:apply-templates select="jp:final-decision-bibliog" />
                <xsl:apply-templates select="jp:final-decision-body" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:drafting-date 起案日
         ====================================================================-->
    <xsl:template match="jp:drafting-date">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:date" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:heading 中央段落
         ====================================================================-->
    <xsl:template match="jp:heading">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:final-decision-bibliog メモ内書誌部
         ====================================================================-->
    <xsl:template match="jp:final-decision-bibliog">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:application-reference" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:final-decision-body メモ内本文部
         ====================================================================-->
    <xsl:template match="jp:final-decision-body">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:field-of-search-article" />
                <xsl:apply-templates select="jp:patent-reference-article" />
                <xsl:apply-templates select="jp:reference-books-article" />
                <xsl:apply-templates select="jp:exceptions-to-lack-of-novelty-art" />
                <xsl:apply-templates select="jp:deposit-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:document-id ドキュメント識別
         ====================================================================-->
    <xsl:template match="jp:document-id">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:doc-number | jp:date" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:approval-column-article 決裁欄
         
         <u>     <u> で区切りの下線を引いているように思われる。
         XSLT はこのような出力はせず、のちのRendererで引かせる実装とする。
         ====================================================================-->
    <xsl:template match="jp:approval-column-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:staff1-group/jp:official-title" />
                <xsl:apply-templates select="jp:staff2-group/jp:official-title" />
                <xsl:apply-templates select="jp:staff3-group/jp:official-title" />
                <xsl:apply-templates select="jp:staff4-group/jp:official-title" />
                <xsl:choose>
                    <xsl:when test="//@jp:grant = 'post'">
                        <xsl:if test="following-sibling::jp:devider">
                            <xsl:apply-templates
                                select="following-sibling::jp:devider/jp:official-title" />
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
                
                
                <xsl:apply-templates select="jp:staff1-group/jp:name" />
                <xsl:apply-templates select="jp:staff2-group/jp:name" />
                <xsl:apply-templates select="jp:staff3-group/jp:name" />
                <xsl:apply-templates select="jp:staff4-group/jp:name" />
                <xsl:choose>
                    <xsl:when test="//@jp:grant = 'post'">
                        <xsl:if test="following-sibling::jp:devider">
                            <xsl:apply-templates select="following-sibling::jp:devider/jp:name" />
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
                
                
                <xsl:apply-templates select="jp:staff1-group/jp:staff-code" />
                <xsl:apply-templates select="jp:staff2-group/jp:staff-code" />
                <xsl:apply-templates select="jp:staff3-group/jp:staff-code" />
                <xsl:apply-templates select="jp:staff4-group/jp:staff-code" />
                
                <xsl:choose>
                    <xsl:when test="//@jp:grant = 'post'">
                        <xsl:if test="following-sibling::jp:devider">
                            <xsl:apply-templates select="following-sibling::jp:devider/jp:staff-code" />
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:image-group イメージ
         ====================================================================-->
    <xsl:template match="jp:image-group">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="img" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:application-reference 出願書類参照
         ====================================================================-->
    <xsl:template match="jp:application-reference">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:parent-application-article">
                        <xsl:if test="position() = 1">
                            <xf:string key="text">
                                <xsl:value-of select="'　対応する原出願の出願番号、原出願の出願日'" />
                            </xf:string>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xf:string key="text">
                            <xsl:value-of select="''" />
                        </xf:string>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:apply-templates select="jp:document-id" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <schema:object name="ntc-pt-e-container-items-type-a">
        <schema:property
            name="tag" type="string"
                   enum="jp:bibliog-in-ntc-pat-exam,
                         jp:conclusion-part-article,
                         jp:drafting-body,
                         jp:footer-article,
                         jp:final-decision-group,
                         jp:final-decision-memo,
                         jp:drafting-date,
                         jp:heading,
                         jp:final-decision-bibliog,
                         jp:final-decision-body,
                         jp:document-id,
                         jp:approval-column-article,
                         jp:image-group,
                         jp:application-reference" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="ntc-pt-e-terminal-items-type-a" />
                <schema:ref name="ntc-pt-e-terminal-items-type-b" />
                <schema:ref name="ntc-pt-e-container-items-type-a" />
                <schema:ref name="ntc-pt-e-container-items-type-b" />
                <schema:ref file="ntc-ninsyo.json" name="certification-column-article" />
                <schema:ref file="ntc-ninsyo.json" name="inquiry-article" />
                <schema:ref file="ntc-ninsyo.json" name="image-container" />
                <schema:ref file="ntc-paragraph.json" name="paragraph" />
                <schema:ref file="ntc-paragraph.json" name="inline-text" />
            </schema:anyOf>
        </schema:property>
    </schema:object> 
    <!-- ====================================================================
         end: container type A elements have a tag and blocks.
         ====================================================================-->
    
    <!-- ====================================================================
         Begin:
         container type B elements have tag, jpTag, child elements and
         optional indentLevel.
         ====================================================================-->
    <!-- ====================================================================
         jp:draft-person-group 起案者
         ====================================================================-->
    <xsl:template match="jp:draft-person-group">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when
                        test="$node = 'jp:examiner-notification-a2515'
                            or $node = 'jp:examiner-notification-a2516'
                            or $node = 'jp:examiner-notification-a2522'">
                        <xsl:value-of select="'特許庁長官'" />
                    </xsl:when>
                    <xsl:when test="$node = 'jp:examiner-notification-a30'">
                        <xsl:value-of select="'作成者'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'特許庁審査官'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:name" />
                <xsl:apply-templates select="jp:staff-code" />
                <xsl:apply-templates select="jp:office-code" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:article-group 適用条文グループ
         ====================================================================-->
    <xsl:template match="jp:article-group">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'適用条文'" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:remark 備考
         ====================================================================-->
    <xsl:template match="jp:remark">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'備考'" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="p" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:ipc-article 国際特許分類の記事
         ====================================================================-->
    <xsl:template match="jp:ipc-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'５．国際特許分類（ＩＰＣ）'" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:ipc" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:classification-article 併記特許分類の記事
         ====================================================================-->
    <xsl:template match="jp:classification-article">
        <xsl:choose>
            <xsl:when
                test="number(normalize-space(preceding::jp:drafting-date/jp:date)) &gt;= 20050401">
            </xsl:when>
            <xsl:when test="string-length(normalize-space(preceding::jp:drafting-date/jp:date)) = 0">
            </xsl:when>
            <xsl:otherwise>
                <xf:map>
                    <xf:string key="tag">
                        <xsl:value-of select="name()" />
                    </xf:string>
                    <xf:string key="jpTag">
                        <xsl:value-of select="'６．併記特許分類'" />
                    </xf:string>
                    <xf:array key="blocks">
                        <xsl:apply-templates select="jp:version-number" />
                        <xsl:apply-templates select="jp:ipc" />
                    </xf:array>
                </xf:map>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ====================================================================
         jp:deposit-article 菌寄託の記事
         ====================================================================-->
    <xsl:template match="jp:deposit-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:final-decision-group">
                        <xsl:choose>
                            <xsl:when
                                test="number(normalize-space(preceding::jp:drafting-date/jp:date)) &gt;= 20050401">
                                <xsl:value-of select="'６．菌寄託'" />
                            </xsl:when>
                            <xsl:when
                                test="string-length(normalize-space(preceding::jp:drafting-date/jp:date)) = 0">
                                <xsl:value-of select="'６．菌寄託'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'７．菌寄託'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="ancestor::jp:final-decision-memo">
                        <xsl:choose>
                            <xsl:when test="preceding-sibling::jp:exceptions-to-lack-of-novelty-art">
                                <xsl:value-of select="'５．菌寄託'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'４．菌寄託'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:deposit" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:deposit 菌寄託
         ====================================================================-->
    <xsl:template match="jp:deposit">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'菌寄託'" />
                <xsl:value-of select="f:to-fullwidth-digit(string(position()))" />
            </xf:string>
            <xf:string key="indentLevel">1</xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:depository-ins-code" />
                <xsl:if test="jp:depository-number">
                    <xsl:choose>
                        <xsl:when test="ancestor::jp:final-decision-group">
                            <xsl:apply-templates select="jp:depository-number" />
                        </xsl:when>
                        <xsl:when test="ancestor::jp:final-decision-memo">
                            <xsl:apply-templates select="jp:depository-number" />
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:parent-application-article 分割変更表示の記事
         ====================================================================-->
    <xsl:template match="jp:parent-application-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when
                        test="number(normalize-space(preceding::jp:drafting-date/jp:date)) &gt;= 20050401">
                        <xsl:value-of select="'７．出願日の遡及を認めない旨の表示'" />
                    </xsl:when>
                    <xsl:when
                        test="string-length(normalize-space(preceding::jp:drafting-date/jp:date)) = 0">
                        <xsl:value-of select="'７．出願日の遡及を認めない旨の表示'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'８．分割・変更の遡及を認めない旨の表示'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:application-reference" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:field-of-search-article 調査分野の記事
         ====================================================================-->
    <xsl:template match="jp:field-of-search-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when
                        test="number(normalize-space(//jp:drafting-date/jp:date)) &gt; 20060100">
                        <xsl:value-of select="'１．調査した分野（ＩＰＣ，ＤＢ名）'" />
                    </xsl:when>
                    <xsl:when
                        test="number(string-length(normalize-space(preceding::jp:drafting-date/jp:date))) = 0">
                        <xsl:value-of select="'１．調査した分野（ＩＰＣ，ＤＢ名）'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'１．調査した分野（ＩＰＣ第７版，ＤＢ名）'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:field-of-search" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:patent-reference-article 参考特許文献の記事
         ====================================================================-->
    <xsl:template match="jp:patent-reference-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'２．参考特許文献'" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:patent-reference-group" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:reference-books-article 参考図書雑誌の記事
         ====================================================================-->
    <xsl:template match="jp:reference-books-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'３．参考図書雑誌'" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:reference-books" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:exceptions-to-lack-of-novelty-art 新規性喪失例外の記事
         ====================================================================-->
    <xsl:template match="jp:exceptions-to-lack-of-novelty-art">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'４．新規性喪失例外規定の適用の事実'" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:exceptions-to-lack-of-novelty-grp" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:exceptions-to-lack-of-novelty-grp
         ====================================================================-->
    <!-- 新規性喪失の例外 -->
    <xsl:template match="jp:exceptions-to-lack-of-novelty-grp">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'新規性喪失の例外'" />
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(./@jp:serial-number))" />
            </xf:string>
            <xf:string key="indentLevel">1</xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:application-section" />
                <xsl:apply-templates select="jp:exceptions-to-lack-of-novelty" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <schema:object name="ntc-pt-e-container-items-type-b">
        <schema:property
            name="tag" type="string"
                   enum="jp:draft-person-group,
                         jp:article-group,
                         jp:remark,
                         jp:ipc-article,
                         jp:classification-article,
                         jp:deposit-article,
                         jp:deposit,
                         jp:parent-application-article,
                         jp:field-of-search-article,
                         jp:patent-reference-article,
                         jp:reference-books-article,
                         jp:exceptions-to-lack-of-novelty-art,
                         jp:exceptions-to-lack-of-novelty-grp" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="integer" optional="true" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="ntc-pt-e-terminal-items-type-a" />
                <schema:ref name="ntc-pt-e-terminal-items-type-b" />
                <schema:ref name="ntc-pt-e-container-items-type-a" />
                <schema:ref name="ntc-pt-e-container-items-type-b" />
                <schema:ref file="ntc-paragraph.json" name="paragraph" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ====================================================================
         End: container type B elements.
         ====================================================================-->
    
    <!-- ====================================================================
         日付タイトル
         ====================================================================-->
    <xsl:template name="日付タイトル">
        <xsl:choose>
            <xsl:when test="ancestor::jp:drafting-date">
                <xsl:choose>
                    <xsl:when test="$node = 'jp:examiner-notification-a30'">
                        <xsl:value-of select="'作成日'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'起案日'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ====================================================================
         jp:administrative-appeal-sentence
         ====================================================================-->
    <xsl:template match="jp:administrative-appeal-sentence">
        <xsl:call-template name="unsupported-tag" />
    </xsl:template>
    
    <!-- ====================================================================
         未サポートタグ
         remove jp:file-reference-id from original matches.
         ====================================================================-->
    <xsl:template
        match="jp:kana | country | kind | name | last-name
            | first-name | midle-name | iid | role | orgname | orgname | department
            | synonym | jp:phone | jp:fax | email | url | ead | dtext | text
            | jp:approval-without-contents"
        >
        <xsl:call-template name="unsupported-tag" />
    </xsl:template>
    
    <!-- ====================================================================
         未サポートタグ
         ====================================================================-->
    <xsl:template
        match="jp:addressbook//address-1 | jp:addressbook//address-2 | jp:addressbook//address-3
            | jp:addressbook//address-4 | jp:addressbook//address-5
            | jp:addressbook//mailcode | jp:addressbook//pobox | jp:addressbook//room
            | jp:addressbook//address-floor | jp:addressbook//building | jp:addressbook//street
            | jp:addressbook//city | jp:addressbook//county | jp:addressbook//state
            | jp:addressbook//postcode | jp:addressbook//country | jp:addressbook//jp:text
            | jp:addressbook//jp:original-language-of-address
            | jp:administrative-appeal-sentence/p
            | jp:administrative-appeal-sentence/jp:approval-without-contents
            | jp:administrative-appeal-sentence//jp:certification-column-group"
        >
        <xsl:call-template name="unsupported-tag" />
    </xsl:template>
    
    <!-- ====================================================================
         未サポートタグ
         ====================================================================-->
    <xsl:template
        match="jp:administrative-appeal-sentence//jp:staff1-group
            | jp:administrative-appeal-sentence//jp:staff2-group
            | jp:administrative-appeal-sentence//jp:staff3-group
            | jp:administrative-appeal-sentence//jp:staff4-group
            | jp:administrative-appeal-sentence//jp:devider
            | jp:administrative-appeal-sentence//jp:phone
            | jp:administrative-appeal-sentence//jp:fax"
        >
        <xsl:call-template name="unsupported-tag" />
    </xsl:template>
    
    <!-- ====================================================================
         未サポートタグ（ｐタグ用）
         ====================================================================-->
    <xsl:template
        match="b | i |smallcaps | ol | figref | patcit | nplcit
            | bio-deposit | crossref | maths | tables | chemistry
            | o | pre | table-external-doc">
        <xsl:call-template name="unsupported-tag" />
    </xsl:template>
</xsl:stylesheet>