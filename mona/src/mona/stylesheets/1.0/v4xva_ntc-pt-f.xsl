<?xml version="1.0" encoding="UTF-8"?>

<!-- 
 original xsl: v4xva_ntc-pt-f.xsl at Apr 28  2022
sha256sum:dba97bafc2a6370c6e85ef6a80a368bf618fe479236e6a53e2e803183ee73474
-->
<!-- ====================================================================
　　　変換対象書類名：特実方式審査（共通部）
     ====================================================================-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:schema="urn:schema-dsl"
    xmlns:f="urn:phantom-mona:string-utils">

    <xsl:variable name="node" select="name(//jp:notice-pat-frm/*)" />
    <xsl:variable name="kind-of-law">
        <xsl:value-of select="/root/jp:cpy-notice-pat-frm/jp:notice-pat-frm/*/@jp:kind-of-law[1]" />
    </xsl:variable>

    <xsl:include href="ntc-ninsyo.xsl" />
    <xsl:include href="common-templates/country.xsl" />
    <xsl:include href="common-templates/v4xva_prm.xsl" />
    <xsl:include href="common-templates/string-utils.xsl" />
    <xsl:include href="common-templates/date-templates.xsl" />

    <!-- 当面、A242623 実案技術評価書の通知のみ対応 -->

    <!-- ====================================================================
     jp:notice-pat-frm
     ====================================================================-->
    <xsl:template match="jp:notice-pat-frm">
        <xsl:apply-templates
            select="jp:notification-a242623" />
        <!--
        <xsl:apply-templates
            select="jp:disposition-a042 | jp:disposition-a043 | jp:disposition-a072
                   | jp:disposition-a073 | jp:invitation-a101 | jp:disposition-a071
                   | jp:invitation-a102 | jp:notification-a103 | jp:invitation-to-correct-a111
                   | jp:invitation-to-correct-a112 | jp:reference-a115 | jp:invitation-a121
                   | jp:invitation-a141 | jp:notification-a231 | jp:notification-a232
                   | jp:commissioner-notifie-a241 | jp:notification-a241764
                   | jp:commissioner-notifie-a242 | jp:commissioner-notifie-a24214
                   | jp:notification-a242623 | jp:notification-a242625 | jp:notification-a242764
                   | jp:notification-a242831 | jp:written-answer-inquiry-a242902
                   | jp:notification-a26 | jp:correction-by-ex-officio-a273
                   | jp:correction-by-ex-officio-a274 | jp:notification-a275
                   | jp:notification-a244001
                   | jp:notification-a242624 | jp:notification-a243624
                   | jp:notification-a243631 | jp:notification-a24379" />
        -->
    </xsl:template>

    <!-- ====================================================================
     jp:disposition-a042 | jp:disposition-a043 | jp:disposition-a072 | jp:disposition-a073 |
     jp:invitation-a101 | jp:disposition-a071 | jp:invitation-a102 | jp:notification-a103 |
     jp:invitation-to-correct-a111 | jp:invitation-to-correct-a112 | jp:reference-a115 |
     jp:invitation-a121 | jp:invitation-a141 | jp:notification-a231 | jp:notification-a232 |
     jp:commissioner-notifie-a241 | jp:notification-a241764 | jp:commissioner-notifie-a242 |
     jp:commissioner-notifie-a24214 | jp:notification-a242623 | jp:notification-a242625 |
     jp:notification-a242764 | jp:notification-a242831 | jp:written-answer-inquiry-a242902 |
     jp:notification-a26 | jp:correction-by-ex-officio-a273 | jp:correction-by-ex-officio-a274 |
     jp:notification-a275 | jp:notification-a242624 | jp:notification-a243624
     ====================================================================-->
    <xsl:template
        match="jp:disposition-a042 | jp:disposition-a043 | jp:disposition-a072
                   | jp:disposition-a073 | jp:invitation-a101 | jp:disposition-a071
                   | jp:invitation-a102 | jp:notification-a103 | jp:invitation-to-correct-a111
                   | jp:invitation-to-correct-a112 | jp:reference-a115 | jp:invitation-a121
                   | jp:invitation-a141 | jp:notification-a231 | jp:notification-a232
                   | jp:commissioner-notifie-a241 | jp:notification-a241764
                   | jp:commissioner-notifie-a242 | jp:commissioner-notifie-a24214
                   | jp:notification-a242623 | jp:notification-a242625 | jp:notification-a242764
                   | jp:notification-a242831 | jp:written-answer-inquiry-a242902
                   | jp:notification-a26 | jp:correction-by-ex-officio-a273
                   | jp:correction-by-ex-officio-a274 | jp:notification-a275
                   | jp:notification-a242624 | jp:notification-a243624
                   | jp:notification-a243631 | jp:notification-a24379">
        <xsl:apply-templates select="jp:document-name" />
        <xsl:apply-templates select="jp:bibliog-in-ntc-pat-frm" />
        <xsl:apply-templates select="jp:conclusion-part-article" />
        <xsl:apply-templates select="jp:drafting-body" />
        <xsl:apply-templates select="jp:footer-article" />
        <xsl:apply-templates select="jp:image-group" />
    </xsl:template>

    <schema:object
        name="notice-pat-frm">
        <schema:property name="tag" type="string"
            const="jp:notice-pat-frm" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="dispatch-control-article" />
                <schema:ref name="document-name" />
                <schema:ref name="bibliog-in-ntc-pat-frm" />
                <schema:ref name="conclusion-part-article" />
                <schema:ref name="drafting-body" />
                <schema:ref name="footer-article" />
                <schema:ref name="image-group" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:invitation-to-correct-a111
     ====================================================================
    <xsl:template match="jp:invitation-to-correct-a111">
        <xsl:apply-templates select="jp:document-name" />
        <xsl:apply-templates select="jp:bibliog-in-ntc-pat-frm" />
        <xsl:apply-templates select="jp:conclusion-part-article" />
        <xsl:apply-templates select="jp:drafting-body" />
        <xsl:apply-templates select="jp:footer-article" />
        <xsl:apply-templates select="jp:image-group" />
    </xsl:template>
    -->

    <!-- ====================================================================
     jp:notification-a244001
     ====================================================================
    <xsl:template match="jp:notification-a244001">
        <xsl:apply-templates select="jp:document-name" />
        <xsl:apply-templates select="jp:bibliog-in-ntc-pat-frm" />
        <xsl:apply-templates select="jp:conclusion-part-article" />
        <xsl:apply-templates select="jp:das-info" />
        <xsl:apply-templates select="jp:footer-article" />
        <xsl:apply-templates select="jp:image-group" />
    </xsl:template>
    -->

    <!-- ====================================================================
     jp:document-name
     ====================================================================-->
    <!-- 書類名 -->
    <xsl:template match="jp:document-name">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="notice-document-name" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- ====================================================================
     jp:bibliog-in-ntc-pat-frm
     ====================================================================-->
    <!-- 書誌部 -->
    <xsl:template match="jp:bibliog-in-ntc-pat-frm">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:drafting-date" />
            <xsl:apply-templates select="jp:draft-person-group" />
            <xsl:apply-templates select="jp:addressed-to-person-group" />
            <xsl:apply-templates select="jp:application-reference" />
            <xsl:apply-templates select="jp:not-specify-apl-ref" />
            <xsl:apply-templates select="jp:refer-from" />
            <xsl:apply-templates select="jp:reference-date" />
            <xsl:apply-templates select="jp:refer-to" />
            <xsl:apply-templates select="jp:present-date-of-a632" />
        </xsl:element>
    </xsl:template>
    <schema:object name="bibliog-in-ntc-pat-frm">
        <schema:property name="tag" type="string"
            const="jp:bibliog-in-ntc-pat-frm" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="draft-person-group" />
                <schema:ref name="drafting-date" />
                <schema:ref name="addressed-to-person-group" />
                <schema:ref name="application-reference" />
                <schema:ref name="not-specify-apl-ref" />
                <schema:ref name="refer-from" />
                <schema:ref name="reference-date" />
                <schema:ref name="refer-to" />
                <schema:ref name="present-date-of-a632" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:conclusion-part-article
     ====================================================================-->
    <!-- 結論部 -->
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
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- ====================================================================
     jp:drafting-body
     ====================================================================-->
    <!-- 記部 -->
    <xsl:template match="jp:drafting-body">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="p" />
        </xsl:element>
    </xsl:template>
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- ====================================================================
     jp:footer-article
     ====================================================================-->
    <!-- フッタ部  -->
    <xsl:template match="jp:footer-article">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:administrative-appeal-sentence" />
            <xsl:apply-templates select="jp:approval-column-article" />
            <xsl:apply-templates select="jp:approval-without-contents" />
            <xsl:apply-templates select="jp:certification-column-article" />
            <xsl:apply-templates select="jp:inquiry-article" />
        </xsl:element>

        <!-- 未サポート -->
        <xsl:if test="jp:devider">
            <xsl:apply-templates
                select="jp:devider/jp:official-title | jp:devider/jp:name
                                   | jp:devider/jp:staff-code" />
        </xsl:if>
    </xsl:template>
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- ====================================================================
     jp:image-group
     ====================================================================-->
    <!-- イメージグループ  -->
    <xsl:template match="jp:image-group">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="img" />
        </xsl:element>
    </xsl:template>
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

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
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- ====================================================================
     jp:draft-person-group
     ====================================================================-->
    <!-- 起案者  -->
    <xsl:template match="jp:draft-person-group">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:value-of select="''" />
            </xsl:element>
            <xsl:apply-templates select="jp:name" />
        </xsl:element>

        <!-- 未サポート -->
        <xsl:if test="jp:staff-code or jp:office-code">
            <xsl:apply-templates select="jp:staff-code | jp:office-code" mode="unsupported" />
        </xsl:if>
    </xsl:template>
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- ====================================================================
     jp:addressed-to-person-group
     ====================================================================-->
    <!-- あて先  -->
    <xsl:template match="jp:addressed-to-person-group">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <!-- render jp-tag, text -->
            <xsl:call-template name="あて先編集" />

            <!-- addressbook renders no children.
            <xsl:apply-templates select="jp:addressbook" />
            -->
        </xsl:element>
    </xsl:template>
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- ====================================================================
     あて先編集
     ====================================================================-->
    <xsl:template name="あて先編集">
        <xsl:variable name="name" select="normalize-space(.//jp:name)" />

        <xsl:choose>
            <xsl:when test="$node = 'jp:notification-a232'">
                <xsl:element name="jp-tag">
                    <xsl:value-of select="'出願人'" />
                </xsl:element>
                <xsl:element name="text">
                    <xsl:if test="string-length(normalize-space(.//jp:registered-number)) != 0">
                        <xsl:value-of select="f:to-fullwidth-alnum(.//jp:registered-number)" />
                    </xsl:if>
                    <xsl:value-of select="$name || '　様'" />
                    <xsl:if
                        test="string-length(normalize-space(.//jp:number-of-other-persons)) != 0">
                        <xsl:value-of select="'　外'" />
                        <xsl:apply-templates select=".//jp:number-of-other-persons" />
                        <xsl:value-of select="'名'" />
                    </xsl:if>
                </xsl:element>
            </xsl:when>

            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="./@jp:kind-of-applicant = 'evaluation-requester'">
                        <xsl:element name="jp-tag">
                            <xsl:if test="./@kind-of-applicant">
                                <xsl:call-template name="出願人種別編集" />
                            </xsl:if>
                            <xsl:if test="./@kind-of-agent">
                                <xsl:call-template name="代理人種別編集" />
                            </xsl:if>
                        </xsl:element>
                        <xsl:element name="text">
                            <xsl:value-of select="$name" />
                            <xsl:call-template name="あて先項目内容編集" />
                        </xsl:element>
                    </xsl:when>
                    <xsl:when
                        test="(./@jp:kind-of-applicant = 'inheritor'
                    and ($node = 'jp:invitation-a141' or $node = 'jp:invitation-a141'
                     or $node = 'jp:commissioner-notifie-a24214'
                     or $node = 'jp:written-answer-inquiry-a242902'
                     or $node = 'jp:commissioner-notifie-a241'
                     or $node = 'jp:commissioner-notifie-a242'))">
                        <xsl:element name="jp-tag">
                            <xsl:if test="./@kind-of-applicant">
                                <xsl:call-template name="出願人種別編集" />
                            </xsl:if>
                            <xsl:if test="./@kind-of-agent">
                                <xsl:call-template name="代理人種別編集" />
                            </xsl:if>
                        </xsl:element>
                        <xsl:element name="text">
                            <xsl:value-of select="$name" />
                            <xsl:call-template name="あて先項目内容編集" />
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="jp-tag">
                            <xsl:choose>
                                <xsl:when test="$kind-of-law = 'patent'">
                                    <xsl:value-of select="'特許'" />
                                </xsl:when>
                                <xsl:when test="$kind-of-law = 'utility'">
                                    <xsl:value-of select="'実用新案登録'" />
                                </xsl:when>
                            </xsl:choose>
                            <xsl:if test="./@kind-of-representative">
                                <xsl:value-of select="'代表'" />
                            </xsl:if>
                            <xsl:if test="./@kind-of-applicant">
                                <xsl:call-template name="出願人種別編集" />
                            </xsl:if>
                            <xsl:if test="./@kind-of-agent">
                                <xsl:call-template name="代理人種別編集" />
                            </xsl:if>
                        </xsl:element>
                        <xsl:element name="text">
                            <xsl:value-of select="$name" />
                            <xsl:call-template name="あて先項目内容編集" />
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     あて先項目内容編集
     ====================================================================-->
    <xsl:template name="あて先項目内容編集">
        <xsl:variable name="persons"
            select="translate(normalize-space(.//jp:number-of-other-persons),'&#160;',0)" />
        <xsl:choose>
            <xsl:when test=".//jp:number-of-other-persons">
                <xsl:value-of select="'（外' || $persons || '名）　様'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'　様'" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     jp:application-reference
     ====================================================================-->
    <!-- 出願書類参照  -->
    <xsl:template match="jp:application-reference">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="''" />
            </xsl:element>
            <xsl:apply-templates select="jp:document-id" />
        </xsl:element>
    </xsl:template>
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- ====================================================================
     jp:not-specify-apl-ref
     ====================================================================-->
    <!-- 不特定願番  -->
    <xsl:template match="jp:not-specify-apl-ref">
    </xsl:template>

    <!-- ====================================================================
     jp:refer-from 照会元
     import from <xsl:template name="照会元編集">
     ====================================================================-->
    <xsl:template match="jp:refer-from">
        <xsl:variable name="data" select="normalize-space(.//jp:text)" />
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="blocks">
                <xsl:element name="tag">
                    <xsl:value-of select="'text'" />
                </xsl:element>
                <xsl:element name="text">
                    <xsl:value-of select="'－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－'" />
                </xsl:element>
                <xsl:element name="is-last-sentence">
                    <xsl:value-of select="'true'" />
                </xsl:element>
            </xsl:element>
            <xsl:element name="blocks">
                <xsl:element name="tag">
                    <xsl:value-of select="'text'" />
                </xsl:element>
                <xsl:element name="text">
                    <xsl:value-of select="'Address:' || $data" />
                </xsl:element>
                <xsl:element name="is-last-sentence">
                    <xsl:value-of select="'true'" />
                </xsl:element>
            </xsl:element>
            <xsl:element name="blocks">
                <xsl:element name="tag">
                    <xsl:value-of select="'text'" />
                </xsl:element>
                <xsl:element name="text">
                    <xsl:value-of select="'Telephone:' || jp:phone" />
                </xsl:element>
                <xsl:element name="is-last-sentence">
                    <xsl:value-of select="'true'" />
                </xsl:element>
            </xsl:element>
            <xsl:element name="blocks">
                <xsl:element name="tag">
                    <xsl:value-of select="'text'" />
                </xsl:element>
                <xsl:element name="text">
                    <xsl:value-of select="'Fax:' || jp:fax" />
                </xsl:element>
                <xsl:element name="is-last-sentence">
                    <xsl:value-of select="'true'" />
                </xsl:element>
            </xsl:element>
            <xsl:element name="blocks">
                <xsl:element name="tag">
                    <xsl:value-of select="'text'" />
                </xsl:element>
                <xsl:element name="text">
                    <xsl:value-of select="'－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－'" />
                </xsl:element>
                <xsl:element name="is-last-sentence">
                    <xsl:value-of select="'true'" />
                </xsl:element>
            </xsl:element>

            <!-- 未サポート -->
            <xsl:if
                test=".//address-1 or .//address-2 or .//address-3 or .//address-4 or .//address-5 or .//mailcode or .//pobox or .//room
             or .//address-floor or .//building or .//street or .//city or .//county or .//state
             or .//postcode or .//country or .//jp:original-language-of-address">
                <xsl:apply-templates
                    select=".//address-1 | .//address-2 | .//address-3 | .//address-4 | .//address-5 | .//mailcode
                                 | .//pobox | .//room | .//address-floor | .//building
                                 | .//street | .//city | .//county | .//state | .//country
                                 | .//postcode | .//jp:original-language-of-address"
                    mode="unsupported" />
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <schema:object name="refer-from">
        <schema:property name="tag" type="string"
            const="jp:refer-from" />
        <schema:property name="blocks" type="array">
            <schema:ref name="inline-text" />
        </schema:property>
    </schema:object>


    <!-- ====================================================================
     jp:reference-date
     ====================================================================-->
    <!-- 照会日  -->
    <xsl:template match="jp:reference-date">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:date" />
        </xsl:element>
    </xsl:template>
    <schema:object name="reference-date">
        <schema:property name="tag" type="string" const="jp:reference-date" />
        <schema:property name="blocks" type="array">
            <schema:ref name="date" />
        </schema:property>
    </schema:object>


    <!-- ====================================================================
     jp:refer-to
     ====================================================================-->
    <!-- 紹介先  -->
    <xsl:template match="jp:refer-to">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:name" />
            <xsl:apply-templates select="jp:address" />

            <!-- 未サポート -->
            <xsl:if
                test=".//address-1 or .//address-2 or .//address-3 or .//address-4 or .//address-5 or .//mailcode or .//pobox or .//room
             or .//address-floor or .//building or .//street or .//city or .//county or .//state
             or .//postcode or .//country or .//jp:original-language-of-address">
                <xsl:apply-templates
                    select=".//address-1 | .//address-2 | .//address-3 | .//address-4 | .//address-5 | .//mailcode
                                 | .//pobox | .//room | .//address-floor | .//building
                                 | .//street | .//city | .//county | .//state | .//country
                                 | .//postcode | .//jp:original-language-of-address"
                    mode="unsupported" />
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <schema:object name="refer-to">
        <schema:property name="tag" type="string" const="jp:refer-to" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="name" />
                <schema:ref name="address" />
            </schema:anyOf>
        </schema:property>
    </schema:object>


    <!-- ====================================================================
     jp:present-date-of-a632
     ====================================================================-->
    <!-- 国内書面差出日  -->
    <xsl:template match="jp:present-date-of-a632">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:date" />
        </xsl:element>
    </xsl:template>
    <schema:object name="present-date-of-a632">
        <schema:property name="tag" type="string" const="jp:present-date-of-a632" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="date" />
            </schema:anyOf>
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     p
     ====================================================================-->
    <!-- 段落、段落内テキスト  -->
    <xsl:template match="p">
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
                <xsl:element name="is-last-sentence">
                    <xsl:value-of select="$isLastSentence" />
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <!-- <schema:object name="inline-text"> is defined in pat_common.xsl -->

    <!-- ====================================================================
     jp:administrative-appeal-sentence
     ====================================================================-->
    <!-- 行服部  -->
    <xsl:template match="jp:administrative-appeal-sentence">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:if test="$node = 'jp:notification-a232'">
                <xsl:element name="blocks">
                    <xsl:element name="tag">
                        <xsl:value-of select="'text'" />
                    </xsl:element>
                    <xsl:element name="text">
                        <xsl:value-of select="'　お願い：'" />
                    </xsl:element>
                    <xsl:element name="is-last-sentence">
                        <xsl:value-of select="'true'" />
                    </xsl:element>
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates select="p" />
        </xsl:element>
    </xsl:template>
    <schema:object name="administrative-appeal-sentence">
        <schema:property name="tag" type="string"
            const="jp:administrative-appeal-sentence" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="inline-text" />
                <schema:ref name="paragraph" />
            </schema:anyOf>
        </schema:property>
    </schema:object>


    <!-- ====================================================================
     jp:approval-column-article
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

            <xsl:apply-templates select="jp:staff1-group/jp:name" />
            <xsl:apply-templates select="jp:staff2-group/jp:name" />
            <xsl:apply-templates select="jp:staff3-group/jp:name" />
            <xsl:apply-templates select="jp:staff4-group/jp:name" />

            <xsl:apply-templates select="jp:staff1-group/jp:staff-code" />
            <xsl:apply-templates select="jp:staff2-group/jp:staff-code" />
            <xsl:apply-templates select="jp:staff3-group/jp:staff-code" />
            <xsl:apply-templates select="jp:staff4-group/jp:staff-code" />
        </xsl:element>
    </xsl:template>
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- ====================================================================
     jp:approval-without-contents
     ====================================================================-->
    <!-- 内容なし決裁欄  -->
    <xsl:template match="jp:approval-without-contents">
    </xsl:template>

    <!-- ====================================================================
     img
     ====================================================================-->
    <!-- イメージ
    <xsl:template match="jp:image-group/img">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="img" />
        </xsl:element>
    </xsl:template>
  -->

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
     jp:date 日付
　　　import from <xsl:template name="日付タイトル">　
     ====================================================================-->
    <xsl:template match="jp:date">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:reference-date">
                        <xsl:value-of select="'Date'" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:present-date-of-a632">
                        <xsl:value-of select="'国内書面差出日'" />
                    </xsl:when>
                    <xsl:otherwise>
                    </xsl:otherwise>
                </xsl:choose>
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
    <!-- the schema:object of this element is defined in pat_common.xsl -->

    <!-- ====================================================================
     jp:name
     ====================================================================-->
    <!-- 氏名 -->
    <xsl:template match="jp:name">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="'notice-name'" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

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

            <!-- 未サポート -->
            <xsl:if test="country or kind or name">
                <xsl:apply-templates select="country | kind | name" mode="unsupported" />
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- ====================================================================
     jp:address
     ====================================================================-->
    <xsl:template match="jp:address">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:apply-templates select="jp:text" />
        </xsl:element>
    </xsl:template>
    <schema:object name="address">
        <schema:property name="tag" type="string"
            const="jp:address" />
        <schema:property name="blocks" type="array">
            <schema:ref name="text" />
        </schema:property>
    </schema:object>

    <!-- ====================================================================
     jp:doc-number
     ====================================================================-->
    <!-- 文書番号 -->
    <xsl:template match="jp:doc-number">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="jp-tag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:das-group">
                        <xsl:value-of select="'基礎出願番号'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="''" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
            <xsl:element name="converted-text">
                <xsl:call-template name="文書番号編集" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- ====================================================================
     jp:text
     ====================================================================-->
    <!-- 住所 -->
    <xsl:template match="jp:text">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="'notice-pat-frm-text'" />
            </xsl:element>
            <xsl:element name="indent-level">0</xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <schema:object name="notice-pat-frm-text">
        <schema:property name="tag" type="string" const="notice-pat-frm-text" />
        <schema:property name="indent-level" type="integer" />
        <schema:property name="text" type="string" />
    </schema:object>

    <!-- ====================================================================
     jp:official-title
     ====================================================================-->
    <!-- 役職名 -->
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
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- ====================================================================
     jp:staff-code
     ====================================================================-->
    <!-- 担当者コード -->
    <xsl:template match="jp:staff-code">
        <xsl:variable name="code" select="f:to-fullwidth-alnum(normalize-space(.))" />
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="text">
                <xsl:value-of select="normalize-space(.)" />
            </xsl:element>
            <xsl:element name="converted-text">
                <xsl:value-of select="$code" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- ====================================================================
     jp:addressbook
     ====================================================================-->
    <xsl:template match="jp:addressbook">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>

            <!-- 未サポート -->
            <xsl:if
                test="jp:kana or prefix or last-name or first-name or midle-name or suffix or iid
             or role or orgname or department or synonym or jp:address or jp:phone or jp:fax
             or email or url or ead or dtext or text">
                <xsl:apply-templates
                    select="jp:kana | prefix | last-name | first-name | midle-name | iid
                                     | role | orgname | department | synonym"
                    mode="unsupported" />
                <xsl:if test="jp:address">
                    <xsl:apply-templates
                        select=".//address-1 | .//address-2 | .//address-3 | .//address-4 | .//address-5 | .//mailcode
                                       | .//pobox | .//room | .//address-floor | .//building
                                       | .//street | .//city | .//county | .//state | .//country 
                                       | .//postcode | .//jp:text
                                       | .//jp:original-language-of-address"
                        mode="unsupported" />
                </xsl:if>
                <xsl:apply-templates select="jp:phone | jp:fax | email | url | ead | dtext | text"
                    mode="unsupported" />
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <!-- no need to define schema for this template, due to no children rendered -->

    <!-- ====================================================================
     jp:number-of-other-persons
     ====================================================================-->
    <!-- 外何名 -->
    <xsl:template match="jp:number-of-other-persons">
        <xsl:variable name="persons" select="normalize-space(.)" />
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
    <!-- schema is defined in v4xva_ntc-pt-e.xsl -->

    <!-- 当面未対応。a242623 以外の書類で必要とされるtemplate のため
     jp:das-info
     jp:das-group
     jp:country
     jp:access-code
    -->

    <!-- ====================================================================
     jp:das-info
     ====================================================================-->
    <!-- （ＤＡＳアクセスコード情報） -->
    <xsl:template match="jp:das-info">
        <xsl:apply-templates select="jp:das-group" />
    </xsl:template>

    <!-- ====================================================================
     jp:das-group
     ====================================================================-->
    <!-- ＤＡＳアクセスコードグループ -->
    <xsl:template match="jp:das-group">
        <BR /><!--子要素編集前の改行-->
        <xsl:apply-templates select="jp:country" />
        <xsl:apply-templates select="jp:doc-number" />
        <xsl:apply-templates select="jp:access-code" />
    </xsl:template>

    <!-- ====================================================================
     jp:country
     ====================================================================-->
    <!-- 国コード -->
    <xsl:template match="jp:country">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
            <xsl:element name="blocks">
                <xsl:element name="tag">
                    <xsl:value-of select="'country-name'" />
                </xsl:element>
                <xsl:element name="jp-tag">
                    <xsl:value-of select="'国名・地域'" />
                </xsl:element>
                <xsl:element name="text">
                    <xsl:call-template name="国名県名変換" />
                </xsl:element>
            </xsl:element>
            <xsl:element name="blocks">
                <xsl:element name="tag">
                    <xsl:value-of select="'country-code'" />
                </xsl:element>
                <xsl:element name="jp-tag">
                    <xsl:value-of select="'国・地域コード'" />
                </xsl:element>
                <xsl:element name="text">
                    <xsl:value-of select="f:to-fullwidth-alnum(normalize-space(.))" />
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:access-code
     ====================================================================-->
    <!-- アクセスコード -->
    <xsl:template match="jp:access-code">
        <xsl:value-of select="'　アクセスコード　'" />
        <xsl:choose>
            <xsl:when test="./@jp:already-issued = 'true'">
                <xsl:value-of select="." />
                <xsl:value-of select="'（発行済み）'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="." />
            </xsl:otherwise>
        </xsl:choose>
        <BR />
    </xsl:template>

    <!-- ====================================================================
     タイトル編集
     ====================================================================-->
    <xsl:template name="タイトル編集">
        <xsl:choose>
            <xsl:when test="$node = 'jp:disposition-a042'">
                <xsl:value-of select="'出願却下の処分（却下理由）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:disposition-a043'">
                <xsl:value-of select="'出願却下の処分（補正指令）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:disposition-a071'">
                <xsl:value-of select="'通知書（再提出通知）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:disposition-a072'">
                <xsl:value-of select="'手続却下の処分（却下理由）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:disposition-a073'">
                <xsl:value-of select="'手続却下の処分（補正指令）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:invitation-a101'">
                <xsl:value-of select="'却下理由通知書（出願）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:invitation-a102'">
                <xsl:value-of select="'却下理由通知書（中間書類）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a103'">
                <xsl:value-of select="'通知書（却下処分前通知）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:invitation-to-correct-a111'">
                <xsl:value-of select="'手続補正指令書（出願）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:invitation-to-correct-a112'">
                <xsl:value-of select="'手続補正指令書（中間書類）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:reference-a115'">
                <xsl:value-of select="'IB照会書'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:invitation-a121'">
                <xsl:value-of select="'物件提出命令書（方式）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:invitation-a141'">
                <xsl:value-of select="'手続受継指令書'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a231'">
                <xsl:value-of select="'出願番号特定通知書'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a232'">
                <xsl:value-of select="'出願番号通知'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:commissioner-notifie-a241'">
                <xsl:value-of select="'通知書（その他の通知）（期間有）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a241764'">
                <xsl:value-of select="'優先権主張に関する通知'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:commissioner-notifie-a242'">
                <xsl:value-of select="'通知書（その他の通知）（期間無）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:commissioner-notifie-a24214'">
                <xsl:value-of select="'手続続行通知書'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a242623'">
                <xsl:value-of select="'実用新案技術評価の通知'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a242625'">
                <xsl:value-of select="'通知書（他人請求）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a242764'">
                <xsl:value-of select="'優先権主張に関する通知'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a242831'">
                <xsl:value-of select="'刊行物等提出による通知書'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:written-answer-inquiry-a242902'">
                <xsl:value-of select="'伺い回答書'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a26'">
                <xsl:value-of select="'誤送通知書'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:correction-by-ex-officio-a273'">
                <xsl:value-of select="'職権訂正通知書（職権訂正）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:correction-by-ex-officio-a274'">
                <xsl:value-of select="'職権訂正通知書（書類修正）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a275'">
                <xsl:value-of select="'認定情報通知書'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a242624'">
                <xsl:value-of select="'通知書（他人評価請求）'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a243624'">
                <xsl:value-of select="'評価書未作成通知'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a244001'">
                <xsl:value-of select="'アクセスコード通知書'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a243631'">
                <xsl:value-of select="'翻訳文未提出通知書'" />
            </xsl:when>
            <xsl:when test="$node = 'jp:notification-a24379'">
                <xsl:value-of select="'優先権証明書未提出通知書'" />
            </xsl:when>
            <xsl:otherwise />
        </xsl:choose>
    </xsl:template>


    <!-- ====================================================================
     出願人種別編集
     ====================================================================-->
    <xsl:template name="出願人種別編集">
        <xsl:choose>
            <xsl:when test="./@jp:kind-of-applicant = 'application'">
                <xsl:value-of select="'出願人'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'successor'">
                <xsl:value-of select="'承継人'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'presentment'">
                <xsl:value-of select="'提出者'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'supplement'">
                <xsl:value-of select="'補足をする者'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'requester-resumption'">
                <xsl:value-of select="'受継申立人'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'writer-argument'">
                <xsl:value-of select="'上申をする者'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'writer-statement'">
                <xsl:value-of select="'弁明をする者'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'assignor'">
                <xsl:value-of select="'譲渡人'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'requester'">
                <xsl:value-of select="'請求人'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'demandant'">
                <xsl:value-of select="'出願審査請求人'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'succeeded'">
                <xsl:value-of select="'被承継人'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'amender'">
                <xsl:value-of select="'補正をする者'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'proceeder'">
                <xsl:value-of select="'手続をした者'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'claimor'">
                <xsl:value-of select="'申立人'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'inheritor'">
                <xsl:value-of select="'相続人'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'evaluation-requester'">
                <xsl:value-of select="'技術評価請求人'" />
            </xsl:when>
            <xsl:when test="./@jp:kind-of-applicant = 'right-holder'">
                <xsl:value-of select="'実用新案権者'" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     代理人種別編集
     ====================================================================-->
    <xsl:template name="代理人種別編集">
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
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     文書番号編集
     ====================================================================-->
    <xsl:template name="文書番号編集">
        <xsl:variable name="first-part" select="substring(normalize-space(.),1,4)" />
        <xsl:variable name="second-part" select="substring(normalize-space(.),5,6)" />

        <xsl:choose>
            <xsl:when test="ancestor::jp:das-group [@jp:is-jpo = 'true']">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(.)) = 0" />
                    <xsl:otherwise>
                        <xsl:value-of select="f:to-fullwidth-alnum($first-part)" />
                        <xsl:value-of select="'－'" />
                        <xsl:value-of select="f:to-fullwidth-alnum($second-part)" />
                        <xsl:if test="ancestor::jp:das-group [@jp:kind-of-law = 'utility']">
                            <xsl:value-of select="'　　Ｕ'" />
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="ancestor::jp:das-group [@jp:is-jpo = 'false']">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(.)) = 0" />
                    <xsl:otherwise>
                        <xsl:value-of select="f:to-fullwidth-alnum(normalize-space(.))" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when
                test="ancestor::jp:application-reference and $node = 'jp:notification-a244001'">
                <xsl:value-of select="'ＪＰ'" />
                <xsl:value-of select="f:to-fullwidth-alnum($first-part)" />
                <xsl:value-of select="'－'" />
                <xsl:value-of select="f:to-fullwidth-alnum($second-part)" />
                <xsl:if test="ancestor::jp:application-reference [@jp:kind-of-law = 'utility']">
                    <xsl:value-of select="'　　Ｕ'" />
                </xsl:if>
                <xsl:value-of select="'（ＪＰは国コード）'" />
            </xsl:when>
            <xsl:when
                test="ancestor::jp:application-reference
                and ancestor::jp:application-reference [@appl-type = 'international-application']">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:bibliog-in-ntc-pat-frm
                    and ancestor::jp:bibliog-in-ntc-pat-frm [@jp:designated-form = 'related']">
                        <xsl:call-template name="国際出願番号編集" />
                        <xsl:value-of select="'　に関し'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="国際出願番号編集" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when
                test="ancestor::jp:application-reference
                and ancestor::jp:application-reference [@appl-type = 'application']">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:bibliog-in-ntc-pat-frm
                    and ancestor::jp:bibliog-in-ntc-pat-frm [@jp:designated-form = 'related']">
                        <xsl:choose>
                            <xsl:when test="substring(normalize-space(.),1,4) &lt; '2000'">
                                <xsl:call-template name="出願番号編集" />
                                <xsl:value-of select="'　に関し'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="出願番号編集" />
                                <xsl:call-template name="出願番号編集" />
                                <xsl:value-of select="'　に関し'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="substring(normalize-space(.),1,4) &lt; '2000'">
                                <xsl:call-template name="出願番号編集" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="出願番号編集" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when
                test="ancestor::jp:application-reference
                and ancestor::jp:application-reference [@appl-type = 'registration']">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:application-reference [@jp:kind-of-law = 'patent']">
                        <xsl:value-of
                            select="'特許　第' || f:to-fullwidth-alnum(.) || '号'" />
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:application-reference [@jp:kind-of-law = 'utility']">
                        <xsl:value-of
                            select="'実用新案登録　第' || f:to-fullwidth-alnum(.) || '号'" />
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     国際出願番号編集
     ====================================================================-->
    <xsl:template name="国際出願番号編集">
        <xsl:variable name="number" select="normalize-space(.)" />

        <xsl:choose>
            <xsl:when test="string-length($number) = '12'">
                <xsl:variable name="first-part"
                    select="f:to-fullwidth-alnum(substring($number,1,6))" />
                <xsl:variable name="second-part"
                    select="f:to-fullwidth-alnum(substring($number,7,6))" />
                <xsl:value-of
                    select="'ＰＣＴ／' || $first-part || '／' || $second-part" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="first-part"
                    select="f:to-fullwidth-alnum(substring($number,1,4))" />
                <xsl:variable name="second-part"
                    select="f:to-fullwidth-alnum(substring($number,5,5))" />
                <xsl:value-of
                    select="'ＰＣＴ／' || $first-part || '／' || $second-part" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     出願番号編集
     ====================================================================-->
    <xsl:template name="出願番号編集">
        <xsl:variable name="kind-of-law" select="ancestor::jp:application-reference/@jp:kind-of-law" />
        <xsl:variable name="number" select="normalize-space(.)" />
        <xsl:variable name="first-part" select="f:to-fullwidth-alnum(substring($number,1,4))" />
        <xsl:variable name="second-part" select="f:to-fullwidth-alnum(substring($number,5,6))" />

        <xsl:choose>
            <xsl:when test="$number &gt;= 2000000000">
                <xsl:choose>
                    <xsl:when test="$kind-of-law = 'patent'">
                        <xsl:value-of select="'特願'" />
                    </xsl:when>
                    <xsl:when test="$kind-of-law = 'utility'">
                        <xsl:value-of select="'実願'" />
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of
                    select="$first-part || '－' || $second-part" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="和暦変換" />
                <xsl:choose>
                    <xsl:when test="$kind-of-law = 'patent'">
                        <xsl:value-of select="'特許願'" />
                    </xsl:when>
                    <xsl:when test="$kind-of-law = 'utility'">
                        <xsl:value-of select="'実用新案登録願'" />
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of
                    select="'第' || $second-part || '号'" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     和暦変換
     ====================================================================-->
    <xsl:template name="和暦変換">
        <xsl:variable name="day" select="normalize-space(.)" />
        <xsl:variable name="day-as-int" select="xs:integer($day)" as="xs:integer" />
        <xsl:variable name="year" select="xs:integer(substring($day, 1, 4))" as="xs:integer" />


        <xsl:choose>
            <xsl:when test="($day-as-int &gt;= 1912000001) and ($day-as-int &lt;= 1926000000)">
                <xsl:value-of select="'大正'" />
                <xsl:value-of select="$year - 1911" />
                <xsl:value-of select="'年'" />
            </xsl:when>
            <xsl:when test="($day-as-int &gt;= 1868000001) and ($day-as-int &lt;= 1912000000)">
                <xsl:value-of select="'明治'" />
                <xsl:value-of select="$year - 1867" />
                <xsl:value-of select="'年'" />
            </xsl:when>
            <xsl:when test="$day-as-int &lt;= 1868000000">
                <xsl:value-of select="'不明'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="ancestor::jp:application-reference [@jp:kind-of-law = 'patent']">
                        <xsl:choose>
                            <xsl:when test="$day-as-int &gt;= 1989001147">
                                <xsl:value-of select="'平成'" />
                                <xsl:value-of select="$year - 1988" />
                                <xsl:value-of select="'年'" />
                            </xsl:when>
                            <xsl:when
                                test="($day-as-int &gt;= 1926000001) and ($day-as-int &lt;= 1989001146)">
                                <xsl:value-of select="'昭和'" />
                                <xsl:value-of select="$year - 1925" />
                                <xsl:value-of select="'年'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:application-reference [@jp:kind-of-law = 'utility']">
                        <xsl:choose>
                            <xsl:when test="$day-as-int &gt;= 1989000492">
                                <xsl:value-of select="'平成'" />
                                <xsl:value-of select="$year - 1988" />
                                <xsl:value-of select="'年'" />
                            </xsl:when>
                            <xsl:when
                                test="($day-as-int &gt;= 1926000001) and ($day-as-int &lt;= 1989000491)">
                                <xsl:value-of select="'昭和'" />
                                <xsl:value-of select="$year - 1925" />
                                <xsl:value-of select="'年'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="ancestor::jp:application-reference [@jp:kind-of-law = 'design']">
                        <xsl:choose>
                            <xsl:when test="$day-as-int &gt;= 1989000125">
                                <xsl:value-of select="'平成'" />
                                <xsl:value-of select="$year - 1988" />
                                <xsl:value-of select="'年'" />
                            </xsl:when>
                            <xsl:when
                                test="($day-as-int &gt;= 1926000001) and ($day-as-int &lt;= 1989000124)">
                                <xsl:value-of select="'昭和'" />
                                <xsl:value-of select="$year - 1925" />
                                <xsl:value-of select="'年'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:application-reference [@jp:kind-of-law = 'trademark']">
                        <xsl:choose>
                            <xsl:when test="$day-as-int &gt;= 1989000355">
                                <xsl:value-of select="'平成'" />
                                <xsl:value-of select="$year - 1988" />
                                <xsl:value-of select="'年'" />
                            </xsl:when>
                            <xsl:when
                                test="($day-as-int &gt;= 1926000001) and ($day-as-int &lt;= 1989000354)">
                                <xsl:value-of select="'昭和'" />
                                <xsl:value-of select="$year - 1925" />
                                <xsl:value-of select="'年'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     未サポートタグ（全角空白１つあけて表示）
     ====================================================================-->
    <xsl:template
        match="jp:draft-person-group/jp:staff-code | jp:draft-person-group/jp:office-code
                   | jp:kana | country | kind | name | last-name
                   | first-name | midle-name | iid | role | orgname | orgname | department
                   | synonym | jp:phone | jp:fax | email | url | ead | dtext | text
                   | jp:refer-from//address-1 | jp:refer-from//address-2 | jp:refer-from//address-3
                   | jp:refer-from//address-4 | jp:refer-from//address-5
                   | jp:refer-from//mailcode | jp:refer-from//pobox | jp:refer-from//room
                   | jp:refer-from//address-floor | jp:refer-from//building | jp:refer-from//street
                   | jp:refer-from//city | jp:refer-from//county | jp:refer-from//state
                   | jp:refer-from//postcode | jp:refer-from//country
                   | jp:refer-from//jp:original-language-of-address
                   | jp:refer-to//address-1 | jp:refer-to//address-2 | jp:refer-to//address-3
                   | jp:refer-to//address-4 | jp:refer-to//address-5
                   | jp:refer-to//mailcode | jp:refer-to//pobox | jp:refer-to//room
                   | jp:refer-to//address-floor | jp:refer-to//building | jp:refer-to//street
                   | jp:refer-to//city | jp:refer-to//county | jp:refer-to//state
                   | jp:refer-to//postcode | jp:refer-to//country | jp:date
                   | jp:refer-to//jp:original-language-of-address"
        mode="unsupported">
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
                   | jp:devider/jp:official-title | jp:devider/jp:name | jp:devider/jp:staff-code"
        mode="unsupported">
        <xsl:call-template name="unsupported-tag" />
    </xsl:template>

    <!-- ====================================================================
     未サポートタグ（ｐタグ用）
     ====================================================================-->
    <xsl:template
        match="b | i | smallcaps | ul | ol | figref | patcit | nplcit
                   | bio-deposit | crossref | maths | tables | chemistry
                   | o | pre | table-external-doc">
        <xsl:call-template name="unsupported-tag" />
    </xsl:template>

    <!-- ====================================================================
     属性値出力
     ====================================================================-->
    <xsl:template match="@*" mode="unsupported">
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
                <xsl:value-of select="'is not supported in v4xva_ntc-pt-f.xsl'" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>