<?xml version="1.0" encoding="UTF-8"?>

<!-- 
 original xsl: v4xva_ntc-pt-e.xsl at May  8  2018
sha256sum:a7320028fed94b06b18c588279b712cf52305aa76b5f4472c1d76604fe84d07d
-->
<!-- ====================================================================
　　　変換対象書類名：特実審査周辺（共通部）
　   ====================================================================-->
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:f="urn:phantom-mona:string-utils"
    xmlns:schema="urn:schema-dsl"
    exclude-result-prefixes="f jp">

    <xsl:variable name="node" select="name(//jp:notice-pat-exam/*)" />
    <xsl:variable name="kind-of-law">
        <xsl:value-of select="/root/jp:cpy-notice-pat-exam/jp:notice-pat-exam/*/@jp:kind-of-law[1]" />
    </xsl:variable>

    <xsl:include href="ntc-ninsyo.xsl" />
    <xsl:include href="common-templates/doc-number.xsl" />
    <xsl:include href="common-templates/string-utils.xsl" />
    <xsl:include href="common-templates/v4xva_prm.xsl" />
    <xsl:include href="common-templates/dispatch-control-article.xsl" />
    <xsl:include href="common-templates/date-templates.xsl" />


    <!-- ====================================================================
     jp:notice-pat-exam

     jp:decision-of-registration-a01  A[12]01 特許査定
     jp:decision-of-rejection-a02     A[12]02 拒絶査定
     jp:notice-of-rejection-a131      A1131   拒絶理由通知
     jp:declining-the-amendment-a191  A[12]191    補正却下の決定
     jp:declining-the-amendment-a192  A[12]192    補正却下の決定
     jp:examiner-notification-a251    A[12]251    審査官通知i(その他の通知）（期間有）
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
        <xsl:apply-templates
            select="jp:decision-of-registration-a01 | jp:decision-of-rejection-a02
                   | jp:notice-of-rejection-a131 | jp:declining-the-amendment-a191
                   | jp:declining-the-amendment-a192 | jp:examiner-notification-a251
                   | jp:examiner-notification-a2514 | jp:examiner-notification-a2515
                   | jp:examiner-notification-a2516 | jp:examiner-notification-a252
                   | jp:examiner-notification-a2522 | jp:examiner-notification-a2529
                   | jp:examiner-notification-a30
                   | jp:examiner-notification-a25110| jp:examiner-notification-a25111" />
    </xsl:template>

    <!-- ====================================================================
     jp:decision-of-registration-a01
     ====================================================================-->
    <xsl:template match="jp:decision-of-registration-a01">
        <xsl:apply-templates select="jp:document-name" />
        <xsl:apply-templates select="jp:kind-of-application" />
        <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam" />
        <xsl:apply-templates select="jp:reconsideration-before-appeal" />
        <xsl:apply-templates select="jp:conclusion-part-article" />
        <xsl:apply-templates select="jp:drafting-body" />
        <xsl:apply-templates select="jp:footer-article" />
        <xsl:apply-templates select="jp:final-decision-group" />
        <xsl:apply-templates select="jp:final-decision-memo" />
    </xsl:template>

    <!-- ====================================================================
     jp:decision-of-rejection-a02
     ====================================================================-->
    <xsl:template match="jp:decision-of-rejection-a02">
        <xsl:apply-templates select="jp:document-name" />
        <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam" />
        <xsl:apply-templates select="jp:reconsideration-before-appeal" />
        <xsl:apply-templates select="jp:drafting-body" />
        <xsl:apply-templates select="jp:footer-article" />
    </xsl:template>

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
        <xsl:apply-templates select="jp:document-name" />
        <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam" />
        <xsl:apply-templates select="jp:reconsideration-before-appeal" />
        <xsl:apply-templates select="jp:conclusion-part-article" />
        <xsl:apply-templates select="jp:drafting-body" />
        <xsl:apply-templates select="jp:footer-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:examiner-notification-a30
     ====================================================================-->
    <xsl:template match="jp:examiner-notification-a30">
        <xsl:apply-templates select="jp:document-name" />
        <xsl:apply-templates select="jp:bibliog-in-ntc-pat-exam" />
        <xsl:apply-templates select="jp:reconsideration-before-appeal" />
        <xsl:apply-templates select="jp:image-group" />
    </xsl:template>

    <schema:object
        name="notice-pat-exam">
        <schema:property name="tag" type="string"
            const="jp:notice-pat-exam" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="dispatch-control-article" />
                <schema:ref name="bibliog-in-ntc-pat-exam" />
                <schema:ref name="conclusion-part-article" />
                <schema:ref name="document-name" />
                <schema:ref name="drafting-body" />
                <schema:ref name="final-decision-group" />
                <schema:ref name="final-decision-memo" />
                <schema:ref name="footer-article" />
                <schema:ref name="image-group" />
                <schema:ref name="kind-of-application" />
                <schema:ref name="reconsideration-before-appeal" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     begin: type A elements have a tag and blocks.
     ====================================================================-->
    <!-- ====================================================================
     jp:bibliog-in-ntc-pat-exam
     ====================================================================-->
    <!-- 書誌部 -->
    <xsl:template match="jp:bibliog-in-ntc-pat-exam">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>

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
        </xsl:element>
    </xsl:template>
    <schema:object name="bibliog-in-ntc-pat-exam">
        <schema:property name="tag" type="string"
            const="jp:bibliog-in-ntc-pat-exam" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="addressed-to-person-group" />
                <schema:ref name="application-reference" />
                <schema:ref name="article-group" />
                <schema:ref name="draft-person-group" />
                <schema:ref name="drafting-date" />
                <schema:ref name="notice-invention-title" />
                <schema:ref name="number-of-claim" />
                <schema:ref name="remark" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:conclusion-part-article
     ====================================================================-->
    <!-- 結論 -->
    <xsl:template match="jp:conclusion-part-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:for-each select="p">
                <xsl:apply-templates select="." />
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <schema:object name="conclusion-part-article">
        <schema:property name="tag" type="string"
            const="jp:conclusion-part-article" />
        <schema:property name="blocks" type="array">
            <schema:ref name="paragraph" />
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:drafting-body
     ====================================================================-->
    <!-- 本文部 -->
    <xsl:template match="jp:drafting-body">
        <xsl:if test="p/* or jp:heading">
            <xsl:element name="blocks">
                <xsl:element name="tag">
                    <xsl:value-of select="name()" />
                </xsl:element>
                <xsl:apply-templates select="p | jp:heading" />
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <schema:object name="drafting-body">
        <schema:property name="tag" type="string"
            const="jp:drafting-body" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="heading" />
                <schema:ref name="paragraph" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:footer-article
     ====================================================================-->
    <!-- フッタ部 -->
    <xsl:template match="jp:footer-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:administrative-appeal-sentence" />
            <xsl:apply-templates select="jp:approval-column-article" />
            <!--
            XSL に定義なし
            <xsl:apply-templates select="jp:approval-without-contents" />
            -->
            <xsl:apply-templates select="jp:certification-column-article" />
            <xsl:apply-templates select="jp:inquiry-article" />
        </xsl:element>
    </xsl:template>
    <schema:object name="footer-article">
        <schema:property name="tag" type="string"
            const="jp:footer-article" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="administrative-appeal-sentence" />
                <schema:ref name="approval-column-article" />
                <schema:ref name="certification-column-article" />
                <schema:ref name="inquiry-article" />

                <!--child
                under ntc-pt-e-rn/footer-article -->
                <schema:ref name="approval-without-contents" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:final-decision-group
     ====================================================================-->
    <!-- 査定固有部 -->
    <xsl:template match="jp:final-decision-group">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:kind-of-application" />
            <xsl:apply-templates select="jp:exist-of-reference-doc" />
            <xsl:apply-templates select="jp:patent-law-section30" />
            <xsl:apply-templates select="jp:change-flag-invention-title" />
            <xsl:apply-templates select="jp:ipc-article" />
            <xsl:apply-templates select="jp:classification-article" />
            <xsl:apply-templates select="jp:deposit-article" />
            <xsl:apply-templates select="jp:parent-application-article" />
        </xsl:element>
    </xsl:template>
    <schema:object name="final-decision-group">
        <schema:property name="tag" type="string"
            enum="jp:final-decision-group jp:final-decision-group-rn" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="kind-of-application" />
                <schema:ref name="exist-of-reference-doc" />
                <schema:ref name="patent-law-section30" />
                <schema:ref name="change-flag-invention-title" />
                <schema:ref name="deposit-article" />
                <schema:ref name="parent-application-article" />

                <!-- these two are children under this template,
                     not in ntc-pat-exam-rn. -->
                <schema:ref name="ipc-article" />
                <schema:ref name="classification-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:final-decision-memo
     ====================================================================-->
    <!-- 査定メモ -->
    <xsl:template match="jp:final-decision-memo">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:document-name" />
            <xsl:apply-templates select="jp:final-decision-bibliog" />
            <xsl:apply-templates select="jp:final-decision-body" />
        </xsl:element>
    </xsl:template>
    <schema:object name="final-decision-memo">
        <schema:property name="tag" type="string"
            enum="jp:final-decision-memo jp:final-decision-memo-rn" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="document-name" />
                <schema:ref name="final-decision-bibliog" />
                <schema:ref name="final-decision-body" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:drafting-date
     ====================================================================-->
    <!-- 起案日  -->
    <xsl:template match="jp:drafting-date">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:date" />
        </xsl:element>
    </xsl:template>
    <schema:object name="drafting-date">
        <schema:property name="tag" type="string" const="jp:drafting-date" />
        <schema:property name="blocks" type="array">
            <schema:ref name="date" />
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:heading
     ====================================================================-->
    <!-- 中央段落  -->
    <xsl:template match="jp:heading">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    <schema:object name="heading">
        <schema:property name="tag" type="string" const="jp:heading" />
        <schema:property name="blocks" type="array">
            <schema:ref name="inline-text" />
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:final-decision-bibliog
     ====================================================================-->
    <!-- メモ内書誌部  -->
    <xsl:template match="jp:final-decision-bibliog">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:application-reference" />
        </xsl:element>
    </xsl:template>
    <schema:object name="final-decision-bibliog">
        <schema:property name="tag" type="string"
            enum="jp:final-decision-bibliog jp:final-decision-bibliog-rn" />
        <schema:property name="blocks" type="array">
            <schema:ref name="application-reference" />
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:final-decision-body
     ====================================================================-->
    <!-- メモ内本文部  -->
    <xsl:template match="jp:final-decision-body">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:field-of-search-article" />
            <xsl:apply-templates select="jp:patent-reference-article" />
            <xsl:apply-templates select="jp:reference-books-article" />
            <xsl:apply-templates select="jp:exceptions-to-lack-of-novelty-art" />
            <xsl:apply-templates select="jp:deposit-article" />
        </xsl:element>
    </xsl:template>
    <schema:object name="final-decision-body">
        <schema:property name="tag" type="string"
            enum="jp:final-decision-body jp:final-decision-body-rn" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="field-of-search-article" />
                <schema:ref name="patent-reference-article" />
                <schema:ref name="reference-books-article" />
                <schema:ref name="exceptions-to-lack-of-novelty-art" />

                <!--this
                is child under this template, not in v4xva_ntc-p-e-rn -->
                <schema:ref name="deposit-article" />

                <!--this
                is not child under this template, in v4xva_ntc-p-e-rn -->
                <schema:ref name="jp:fi-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:document-id
     ====================================================================-->
    <!-- ドキュメント識別 -->
    <xsl:template match="jp:document-id">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:doc-number | jp:date" />
        </xsl:element>
    </xsl:template>
    <schema:object name="document-id">
        <schema:property name="tag" type="string"
            const="jp:document-id" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="doc-number" />
                <schema:ref name="date" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:approval-column-article

     <u>     <u> で区切りの下線を引いているように思われる。
     XSLT はこのような出力はせず、のちのRendererで引かせる実装とする。
     ====================================================================-->
    <!-- 決裁欄  -->
    <xsl:template match="jp:approval-column-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
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
        </xsl:element>
    </xsl:template>
    <schema:object name="approval-column-article">
        <schema:property name="tag" type="string"
            const="jp:approval-column-article" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="official-title" />
                <schema:ref name="name" />
                <schema:ref name="staff-code" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:image-group
     ====================================================================-->
    <!-- イメージ -->
    <xsl:template match="jp:image-group">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="img" />
        </xsl:element>
    </xsl:template>
    <schema:object name="image-group">
        <schema:property name="tag" type="string"
            const="jp:image-group" />
        <schema:property name="blocks" type="array">
            <schema:ref name="img" />
        </schema:property>
    </schema:object>
    <!-- ====================================================================
     end: type A elements have a tag and blocks.
     ====================================================================-->

    <!-- ====================================================================
     begin:
       type B elements have tag, jp-tag, indent-level and text.
       optional: converted-text
     ====================================================================-->
    <!-- ====================================================================
     jp:kind-of-application
     ====================================================================-->
    <!-- 出願種別 -->
    <xsl:template match="jp:kind-of-application">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:final-decision-group">
                        <xsl:value-of select="'１．出願種別'" />
                    </xsl:when>
                    <xsl:otherwise />
                </xsl:choose>
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:final-decision-group">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'（' || . || '）'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="kind-of-application">
        <schema:property name="tag" type="string"
            const="jp:kind-of-application" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     invention-title
     ====================================================================-->
    <!-- 発明または考案の名称  -->
    <xsl:template match="invention-title">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="'notice-invention-title'" />
            </xsl:element>
            <xsl:element name="jp-tag">
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
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="notice-invention-title">
        <schema:property name="tag" type="string"
            const="notice-invention-title" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:number-of-claim
     ====================================================================-->
    <!-- 請求項の数  -->
    <xsl:template match="jp:number-of-claim">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:choose>
                    <xsl:when test="./@jp:adopted-law = 'claim'">
                        <xsl:value-of select="'請求項の数'" />
                    </xsl:when>
                    <xsl:when test="./@jp:adopted-law = 'invention'">
                        <xsl:value-of select="'特許請求の範囲に記載された発明の数'" />
                    </xsl:when>
                </xsl:choose>
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="f:remove-nbsp(.)" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="number-of-claim">
        <schema:property name="tag" type="string"
            const="jp:number-of-claim" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:exist-of-reference-doc
     ====================================================================-->
    <!-- 参考文献有無  -->
    <xsl:template match="jp:exist-of-reference-doc">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'２．参考文献'" />
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:choose>
                    <xsl:when test="./@jp:true-or-false = 'true'">
                        <xsl:value-of select="'有'" />
                    </xsl:when>
                    <xsl:when test="./@jp:true-or-false = 'false'">
                        <xsl:value-of select="'無'" />
                    </xsl:when>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="exist-of-reference-doc">
        <schema:property name="tag" type="string"
            const="jp:exist-of-reference-doc" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:addressed-to-person-group
     ====================================================================-->
    <!-- あて先  -->
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


        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
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
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="$allname" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="addressed-to-person-group">
        <schema:property name="tag" type="string"
            const="jp:addressed-to-person-group" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:patent-law-section30
     ====================================================================-->
    <!-- 特許法第３０条適用有無  -->
    <xsl:template match="jp:patent-law-section30">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'３．特許法第３０条適用'" />
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:choose>
                    <xsl:when test="./@jp:true-or-false = 'true'">
                        <xsl:value-of select="'有'" />
                    </xsl:when>
                    <xsl:when test="./@jp:true-or-false = 'false'">
                        <xsl:value-of select="'無'" />
                    </xsl:when>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="patent-law-section30">
        <schema:property name="tag" type="string"
            const="jp:patent-law-section30" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:change-flag-invention-title
     ====================================================================-->
    <!-- 発明の名称の変更有無  -->
    <xsl:template match="jp:change-flag-invention-title">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:choose>
                    <xsl:when test="$kind-of-law = 'patent'">
                        <xsl:value-of select="'４．発明の名称の変更'" />
                    </xsl:when>
                    <xsl:when test="$kind-of-law = 'utility'">
                        <xsl:value-of select="'４．考案の名称の変更'" />
                    </xsl:when>
                </xsl:choose>
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:choose>
                    <xsl:when test="./@jp:true-or-false = 'true'">
                        <xsl:value-of select="'有'" />
                    </xsl:when>
                    <xsl:when test="./@jp:true-or-false = 'false'">
                        <xsl:value-of select="'無'" />
                    </xsl:when>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="change-flag-invention-title">
        <schema:property name="tag" type="string"
            const="jp:change-flag-invention-title" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:date
     ====================================================================-->
    <!-- 日付 -->
    <xsl:template match="jp:date">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:call-template name="日付タイトル" />
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
            <xsl:element name="converted-text">
                <xsl:call-template name="format-date-jp2">
                    <xsl:with-param name="date-str" select="normalize-space(.)" />
                </xsl:call-template>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="date">
        <schema:property name="tag" type="string" const="jp:date" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="text" type="string" />
        <schema:property name="converted-text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:version-number
     ====================================================================-->
    <!-- 版コード -->
    <xsl:template match="jp:version-number">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'　版コード　　　'" />
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
            <xsl:element name="converted-text">
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(.))" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="version-number">
        <schema:property name="tag" type="string"
            const="jp:version-number" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="text" type="string" />
        <schema:property name="converted-text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:doc-number
      元 <xsl:template name="文書番号編集">
     ====================================================================-->
    <!-- 文書番号 -->
    <xsl:template match="jp:doc-number">
        <xsl:variable name="kind-of-law" select="ancestor::jp:application-reference/@jp:kind-of-law" />
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
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
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
            <xsl:element name="converted-text">
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
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="doc-number">
        <schema:property name="tag" type="string" const="jp:doc-number" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="text" type="string" />
        <schema:property name="converted-text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:depository-ins-code
     ====================================================================-->
    <!-- 受託機関コード -->
    <xsl:template match="jp:depository-ins-code">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'受託機関コード'" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
            <xsl:element name="converted-text">
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(.))" />
            </xsl:element>
            <xsl:element name="indent-level">2</xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="depository-ins-code">
        <schema:property name="tag" type="string"
            const="jp:depository-ins-code" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="text" type="string" />
        <schema:property name="converted-text" type="string" />
        <schema:property name="indent-level" type="integer" />
    </schema:object>

    <!-- ====================================================================
     jp:depository-number
     ====================================================================-->
    <!-- 受託番号 -->
    <xsl:template match="jp:depository-number">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'受託番号'" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
            <xsl:element name="converted-text">
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(.))" />
            </xsl:element>
            <xsl:element name="indent-level">2</xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="depository-number">
        <schema:property name="tag" type="string"
            const="jp:depository-number" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="text" type="string" />
        <schema:property name="converted-text" type="string" />
        <schema:property name="indent-level" type="integer" />
    </schema:object>

    <!-- ====================================================================
     jp:application-section
     ====================================================================-->
    <!-- 適用条項 -->
    <xsl:template match="jp:application-section">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'適用条文'" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
            <xsl:element name="indent-level">2</xsl:element>
            <xsl:element name="converted-text">
                <xsl:choose>
                    <xsl:when test="$kind-of-law = 'patent'">
                        <xsl:value-of select="'特許法第３０条' || . || 'の規定の適用'" />
                    </xsl:when>
                    <xsl:when test="$kind-of-law = 'utility'">
                        <xsl:value-of select="'実用新案法第９条第１項で準用する特許法第３０条' || . || 'の規定の適用'" />
                    </xsl:when>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="application-section">
        <schema:property name="tag" type="string"
            const="jp:application-section" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="text" type="string" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="converted-text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:exceptions-to-lack-of-novelty
     ====================================================================-->
    <!-- 新規性喪失例外適用 -->
    <xsl:template match="jp:exceptions-to-lack-of-novelty">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'内容'" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:for-each select="p">
                    <xsl:value-of select="normalize-space(.)" />
                </xsl:for-each>
            </xsl:element>
            <xsl:element name="indent-level">2</xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="exceptions-to-lack-of-novelty">
        <schema:property name="tag" type="string"
            const="jp:exceptions-to-lack-of-novelty" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="text" type="string" />
        <schema:property name="indent-level" type="integer" />
    </schema:object>
    <!--=========================================
     End: type B
     ===========================================-->

    <!-- ====================================================================
     Begin:
       type C elements have tag, jp-tag, child elements and optional indent-level.
     ====================================================================-->
    <!-- ====================================================================
     jp:draft-person-group 起案者
     ====================================================================-->
    <xsl:template match="jp:draft-person-group">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
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
            </xsl:element>
            <xsl:apply-templates select="jp:name" />
            <xsl:apply-templates select="jp:staff-code" />
            <xsl:apply-templates select="jp:office-code" />
        </xsl:element>
    </xsl:template>
    <schema:object name="draft-person-group">
        <schema:property name="tag" type="string"
            const="jp:draft-person-group" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="name" />
                <schema:ref name="staff-code" />
                <schema:ref name="office-code" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:article-group 適用条文グループ
     ====================================================================-->
    <xsl:template match="jp:article-group">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'適用条文'" />
            </xsl:element>
            <xsl:apply-templates select="jp:article" />
        </xsl:element>
    </xsl:template>
    <schema:object name="article-group">
        <schema:property name="tag" type="string"
            const="jp:article-group" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="article" />
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:remark 備考
     ====================================================================-->
    <xsl:template match="jp:remark">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'備考'" />
            </xsl:element>
            <xsl:apply-templates select="p" />
        </xsl:element>
    </xsl:template>
    <schema:object name="remark">
        <schema:property name="tag" type="string" const="jp:remark" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="paragraph" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:ipc-article 国際特許分類の記事
     ====================================================================-->
    <xsl:template match="jp:ipc-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'５．国際特許分類（ＩＰＣ）'" />
            </xsl:element>
            <xsl:apply-templates select="jp:ipc" />
        </xsl:element>
    </xsl:template>
    <schema:object name="ipc-article">
        <schema:property name="tag" type="string"
            const="jp:ipc-article" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="ipc" />
        </schema:property>
    </schema:object>

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
                <xsl:element name="blocks">
                    <xsl:element name="tag">
                        <xsl:value-of select="name()" />
                    </xsl:element>
                    <xsl:element name="jp-tag">
                        <xsl:value-of select="'６．併記特許分類'" />
                    </xsl:element>
                    <xsl:apply-templates select="jp:version-number" />
                    <xsl:apply-templates select="jp:ipc" />
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <schema:object name="classification-article">
        <schema:property name="tag" type="string"
            const="jp:classification-article" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="version-number" />
                <schema:ref name="ipc" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:deposit-article 菌寄託の記事
     ====================================================================-->
    <xsl:template match="jp:deposit-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
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
            </xsl:element>
            <xsl:apply-templates select="jp:deposit" />
        </xsl:element>
    </xsl:template>
    <schema:object name="deposit-article">
        <schema:property name="tag" type="string"
            const="jp:deposit-article" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="deposit" />
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:parent-application-article 分割変更表示の記事
     ====================================================================-->
    <xsl:template match="jp:parent-application-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
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
            </xsl:element>
            <xsl:apply-templates select="jp:application-reference" />
        </xsl:element>
    </xsl:template>
    <schema:object name="parent-application-article">
        <schema:property name="tag" type="string"
            const="jp:parent-application-article" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="application-reference" />
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:field-of-search-article 調査分野の記事
     ====================================================================-->
    <xsl:template match="jp:field-of-search-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
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
            </xsl:element>
            <xsl:apply-templates select="jp:field-of-search" />
        </xsl:element>
    </xsl:template>
    <schema:object name="field-of-search-article">
        <schema:property name="tag" type="string"
            const="jp:field-of-search-article" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="field-of-search" />
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:patent-reference-article 参考特許文献の記事
     ====================================================================-->
    <xsl:template match="jp:patent-reference-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'２．参考特許文献'" />
            </xsl:element>
            <xsl:apply-templates select="jp:patent-reference-group" />
        </xsl:element>
    </xsl:template>
    <schema:object name="patent-reference-article">
        <schema:property name="tag" type="string"
            const="jp:patent-reference-article" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="patent-reference-group" />
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:reference-books-article 参考図書雑誌の記事
     ====================================================================-->
    <xsl:template match="jp:reference-books-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'３．参考図書雑誌'" />
            </xsl:element>
            <xsl:apply-templates select="jp:reference-books" />
        </xsl:element>
    </xsl:template>
    <schema:object name="reference-books-article">
        <schema:property name="tag" type="string"
            const="jp:reference-books-article" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="reference-books" />
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:exceptions-to-lack-of-novelty-art 新規性喪失例外の記事
     ====================================================================-->
    <xsl:template match="jp:exceptions-to-lack-of-novelty-art">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'４．新規性喪失例外規定の適用の事実'" />
            </xsl:element>
            <xsl:apply-templates select="jp:exceptions-to-lack-of-novelty-grp" />
        </xsl:element>
    </xsl:template>
    <schema:object name="exceptions-to-lack-of-novelty-art">
        <schema:property name="tag" type="string"
            const="jp:exceptions-to-lack-of-novelty-art" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="exceptions-to-lack-of-novelty-grp" />
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:exceptions-to-lack-of-novelty-grp
     ====================================================================-->
    <!-- 新規性喪失の例外 -->
    <xsl:template match="jp:exceptions-to-lack-of-novelty-grp">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'新規性喪失の例外'" />
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(./@jp:serial-number))" />
            </xsl:element>
            <xsl:element name="indent-level">1</xsl:element>
            <xsl:apply-templates select="jp:application-section" />
            <xsl:apply-templates select="jp:exceptions-to-lack-of-novelty" />
        </xsl:element>
    </xsl:template>
    <schema:object name="exceptions-to-lack-of-novelty-grp">
        <schema:property name="tag" type="string"
            const="jp:exceptions-to-lack-of-novelty-grp" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="application-section" />
                <schema:ref name="exceptions-to-lack-of-novelty" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ====================================================================
     End: type C elements.
     ====================================================================-->


    <!-- ====================================================================
     Begin:
       type D elements have tag, text and optional converted-text.
     ====================================================================-->
    <!-- ====================================================================
     jp:document-name 書類名
     ====================================================================-->
    <xsl:template match="jp:document-name">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="document-name">
        <schema:property name="tag" type="string"
            const="jp:document-name" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:reconsideration-before-appeal 前置審査
     ====================================================================-->
    <xsl:template match="jp:reconsideration-before-appeal">
        <xsl:if test="./@jp:true-or-false = 'true'">
            <xsl:element name="blocks">
                <xsl:element name="tag">
                    <xsl:value-of select="name()" />
                </xsl:element>
                <xsl:element name="text">
                    <xsl:value-of select="'［前置審査］'" />
                    <xsl:if test="ancestor::jp:decision-of-registration-a01">
                        <xsl:value-of select="'　原査定を取消す。'" />
                    </xsl:if>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <schema:object name="reconsideration-before-appeal">
        <schema:property name="tag" type="string"
            const="jp:reconsideration-before-appeal" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:article 適用条文
     ====================================================================-->
    <xsl:template match="jp:article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space()" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="article">
        <schema:property name="tag" type="string" const="jp:article" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:ipc IPC
     ====================================================================-->
    <xsl:template match="jp:ipc">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(.))" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="ipc">
        <schema:property name="tag" type="string" const="jp:ipc" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:name 氏名、氏名または名称
     ====================================================================-->
    <xsl:template match="jp:name">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="'notice-name'" />
            </xsl:element>
            <xsl:element name="text">
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
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="notice-name">
        <schema:property name="tag" type="string" const="notice-name" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:staff-code 担当者コード
     ====================================================================-->
    <xsl:template match="jp:staff-code">
        <xsl:variable name="code" select="normalize-space(.)" />
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
            <xsl:element name="converted-text">
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
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="staff-code">
        <schema:property name="tag" type="string" const="jp:staff-code" />
        <schema:property name="text" type="string" />
        <schema:property name="converted-text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:draft-person-group/jp:staff-code 担当者コード
    <xsl:template name="jp:staff-code" より関係箇所を抜き出した。
     ====================================================================-->
    <xsl:template match="jp:draft-person-group/jp:staff-code">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
            <xsl:element name="converted-text">
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(.))" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- schema object is the same as above staff-code -->

    <!-- ====================================================================
     jp:office-code 所属コード
     ====================================================================-->
    <xsl:template match="jp:office-code">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
            <xsl:element name="converted-text">
                <xsl:value-of select="f:to-fullwidth-digit(normalize-space(.))" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="office-code">
        <schema:property name="tag" type="string" const="jp:office-code" />
        <schema:property name="text" type="string" />
        <schema:property name="converted-text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:official-title 役職名
     ====================================================================-->
    <xsl:template match="jp:official-title">
        <xsl:variable name="name" select="normalize-space(.)" />
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="$name" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="official-title">
        <schema:property name="tag" type="string"
            const="jp:official-title" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:field-of-search 調査分野
     ====================================================================-->
    <xsl:template match="jp:field-of-search">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="field-of-search">
        <schema:property name="tag" type="string"
            const="jp:field-of-search" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:patent-reference-group 参考特許文献グル－プ 
     ====================================================================-->
    <xsl:template match="jp:patent-reference-group">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
            <xsl:element name="converted-text">
                <xsl:value-of select="jp:document-number || '　' || jp:kind-of-document" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="patent-reference-group">
        <schema:property name="tag" type="string"
            const="jp:patent-reference-group" />
        <schema:property name="text" type="string" />
        <schema:property name="converted-text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:reference-books 参考図書雑誌
     ====================================================================-->
    <xsl:template match="jp:reference-books">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="reference-books">
        <schema:property name="tag" type="string"
            const="jp:reference-books" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
        jp:number-of-other-persons 外の者の人数
     ====================================================================-->
    <xsl:template match="jp:number-of-other-persons">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="f:remove-nbsp(.)" />
            </xsl:element>
            <xsl:element name="converted-text">
                <xsl:value-of select="'（外'" />
                <xsl:value-of
                    select="f:to-fullwidth-digit(f:remove-nbsp(.))" />
                <xsl:value-of select="'名）'" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="number-of-other-persons">
        <schema:property name="tag" type="string"
            const="jp:number-of-other-persons" />
        <schema:property name="text" type="string" />
        <schema:property name="converted-text" type="string" />
    </schema:object>
    <!-- ====================================================================
     End: type D elements.
     ====================================================================-->

    <!-- ====================================================================
     Begin:
       other types.
     ====================================================================-->
    <!-- ====================================================================
     jp:application-reference 出願書類参照
     ====================================================================-->
    <xsl:template match="jp:application-reference">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>

            <xsl:choose>
                <xsl:when test="ancestor::jp:parent-application-article">
                    <xsl:if test="position() = 1">
                        <xsl:element name="text">
                            <xsl:value-of select="'　対応する原出願の出願番号、原出願の出願日'" />
                        </xsl:element>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="text">
                        <xsl:value-of select="''" />
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates select="jp:document-id" />
        </xsl:element>
    </xsl:template>
    <schema:object name="application-reference">
        <schema:property name="tag" type="string"
            const="jp:application-reference" />
        <schema:property name="text" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="document-id" />
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:deposit 菌寄託
     ====================================================================-->
    <xsl:template match="jp:deposit">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="'菌寄託'" />
                <xsl:value-of select="f:to-fullwidth-digit(string(position()))" />
            </xsl:element>
            <xsl:element name="indent-level">1</xsl:element>

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
        </xsl:element>
    </xsl:template>
    <schema:object name="deposit">
        <schema:property name="tag" type="string"
            const="jp:deposit" />
        <schema:property name="jp-tag" type="string" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="depository-ins-code" />
                <schema:ref name="depository-number" />
            </schema:anyOf>
        </schema:property>
    </schema:object>


    <!-- 変換元XMLにある images/image のlookup -->
    <xsl:key name="images-table-key" match="/root/images/image" use="@orig-filename" />

    <!--  イメージ   -->
    <xsl:template match="img">
        <!-- 次の「有意ノード」を見る -->
        <xsl:variable name="nextNode"
            select="following-sibling::node()[not(self::text()[normalize-space(.)=''])][1]" />

        <!-- 次が br か、次が存在しない（p末尾）なら true -->
        <xsl:variable name="isLastSentence"
            select="if (empty($nextNode) or $nextNode/self::br) then 'true' else 'false'" />

        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="'other-images'" />
            </xsl:element>
            <xsl:element name="isLastSentence">
                <xsl:value-of select="$isLastSentence" />
            </xsl:element>
            <xsl:for-each select="key('images-table-key', @file)">
                <xsl:element name="images">
                    <xsl:element name="src">
                        <xsl:value-of select="@new" />
                    </xsl:element>
                    <xsl:element name="width">
                        <xsl:value-of select="@width" />
                    </xsl:element>
                    <xsl:element name="height">
                        <xsl:value-of select="@height" />
                    </xsl:element>
                    <xsl:element name="kind">
                        <xsl:value-of select="@kind" />
                    </xsl:element>
                    <xsl:element name="sizeTag">
                        <xsl:value-of select="@sizeTag" />
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <!-- schema:object name="other-images" is defined in pat_common.xsl -->

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
     p
     ====================================================================-->
    <!-- 段落 ,段落内テキスト -->
    <xsl:template
        match="p">
        <xsl:element name="blocks">
            <xsl:element name="tag">paragraph</xsl:element>
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    <!-- <schema:object name="paragraph"> is defined in pat_common.xsl -->

    <xsl:template match="text() | sup | sub | u">
        <xsl:variable name="tag">
            <xsl:choose>
                <xsl:when test="self::text()">text</xsl:when>
                <xsl:when test="self::sup">sup</xsl:when>
                <xsl:when test="self::sub">sub</xsl:when>
                <xsl:when test="self::u">underline</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- 次の「有意ノード」を見る -->
        <xsl:variable name="nextNode"
            select="following-sibling::node()[not(self::text()[normalize-space(.)=''])][1]" />

        <!-- 次が br か、次が存在しない（p末尾）なら true -->
        <xsl:variable name="isLastSentence"
            select="if (empty($nextNode) or $nextNode/self::br) then 'true' else 'false'" />

        <xsl:if test="normalize-space() != ''">
            <xsl:element name="blocks">
                <xsl:element name="tag">
                    <xsl:value-of select="$tag" />
                </xsl:element>
                <xsl:element name="text">
                    <xsl:call-template name="trim">
                        <xsl:with-param name="text" select="f:remove-nbsp(.)" />
                    </xsl:call-template>
                </xsl:element>
                <xsl:element name="isLastSentence">
                    <xsl:value-of select="$isLastSentence" />
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <!-- <schema:object name="inline-text"> is defined in pat_common.xsl -->


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

    <xsl:template name="unsupported-tag">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="'unsupported-tag'" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="'&lt;' || name() || '&gt;'" />
                <xsl:value-of select="." />
                <xsl:value-of select="'&lt;/', name(), '&gt;'" />
                <xsl:value-of select="'is not supported in v4xva_ntc-pt-e.xsl'" />
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>