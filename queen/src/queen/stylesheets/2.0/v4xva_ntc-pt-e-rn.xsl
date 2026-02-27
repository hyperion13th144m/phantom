<?xml version="1.0" encoding="UTF-8"?>

<!-- 
     original xsl: v4xva_ntc-pt-e-rn.xsl at Jun 22  2023 
     sha256sum:d13dddcf939f5289fb8528834cf0ddbf0f3bff28b7857ad6ba6c0399b08db28d 
-->

<!-- ====================================================================
     変換対象書類名：発送書類 特実審査（分類付与、実体審査）Y21M05-
     ====================================================================-->
<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:f="urn:phantom-mona:string-utils"
    xmlns:schema="urn:schema-dsl"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xsl jp f schema xf">
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <xsl:variable name="node" select="name(//jp:notice-pat-exam-rn/*)" />
    <xsl:variable name="kind-of-law">
        <xsl:value-of
            select="/root/jp:cpy-notice-pat-exam-rn/jp:notice-pat-exam-rn/*/@jp:kind-of-law[1]" />
    </xsl:variable>
    
    <xsl:include href="common-templates/ntc-ninsyo.xsl" />
    <xsl:include href="common-templates/ntc-paragraph.xsl" />
    <xsl:include href="common-templates/doc-number.xsl" />
    <xsl:include href="common-templates/string-utils.xsl" />
    <xsl:include href="common-templates/v4xva_prm.xsl" />
    <xsl:include href="common-templates/dispatch-control-article.xsl" />
    <xsl:include href="common-templates/date-templates.xsl" />
    <xsl:include href="common-templates/unsupported-tags.xsl" />
    
    <schema:title>v4xva_ntc-pt-e-rn</schema:title>
    
    
    <!-- ====================================================================
         jp:notice-pat-exam-rn
         
         jp:decision-of-registration-a01-rn  A[12]01 特許査定
         jp:decision-of-rejection-a02-rn     A[12]02 拒絶査定
         jp:notice-of-rejection-a131-rn      A1131   拒絶理由通知
         jp:declining-the-amendment-a191-rn  A[12]191    補正却下の決定
         jp:declining-the-amendment-a192-rn  A[12]192    補正却下の決定
         jp:examiner-notification-a251-rn    A[12]251    審査官通知(その他の通知）（期間有）
         jp:examiner-notification-a2514-rn   A[12]2514   立会実験申請書の提出命令書
         jp:examiner-notification-a2515-rn   A[12]2515   同一出願人による同日出願通知書
         jp:examiner-notification-a2516-rn   A[12]2516   出願人相違の同日出願通知書
         jp:examiner-notification-a252-rn    A[12]252    審査官通知（その他の通知）（期間無）
         jp:examiner-notification-a2522-rn   A[12]2522   先願未請求による審査不可能通知書
         jp:examiner-notification-a2529-rn   A12529      先行技術文献情報不開示の通知
         jp:examiner-notification-a30-rn     A[12]30     引用非特許文献
         jp:examiner-notification-a25110-rn  A[12]25110  １９４条の通知（分割出願に関する説明書）
         jp:examiner-notification-a25111-rn  A[12]25111  １９４条の通知（その他）
         jp:examiner-notification-a242623-rn              特許非公開化関連
         jp:examiner-notification-a2541-rn                
         jp:examiner-notification-a2542-rn
         ====================================================================-->
    <xsl:template match="jp:notice-pat-exam-rn">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates
                    select="jp:decision-of-registration-a01-rn | jp:decision-of-rejection-a02-rn
                        | jp:notice-of-rejection-a131-rn     | jp:declining-the-amendment-a191-rn
                        | jp:examiner-notification-a251-rn   | jp:examiner-notification-a2515-rn
                        | jp:examiner-notification-a2516-rn  | jp:examiner-notification-a252-rn
                        | jp:examiner-notification-a2522-rn  | jp:examiner-notification-a2529-rn
                        | jp:examiner-notification-a30-rn    | jp:examiner-notification-a2530-rn
                        | jp:examiner-notification-a242623-rn
                        | jp:examiner-notification-a2541-rn  | jp:examiner-notification-a2542-rn" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="notice-pat-exam-rn">
        <schema:property name="tag" type="string" const="jp:notice-pat-exam-rn" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="decision-of-registration-a01-rn"/>
                <schema:ref name="decision-of-rejection-a02-rn"/>
                <schema:ref name="examiner-notification-a30-rn"/>
                <schema:ref name="examiner-notification-a242623-rn"/>
                <schema:ref name="notice-a2541-a2542-rn"/>
                <schema:ref name="notice-others-rn"/>
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:decision-of-registration-a01-rn
         ====================================================================-->
    <xsl:template match="jp:decision-of-registration-a01-rn">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-name" />
                <xsl:apply-templates select="jp:kind-of-application" />
                <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam-rn" />
                <xsl:apply-templates select="jp:reconsideration-before-appeal" />
                <xsl:apply-templates select="jp:conclusion-part-article" />
                <xsl:apply-templates select="jp:drafting-body" />
                <xsl:apply-templates select="jp:footer-article" />
                <xsl:apply-templates select="jp:final-decision-group-rn" />
                <xsl:apply-templates select="jp:final-decision-memo-rn" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="decision-of-registration-a01-rn">
        <schema:property
            name="tag" type="string" const="jp:decision-of-registration-a01-rn" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-a" />
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-b" />
                <schema:ref name="ntc-pt-e-rn-container-items-type-a" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:decision-of-rejection-a02-rn
         ====================================================================-->
    <xsl:template match="jp:decision-of-rejection-a02-rn">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-name" />
                <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam-rn" />
                <xsl:apply-templates select="jp:conclusion-part-article" />
                <xsl:apply-templates select="jp:drafting-body" />
                <xsl:apply-templates select="jp:footer-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="decision-of-rejection-a02-rn">
        <schema:property
            name="tag" type="string" const="jp:decision-of-rejection-a02-rn" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-a" />
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-b" />
                <schema:ref name="ntc-pt-e-rn-container-items-type-a" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:examiner-notification-a30-rn
         ====================================================================-->
    <xsl:template match="jp:examiner-notification-a30-rn">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-name" />
                <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam-rn" />
                <xsl:apply-templates select="jp:image-group" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="examiner-notification-a30-rn">
        <schema:property
            name="tag" type="string" const="jp:examiner-notification-a30-rn" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-a" />
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-b" />
                <schema:ref name="ntc-pt-e-rn-container-items-type-a" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:examiner-notification-a242623-rn
         ====================================================================-->
    <xsl:template match="jp:examiner-notification-a242623-rn">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-name" />
                <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam-rn" />
                <xsl:apply-templates select="jp:conclusion-part-article" />
                <xsl:apply-templates select="jp:footer-article" />
                <xsl:apply-templates select="jp:image-group" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="examiner-notification-a242623-rn">
        <schema:property
            name="tag" type="string" const="jp:examiner-notification-a242623-rn" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-a" />
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-b" />
                <schema:ref name="ntc-pt-e-rn-container-items-type-a" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:examiner-notification-a2541-rn、jp:examiner-notification-a2542-rn
         ====================================================================-->
    <xsl:template match="jp:examiner-notification-a2541-rn | jp:examiner-notification-a2542-rn">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-name" />
                <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam-rn" />
                <xsl:apply-templates select="jp:conclusion-part-article" />
                <xsl:apply-templates select="jp:drafting-body" />
                <xsl:apply-templates select="jp:footer-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="notice-a2541-a2542-rn">
        <schema:property name="tag" type="string"
                         enum="jp:examiner-notification-a2541-rn,
                               jp:examiner-notification-a2542-rn" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-a" />
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-b" />
                <schema:ref name="ntc-pt-e-rn-container-items-type-a" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         書類識別
         ====================================================================-->
    <xsl:template
        match="jp:notice-of-rejection-a131-rn     | jp:declining-the-amendment-a191-rn
            | jp:examiner-notification-a251-rn   | jp:examiner-notification-a2515-rn
            | jp:examiner-notification-a2516-rn  | jp:examiner-notification-a252-rn
            | jp:examiner-notification-a2522-rn  | jp:examiner-notification-a2529-rn
            | jp:examiner-notification-a2530-rn">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-name" />
                <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam-rn" />
                <xsl:apply-templates select="jp:reconsideration-before-appeal" />
                <xsl:apply-templates select="jp:conclusion-part-article" />
                <xsl:apply-templates select="jp:drafting-body" />
                <xsl:apply-templates select="jp:footer-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="notice-others-rn">
        <schema:property name="tag" type="string"
                         enum="jp:notice-of-rejection-a131-rn,
                               jp:declining-the-amendment-a191-rn,
                               jp:declining-the-amendment-a192-rn,
                               jp:examiner-notification-a251-rn,
                               jp:examiner-notification-a2515-rn,
                               jp:examiner-notification-a2516-rn,
                               jp:examiner-notification-a252-rn,
                               jp:examiner-notification-a2522-rn,
                               jp:examiner-notification-a2529-rn,
                               jp:examiner-notification-a2530-rn" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-a" />
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-b" />
                <schema:ref name="ntc-pt-e-rn-container-items-type-a" />
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
                <xsl:value-of select="'発明の名称'" />
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
                <xsl:value-of select="'請求項の数'" />
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
                <xsl:value-of select="'・参考文献'" />
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
                    test="$node = 'jp:notice-of-rejection-a131-rn' 
                        or $node = 'jp:examiner-notification-a2515-rn' or $node = 'jp:examiner-notification-a2516-rn'
                        or $node = 'jp:examiner-notification-a251-rn'  or $node = 'jp:examiner-notification-a2522-rn'
                        or $node = 'jp:examiner-notification-a252-rn'  or $node = 'jp:examiner-notification-a2529-rn'
                        or $node = 'jp:examiner-notification-a2530-rn' or $node = 'jp:examiner-notification-a242623-rn'
                        or $node = 'jp:examiner-notification-a2541-rn'  or $node = 'jp:examiner-notification-a2542-rn'">
                    <xsl:value-of select="'　様'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="allname" select="concat($name,$persons,$sama)" />
        
        <xf:map>
            <xf:string key="sequence">
                <xsl:value-of select="position()" />
            </xf:string>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="$kind-of-law = 'patent'">
                        <xsl:choose>
                            <xsl:when test="./@jp:kind-of-person = 'applicant'">
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
                                    <xsl:when
                                        test="./@jp:kind-of-agent = 'designated-representative'">
                                        <xsl:value-of select="'指定代理人'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="''" /><!--14-->
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="''" /><!--14-->
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    
                    <xsl:when test="$kind-of-law = 'utility'">
                        <xsl:choose>
                            <xsl:when test="./@jp:kind-of-person = 'applicant'">
                                <xsl:choose>
                                    <xsl:when
                                        test="./@jp:kind-of-representative = 'representative-application'">
                                        <xsl:choose>
                                            <xsl:when test="position() = 1">
                                                <xsl:value-of select="'実用新案登録代表出願人'" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'代表出願人'" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <xsl:when test="./@jp:kind-of-agent = 'representative'">
                                                <xsl:choose>
                                                    <xsl:when test="position() = 1">
                                                        <xsl:value-of select="'実用新案登録出願人代理人'" />
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="'出願人代理人'" />
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'sub-representative'">
                                                <xsl:choose>
                                                    <xsl:when test="position() = 1">
                                                        <xsl:value-of select="'実用新案登録出願人復代理人'" />
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="'出願人復代理人'" />
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'legal-representative'">
                                                <xsl:choose>
                                                    <xsl:when test="position() = 1">
                                                        <xsl:value-of select="'実用新案登録出願人法定代理人'" />
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="'出願人法定代理人'" />
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                            <xsl:when
                                                test="./@jp:kind-of-agent = 'designated-representative'">
                                                <xsl:choose>
                                                    <xsl:when test="position() = 1">
                                                        <xsl:value-of select="'実用新案登録出願人指定代理人'" />
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="'出願人指定代理人'" />
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:choose>
                                                    <xsl:when test="position() = 1">
                                                        <xsl:value-of select="'実用新案登録出願人'" />
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="'出願人'" />
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="./@jp:kind-of-applicant = 'right-holder'">
                                <xsl:choose>
                                    <xsl:when test="./@jp:kind-of-agent = 'representative'">
                                        <xsl:value-of select="'実用新案権者代理人'" />
                                    </xsl:when>
                                    <xsl:when test="./@jp:kind-of-agent = 'sub-representative'">
                                        <xsl:value-of select="'実用新案権者復代理人'" />
                                    </xsl:when>
                                    <xsl:when test="./@jp:kind-of-agent = 'legal-representative'">
                                        <xsl:value-of select="'実用新案権者法定代理人'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="./@jp:kind-of-agent = 'designated-representative'">
                                        <xsl:value-of select="'実用新案権者指定代理人'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'実用新案権者'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="./@jp:kind-of-applicant = 'evaluation-requester'">
                                <xsl:choose>
                                    <xsl:when test="./@jp:kind-of-agent = 'representative'">
                                        <xsl:value-of select="'技術評価請求人代理人'" />
                                    </xsl:when>
                                    <xsl:when test="./@jp:kind-of-agent = 'sub-representative'">
                                        <xsl:value-of select="'技術評価請求人復代理人'" />
                                    </xsl:when>
                                    <xsl:when test="./@jp:kind-of-agent = 'legal-representative'">
                                        <xsl:value-of select="'技術評価請求人法定代理人'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="./@jp:kind-of-agent = 'designated-representative'">
                                        <xsl:value-of select="'技術評価請求人指定代理人'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'技術評価請求人'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="''" /><!--14-->
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="''" /><!--14-->
                    </xsl:otherwise>
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
                <xsl:value-of select="'・特許法第３０条適用'" />
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
                        <xsl:value-of select="'・発明の名称の変更'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="''" />
                    </xsl:otherwise>
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
                <xsl:choose>
                    <xsl:when test="number(normalize-space(.)) &lt; 19261225" /><!--編集しない-->
                    <xsl:when test="string-length(normalize-space(.)) = 8">
                        <xsl:call-template name="format-date-jp2">
                            <xsl:with-param name="date-str" select="normalize-space(.)" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise />
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:doc-number 文書番号
         ====================================================================-->
    <xsl:template match="jp:doc-number">
        <xsl:variable name="appl-type" select="ancestor::jp:application-reference/@appl-type" />
        <xsl:variable name="kind-of-law"
            select="ancestor::jp:application-reference/@jp:kind-of-law" />
        <xsl:variable name="appl-type"
            select="ancestor::jp:application-reference/@appl-type" />
        <xsl:variable name="kind-of-application"
            select="ancestor::jp:parent-application-article/@jp:kind-of-application" />
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when
                        test="$node = 'jp:examiner-notification-a242623-rn' or
                            $node = 'jp:examiner-notification-a2541-rn' or
                            $node = 'jp:examiner-notification-a2542-rn'">
                        <xsl:value-of select="''" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:parent-application-article">
                        <xsl:choose>
                            <xsl:when test="$kind-of-application = 'division'">
                                <xsl:value-of select="'分割出願'" />
                            </xsl:when>
                            <xsl:when test="$kind-of-application = 'change'">
                                <xsl:value-of select="'変更出願'" />
                            </xsl:when>
                            <xsl:when test="$kind-of-application = 'based-on-utility'">
                                <xsl:value-of select="'実用基礎'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="''" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="ancestor::jp:application-reference">
                        <xsl:choose>
                            <xsl:when test="$kind-of-law = 'patent'">
                                <xsl:value-of select="'特許出願の番号'" />
                            </xsl:when>
                            <xsl:when test="$kind-of-law = 'utility'">
                                <xsl:value-of select="'実用新案登録出願の番号'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="''" /><!--14-->
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="''" /><!--14-->
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">0</xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space(.)" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:application-reference and $appl-type = 'application'">
                        <!-- 発送系は、出願番号の表示が「特許願」だけど、
                             出願系は「特願」である。だけど、出願系の表示に変更（共用）-->
                        <xsl:call-template name="文書番号内容編集" />
                        <!--
                             <xsl:call-template name="translate-application-number">
                             <xsl:with-param name="number" select="normalize-space(.)" />
                             <xsl:with-param name="law" select="$kind-of-law" />
                             <xsl:with-param name="kinddoc" select="$node" />
                             </xsl:call-template>
                        -->
                        <xsl:if
                            test="$node = 'jp:examiner-notification-a2541-rn' or 
                                $node = 'jp:examiner-notification-a2542-rn'">
                            <xsl:value-of select="'　に関し'" />
                        </xsl:if>
                        
                    </xsl:when>
                    <!--登録番号-->
                    <xsl:when
                        test="ancestor::jp:application-reference and $appl-type = 'registration'">
                        <xsl:if test="string-length(normalize-space(.)) = 7"><!--7桁のみ編集-->
                            <xsl:value-of select="'実用新案登録　第'" />
                            <xsl:value-of select="f:to-fullwidth-digit(f:remove-nbsp(.))" />
                            <xsl:value-of select="'号'" />
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise />
                </xsl:choose>
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
            <xf:string key="convertedText">
                <xsl:value-of select="'特許法第３０条' || . || 'の規定の適用'" />
            </xf:string>
            <xf:string key="indentLevel">2</xf:string>
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
    <schema:object name="ntc-pt-e-rn-terminal-items-type-a">
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
                         jp:doc-number,
                         jp:depository-ins-code,
                         jp:depository-number,
                         jp:application-section,
                         jp:exceptions-to-lack-of-novelty" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="text" type="string" />
        <schema:property name="convertedText" type="string" optional="true" />
    </schema:object>
    <!--=========================================
         End: terminal type A
         ===========================================-->
    
    <!-- ====================================================================
         Begin:
         terminal type B elements have tag, text and optional convertedText.
         no child elements.
         ====================================================================-->
    <!-- ====================================================================
         jp:document-name 書類名
         ====================================================================-->
    <xsl:template match="jp:document-name">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
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
         jp:fi ＦＩ
         ====================================================================-->
    <xsl:template match="jp:fi">
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
                        test="ancestor::jp:staff2-group or ancestor::jp:staff3-group
                            or ancestor::jp:staff4-group or ancestor::jp:devider">
                        <xsl:value-of select="normalize-space(.)" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:addressed-to-person-group">
                        <xsl:value-of select="normalize-space(.)" />
                    </xsl:when>
                    <xsl:when
                        test="($node = 'jp:examiner-notification-a2515-rn'
                                or $node = 'jp:examiner-notification-a2516-rn'
                                or $node = 'jp:examiner-notification-a2522-rn')
                            and ancestor::jp:draft-person-group">
                        <xsl:value-of select="''" />
                    </xsl:when>
                    <xsl:when
                        test="($node = 'jp:examiner-notification-a242623-rn'
                                or $node = 'jp:examiner-notification-a2541-rn'
                                or $node = 'jp:examiner-notification-a2542-rn')
                            and ancestor::jp:draft-person-group">
                        <xsl:value-of select="normalize-space(.)" />
                    </xsl:when>
                    
                    <xsl:when
                        test="($node != 'jp:examiner-notification-a2515-rn'
                                and $node != 'jp:examiner-notification-a2516-rn'
                                and $node != 'jp:examiner-notification-a2522-rn')
                            and ancestor::jp:draft-person-group">
                        <xsl:value-of select="normalize-space(.)" />
                    </xsl:when>
                    <xsl:otherwise />
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
                    <xsl:when test="ancestor::jp:devider">
                        <xsl:value-of select="f:to-fullwidth-digit($code)" />
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:staff2-group
                            or ancestor::jp:staff3-group or ancestor::jp:staff4-group">
                        <xsl:value-of select="f:to-fullwidth-digit($code)" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:draft-person-group">
                        <xsl:value-of select="f:to-fullwidth-digit($code)" />
                    </xsl:when>
                    <xsl:otherwise />
                </xsl:choose>
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
    
    <!-- all of terminal type B elements follow the same pattern. -->
    <schema:object name="ntc-pt-e-rn-terminal-items-type-b">
        <schema:property
            name="tag" type="string"
                   enum="jp:document-name,
                         jp:reconsideration-before-appeal,
                         jp:article,
                         jp:fi,
                         jp:name,
                         jp:staff-code,
                         jp:office-code,
                         jp:official-title,
                         jp:field-of-search,
                         jp:patent-reference-group,
                         jp:reference-books" />
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
         jp:bibliog-in-ntc-pat-exam-rn 書誌部
         ====================================================================-->
    <xsl:template match="jp:bibliog-in-ntc-pat-exam-rn">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:choose>
                    <xsl:when test="$node = 'jp:examiner-notification-a242623-rn'">
                        <xsl:apply-templates select="jp:drafting-date" />
                        <xsl:apply-templates select="jp:draft-person-group" />
                        <xsl:apply-templates select="jp:addressed-to-person-group" />
                        <xsl:apply-templates select="jp:application-reference" />
                    </xsl:when>
                    <xsl:when
                        test="$node = 'jp:examiner-notification-a2541-rn' or 
                            $node = 'jp:examiner-notification-a2542-rn'">
                        <xsl:apply-templates select="jp:drafting-date" />
                        <xsl:apply-templates select="jp:draft-person-group" />
                        <xsl:apply-templates select="jp:addressed-to-person-group" />
                        <xsl:apply-templates select="jp:application-reference" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="jp:application-reference" />
                        <xsl:apply-templates select="jp:drafting-date" />
                        <xsl:apply-templates select="jp:draft-person-group" />
                        <xsl:apply-templates select="invention-title" />
                        <xsl:apply-templates select="jp:number-of-claim" />
                        <xsl:apply-templates select="jp:addressed-to-person-group" />
                        <xsl:apply-templates select="jp:article-group" />
                        <xsl:apply-templates select="jp:remark" />
                    </xsl:otherwise>
                </xsl:choose>
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
         jp:footer-article フッタ部
         ====================================================================-->
    <xsl:template match="jp:footer-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:approval-column-article" />
                <xsl:apply-templates select="jp:certification-column-article" />
                <xsl:apply-templates select="jp:inquiry-article" />
                <xsl:apply-templates select="jp:approval-without-contents" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:final-decision-group-rn 査定固有部
         ====================================================================-->
    <xsl:template match="jp:final-decision-group-rn">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:kind-of-application" />
                <xsl:apply-templates select="jp:exist-of-reference-doc" />
                <xsl:apply-templates select="jp:patent-law-section30" />
                <xsl:apply-templates select="jp:change-flag-invention-title" />
                <xsl:apply-templates select="jp:deposit-article" />
                <xsl:apply-templates select="jp:parent-application-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:final-decision-memo-rn 査定メモ
         ====================================================================-->
    <xsl:template match="jp:final-decision-memo-rn">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-name" />
                <xsl:apply-templates select="jp:final-decision-bibliog-rn" />
                <xsl:apply-templates select="jp:final-decision-body-rn" />
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
         jp:final-decision-bibliog-rn メモ内書誌部
         ====================================================================-->
    <xsl:template match="jp:final-decision-bibliog-rn">
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
         jp:final-decision-body-rn メモ内本文部
         ====================================================================-->
    <xsl:template match="jp:final-decision-body-rn">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:fi-article" />
                <xsl:apply-templates select="jp:field-of-search-article" />
                <xsl:apply-templates select="jp:patent-reference-article" />
                <xsl:apply-templates select="jp:reference-books-article" />
                <xsl:apply-templates select="jp:exceptions-to-lack-of-novelty-art" />
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
                <xsl:choose>
                    <xsl:when test="ancestor::jp:parent-application-article">
                        <xsl:apply-templates select="jp:doc-number | jp:date" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="jp:doc-number" />
                    </xsl:otherwise>
                </xsl:choose>
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
                <xsl:choose>
                    <xsl:when test="$node = 'jp:decision-of-registration-a01-rn'">
                        <xsl:apply-templates select="jp:staff2-group/jp:official-title" />
                        <xsl:apply-templates select="jp:staff3-group/jp:official-title" />
                        <xsl:apply-templates select="jp:staff4-group/jp:official-title" />
                        <xsl:if test="following-sibling::jp:devider">
                            <xsl:apply-templates
                                select="following-sibling::jp:devider/jp:official-title" />
                        </xsl:if>
                        
                        <xsl:apply-templates select="jp:staff2-group/jp:name" />
                        <xsl:apply-templates select="jp:staff3-group/jp:name" />
                        <xsl:apply-templates select="jp:staff4-group/jp:name" />
                        <xsl:if test="following-sibling::jp:devider">
                            <xsl:apply-templates select="following-sibling::jp:devider/jp:name" />
                        </xsl:if>
                        
                        <xsl:apply-templates select="jp:staff2-group/jp:staff-code" />
                        <xsl:apply-templates select="jp:staff3-group/jp:staff-code" />
                        <xsl:apply-templates select="jp:staff4-group/jp:staff-code" />
                        <xsl:if test="following-sibling::jp:devider">
                            <xsl:apply-templates select="following-sibling::jp:devider/jp:staff-code" />
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="jp:staff2-group/jp:official-title" />
                        <xsl:apply-templates select="jp:staff3-group/jp:official-title" />
                        <xsl:apply-templates select="jp:staff4-group/jp:official-title" />
                        
                        <xsl:apply-templates select="jp:staff2-group/jp:name" />
                        <xsl:apply-templates select="jp:staff3-group/jp:name" />
                        <xsl:apply-templates select="jp:staff4-group/jp:name" />
                        
                        <xsl:apply-templates select="jp:staff2-group/jp:staff-code" />
                        <xsl:apply-templates select="jp:staff3-group/jp:staff-code" />
                        <xsl:apply-templates select="jp:staff4-group/jp:staff-code" />
                    </xsl:otherwise>
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
                <xsl:if test="ancestor::jp:parent-application-article">
                    <xsl:if test="position() = 1">
                        <xf:map>
                            <xf:string key="tag">
                                <xsl:value-of select="'text'" />
                            </xf:string>
                            <xf:string key="text">
                                <xsl:value-of select="'　遡及を認める原出願の出願番号、原出願の出願日'" />
                            </xf:string>
                        </xf:map>
                    </xsl:if>
                </xsl:if>
                <xsl:apply-templates select="jp:document-id" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <schema:object name="ntc-pt-e-rn-container-items-type-a">
        <schema:property
            name="tag" type="string"
                   enum="jp:bibliog-in-ntc-pat-exam-rn,
                         jp:conclusion-part-article,
                         jp:drafting-body,
                         jp:footer-article,
                         jp:final-decision-group-rn,
                         jp:final-decision-memo-rn,
                         jp:drafting-date,
                         jp:heading,
                         jp:final-decision-bibliog-rn,
                         jp:final-decision-body-rn,
                         jp:document-id,
                         jp:approval-column-article,
                         jp:image-group,
                         jp:application-reference" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-a" />
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-b" />
                <schema:ref name="ntc-pt-e-rn-container-items-type-a" />
                <schema:ref name="ntc-pt-e-rn-container-items-type-b" />
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
                        test="$node = 'jp:examiner-notification-a2515-rn'
                            or $node = 'jp:examiner-notification-a2516-rn'
                            or $node = 'jp:examiner-notification-a2522-rn'">
                        <xsl:value-of select="'特許庁長官'" />
                    </xsl:when>
                    <xsl:when test="$node = 'jp:examiner-notification-a242623-rn'" />
                    <xsl:when test="$node = 'jp:examiner-notification-a2541-rn'" />
                    <xsl:when test="$node = 'jp:examiner-notification-a2542-rn'" />
                    <xsl:otherwise>
                        <xsl:value-of select="'特許庁審査官'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:choose>
                    <xsl:when
                        test="$node = 'jp:examiner-notification-a242623-rn' or
                            $node = 'jp:examiner-notification-a2541-rn'  or
                            $node = 'jp:examiner-notification-a2542-rn'">
                        <xsl:apply-templates select="jp:name" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="jp:name" />
                        <xsl:apply-templates select="jp:staff-code" />
                        <xsl:apply-templates select="jp:office-code" />
                    </xsl:otherwise>
                </xsl:choose>
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
         jp:fi-article ＦＩの記事
         ====================================================================-->
    <xsl:template match="jp:fi-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'・ＦＩ'" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:fi" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:deposit-article
         ====================================================================-->
    <!-- 菌寄託の記事 -->
    <xsl:template match="jp:deposit-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'・菌寄託'" />
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
                <xsl:apply-templates select="jp:depository-number" />
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
                <xsl:value-of select="'・出願日の遡及を認めない旨の表示'" />
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./jp:application-reference">
                        <xsl:value-of select="'　出願日の遡及を一部認めない。'" />
                    </xsl:when>
                    <xsl:when test="not(./jp:application-reference)">
                        <xsl:value-of select="'　出願日の遡及を認めない。'" />
                    </xsl:when>
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
                <xsl:value-of select="'・調査した分野（ＩＰＣ，ＤＢ名）'" />
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
                <xsl:value-of select="'・参考特許文献'" />
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
                <xsl:value-of select="'・参考図書雑誌'" />
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
                <xsl:value-of select="'・新規性喪失例外規定の適用の事実'" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:exceptions-to-lack-of-novelty-grp" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:exceptions-to-lack-of-novelty-grp 新規性喪失の例外
         ====================================================================-->
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
    
    <schema:object name="ntc-pt-e-rn-container-items-type-b">
        <schema:property
            name="tag" type="string"
                   enum="jp:draft-person-group,
                         jp:article-group,
                         jp:remark,
                         jp:fi-article,
                         jp:deposit-article,
                         jp:deposit,
                         jp:parent-application-article,
                         jp:field-of-search-article,
                         jp:patent-reference-article,
                         jp:reference-books-article,
                         jp:exceptions-to-lack-of-novelty-art,
                         jp:exceptions-to-lack-of-novelty-grp" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" optional="true" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-a" />
                <schema:ref name="ntc-pt-e-rn-terminal-items-type-b" />
                <schema:ref name="ntc-pt-e-rn-container-items-type-a" />
                <schema:ref name="ntc-pt-e-rn-container-items-type-b" />
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
                    <xsl:when test="$node = 'jp:examiner-notification-a30-rn'">
                        <xsl:value-of select="'作成日'" />
                    </xsl:when>
                    <xsl:when
                        test="$node = 'jp:examiner-notification-a242623-rn' or 
                            $node = 'jp:examiner-notification-a2541-rn' or
                            $node = 'jp:examiner-notification-a2542-rn'">
                        <xsl:value-of select="''" />
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
    <!-- 行服部 -->
    <xsl:template match="jp:administrative-appeal-sentence">
        <xsl:call-template name="unsupported-tag" />
    </xsl:template>
    
    <!-- ====================================================================
         jp:approval-without-contents
         ====================================================================-->
    <!-- 内容無し決裁欄 -->
    <xsl:template match="jp:approval-without-contents">
        <!--編集しない-->
    </xsl:template>
    
    <!-- ====================================================================
         jp:addressbook
         ====================================================================-->
    <xsl:template match="jp:addressbook">
        <xsl:call-template name="unsupported-tag" />
    </xsl:template>
    
    
    <!-- ====================================================================
         未サポートタグ（全角空白１つあけて表示）
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
         未サポートタグ（全角空白２つあけて表示）
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
         未サポートタグ（全角空白３つあけて表示）
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