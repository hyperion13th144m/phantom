<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:phantom-mona:string-utils"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    xmlns:schema="urn:schema-dsl"
    exclude-result-prefixes="xsl jp xs f xf schema">
    <!-- this xslt was created with reference to pat_common.xsl at Apr  4  2023 
         sha256sum:054dec3b453ed47edcc0732a4156c236344fbdece7d40d2eb669a8c0d1756d92 
    -->
    
    <!--　先頭の書類識別コードを取得 -->
    <xsl:variable name="doc-code"
        select="normalize-space(/descendant::jp:document-code[1])" />
    
    <xsl:include href="v4xva_prm.xsl" />
    <xsl:include href="applicants.xsl" />
    <xsl:include href="agents.xsl" />
    <xsl:include href="string-utils.xsl" />
    <xsl:include href="doc-code.xsl" />
    <xsl:include href="special-mention-matter-article.xsl" />
    <xsl:include href="country.xsl" />
    <xsl:include href="doc-number.xsl" />
    <xsl:include href="date-templates.xsl" />
    <xsl:include href="unsupported-tags.xsl" />
    
    <!-- schema:title is set to the name of this stylesheet -->
    <schema:title>pat_common</schema:title>
    
    <!-- ====================================================================
         begin:
         terminal type A elements have tag, jpTag, indentLevel and text.
         optional: convertedText
         no child elements
         ====================================================================--> 
    <!-- ====================================================================
         jp:document-code 書類識別コード
         ====================================================================-->
    <xsl:template match="jp:document-code">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
            <xsl:call-template name="書類名タイトル" />
            <xf:string key="convertedText">
                <xsl:call-template name="書類名変換" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <xsl:template
        name="書類名タイトル">
        <xsl:variable name="kinddoc">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:value-of select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="parent::jp:amendment-charge-article">
                <xf:string key="jpTag">
                    <xsl:value-of select="'【補正対象書類名】'" />
                </xf:string>
                <xf:string key="indentLevel">
                    <xsl:value-of select="'2'" />
                </xf:string>
            </xsl:when>
            <xsl:when test="parent::jp:target-document">
                <xf:string key="jpTag">
                    <xsl:value-of select="'【書類名】'" />
                </xf:string>
                <xf:string key="indentLevel">
                    <xsl:value-of select="'2'" />
                </xf:string>
            </xsl:when>
            <xsl:when test="ancestor::jp:contents-of-amendment">
                <xsl:choose>
                    <xsl:when test="parent::jp:amendment-group">
                        <xsl:choose>
                            <xsl:when test="$kinddoc = 'jp:amendment-a524'">
                                <xf:string key="jpTag">
                                    <xsl:value-of select="'【訂正対象書類名】'" />
                                </xf:string>
                                <xf:string key="indentLevel">
                                    <xsl:value-of select="'2'" />
                                </xf:string>
                            </xsl:when>
                            <xsl:otherwise>
                                <xf:string key="jpTag">
                                    <xsl:value-of select="'【補正対象書類名】'" />
                                </xf:string>
                                <xf:string key="indentLevel">
                                    <xsl:value-of select="'2'" />
                                </xf:string>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【書類名】'" />
                        </xf:string>
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'2'" />
                        </xf:string>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="parent::jp:amendment-group">
                        <xsl:choose>
                            <xsl:when test="$kinddoc = 'jp:amendment-a524'">
                                <xf:string key="jpTag">
                                    <xsl:value-of select="'【訂正対象書類名】'" />
                                </xf:string>
                                <xf:string key="indentLevel">
                                    <xsl:value-of select="'1'" />
                                </xf:string>
                            </xsl:when>
                            <xsl:otherwise>
                                <xf:string key="jpTag">
                                    <xsl:value-of select="'【補正対象書類名】'" />
                                </xf:string>
                                <xf:string key="indentLevel">
                                    <xsl:value-of select="'1'" />
                                </xf:string>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【書類名】'" />
                        </xf:string>
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'0'" />
                        </xf:string>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ====================================================================
         jp:file-reference-id 整理番号
         ====================================================================-->
    <xsl:template match="jp:file-reference-id">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xsl:call-template name="整理番号項目名編集" />
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:share-rate 持分の割合
         import from <xsl:template name="持分の割合編集">
         ====================================================================-->
    <xsl:template match="jp:share-rate">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【持分の割合】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="jp:moleclar" />
                <xsl:value-of select="'/'" />
                <xsl:value-of select="jp:denominator" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:dtext その他、提出物件の特記事項
         import from <xsl:template name="その他編集">
         ====================================================================-->
    <xsl:template match="jp:dtext">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:submission-object-list-article">
                        <xsl:value-of select="'【提出物件の特記事項】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【その他】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space()" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:submission-object-list-article">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:payment-years 納付年分
         import from <xsl:template name="納付年分編集">
         ====================================================================-->
    <xsl:template match="jp:payment-years">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【納付年分】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:annexation-payment
                            or ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:apply-templates select="jp:year-from" />
                <xsl:apply-templates select="jp:year-to" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:year-from 納付年分（自）
         ====================================================================-->
    <xsl:template match="jp:year-from">
        <xsl:choose>
            <xsl:when test="./@jp:error-code">
                <xsl:value-of select="." />
            </xsl:when>
            <xsl:when test="string-length(normalize-space(.)) = 0" />
            
            <xsl:when
                test="number(string-length(normalize-space(.))) != 0 and number(.) != number(normalize-space(.))">
                <xsl:value-of select="'unknown year'" />
            </xsl:when>
            <xsl:when test="string-length(normalize-space(.)) &gt; 2">
                <xsl:value-of select="'unknown year'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'第' || . || '年分'" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ====================================================================
         jp:year-to 納付年分（至）
         ====================================================================-->
    <xsl:template match="jp:year-to">
        <xsl:choose>
            <xsl:when test="./@jp:error-code">
                <xsl:value-of select="." />
            </xsl:when>
            <xsl:when test="string-length(normalize-space(.)) = 0" />
            <xsl:when
                test="number(string-length(normalize-space(.))) != 0 and number(.) != number(normalize-space(.))">
                <xsl:value-of select="'unknown year'" />
            </xsl:when>
            <xsl:when test="string-length(normalize-space(.)) &gt; 2">
                <xsl:value-of select="'unknown year'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'から第' || . || '年分'" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ====================================================================
         jp:proof-necessity プルーフの要否 
         imoprt from <xsl:template name="プルーフの要否編集">
         ====================================================================-->
    <xsl:template match="jp:proof-necessity">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【プルーフの要否】'" />
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@jp:error-code">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="normalize-space(.) = '0'">
                                <xsl:value-of select="'不要'" />
                            </xsl:when>
                            <xsl:when test="normalize-space(.) = '1'">
                                <xsl:value-of select="'要'" />
                            </xsl:when>
                            <xsl:when test="normalize-space(.) = ''">
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="書誌編集エラー処理" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:notice-contents-group 届出の内容
         import from 届出の内容編集
         ====================================================================-->
    <xsl:template match="jp:notice-contents-group">
        
        <xsl:variable name="node">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:value-of select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="$node = 'jp:applicant-a55'">
                        <xsl:value-of select="'【申立の内容】'" />
                    </xsl:when>
                    <xsl:when test="$node = 'jp:etcetera-a601'">
                        <xsl:value-of select="'【請求の内容】'" />
                    </xsl:when>
                    <xsl:when test="$node = 'jp:etcetera-a821' or $node = 'jp:payment-r220'">
                        <xsl:value-of select="'【補足の内容】'" />
                    </xsl:when>
                    <xsl:when test="$node = 'jp:etcetera-a831'">
                        <xsl:value-of select="'【提出の理由】'" />
                    </xsl:when>
                    <xsl:when test="$node = 'jp:etcetera-a623' or $node = 'jp:etcetera-a624'">
                        <xsl:value-of select="'【評価の請求に係る請求項の表示】'" />
                    </xsl:when>
                    <xsl:when test="$node = 'jp:application-a631'">
                        <xsl:value-of select="'【確認事項】'" />
                    </xsl:when>
                    <xsl:when
                        test="$node = 'jp:application-a632' or $node = 'jp:application-a635'
                            or $node = 'jp:amendment-a526' or $node = 'jp:amendment-a528'
                            or $node = 'jp:amendment-a5210' or $node = 'jp:amendment-a5212'">
                        <xsl:value-of select="'【職権作成の表示】'" />
                    </xsl:when>
                    <xsl:when test="$node = 'jp:etcetera-a603'">
                        <xsl:value-of select="'【請求の内容】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【届出の内容】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="normalize-space()" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:ip-type 出願の区分
         ====================================================================-->
    <xsl:template match="jp:ip-type">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【出願の区分】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'2'" />
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@jp:error-code">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:when test="normalize-space(.) = 'patent'">
                        <xsl:value-of select="'特許'" />
                    </xsl:when>
                    <xsl:when test="normalize-space(.) = 'utility'">
                        <xsl:value-of select="'実用新案登録'" />
                    </xsl:when>
                    <xsl:when test="normalize-space(.) = 'design'">
                        <xsl:value-of select="'意匠登録'" />
                    </xsl:when>
                    <xsl:when test="normalize-space(.) = ''"><!--NULLの場合、編集しない-->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="書誌編集エラー処理" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:use-of-das DAS利用
         import from <xsl:template name="DAS利用編集">
         ====================================================================-->
    <xsl:template match="jp:use-of-das">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:priority-claim">
                        <xsl:value-of select="'【優先権証明書に係る付与】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【本出願に係る付与】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:priority-claim">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="ancestor::jp:contents-of-amendment">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'0'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@jp:error-code">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:when test="normalize-space(.) = '1'">
                        <xsl:value-of select="'希望'" />
                    </xsl:when>
                    <xsl:when test="normalize-space(.) = ''"><!--NULLの場合、編集しない-->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="書誌編集エラー処理" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:doc-number 文書番号
         import from <xsl:template name="文書番号編集">
         ====================================================================-->
    <xsl:template match="jp:doc-number">
        <xsl:variable name="law" select="ancestor::jp:application-reference/@jp:kind-of-law" />
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:application-reference">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::jp:application-reference [@appl-type = 'application']">
                                <xsl:value-of select="'【出願番号】'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:application-reference [@appl-type = 'international-application']">
                                <xsl:value-of select="'【国際出願番号】'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:application-reference [@appl-type = 'registration']">
                                <xsl:choose>
                                    <xsl:when test="$law = 'patent'">
                                        <xsl:value-of select="'【特許番号】'" />
                                    </xsl:when>
                                    <xsl:when test="$law = 'utility'">
                                        <xsl:value-of select="'【実用新案登録番号】'" />
                                    </xsl:when>
                                    <xsl:when test="$law = 'design'">
                                        <xsl:value-of select="'【意匠登録番号】'" />
                                    </xsl:when>
                                    <xsl:when test="$law = 'trademark'">
                                        <xsl:value-of select="'【商標登録番号】'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'【登録番号】'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:application-reference [@appl-type = 'examined-pub']">
                                <xsl:value-of select="'【出願公告番号】'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:application-reference [@appl-type = 'un-examined-pub']">
                                <xsl:value-of select="'【出願公開番号】'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="ancestor::jp:appeal-reference">
                        <xsl:value-of select="'【審判番号】'" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:priority-doc-location-info">
                        <xsl:value-of select="'【提供国（機関）における出願の番号】'" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:priority-claim">
                        <xsl:value-of select="'【出願番号】'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:application-reference or ancestor::jp:appeal-reference">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::jp:application-reference
                                    and ancestor::jp:application-reference [@appl-type = 'registration']">
                                <xsl:choose>
                                    <xsl:when
                                        test="ancestor::jp:indication-of-case-article
                                            and ($payment = 'jp:payment-' or $node = 'jp:demand-e853'
                                                or $node = 'jp:demand-e854' or $node = 'jp:demand-e862') ">
                                        <xsl:value-of select="'0'" />
                                    </xsl:when>
                                    <xsl:when test="ancestor::jp:annexation-payment">
                                        <xsl:value-of select="'0'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="ancestor::jp:indication-of-case-article
                                            and ($node = 'jp:etcetera-a623' or $node = 'jp:etcetera-a624' or $node = 'jp:etcetera-a915')
                                            and $kind-of-law = 'utility'
                                            and string-length(normalize-space(ancestor::jp:application-reference/jp:document-id/jp:date)) = 0">
                                        <xsl:choose>
                                            <xsl:when
                                                test="//jp:application-reference/@appl-type != 'registration'">
                                                <xsl:value-of select="'2'" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'0'" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'2'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when
                                        test="ancestor::jp:indication-of-case-article
                                            and ($payment = 'jp:payment-' or $node = 'jp:demand-e853'
                                                or $node = 'jp:demand-e854' or $node = 'jp:demand-e862') ">
                                        <xsl:value-of select="'0'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'2'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="ancestor::jp:priority-doc-location-info">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:priority-claim">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@jp:error-code">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="normalize-space(.) = ''" />
                            <xsl:otherwise>
                                <xsl:call-template name="文書番号内容編集" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:name 氏名又は名称
         import from <xsl:template name="氏名又は名称編集">
         ====================================================================-->
    <xsl:template match="jp:name">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:inventor">
                        <xsl:value-of select="'【氏名】'" />
                    </xsl:when>
                    <xsl:when test=" parent::jp:bank-account">
                        <xsl:value-of select="'【口座名義人】'" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:representative">
                        <xsl:choose>
                            <xsl:when
                                test="(ancestor::jp:attorney-disappear-article
                                        or ancestor::jp:attorney-change-article)
                                    and ($node = 'jp:attorney-a7421' or $node = 'jp:attorney-a7423'
                                        or $node = 'jp:attorney-a7425' or $node = 'jp:attorney-a7426'
                                        or $node = 'jp:attorney-a7427' or $node = 'jp:attorney-a7428'
                                        or $node = 'jp:attorney-a7431' or $node = 'jp:attorney-a7433'
                                        or $node = 'jp:attorney-a7435' or $node = 'jp:attorney-a7436'
                                        or $node = 'jp:attorney-a7437') ">
                                <xsl:call-template name="名称編集">
                                    <xsl:with-param name="type" select="1" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="名称編集">
                                    <xsl:with-param name="type" select="1" />
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when
                                test="(ancestor::jp:attorney-disappear-article
                                        or ancestor::jp:attorney-change-article)
                                    and ($node = 'jp:attorney-a7421' or $node = 'jp:attorney-a7423'
                                        or $node = 'jp:attorney-a7425' or $node = 'jp:attorney-a7426'
                                        or $node = 'jp:attorney-a7427' or $node = 'jp:attorney-a7428'
                                        or $node = 'jp:attorney-a7431' or $node = 'jp:attorney-a7433'
                                        or $node = 'jp:attorney-a7435' or $node = 'jp:attorney-a7436'
                                        or $node = 'jp:attorney-a7437') ">
                                <xsl:value-of select="'【氏名又は名称】'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'【氏名又は名称】'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:inventor">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:when test=" parent::jp:bank-account">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:representative">
                        <xsl:choose>
                            <xsl:when
                                test="(ancestor::jp:attorney-disappear-article
                                        or ancestor::jp:attorney-change-article)
                                    and ($node = 'jp:attorney-a7421' or $node = 'jp:attorney-a7423'
                                        or $node = 'jp:attorney-a7425' or $node = 'jp:attorney-a7426'
                                        or $node = 'jp:attorney-a7427' or $node = 'jp:attorney-a7428'
                                        or $node = 'jp:attorney-a7431' or $node = 'jp:attorney-a7433'
                                        or $node = 'jp:attorney-a7435' or $node = 'jp:attorney-a7436'
                                        or $node = 'jp:attorney-a7437') ">
                                <xsl:value-of select="'3'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'2'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when
                                test="(ancestor::jp:attorney-disappear-article
                                        or ancestor::jp:attorney-change-article)
                                    and ($node = 'jp:attorney-a7421' or $node = 'jp:attorney-a7423'
                                        or $node = 'jp:attorney-a7425' or $node = 'jp:attorney-a7426'
                                        or $node = 'jp:attorney-a7427' or $node = 'jp:attorney-a7428'
                                        or $node = 'jp:attorney-a7431' or $node = 'jp:attorney-a7433'
                                        or $node = 'jp:attorney-a7435' or $node = 'jp:attorney-a7436'
                                        or $node = 'jp:attorney-a7437') ">
                                <xsl:value-of select="'3'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'2'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:original-language-of-name 氏名又は名称原語表記
         import from <xsl:template name="氏名又は名称原語表記編集">
         ====================================================================-->
    <xsl:template match="jp:original-language-of-name">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:representative">
                        <xsl:call-template name="名称編集">
                            <xsl:with-param name="type" select="2" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【氏名又は名称原語表記】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'2'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:country 国コード
         import from <xsl:template name="国コード編集">
         ====================================================================-->
    <xsl:template match="jp:country">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:application-country-article">
                        <xsl:value-of select="'【出願国・地域名】'" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:priority-doc-location-info">
                        <xsl:value-of select="'【優先権証明書提供国（機関）】'" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:priority-claim">
                        <xsl:value-of select="'【国・地域名】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【国籍・地域】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:application-country-article">
                        <xsl:value-of select="'0'" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:priority-doc-location-info">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:priority-claim">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'2'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@jp:error-code">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="国名県名変換" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:receipt-number 受付番号
         import from <xsl:template name="受付番号編集">
         ====================================================================-->
    <xsl:template match="jp:receipt-number">
        <xsl:variable name="kinddoc">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:value-of select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="c-payment">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:value-of
                        select="substring(ancestor::jp:contents-of-amendment/@jp:kind-of-document,1,11)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$payment" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:choose>
                            <xsl:when test="parent::jp:amendment-group">
                                <xsl:choose>
                                    <xsl:when test="$kinddoc = 'jp:amendment-a524'">
                                        <xsl:value-of select="'【訂正対象書類受付番号】'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'【補正対象書類受付番号】'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'【受付番号】'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="ancestor::jp:indication-of-case-article">
                                <xsl:choose>
                                    <xsl:when
                                        test="$c-payment = 'jp:payment-'
                                            or $kinddoc = 'jp:demand-e853'
                                            or $kinddoc = 'jp:demand-e854'
                                            or $kinddoc = 'jp:demand-e862' ">
                                        <xsl:value-of select="'【受付番号】'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'【受付番号】'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="parent::jp:amendment-group">
                                <xsl:choose>
                                    <xsl:when test="$kinddoc = 'jp:amendment-a524'">
                                        <xsl:value-of select="'【訂正対象書類受付番号】'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'【補正対象書類受付番号】'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'【受付番号】'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="ancestor::jp:indication-of-case-article">
                                <xsl:choose>
                                    <xsl:when
                                        test="$c-payment = 'jp:payment-'
                                            or $kinddoc = 'jp:demand-e853'
                                            or $kinddoc = 'jp:demand-e854'
                                            or $kinddoc = 'jp:demand-e862' ">
                                        <xsl:value-of select="'0'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'2'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="parent::jp:amendment-group">
                                <xsl:value-of select="'1'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'2'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:relation-of-case 事件との関係
         import from <xsl:template name="事件との関係編集">
         ====================================================================-->
    <xsl:template match="jp:relation-of-case">
        <xsl:variable name="kinddoc">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="$kinddoc = 'jp:etcetera-a621' or $kinddoc = 'jp:etcetera-a625'">
                        <xsl:value-of select="'【出願人との関係】'" />
                    </xsl:when>
                    <xsl:when test="ancestor::jp:presenter-article">
                        <xsl:value-of select="'【請求人との関係】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【事件との関係】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'2'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:fee 納付方法・納付金額
         import from <xsl:template name="納付金額編集">
         ====================================================================-->
    <xsl:template match="jp:fee">
        <xsl:variable name="kinddoc">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when
                        test="$kinddoc = 'jp:payment-r110' or $kinddoc = 'jp:payment-r111'
                            or $kinddoc = 'jp:payment-r112' or $kinddoc = 'jp:payment-r113'
                            or $kinddoc = 'jp:payment-r114' or $kinddoc = 'jp:payment-r115'
                            or $kinddoc = 'jp:payment-r21' or $kinddoc = 'jp:payment-r210'
                            or $kinddoc = 'jp:payment-r211' ">
                        <xsl:value-of select="'【補充金額】'" />
                    </xsl:when>
                    <xsl:when
                        test="parent::jp:amount-paid and not(ancestor::jp:contents-of-amendment)">
                        <xsl:value-of select="'【納付済金額】'" />
                    </xsl:when>
                    <xsl:when test="parent::jp:amount-paid ">
                        <xsl:value-of select="'【納付済金額】'" />
                    </xsl:when>
                    <xsl:when
                        test=" parent::jp:amount-restoration-claim and not(ancestor::jp:contents-of-amendment)">
                        <xsl:value-of select="'【返還請求金額】'" />
                    </xsl:when>
                    <xsl:when test=" parent::jp:amount-restoration-claim ">
                        <xsl:value-of select="'【返還請求金額】'" />
                    </xsl:when>
                    <xsl:when
                        test="parent::jp:amount-proper-payment and not(ancestor::jp:contents-of-amendment)">
                        <xsl:value-of select="'【適正納付金額】'" />
                    </xsl:when>
                    <xsl:when test="parent::jp:amount-proper-payment ">
                        <xsl:value-of select="'【適正納付金額】'" />
                    </xsl:when>
                    <xsl:when
                        test="($kinddoc = 'jp:etcetera-a914') and
                            ancestor::jp:charge-article">
                        <xsl:value-of select="'【加算金額】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【納付金額】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="$kinddoc = 'jp:payment-r110' or $kinddoc = 'jp:payment-r111'
                            or $kinddoc = 'jp:payment-r112' or $kinddoc = 'jp:payment-r113'
                            or $kinddoc = 'jp:payment-r114' or $kinddoc = 'jp:payment-r115'
                            or $kinddoc = 'jp:payment-r21' or $kinddoc = 'jp:payment-r210'
                            or $kinddoc = 'jp:payment-r211' ">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:when
                        test="parent::jp:amount-paid and not(ancestor::jp:contents-of-amendment)">
                        <xsl:value-of select="'0'" />
                    </xsl:when>
                    <xsl:when test="parent::jp:amount-paid ">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:when
                        test=" parent::jp:amount-restoration-claim and not(ancestor::jp:contents-of-amendment)">
                        <xsl:value-of select="'0'" />
                    </xsl:when>
                    <xsl:when test=" parent::jp:amount-restoration-claim ">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:when
                        test="parent::jp:amount-proper-payment and not(ancestor::jp:contents-of-amendment)">
                        <xsl:value-of select="'0'" />
                    </xsl:when>
                    <xsl:when test="parent::jp:amount-proper-payment ">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:when
                        test="($kinddoc = 'jp:etcetera-a914') and
                            ancestor::jp:charge-article">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'2'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="./@amount" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:choose>
                    <xsl:when test="./@jp:error-code">
                        <xsl:value-of select="./@amount" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when
                                test="./@amount != '' and string(number(./@amount)) != 'NaN'">
                                <xsl:value-of
                                    select="format-number(xs:integer(normalize-space(./@amount)), '#,###')" />
                                <xsl:value-of select="'円'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:account 予納台帳番号・納付書番号
         import from <xsl:template name="予納台帳番号編集">
         ====================================================================-->
    <xsl:template match="jp:account">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="./@account-type = 'deposit'">
                        <xsl:value-of select="'【予納台帳番号】'" />
                    </xsl:when>
                    <xsl:when test="./@account-type = 'form'">
                        <xsl:value-of select="'【納付書番号】'" />
                    </xsl:when>
                    <xsl:when test="./@account-type = 'electronic-cash'">
                        <xsl:value-of select="'【納付番号】'" />
                    </xsl:when>
                    <xsl:when test="./@account-type = 'transfer'">
                        <xsl:value-of select="'【振替番号】'" />
                    </xsl:when>
                    <xsl:when test="./@account-type = 'credit-card'">
                        <xsl:value-of select="'【指定立替納付】'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'2'" />
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@account-type = 'credit-card'">
                        <xsl:if test="./@jp:error-code">
                            <xsl:value-of select="./@number" />
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="./@number" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xsl:if test="./@account-type = 'electronic-cash'">
                <xsl:if test="string-length(normalize-space(./@number)) = 16">
                    <xf:string key="convertedText">
                        <xsl:call-template name="split-at-n-chars">
                            <xsl:with-param name="input-string"
                                select="normalize-space(./@number)" />
                            <xsl:with-param name="n-chars" select="4" />
                            <xsl:with-param name="sep" select="'-'" />
                        </xsl:call-template>
                    </xf:string>
                </xsl:if>
            </xsl:if>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:document-name 物件名
         import from <xsl:template name="物件名編集">
         ====================================================================-->
    <xsl:template match="jp:document-name">
        <xsl:variable name="node">
            <xsl:choose>
                <xsl:when
                    test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                    <xsl:value-of
                        select="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:list-group">
                        <xsl:value-of select="'【物件名】'" />
                    </xsl:when>
                    <xsl:when test="$node = 'jp:etcetera-a831'">
                        <xsl:value-of select="'【提出する刊行物等】'" />
                    </xsl:when>
                    <xsl:when test="$node = 'jp:presentment-a82'">
                        <xsl:value-of select="'【提出する物件】'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:choose>
                            <xsl:when test="ancestor::jp:list-group">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:when test="$node = 'jp:etcetera-a831'">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:when test="$node = 'jp:presentment-a82'">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="ancestor::jp:list-group">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:when test="$node = 'jp:etcetera-a831'">
                                <xsl:value-of select="'0'" />
                            </xsl:when>
                            <xsl:when test="$node = 'jp:presentment-a82'">
                                <xsl:value-of select="'0'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:list-group">
                        <xsl:value-of select=". || '　' || following-sibling::jp:number-of-object" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:return-request 返還の申出
         import from <xsl:template name="返還の申出編集">
         ====================================================================-->
    <xsl:template match="jp:return-request">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【返還の申出】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'3'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@jp:error-code">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="normalize-space(.) = '0'">
                                <xsl:value-of select="'無'" />
                            </xsl:when>
                            <xsl:when test="normalize-space(.) = '1'">
                                <xsl:value-of select="'有'" />
                            </xsl:when>
                            <xsl:when test="normalize-space(.) = ''">
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="書誌編集エラー処理" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:special-mention-matter-article/jp:article 条文
         ====================================================================-->
    <xsl:template match="jp:article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xf:string key="jpTag">
                        <xsl:value-of select="'【特記事項】'" />
                    </xf:string>
                    <xsl:choose>
                        <xsl:when test="ancestor::jp:contents-of-amendment">
                            <xf:string key="indentLevel">
                                <xsl:value-of select="'2'" />
                            </xf:string>
                        </xsl:when>
                        <xsl:otherwise>
                            <xf:string key="indentLevel">
                                <xsl:value-of select="'0'" />
                            </xf:string>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xf:string key="jpTag">
                        <xsl:value-of select="'　　　　　　　　　　　'" />
                    </xf:string>
                </xsl:otherwise>
            </xsl:choose>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:call-template name="convert-special-mention-matter-article">
                    <xsl:with-param name="article" select="normalize-space()" />
                    <xsl:with-param name="kind-of-law" select="$kind-of-law" />
                </xsl:call-template>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:ipc-article
         jp:ipc-article <- 国際特許分類編集 
         ====================================================================-->
    <xsl:template match="jp:ipc-article">
        <xsl:for-each select="jp:ipc">
            <xf:map>
                <xf:string key="tag">
                    <xsl:text>jp:ipc</xsl:text>
                </xf:string>
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【国際特許分類】'" />
                        </xf:string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xf:string key="jpTag">
                            <xsl:value-of select="''" />
                        </xf:string>
                    </xsl:otherwise>
                </xsl:choose>
                <xf:string key="text">
                    <xsl:value-of select="normalize-space()" />
                </xf:string>
                <xf:string key="indentLevel">
                    <xsl:choose>
                        <xsl:when test="ancestor::jp:contents-of-amendment">
                            <xsl:value-of select="'2'" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'0'" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xf:string>
            </xf:map>
        </xsl:for-each>
    </xsl:template>
    
    <!-- ====================================================================
         jp:number-of-claim 請求項の数
         import from  <xsl:template name="請求項の数編集">
         ====================================================================-->
    <xsl:template match="jp:number-of-claim">
        <xsl:variable name="kinddoc">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when
                        test="$kinddoc = 'jp:etcetera-a623' or $kinddoc = 'jp:etcetera-a624'">
                        <xsl:value-of select="'【評価の請求に係る請求項の数】'" />
                    </xsl:when>
                    <xsl:when test="./@jp:adopted-law = 'claim' ">
                        <xsl:value-of select="'【請求項の数】'" />
                    </xsl:when>
                    <xsl:when test="./@jp:adopted-law = 'invention' ">
                        <xsl:value-of select="'【発明の数】'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:choose>
                            <xsl:when
                                test="$kinddoc = 'jp:etcetera-a623' or $kinddoc = 'jp:etcetera-a624'">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:when test="./@jp:adopted-law = 'claim' ">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:when test="./@jp:adopted-law = 'invention' ">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'0'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when
                                test="$kinddoc = 'jp:etcetera-a623' or $kinddoc = 'jp:etcetera-a624'">
                                <xsl:value-of select="'0'" />
                            </xsl:when>
                            <xsl:when test="ancestor::jp:annexation-payment">
                                <xsl:choose>
                                    <xsl:when test="./@jp:adopted-law = 'claim' ">
                                        <xsl:value-of select="'2'" />
                                    </xsl:when>
                                    <xsl:when test="./@jp:adopted-law = 'invention' ">
                                        <xsl:value-of select="'2'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'0'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="./@jp:adopted-law = 'claim' ">
                                        <xsl:value-of select="'0'" />
                                    </xsl:when>
                                    <xsl:when test="./@jp:adopted-law = 'invention' ">
                                        <xsl:value-of select="'0'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'0'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:num-claim-decrease-amendment 補正により減少する請求項の数
         import from <xsl:template name="補正により減少する請求項の数編集">
         ====================================================================-->
    <xsl:template match="jp:num-claim-decrease-amendment">
        <xsl:param name="document" />
        
        <xsl:variable name="sikibetu">
            <xsl:choose>
                <xsl:when test="parent::jp:contents-of-amendment">
                    <xsl:value-of select="parent::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$document" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="$sikibetu = 'jp:amendment-a524'">
                        <xsl:choose>
                            <xsl:when test="./@jp:adopted-law = 'claim'">
                                <xsl:value-of select="'【訂正により減少する請求項の数】'" />
                            </xsl:when>
                            <xsl:when test="./@jp:adopted-law = 'invention'">
                                <xsl:value-of select="'【訂正により減少する発明の数】'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="./@jp:adopted-law = 'claim'">
                                <xsl:value-of select="'【補正により減少する請求項の数】'" />
                            </xsl:when>
                            <xsl:when test="./@jp:adopted-law = 'invention'">
                                <xsl:value-of select="'【補正により減少する発明の数】'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:num-claim-increase-amendment 補正により増加する請求項の数
         import from <xsl:template name="補正により増加する請求項の数編集">
         ====================================================================-->
    <xsl:template match="jp:num-claim-increase-amendment">
        <xsl:param name="document" />
        
        <xsl:variable name="sikibetu">
            <xsl:choose>
                <xsl:when test="parent::jp:contents-of-amendment">
                    <xsl:value-of select="parent::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$document" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="$sikibetu = 'jp:amendment-a524'">
                        <xsl:choose>
                            <xsl:when test="./@jp:adopted-law = 'claim'">
                                <xsl:value-of select="'【訂正により増加する請求項の数】'" />
                            </xsl:when>
                            <xsl:when test="./@jp:adopted-law = 'invention'">
                                <xsl:value-of select="'【訂正により増加する発明の数】'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="./@jp:adopted-law = 'claim'">
                                <xsl:value-of select="'【補正により増加する請求項の数】'" />
                            </xsl:when>
                            <xsl:when test="./@jp:adopted-law = 'invention'">
                                <xsl:value-of select="'【補正により増加する発明の数】'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:proof-means 証拠方法
         import from <xsl:template name="証拠方法編集">
         ====================================================================-->
    <xsl:template match="jp:proof-means">
        <xsl:variable name="kinddoc">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when
                        test="$kinddoc = 'jp:payment-r220' or $kinddoc = 'jp:etcetera-a821'">
                        <xsl:value-of select="'【補足対象書類名】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【証拠方法】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:registered-number 識別番号 import from <xsl:template name="識別番号編集">
         jp:office-address 就業場所 import from <xsl:template name="就業場所編集">
         jp:contact 連絡先 import from <xsl:template name="連絡先編集">
         jp:text 住所又は居所 import from <xsl:template name="住所又は居所編集">
         jp:relation-attorney-special-matter 代理関係の特記事項 import from <xsl:template name="代理関係の特記事項編集">
         jp:phone 電話番号 import from <xsl:template name="電話番号編集">
         jp:fax ファクシミリ番号 import from <xsl:template name="ファクシミリ番号編集">
         jp:kana フリガナ import from <xsl:template name="フリカナ編集">
         ====================================================================-->
    <xsl:template match="jp:registered-number | jp:office-address | jp:contact | jp:text |
        jp:relation-attorney-special-matter | jp:phone | jp:fax | jp:kana">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="name() = 'jp:registered-number'">
                        <xsl:value-of select="'【識別番号】'" />
                    </xsl:when>
                    <xsl:when test="name() = 'jp:office-address'">
                        <xsl:value-of select="'【就業場所】'" />
                    </xsl:when>
                    <xsl:when test="name() = 'jp:contact'">
                        <xsl:value-of select="'【連絡先】'" />
                    </xsl:when>
                    <xsl:when test="name() = 'jp:text'">
                        <xsl:value-of select="'【住所又は居所】'" />
                    </xsl:when>
                    <xsl:when test="name() = 'jp:relation-attorney-special-matter'">
                        <xsl:value-of select="'【代理関係の特記事項】'" />
                    </xsl:when>
                    <xsl:when test="name() = 'jp:phone'">
                        <xsl:value-of select="'【電話番号】'" />
                    </xsl:when>
                    <xsl:when test="name() = 'jp:fax'">
                        <xsl:value-of select="'【ファクシミリ番号】'" />
                    </xsl:when>
                    <xsl:when test="name() = 'jp:kana'">
                        <xsl:value-of select="'【フリガナ】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【unknown】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="(ancestor::jp:attorney-disappear-article
                                or ancestor::jp:attorney-change-article)
                            and ($node = 'jp:attorney-a7421' or $node = 'jp:attorney-a7423'
                                or $node = 'jp:attorney-a7425' or $node = 'jp:attorney-a7426'
                                or $node = 'jp:attorney-a7427' or $node = 'jp:attorney-a7428'
                                or $node = 'jp:attorney-a7431' or $node = 'jp:attorney-a7433'
                                or $node = 'jp:attorney-a7435' or $node = 'jp:attorney-a7436'
                                or $node = 'jp:attorney-a7437') ">
                        <xsl:value-of select="'3'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'2'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:submission-date    提出日 
         jp:dispatch-date      発送日 
         jp:notice-filing-date 出願番号通知の出願日 
         jp:proof-filing-date  証明しようとする出願日
         jp:submit-date-of-amendment 補正書の提出年月日
         ====================================================================-->
    <xsl:template match="jp:submission-date | jp:dispatch-date | jp:notice-filing-date |
        jp:proof-filing-date | jp:submit-date-of-amendment">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <!-- render jpTag, text, indentLevel and 
                 convertedText in jp:date template -->
            <xsl:apply-templates select="jp:date" mode="no-blocks" />
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
            <!-- render jpTag, indentLevel -->
            <xsl:call-template name="日付タイトル" />
            <xf:string key="text">
                <xsl:value-of select="normalize-space()" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:call-template name="format-date-jp">
                    <xsl:with-param name="date-str" select="normalize-space()" />
                    <xsl:with-param name="law" select="$kind-of-law" />
                </xsl:call-template>
            </xf:string>
        </xf:map>
    </xsl:template>
    <xsl:template match="jp:date" mode="no-blocks">
        <!-- render jpTag, indentLevel -->
        <xsl:call-template name="日付タイトル" />
        <xf:string key="text">
            <xsl:value-of select="normalize-space()" />
        </xf:string>
        <xf:string key="convertedText">
            <xsl:call-template name="format-date-jp">
                <xsl:with-param name="date-str" select="normalize-space()" />
                <xsl:with-param name="law" select="$kind-of-law" />
            </xsl:call-template>
        </xf:string>
    </xsl:template>
    
    <!-- ===================================================================
         tag, jpTag, indentLevel=2, and text="." with no amendment context.
         ===================================================================-->
    <xsl:template match="jp:generated-access-code | 
        jp:financial-institution-name | jp:account-type | jp:account-number |
        jp:share | jp:representative-applicant |  jp:office-in-japan |
        jp:office | jp:general-power-of-attorney-id |
        jp:original-language-of-address | jp:kind-of-appeals |
        jp:legal-entity-property">
        <xsl:variable name="params"
            select="key('item-type-1-key', name(), $item-type-1-parameters)" />
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="$params/@jpTag" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'2'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <xsl:key name="item-type-1-key" match="parameter" use="@tag" />
    <xsl:variable name="item-type-1-parameters">
        <parameter tag="jp:generated-access-code" jpTag="【アクセスコード】" />
        <parameter tag="jp:financial-institution-name" jpTag="【金融機関名】" />
        <parameter tag="jp:account-type" jpTag="【口座種別】" />
        <parameter tag="jp:account-number" jpTag="【口座番号】" />
        <parameter tag="jp:share" jpTag="【持分】" />
        <parameter tag="jp:representative-applicant" jpTag="【代表出願人】" />
        <parameter tag="jp:office-in-japan" jpTag="【日本における営業所】" />
        <parameter tag="jp:office" jpTag="【営業所】" />
        <parameter tag="jp:general-power-of-attorney-id" jpTag="【包括委任状番号】" />
        <parameter tag="jp:original-language-of-address" jpTag="【住所又は居所原語表記】" />
        <parameter tag="jp:kind-of-appeals" jpTag="【審判の種別】" />
        <parameter tag="jp:legal-entity-property" jpTag="【法人の法的性質】" />
    </xsl:variable>
    
    <!-- ===================================================================
         tag, jpTag, indentLevel=0 or 2 depends on amendments, and text="."
         ===================================================================-->
    <xsl:template match="jp:addressed-to-person | jp:trust-relation | jp:secret-design-term |
        jp:law-of-industrial-regenerate | jp:dispatch-number |
        jp:name-of-old-depository | jp:old-depository-number |
        jp:name-of-new-depository | jp:new-depository-number |
        jp:number-of-class | jp:number-of-annexation | jp:srep-request-no |
        jp:citation | jp:kind-of-accelerated-examination">
        <xsl:variable name="params"
            select="key('item-type-2-key', name(), $item-type-2-parameters)" />
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="$params/@jpTag" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="$params/@indentLevel-amendment" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$params/@indentLevel" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <xsl:key name="item-type-2-key" match="parameter" use="@tag" />
    <xsl:variable name="item-type-2-parameters">
        <parameter tag="jp:addressed-to-person" jpTag="【あて先】"
                   indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="jp:trust-relation" jpTag="【信託関係事項】"
                   indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="jp:secret-design-term" jpTag="【秘密にすることを請求する期間】"
                   indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="jp:law-of-industrial-regenerate" jpTag="【国等の委託研究の成果に係る記載事項】"
                   indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="jp:dispatch-number" jpTag="【発送番号】"
                   indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="jp:name-of-old-depository" jpTag="【旧寄託機関の名称】"
                   indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="jp:old-depository-number" jpTag="【旧受託番号】"
                   indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="jp:name-of-new-depository" jpTag="【新寄託機関の名称】"
                   indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="jp:new-depository-number" jpTag="【新受託番号】"
                   indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="jp:number-of-class" jpTag="【商品及び役務の区分の数】"
                   indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="jp:number-of-annexation" jpTag="【併合件数】"
                   indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="jp:srep-request-no" jpTag="【調査報告番号】"
                   indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="jp:citation" jpTag="【援用の表示】"
                   indentLevel="3"
                   indentLevel-amendment="2" />
        <parameter tag="jp:kind-of-accelerated-examination" jpTag="【早期審査の種別】"
                   indentLevel="0"
                   indentLevel-amendment="2" />
    </xsl:variable>
    
    <!-- schema for terminal type a -->
    <schema:object name="pat-common-terminal-type-a">
        <schema:property name="tag" type="string"
                         enum="jp:document-code,
                               jp:file-reference-id,
                               jp:share-rate,
                               jp:dtext,
                               jp:payment-years,
                               jp:proof-necessity,
                               jp:notice-contents-group,
                               jp:ip-type,
                               jp:use-of-das,
                               jp:doc-number,
                               jp:name,
                               jp:original-language-of-name,
                               jp:country,
                               jp:receipt-number,
                               jp:relation-of-case,
                               jp:fee,
                               jp:account,
                               jp:document-name,
                               jp:return-request,
                               jp:article,
                               jp:ipc-article,
                               jp:number-of-claim,
                               jp:num-claim-decrease-amendment,
                               jp:num-claim-increase-amendment,
                               jp:proof-means,
                               jp:registered-number,
                               jp:office-address,
                               jp:contact,
                               jp:text,
                               jp:relation-attorney-special-matter,
                               jp:phone,
                               jp:fax,
                               jp:kana,
                               jp:submission-date,
                               jp:dispatch-date,
                               jp:notice-filing-date,
                               jp:proof-filing-date,
                               jp:submit-date-of-amendment,
                               jp:date,
                               jp:relief-sought-in-demands,
                               jp:generated-access-code,
                               jp:financial-institution-name,
                               jp:account-type,
                               jp:account-number,
                               jp:share,
                               jp:representative-applicant,
                               jp:office-in-japan,
                               jp:office,
                               jp:general-power-of-attorney-id,
                               jp:original-language-of-address,
                               jp:kind-of-appeals,
                               jp:legal-entity-property,
                               jp:addressed-to-person,
                               jp:trust-relation,
                               jp:secret-design-term,
                               jp:law-of-industrial-regenerate,
                               jp:dispatch-number,
                               jp:name-of-old-depository,
                               jp:old-depository-number,
                               jp:name-of-new-depository,
                               jp:new-depository-number,
                               jp:number-of-class,
                               jp:number-of-annexation,
                               jp:srep-request-no,
                               jp:citation,
                               jp:kind-of-accelerated-examination,
                               shutugan-kubun" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="text" type="string" />
        <schema:property name="convertedText" type="string" optional="true"/>
    </schema:object>
    <!-- ====================================================================
         end:
         terminal type A elements.
         ====================================================================--> 
    
    <!-- ====================================================================
         container type A elements have a tag and blocks.
         
         jp:special-mention-matter-article 特記事項 
         jp:inventors 発明者の記事
         jp:applicants 申請者の記事
         jp:agents 代理人の記事
         jp:attorney-change-article 変更する代理人の記事
         jp:priority-claims パリ条約による優先権等の主張
         jp:declaration-priority-ear-app 先の出願に基づく優先権主張
         jp:list-group 目録 
         jp:nationality 国籍
         jp:priority-doc-location-info 優先権書類の所在情報
         jp:payment 納付
         jp:representative-group 代表者情報
         jp:representative 代表者情報
         ====================================================================-->
    <xsl:template match="jp:special-mention-matter-article |
        jp:inventors | jp:applicants | jp:agents | jp:attorney-change-article |
        jp:priority-claims | jp:declaration-priority-ear-app | jp:list-group |
        jp:nationality | jp:priority-doc-location-info | jp:payment |
        jp:representative-group | jp:representative">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            
            <xf:array key="blocks">
                <xsl:if test="self::jp:special-mention-matter-article">
                    <xsl:apply-templates select="jp:article" />
                </xsl:if>
                
                <xsl:if test="self::jp:inventors">
                    <xsl:apply-templates select="jp:inventor" />
                </xsl:if>
                
                <xsl:if test="self::jp:applicants">
                    <xsl:apply-templates select="jp:applicant" />
                </xsl:if>
                
                <xsl:if test="self::jp:agents or self::jp:attorney-change-article">
                    <xsl:apply-templates select="jp:agent" />
                </xsl:if>
                
                <xsl:if test="self::jp:priority-claims">
                    <xsl:apply-templates select="jp:priority-claim" />
                </xsl:if>
                
                <xsl:if test="self::jp:declaration-priority-ear-app">
                    <xsl:apply-templates select="jp:earlier-app" />
                </xsl:if>
                
                <xsl:if test="self::jp:list-group">
                    <xsl:apply-templates select="jp:document-name" />
                    <xsl:apply-templates select="jp:citation" />
                    <xsl:apply-templates select="jp:return-request" />
                    <xsl:apply-templates select="jp:general-power-of-attorney-id" />
                    <xsl:apply-templates select="jp:dtext" />
                </xsl:if>
                
                <xsl:if test="self::jp:nationality">
                    <xsl:apply-templates select="jp:country" />
                </xsl:if>
                
                <xsl:if test="self::jp:priority-doc-location-info">
                    <xsl:apply-templates select="jp:country" />
                    <xsl:apply-templates select="jp:doc-number" />
                </xsl:if> 
                
                <xsl:if test="self::jp:payment">
                    <xsl:apply-templates select="jp:account" />
                    <xsl:apply-templates select="jp:fee" />
                    
                    <!-- 未サポート -->
                    <xsl:if test="fee-total or credit-card or other-method">
                        <xsl:apply-templates select="fee-total | credit-card | other-method" />
                    </xsl:if>
                </xsl:if>
                
                <xsl:if test="self::jp:representative-group">
                    <xsl:apply-templates select="jp:representative" />
                </xsl:if>
                
                <xsl:if test="self::jp:representative">
                    <xsl:apply-templates select="jp:kana" />
                    <xsl:apply-templates select="jp:name" />
                    <xsl:if test="ancestor::jp:applicants or ancestor::jp:presenter-article">
                        <xsl:apply-templates select="jp:original-language-of-name" />
                    </xsl:if>
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- schema for container type a -->
    <schema:object
        name="pat-common-container-type-a">
        <schema:property
            name="tag" type="string"
                   enum="jp:special-mention-matter-article,
                         jp:inventors,
                         jp:applicants,
                         jp:agents,
                         jp:attorney-change-article,
                         jp:priority-claims,
                         jp:declaration-priority-ear-app,
                         jp:list-group,
                         jp:nationality,
                         jp:priority-doc-location-info,
                         jp:payment,
                         jp:representative-group,
                         jp:representative"/>
        <schema:property name="blocks" type="array">
            <schema:ref name="pat-common-terminal-type-a" />
            <schema:ref name="pat-common-container-type-a" />
            <schema:ref name="inventor" /><!-- defined seperately -->
            <schema:ref name="applicant" /><!-- defined seperately -->
            <schema:ref name="agent" /><!-- defined seperately -->
            <schema:ref name="priority-claim" /><!-- defined seperately -->
            <schema:ref name="earlier-app" /><!-- defined seperately -->
        </schema:property>
    </schema:object>
    <!--===========
         End of the type A elements ===========-->
    
    <!-- ====================================================================
         Begin 補正書関連項目
         ====================================================================-->
    <!-- ====================================================================
         jp:amendment-article 補正の記事
         ====================================================================-->
    <xsl:template match="jp:amendment-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:amendment-group" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="amendment-article">
        <schema:property name="tag" type="string"
                         const="jp:amendment-article" />
        <schema:property name="blocks" type="array">
            <schema:ref name="amendment-group" />
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:amendment-group 手続補正
         ====================================================================-->
    <xsl:template match="jp:amendment-group">
        <xsl:variable name="document" select="$node" />
        
        <xsl:variable name="sikibetu">
            <xsl:choose>
                <xsl:when test="parent::jp:contents-of-amendment">
                    <xsl:value-of select="parent::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$document" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="parent::jp:contents-of-amendment">
                <xf:map>
                    <xf:string key="tag">
                        <xsl:value-of select="name()" />
                    </xf:string>
                    <xf:string key="jpTag">
                        <xsl:choose>
                            <xsl:when test="$sikibetu = 'jp:amendment-a524'">
                                <xsl:value-of select="concat('【誤訳訂正',./@jp:serial-number,'】')" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('【手続補正',./@jp:serial-number,'】')" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xf:string>
                    <xf:string key="indentLevel">
                        <xsl:value-of select="'2'" />
                    </xf:string>
                    <xf:array key="blocks">
                        <xsl:apply-templates select="*" />
                    </xf:array>
                </xf:map>
            </xsl:when>
            <xsl:otherwise>
                <xf:map>
                    <xf:string key="tag">
                        <xsl:value-of select="name()" />
                    </xf:string>
                    <xf:string key="jpTag">
                        <xsl:choose>
                            <xsl:when test="$sikibetu = 'jp:amendment-a524'">
                                <xsl:value-of select="concat('【誤訳訂正',./@jp:serial-number,'】')" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('【手続補正',./@jp:serial-number,'】')" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xf:string>
                    <xf:string key="indentLevel">
                        <xsl:value-of select="'0'" />
                    </xf:string>
                    <xf:array key="blocks">
                        <xsl:apply-templates select="jp:document-code" />
                        <xsl:apply-templates select="jp:receipt-number" />
                        <xsl:apply-templates select="jp:submission-date" />
                        <xsl:apply-templates select="jp:file-reference-id" />
                        <xsl:apply-templates select="jp:item-of-amendment" />
                        <xsl:apply-templates select="jp:way-of-amendment" />
                        <xsl:apply-templates select="jp:contents-of-amendment" />
                    </xf:array>
                </xf:map>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <schema:object
        name="amendment-group">
        <schema:property name="tag" type="string" const="jp:amendment-group" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <!-- below refs are included in pat-common-terminal-type-a
                     <schema:ref name="document-code" />
                     <schema:ref name="receipt-number" />
                     <schema:ref name="submission-date" />
                     <schema:ref name="file-reference-id" />
                -->
                <schema:ref name="pat-common-terminal-type-a" />
                <schema:ref name="amendment-terminal-items" />
                <schema:ref name="contents-of-amendment" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:way-of-amendment 方法
         import from <xsl:template name="方法編集">
         ====================================================================-->
    <xsl:template match="jp:way-of-amendment">
        <xsl:variable name="kinddoc">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:value-of select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="$kinddoc = 'jp:amendment-a524'">
                        <xsl:value-of select="'【訂正方法】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【補正方法】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@jp:error-code">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="normalize-space(.) = ''">
                            </xsl:when>
                            <xsl:when test="normalize-space(.) = '1'">
                                <xsl:value-of select="'追加'" />
                            </xsl:when>
                            <xsl:when test="normalize-space(.) = '2'">
                                <xsl:value-of select="'削除'" />
                            </xsl:when>
                            <xsl:when test="normalize-space(.) = '3'">
                                <xsl:value-of select="'変更'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="書誌編集エラー処理" />
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'1'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:item-of-amendment 対象項目
         import from <xsl:template name="対象項目編集">
         ====================================================================-->
    <xsl:template match="jp:item-of-amendment">
        <xsl:variable name="kinddoc">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:value-of select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="$kinddoc = 'jp:amendment-a524'">
                        <xsl:value-of select="'【訂正対象項目名】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【補正対象項目名】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'1'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    <schema:object name="amendment-terminal-items">
        <schema:property
            name="tag" type="string"
                   enum="jp:item-of-amendment,
                         jp:way-of-amendment" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="text" type="string" />
    </schema:object>
    
    <!-- ====================================================================
         jp:contents-of-amendment 補正の内容
         ====================================================================-->
    <xsl:template match="jp:contents-of-amendment">
        
        <xsl:variable name="kinddoc">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:value-of select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="$kinddoc = 'jp:amendment-a524'">
                        <xsl:value-of select="'【訂正の内容】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【補正の内容】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'1'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="*" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="contents-of-amendment">
        <schema:property name="tag" type="string" const="jp:contents-of-amendment" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="pat-common-terminal-type-a" />
                <schema:ref name="pat-common-container-type-a" />
                <schema:ref name="pat-common-container-type-b" />
                
                <!-- 審判系の補補正対項目 -->
                <schema:ref name="appeal-article" />
                <schema:ref name="relief-sought-in-demands" />
                <schema:ref name="contents-part-article" />
                <schema:ref name="presenter-article" />
                
                <schema:ref name="amendment-charge-article" />
                <schema:ref name="amendment-group" />
                
                <schema:ref name="abstract" />
                <schema:ref name="claim" />
                <schema:ref name="claims" />
                <schema:ref name="description" />
                <schema:ref name="drawings" />
                <schema:ref name="figure" />
                <schema:ref name="invention-title" />
                <schema:ref name="opinion-contents-article" />
                <schema:ref name="paragraph" />
                
                <!-- 当面取り扱わない書類の項目. 補正対象でも扱わない -->
                <!-- <schema:ref name="amount-paid" /> -->
                <!-- <schema:ref name="amount-proper-payment" /> -->
                <!-- <schema:ref name="amount-restoration-claim" /> -->
                <!-- <schema:ref name="annexation-payment-article" /> -->
                <!-- <schema:ref name="applicant-of-case-article" /> -->
                <!-- <schema:ref name="application-country-article" /> -->
                <!-- <schema:ref name="attorney-disappear-article" /> -->
                <!-- <schema:ref name="attorney-of-case-article" /> -->
                <!-- <schema:ref name="bank-account" /> -->
                <!-- <schema:ref name="class-of-goods-and-service" /> -->
                <!-- <schema:ref name="delivery-way" /> -->
                <!-- <schema:ref name="indicate-payment" /> -->
                <!-- <schema:ref name="kind-of-annexation" /> -->
                <!-- <schema:ref name="number-of-copy" /> -->
                <!-- <schema:ref name="proceeded-attorney-article" /> -->
                <!-- <schema:ref name="proof-matter-article" /> -->
                <!-- <schema:ref name="proof-or-deliverty-document" /> -->
                <!-- <schema:ref name="publications-etc-article" /> -->
                <!-- <schema:ref name="rejection-case-accept-notice-art" /> -->
                <!-- <schema:ref name="target-document" /> -->
                <!-- <schema:ref name="target-document-article" /> -->
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:amendment-charge-article 手数料補正
         import from <xsl:template name="手数料補正編集">
         ====================================================================-->
    <xsl:template
        match="jp:amendment-charge-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【手数料補正】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:charge-article" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="amendment-charge-article">
        <schema:property name="tag" type="string" const="jp:amendment-charge-article" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <!-- below refs are included in pat-common-terminal-type-a
                     <schema:ref name="document-code" />
                -->
                <schema:ref name="pat-common-terminal-type-a" />
                
                <!-- below refs are included in pat-common-terminal-type-a
                     <schema:ref name="charge-article" />
                -->
                <schema:ref name="pat-common-container-type-b" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ====================================================================
         End 補正書関連項目
         ====================================================================-->
    
    
    <!-- ====================================================================
         Begin 補正対象となる審判関連文書の項目
         ====================================================================-->
    <!-- ====================================================================
         jp:appeal-article 審判事件の表示
         ====================================================================-->
    <xsl:template match="jp:appeal-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【審判事件の表示】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'2'" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:appeal-reference/jp:doc-number" />
                <xsl:apply-templates select="jp:appeal-reference/jp:date" />
                <xsl:apply-templates select="jp:application-reference" />
                <xsl:apply-templates select="jp:kind-of-appeals" />
                <xsl:apply-templates select="jp:file-reference-id" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="appeal-article">
        <schema:property name="tag" type="string" const="jp:appeal-article" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <!-- XSD には doc-number,date ないけど、xsl ではある。
                     doc-number, date kind-of-appeals and
                     file-reference-id are included
                     in pat-common-terminal-type-a -->
                <schema:ref name="pat-common-terminal-type-a" />
                <schema:ref name="pat-common-container-type-b" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:relief-sought-in-demands 請求の趣旨
         ====================================================================-->
    <xsl:template match="jp:relief-sought-in-demands">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【請求の趣旨】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'2'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    <schema:object
        name="relief-sought-in-demands">
        <schema:property name="tag" type="string" const="jp:relief-sought-in-demands" />
        <schema:property name="jpTag" type="string"/>
        <schema:property name="indentLevel" type="string"/>
        <schema:property name="text" type="string"/>
    </schema:object>
    
    <!-- ====================================================================
         jp:contents-part-article 記部の記事
         ====================================================================-->
    <xsl:template match="jp:contents-part-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:contents-part-group" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="contents-part-article">
        <schema:property name="tag" type="string" const="jp:contents-part-article" />
        <schema:property name="blocks" type="array">
            <schema:ref name="contents-part-group" />
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:contents-part-group 記部
         ====================================================================-->
    <xsl:template match="jp:contents-part-group">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:contents-name" />
                <xsl:apply-templates select="p" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="contents-part-group">
        <schema:property name="tag" type="string" const="jp:contents-part-group" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="contents-name" />
                <schema:ref name="paragraph" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:contents-name 項目名
         ====================================================================-->
    <xsl:template match="jp:contents-name">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【' || . || '】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'2'" />
            </xf:string>
        </xf:map>
    </xsl:template>
    <schema:object
        name="contents-name">
        <schema:property name="tag" type="string" const="jp:contents-name" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
    </schema:object>
    
    <!-- ====================================================================
         jp:presenter-article 提出者の記事
         ====================================================================-->
    <xsl:template match="jp:presenter-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:applicant" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="presenter-article">
        <schema:property name="tag" type="string" const="jp:presenter-article" />
        <schema:property name="blocks" type="array">
            <!-- below ref is included in pat-common-container-type-b.
                 <schema:ref name="applicant" />
            -->
            <schema:ref name="pat-common-container-type-b" />
        </schema:property>
    </schema:object>
    <!-- ====================================================================
         End 補正対象となる審判関連文書の項目
         ====================================================================-->
    
    <!-- ====================================================================
         Begin 意見書関連項目
         ====================================================================-->
    <!-- ====================================================================
         jp:opinion-contents-article 意見の内容
         ====================================================================-->
    <xsl:template match="jp:opinion-contents-article">
        <xsl:param name="document" />
        
        <xsl:variable name="sikibetu">
            <xsl:choose>
                <xsl:when test="parent::jp:contents-of-amendment">
                    <xsl:value-of select="parent::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$document" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="$sikibetu = 'jp:response-a59'">
                        <xsl:value-of select="'【弁明の内容】'" />
                    </xsl:when>
                    <xsl:when test="$sikibetu = 'jp:etcetera-a781'">
                        <xsl:value-of select="'【上申の内容】'" />
                    </xsl:when>
                    <xsl:when test="$sikibetu = 'jp:etcetera-a87'">
                        <xsl:value-of select="'【実施の状況等】'" />
                    </xsl:when>
                    <xsl:when test="$sikibetu = 'jp:etcetera-a871'">
                        <xsl:value-of select="'【早期審査に関する事情説明】'" />
                    </xsl:when>
                    <xsl:when test="$sikibetu = 'jp:etcetera-a872'">
                        <xsl:value-of select="'【補充の内容】'" />
                    </xsl:when>
                    <xsl:when test="$sikibetu = 'jp:amendment-a524'">
                        <xsl:value-of select="'【訂正の理由等】'" />
                    </xsl:when>
                    <xsl:when test="$sikibetu = 'jp:response-a53'">
                        <xsl:value-of select="'【意見の内容】'" />
                    </xsl:when>
                    <xsl:when test="$sikibetu = 'jp:etcetera-a621'">
                        <xsl:value-of select="'【手数料に関する特記事項】'" />
                    </xsl:when>
                    <xsl:when
                        test="$sikibetu = 'jp:etcetera-a623' or $sikibetu = 'jp:etcetera-a624'">
                        <xsl:value-of select="'【請求人の意見】'" />
                    </xsl:when>
                    <xsl:when test="$sikibetu = 'jp:etcetera-a917'">
                        <xsl:value-of select="'【回復の理由】'" />
                    </xsl:when>
                    <xsl:when test="$sikibetu = 'jp:etcetera-a918'">
                        <xsl:value-of select="'【申出の理由】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【特許料等に関する特記事項】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="p" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="opinion-contents-article">
        <schema:property name="tag" type="string" const="jp:opinion-contents-article" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="paragraph" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ====================================================================
         End 意見書関連項目
         ====================================================================-->
    
    <!-- ====================================================================
         Begin 規定外の項目 関連
         ====================================================================-->
    <!-- ====================================================================
         jp:rule-outside-item-article 規定外の項目
         ====================================================================-->
    <xsl:template match="jp:rule-outside-item-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'＊＊＊'" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:rule-outside-group" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="rule-outside-item-article">
        <schema:property name="tag" type="string" const="jp:rule-outside-item-article" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="rule-outside-group" />
        </schema:property>
    </schema:object>
    <!-- ====================================================================
         jp:rule-outside-group 規定外記事
         ====================================================================-->
    <xsl:template match="jp:rule-outside-group">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:item-name" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="rule-outside-group">
        <schema:property name="tag" type="string" const="jp:rule-outside-group" />
        <schema:property name="blocks" type="array">
            <schema:ref name="item-name" />
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:item-name 項目名
         import from <xsl:template name="項目名編集">
         ====================================================================-->
    <xsl:template match="jp:item-name">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【' || . || '】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'0'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="following-sibling::jp:item-content" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="item-name">
        <schema:property name="tag" type="string" const="jp:item-name" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="item-content" />
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:item-content
         ====================================================================-->
    <xsl:template match="jp:item-content">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    <schema:object name="item-content">
        <schema:property name="tag" type="string" const="jp:item-content" />
        <schema:property name="text" type="string" />
    </schema:object>
    <!-- ====================================================================
         End 規定外の項目 関連
         ====================================================================-->
    
    <!-- ====================================================================
         Begin container type B elements have tag, jpTag and blocks.
         ====================================================================-->
    <!-- ====================================================================
         jp:priority-claim パリ優先権主張
         imported from パリ条約による優先権等の主張編集
         ====================================================================-->
    <xsl:template match="jp:priority-claim">
        <!-- <xsl:for-each select="jp:priority-claim"> -->
        <!-- override exsiting $node -->
        <xsl:variable name="node">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:value-of
                        select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- </xsl:for-each> -->
        
        <!--  項目名の編集  -->
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when
                        test="$node = 'jp:withdrawal-abandonment-a765'
                            or $node = 'jp:presentment-a79'">
                        <xsl:value-of select="'【最初の出願の表示】'" />
                    </xsl:when>
                    <xsl:when test="$node = 'jp:etcetera-a916'">
                        <xsl:value-of select="'【提出した優先権証明書】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【パリ条約による優先権等の主張】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="parent::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:country" />
                <xsl:apply-templates select="jp:date" />
                <xsl:apply-templates select="jp:doc-number" />
                <xsl:apply-templates select="jp:ip-type" />
                <xsl:apply-templates select="jp:generated-access-code" />
                <xsl:apply-templates select="jp:priority-doc-location-info" />
                <xsl:apply-templates select="jp:use-of-das" />
                
                <!-- 未サポート -->
                <xsl:if test="office-of-filing">
                    <xsl:apply-templates select="office-of-filing" />
                </xsl:if>
                <xsl:if test="priority-doc-requested">
                    <xsl:apply-templates select="priority-doc-requested" />
                </xsl:if>
                <xsl:if test="priority-doc-attached">
                    <xsl:apply-templates select="priority-doc-attached" />
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:parent-application-article 原出願の表示
         import from <xsl:template name="原出願の表示編集">
         ====================================================================-->
    <xsl:template match="jp:parent-application-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="./@jp:kind-of-application = 'based-on-utility'">
                        <xsl:value-of select="'【基礎とした実用新案登録及びその実用新案登録出願の表示】'" />
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <xsl:value-of select="'【原出願の表示】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates
                    select="jp:application-reference [@appl-type = 'registration']//jp:doc-number" />
                <xsl:apply-templates select="jp:application-reference [@appl-type = 'registration']" />
                <xsl:apply-templates
                    select="jp:application-reference [@appl-type = 'application']//jp:doc-number" />
                <xsl:apply-templates select="jp:application-reference [@appl-type = 'application']" />
                <xsl:apply-templates
                    select="jp:application-reference [@appl-type = 'international-application']//jp:doc-number" />
                <xsl:apply-templates
                    select="jp:application-reference [@appl-type = 'international-application']" />
                <xsl:apply-templates select="jp:file-reference-id" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:earlier-app 先の出願
         import from <xsl:template name="先の出願編集">
         ====================================================================-->
    <xsl:template match="jp:earlier-app">
        <!-- <xsl:param name="node" /> -->
        <!-- override variable $node -->
        <xsl:variable name="node">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:value-of
                        select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="$node = 'jp:withdrawal-abandonment-a764'">
                        <xsl:value-of select="'【先の出願の表示】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【先の出願に基づく優先権主張】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="parent::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates
                    select="jp:application-reference[@appl-type = 'application']//jp:doc-number" />
                <xsl:apply-templates
                    select="jp:application-reference[@appl-type = 'international-application']//jp:doc-number" />
                <xsl:apply-templates select="jp:application-reference" />
                <xsl:apply-templates select="jp:file-reference-id" />
                
                <!-- 未サポート -->
                <xsl:if test=".//country or .//kind or .//name">
                    <xsl:apply-templates select=".//country | .//kind | .//name" />
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:indication-of-case-article 事件の表示
         import from <xsl:template name="事件編集">
         ====================================================================-->
    <xsl:template match="jp:indication-of-case-article">
        
        <!-- override variable $node -->
        <xsl:variable name="node">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:value-of
                        select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="kindlaw">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment/@jp:kind-of-law" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$kind-of-law" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="paym">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="substring(ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-document,1,11)" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="substring(ancestor::jp:contents-of-amendment/@jp:kind-of-document,1,11)" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$payment" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when
                        test="$node = 'jp:application-a631' or $node = 'jp:application-a632' or
                            $node = 'jp:application-a633' or $node = 'jp:application-a634' or
                            $node = 'jp:application-a635' or $node = 'jp:etcetera-a621' or
                            $node = 'jp:etcetera-a623' or $node = 'jp:etcetera-a624' or
                            $node = 'jp:etcetera-a625' or $node = 'jp:etcetera-a626' or
                            $node = 'jp:etcetera-a627' or $node = 'jp:etcetera-a914' or
                            $node = 'jp:amendment-a5210' or $node = 'jp:amendment-a5211' or
                            $node = 'jp:amendment-a5212' or $node = 'jp:amendment-a525' or
                            $node = 'jp:amendment-a526' or $node = 'jp:amendment-a527' or
                            $node = 'jp:amendment-a528' or $node = 'jp:amendment-a529' or
                            $node = 'jp:etcetera-a917' or $node = 'jp:etcetera-a918' or
                            $node = 'jp:etcetera-a919'">
                        <xsl:choose>
                            <xsl:when
                                test="($node = 'jp:etcetera-a623' or $node = 'jp:etcetera-a624') and $kindlaw = 'utility'
                                    and ./jp:application-reference/@appl-type = 'registration'
                                    and string-length(normalize-space(./jp:application-reference/jp:document-id/jp:date)) = 0">
                                <xsl:if
                                    test="./jp:application-reference/@appl-type != 'registration'">
                                    <xsl:value-of select="'【出願の表示】'" />
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'【出願の表示】'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when
                        test="($node = 'jp:demand-e853' or $node = 'jp:demand-e854' or
                                $node = 'jp:demand-e862') or ($paym = 'jp:payment-')">
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when
                                test="($node = 'jp:etcetera-a915') and $kindlaw = 'utility'
                                    and ./jp:application-reference/@appl-type = 'registration'
                                    and string-length(normalize-space(./jp:application-reference/jp:document-id/jp:date)) = 0">
                                <xsl:if
                                    test="./jp:application-reference/@appl-type != 'registration'">
                                    <xsl:value-of select="'【事件の表示】'" />
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'【事件の表示】'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="$node = 'jp:application-a631' or $node = 'jp:application-a632' or
                            $node = 'jp:application-a633' or $node = 'jp:application-a634' or
                            $node = 'jp:application-a635' or $node = 'jp:etcetera-a621' or
                            $node = 'jp:etcetera-a623' or $node = 'jp:etcetera-a624' or
                            $node = 'jp:etcetera-a625' or $node = 'jp:etcetera-a626' or
                            $node = 'jp:etcetera-a627' or $node = 'jp:etcetera-a914' or
                            $node = 'jp:amendment-a5210' or $node = 'jp:amendment-a5211' or
                            $node = 'jp:amendment-a5212' or $node = 'jp:amendment-a525' or
                            $node = 'jp:amendment-a526' or $node = 'jp:amendment-a527' or
                            $node = 'jp:amendment-a528' or $node = 'jp:amendment-a529' or
                            $node = 'jp:etcetera-a917' or $node = 'jp:etcetera-a918' or
                            $node = 'jp:etcetera-a919'">
                        <xsl:choose>
                            <xsl:when
                                test="($node = 'jp:etcetera-a623' or $node = 'jp:etcetera-a624') and $kindlaw = 'utility'
                                    and ./jp:application-reference/@appl-type = 'registration'
                                    and string-length(normalize-space(./jp:application-reference/jp:document-id/jp:date)) = 0">
                                <xsl:choose>
                                    <xsl:when
                                        test="./jp:application-reference/@appl-type != 'registration'">
                                        <xsl:choose>
                                            <xsl:when test="ancestor::jp:contents-of-amendment">
                                                <xsl:value-of select="'2'" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'0'" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'0'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="ancestor::jp:contents-of-amendment">
                                        <xsl:value-of select="'2'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'0'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when
                        test="($node = 'jp:demand-e853' or $node = 'jp:demand-e854' or
                                $node = 'jp:demand-e862') or ($paym = 'jp:payment-')">
                        <xsl:value-of select="'0'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when
                                test="($node = 'jp:etcetera-a915') and $kindlaw = 'utility'
                                    and ./jp:application-reference/@appl-type = 'registration'
                                    and string-length(normalize-space(./jp:application-reference/jp:document-id/jp:date)) = 0">
                                <xsl:choose>
                                    <xsl:when
                                        test="./jp:application-reference/@appl-type != 'registration'">
                                        <xsl:choose>
                                            <xsl:when test="ancestor::jp:contents-of-amendment">
                                                <xsl:value-of select="'2'" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'0'" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'0'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="ancestor::jp:contents-of-amendment">
                                        <xsl:value-of select="'2'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'0'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates
                    select="jp:application-reference[@appl-type = 'international-application']//jp:doc-number" />
                <xsl:apply-templates
                    select="jp:application-reference[@appl-type = 'international-application']//jp:date" />
                <xsl:for-each
                    select="jp:application-reference[@appl-type = 'international-application']">
                    <xsl:call-template name="出願書類参照編集" />
                </xsl:for-each>
                <xsl:apply-templates select="jp:appeal-reference/jp:doc-number" />
                <xsl:apply-templates select="jp:appeal-reference/jp:date" />
                <xsl:apply-templates
                    select="jp:application-reference[@appl-type = 'application']//jp:doc-number" />
                <xsl:apply-templates
                    select="jp:application-reference[@appl-type = 'registration']//jp:doc-number" />
                <xsl:apply-templates
                    select="jp:application-reference[@appl-type = 'examined-pub']//jp:doc-number" />
                <xsl:apply-templates
                    select="jp:application-reference[@appl-type = 'un-examined-pub']//jp:doc-number" />
                <xsl:apply-templates
                    select="jp:application-reference[@appl-type = 'application']//jp:date" />
                <xsl:apply-templates select="jp:file-reference-id" />
                <xsl:apply-templates select="jp:receipt-number" />
                
                <!-- 未サポート -->
                <xsl:if test=".//country or .//kind or .//name">
                    <xsl:apply-templates select=".//country | .//kind | .//name" />
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:application-reference 出願書類参照 
         ====================================================================-->
    <xsl:template
        match="jp:application-reference">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:choose>
                    <xsl:when test="parent::jp:earlier-app or parent::jp:parent-application-article">
                        <xsl:call-template name="出願書類参照編集" />
                        <xsl:if test=".//jp:date">
                            <xsl:choose>
                                <xsl:when test="./@appl-type = 'application'">
                                    <xsl:choose>
                                        <xsl:when
                                            test="
                                                ((./@appl-type='application') and (.//jp:doc-number !='')) or
                                                ((following-sibling::jp:application-reference/@appl-type='application' or
                                                        following-sibling::jp:application-reference/@appl-type='international-application') and
                                                    (following-sibling::jp:application-reference//jp:doc-number !=''))  or
                                                ((preceding-sibling::jp:application-reference/@appl-type='application' or
                                                        preceding-sibling::jp:application-reference/@appl-type='international-application') and
                                                    (preceding-sibling::jp:application-reference//jp:doc-number !=''))">
                                            <xsl:call-template name="先の出願日編集" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:apply-templates select=".//jp:date" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select=".//jp:date" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="jp:document-id/jp:doc-number" />
                        <xsl:call-template name="出願書類参照編集" />
                        <xsl:apply-templates select="jp:document-id/jp:date" />
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- 未サポート -->
                <xsl:if test=".//country or .//kind or .//name">
                    <xsl:apply-templates select=".//country | .//kind | .//name" />
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:submission-object-list-article 提出物件の目録
         ====================================================================-->
    <xsl:template match="jp:submission-object-list-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【提出物件の目録】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:list-group" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:charge-article 手数料の表示
         import from <xsl:template name="手数料の表示編集" />
         ====================================================================-->
    <xsl:template match="jp:charge-article">
        
        <xsl:variable name="kinddoc">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="kind-of-law">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment/@jp:kind-of-law" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$kind-of-law" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="payment">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="substring(ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-document,1,11)" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="substring(ancestor::jp:contents-of-amendment/@jp:kind-of-document,1,11)" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$payment" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="$payment = 'jp:payment-'">
                        <xsl:choose>
                            <xsl:when test="$kind-of-law = 'patent'">
                                <xsl:value-of select="'【特許料の表示】'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'【登録料の表示】'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="ancestor::jp:amendment-charge-article">
                    </xsl:when>
                    <xsl:when test="$kinddoc = 'jp:etcetera-a914'">
                        <xsl:value-of select="'【返還の表示】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【手数料の表示】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="$payment = 'jp:payment-'">
                        <xsl:choose>
                            <xsl:when test="$kind-of-law = 'patent'">
                                <xsl:if test="ancestor::jp:contents-of-amendment">
                                    <xsl:value-of select="'2'" />
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="ancestor::jp:contents-of-amendment">
                                    <xsl:value-of select="'2'" />
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="ancestor::jp:amendment-charge-article">
                        <xsl:value-of select="'0'" />
                    </xsl:when>
                    <xsl:when test="$kinddoc = 'jp:etcetera-a914'">
                        <xsl:choose>
                            <xsl:when test="ancestor::jp:contents-of-amendment">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'0'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="ancestor::jp:contents-of-amendment">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'0'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:payment" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:inventor 発明者
         import from <xsl:template name="発明者編集">
         ====================================================================-->
    <xsl:template match="jp:inventor">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                                <xsl:value-of select="'【発明者】'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                                <xsl:value-of select="'【考案者】'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                                <xsl:value-of select="'【発明者】'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                                <xsl:value-of select="'【考案者】'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$kind-of-law = 'patent'">
                                <xsl:value-of select="'【発明者】'" />
                            </xsl:when>
                            <xsl:when test="$kind-of-law = 'utility'">
                                <xsl:value-of select="'【考案者】'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'0'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select=".//jp:registered-number" />
                <xsl:apply-templates select=".//jp:text" />
                <xsl:apply-templates select=".//jp:kana" />
                <xsl:apply-templates select=".//jp:name" />
                
                <!-- 未サポート -->
                <xsl:if
                    test=".//jp:original-language-of-name or .//prefix or .//last-name
                        or .//first-name or .//midle-name or .//suffix or .//iid or .//role
                        or .//orgname or .//department or .//synonym or .//address-1 or .//address-2
                        or .//address-3 or .//address-4 or .//address-5 or .//mailcode or .//pobox or .//room or .//address-floor
                        or .//building or .//street or .//city or .//county or .//state
                        or .//postcode or .//jp:address/country or .//jp:original-language-of-address
                        or .//jp:phone or .//jp:fax or .//email or .//url or .//ead or .//dtext
                        or .//text or designated-states">
                    <xsl:apply-templates
                        select=".//jp:original-language-of-name | .//prefix | .//last-name
                            | .//first-name | .//midle-name | .//suffix | .//iid | .//role
                            | .//orgname | .//department | .//synonym
                            | .//address-1 | .//address-2 | .//address-3 | .//address-4 | .//address-5 | .//mailcode
                            | .//pobox | .//room | .//address-floor | .//building
                            | .//street | .//city | .//county | .//state | .//postcode
                            | .//jp:address/country | .//jp:original-language-of-address
                            | .//jp:phone | .//jp:fax | .//email | .//url | .//ead | .//dtext
                            | .//text | designated-states" />
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:applicant 申請者
         import from <xsl:template name="申請者前編集">
         ====================================================================-->
    <xsl:template match="jp:applicant">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xsl:choose>
                <xsl:when test="ancestor::jp:presenter-article">
                    <xf:string key="jpTag">
                        <xsl:value-of select="'【提出者】'" />
                    </xf:string>
                    <xf:string key="indentLevel">
                        <xsl:value-of select="'2'" />
                    </xf:string>
                </xsl:when>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:call-template name="申請者編集">
                        <xsl:with-param name="code">
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                                    <xsl:value-of
                                        select="normalize-space(ancestor::jp:amendment-group//jp:contents-of-amendment/jp:amendment-group/jp:document-code)" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="normalize-space(ancestor::jp:amendment-group/jp:document-code)" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="申請者編集">
                        <xsl:with-param name="code" select="normalize-space($doc-code)" />
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:relation-of-case" />
                <xsl:if test="ancestor::jp:applicants or ancestor::jp:presenter-article">
                    <xsl:apply-templates select="jp:share" />
                    <xsl:apply-templates select="jp:representative-applicant" />
                </xsl:if>
                <xsl:apply-templates select=".//jp:registered-number" />
                <xsl:apply-templates select=".//jp:text" />
                <xsl:if test="ancestor::jp:applicants or ancestor::jp:presenter-article">
                    <xsl:apply-templates select=".//jp:original-language-of-address" />
                </xsl:if>
                <xsl:apply-templates select="jp:addressbook/jp:kana" />
                <xsl:apply-templates select="jp:addressbook/jp:name" />
                <xsl:if test="ancestor::jp:applicants or ancestor::jp:presenter-article">
                    <xsl:apply-templates select="jp:addressbook/jp:original-language-of-name" />
                </xsl:if>
                <xsl:if test="ancestor::jp:applicants or ancestor::jp:presenter-article">
                    <xsl:apply-templates select="jp:office-address" />
                    <xsl:apply-templates select="jp:office-in-japan" />
                    <xsl:apply-templates select="jp:office" />
                </xsl:if>
                <xsl:apply-templates select="jp:representative-group" />
                <xsl:if test="ancestor::jp:applicants or ancestor::jp:presenter-article">
                    <xsl:apply-templates select="jp:legal-entity-property" />
                </xsl:if>
                <xsl:apply-templates select="jp:nationality" />
                <xsl:apply-templates select=".//jp:phone" />
                <xsl:apply-templates select=".//jp:fax" />
                <xsl:apply-templates select="jp:contact" />
                
                <!-- 未サポート -->
                <xsl:if
                    test=".//prefix or .//last-name or .//first-name or .//midle-name
                        or .//suffix or .//iid or .//role or .//orgname or .//department
                        or .//synonym or .//address-1 or .//address-2 or .//address-3 or .//address-4 or .//address-5
                        or .//mailcode or .//pobox or .//room or .//address-floor
                        or .//building or .//street or .//city or .//county or .//state
                        or .//postcode or .//jp:address/country or .//email or .//url or .//ead or .//dtext
                        or .//text or residence
                        or us-rights or designated-states or designated-states-as-inventor
                        or (ancestor::jp:applicant-of-case-article and jp:share)
                        or (ancestor::jp:applicant-of-case-article and jp:representative-applicant)
                        or (ancestor::jp:applicant-of-case-article and .//jp:original-language-of-address)
                        or (ancestor::jp:applicant-of-case-article and jp:addressbook/jp:original-language-of-name)
                        or (ancestor::jp:applicant-of-case-article and jp:office-address)
                        or (ancestor::jp:applicant-of-case-article and jp:office-in-japan)
                        or (ancestor::jp:applicant-of-case-article and jp:office)
                        or (ancestor::jp:applicant-of-case-article and jp:representative-group/jp:original-language-of-name)
                        or (ancestor::jp:applicant-of-case-article and jp:legal-entity-property) ">
                    <xsl:if test="ancestor::jp:applicant-of-case-article">
                        <xsl:apply-templates
                            select="jp:share | jp:representative-applicant
                                | jp:addressbook/jp:original-language-of-name" />
                    </xsl:if>
                    <xsl:apply-templates
                        select=".//prefix | .//last-name | .//first-name | .//midle-name
                            | .//suffix | .//iid | .//role | .//orgname | .//department
                            | .//synonym" />
                    <xsl:apply-templates
                        select=".//address-1 | .//address-2 | .//address-3 | .//address-4 | .//address-5 | .//mailcode
                            | .//pobox | .//room | .//address-floor | .//building
                            | .//street | .//city | .//county | .//state | .//postcode
                            | .//jp:address/country" />
                    <xsl:if test="ancestor::jp:applicant-of-case-article">
                        <xsl:apply-templates select=".//jp:original-language-of-address" />
                    </xsl:if>
                    <xsl:apply-templates select=".//email | .//url | .//ead | .//dtext | .//text" />
                    <xsl:if test="ancestor::jp:applicant-of-case-article">
                        <xsl:apply-templates select="jp:office-address | jp:office-in-japan | jp:office" />
                    </xsl:if>
                    <xsl:if
                        test="ancestor::jp:applicant-of-case-article
                            and jp:representative-group//jp:original-language-of-name">
                        <xsl:apply-templates
                            select="jp:representative-group//jp:original-language-of-name" />
                    </xsl:if>
                    <xsl:if test="ancestor::jp:applicant-of-case-article">
                        <xsl:apply-templates select="jp:legal-entity-property" />
                    </xsl:if>
                    <xsl:apply-templates
                        select="residence | us-rights
                            | designated-states | designated-states-as-inventor" />
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:agent 代理人
         import from <xsl:template name="代理人前編集">
         ====================================================================-->
    <xsl:template match="jp:agent">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            
            <!-- jpTag, indentLevel -->
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:call-template name="代理人編集">
                        <xsl:with-param name="code">
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                                    <xsl:value-of
                                        select="normalize-space(ancestor::jp:amendment-group//jp:contents-of-amendment/jp:amendment-group/jp:document-code)" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="normalize-space(ancestor::jp:amendment-group/jp:document-code)" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="代理人編集">
                        <xsl:with-param name="code" select="normalize-space($doc-code)" />
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xf:array key="blocks">
                <xsl:apply-templates select=".//jp:registered-number" />
                <xsl:apply-templates select=".//jp:text" />
                <xsl:apply-templates select="jp:attorney" />
                <xsl:apply-templates select="jp:lawyer" />
                <xsl:apply-templates select="jp:addressbook/jp:kana" />
                <xsl:apply-templates select="jp:addressbook/jp:name" />
                <xsl:choose>
                    <xsl:when test="ancestor::jp:attorney-of-case-article">
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="jp:office-address" />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="jp:representative-group" />
                <xsl:apply-templates select=".//jp:phone" />
                <xsl:apply-templates select=".//jp:fax" />
                <xsl:apply-templates select="jp:contact" />
                <xsl:apply-templates select="jp:relation-attorney-special-matter" />
                
                <!-- 未サポート -->
                <xsl:if
                    test="customer-number or jp:addressbook/jp:original-language-of-name
                        or .//prefix or .//last-name or .//first-name or .//midle-name or .//suffix
                        or .//iid or .//role or .//orgname or .//department or .//synonym
                        or .//address-1 or .//address-2 or .//address-3 or .//address-4 or .//address-5 or .//mailcode or .//pobox
                        or .//room or .//address-floor or .//building or .//street or .//city
                        or .//county or .//state or .//postcode or .//jp:address/country
                        or .//jp:original-language-of-address or .//email or .//url or .//ead
                        or .//dtext or .//text or jp:representative-group//jp:original-language-of-name
                        or (ancestor::jp:attorney-of-case-article and jp:office-address)">
                    <xsl:apply-templates
                        select="customer-number | jp:addressbook/jp:original-language-of-name
                            | .//prefix | .//last-name | .//first-name | .//midle-name
                            | .//suffix | .//iid | .//role | .//orgname | .//department
                            | .//synonym
                            | .//address-1 | .//address-2 | .//address-3 | .//address-4 | .//address-5 | .//mailcode
                            | .//pobox | .//room | .//address-floor | .//building
                            | .//street | .//city | .//county | .//state | .//postcode
                            | .//jp:address/country | .//jp:original-language-of-address" />
                    <xsl:apply-templates select=".//email | .//url | .//ead | .//dtext | .//text" />
                    <xsl:if test="ancestor::jp:attorney-of-case-article">
                        <xsl:apply-templates select="jp:office-address" />
                    </xsl:if>
                    <xsl:if test="jp:representative-group//jp:original-language-of-name">
                        <xsl:apply-templates
                            select="jp:representative-group//jp:original-language-of-name" />
                    </xsl:if>
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="pat-common-container-type-b">
        <schema:property
            name="tag" type="string"
                   enum="jp:priority-claim,
                         jp:parent-application-article,
                         jp:indication-of-case-article,
                         jp:application-reference,
                         jp:earlier-app,
                         jp:submission-object-list-article,
                         jp:charge-article,
                         jp:inventor,
                         jp:applicant,
                         jp:agent" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <!-- below refs are included in pat-common-terminal-type-a, so commented out here to avoid duplication
                     <schema:ref name="kana" />
                     <schema:ref name="name" />
                     <schema:ref name="office-address" />
                     <schema:ref name="office-in-japan" />
                     <schema:ref name="office" />
                     <schema:ref name="text" />
                     <schema:ref name="share" />
                     <schema:ref name="registered-number" />
                     <schema:ref name="contact" />
                     <schema:ref name="original-language-of-name" />
                     <schema:ref name="relation-attorney-special-matter" />
                     <schema:ref name="legal-entity-property" />
                     <schema:ref name="relation-of-case" />
                     <schema:ref name="representative-applicant" />
                     <schema:ref name="country" />
                     <schema:ref name="date" />
                     <schema:ref name="doc-number" />
                     <schema:ref name="ip-type" />
                     <schema:ref name="generated-access-code" />
                     <schema:ref name="file-reference-id" />
                     <schema:ref name="use-of-das" />
                     <schema:ref name="receipt-number" />
                     <schema:ref name="shutugan-kubun" />
                -->
                <schema:ref name="pat-common-terminal-type-a" />
                
                <!-- below ref is included in pat-common-container-type-a, so commented out here to avoid duplication
                     <schema:ref name="nationality" />
                     <schema:ref name="list-group" />
                     <schema:ref name="priority-doc-location-info" />
                     <schema:ref name="payment" />
                     <schema:ref name="representative-group" />
                -->
                <schema:ref name="pat-common-container-type-a" />
                
                <!-- below ref is included in pat-common-container-type-b.
                     called as child by earlier-app
                     <schema:ref name="application-reference" />
                -->
                <schema:ref name="pat-common-container-type-b" />
                
                <schema:ref name="attorney" />
                <schema:ref name="lawyer" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ====================================================================
         End container type b
         ====================================================================-->
    
    <!-- ====================================================================
         jp:lawyer 弁護士
         jp:attorney 弁理士
         ====================================================================-->
    <xsl:template match="jp:lawyer | jp:attorney">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="self::jp:attorney">
                        <xsl:value-of select="'【弁理士】'" />
                    </xsl:when>
                    <xsl:when test="self::jp:lawyer">
                        <xsl:value-of select="'【弁護士】'" />
                    </xsl:when>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="(ancestor::jp:attorney-disappear-article
                                or ancestor::jp:attorney-change-article)
                            and ($node = 'jp:attorney-a7421' or $node = 'jp:attorney-a7423'
                                or $node = 'jp:attorney-a7425' or $node = 'jp:attorney-a7426'
                                or $node = 'jp:attorney-a7427' or $node = 'jp:attorney-a7428'
                                or $node = 'jp:attorney-a7431' or $node = 'jp:attorney-a7433'
                                or $node = 'jp:attorney-a7435' or $node = 'jp:attorney-a7436'
                                or $node = 'jp:attorney-a7437') ">
                        <xsl:value-of select="'3'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'2'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    <schema:object
        name="lawyer">
        <schema:property name="tag" type="string" const="jp:lawyer" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
    </schema:object>
    <schema:object
        name="attorney">
        <schema:property name="tag" type="string" const="jp:attorney" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
    </schema:object>
    
    <!-- ====================================================================
         Begin 明細書系
         ===================================================================-->
    <!-- ====================================================================
         claims 請求の範囲 
         ====================================================================-->
    <xsl:template match="claims">
        <xf:map>
            <xf:string key="tag">claims</xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                                <xsl:value-of select="'【書類名】特許請求の範囲'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                                <xsl:value-of select="'【書類名】実用新案登録請求の範囲'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                                <xsl:value-of select="'【書類名】特許請求の範囲'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                                <xsl:value-of select="'【書類名】実用新案登録請求の範囲'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$kind-of-law = 'patent'">
                                <xsl:value-of select="'【書類名】特許請求の範囲'" />
                            </xsl:when>
                            <xsl:when test="$kind-of-law = 'utility'">
                                <xsl:value-of select="'【書類名】実用新案登録請求の範囲'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'【書類名】請求の範囲'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="claim" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="claims">
        <schema:property name="tag" type="string" const="claims" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="claim" />
        </schema:property>
    </schema:object>
    <!-- ======================= End of claims ======================== -->
    
    <!-- ====================================================================
         claim 請求項 
         ====================================================================-->
    <xsl:template match="claim">
        <xf:map>
            <xf:string key="tag">claim</xf:string>
            <xf:string key="jpTag">【請求項<xsl:apply-templates select="@num" />】</xf:string>
            <xf:string key="number">
                <xsl:value-of select="@num" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:boolean key="isIndependent">
                <xsl:choose>
                    <xsl:when test="claim-text[contains(., '請求項')]">false</xsl:when>
                    <xsl:otherwise>true</xsl:otherwise>
                </xsl:choose>
            </xf:boolean>
            <xf:array key="blocks">
                <xsl:apply-templates select="claim-text" />
                <!-- 未サポート -->
                <xsl:if test="doc-page">
                    <xsl:apply-templates select="doc-page" />
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="claim">
        <schema:property name="tag" type="string" const="claim" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="number" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="isIndependent" type="boolean" />
        <schema:property name="blocks" type="array">
            <schema:ref name="claim-text" />
        </schema:property>
    </schema:object>
    <!-- ======================= End of claim ======================== -->
    
    <!-- ====================================================================
         claim-text 請求項内段落
         ====================================================================-->
    <xsl:template match="claim-text">
        <xf:map>
            <xf:string key="tag">claim-text</xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="claim-text">
        <schema:property name="tag" type="string" const="claim-text" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="inline-text" />
                <schema:ref name="image-container" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ======================= End of claim-text ======================== -->
    
    
    <!-- ====================================================================
         description 明細書
         ====================================================================-->
    <xsl:template match="description">
        <xf:map>
            <xf:string key="tag">description</xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【書類名】明細書'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates
                    select="invention-title | technical-field | background-art | disclosure
                        | mode-for-invention | description-of-drawings  | summary-of-invention
                        | description-of-embodiments | best-mode | industrial-applicability
                        | reference-signs-list | reference-to-deposited-biological-material
                        | sequence-list-text | citation-list | heading | p" />
                <!-- 未サポート -->
                <xsl:if test="doc-page">
                    <xsl:apply-templates select="doc-page" />
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="description">
        <schema:property name="tag" type="string" const="description" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="invention-title" />
                <schema:ref name="summary-of-invention" />
                <schema:ref name="description-items" />
                <schema:ref name="citation-list" />
                <schema:ref name="description-of-embodiments" />
                
                <!-- xsl では mode-for-invention だが、
                     schema では embodiments-example に纏めている -->
                <schema:ref name="embodiments-example" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ======================= End of description ======================== -->
    
    <!-- ====================================================================
         invention-title 発明の名称
         import from <xsl:template name="発明の名称編集">
         ====================================================================-->
    <xsl:template match="invention-title">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                                <xsl:value-of select="'【発明の名称】'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                                <xsl:value-of select="'【考案の名称】'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                                <xsl:value-of select="'【発明の名称】'" />
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                                <xsl:value-of select="'【考案の名称】'" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$kind-of-law = 'patent'">
                                <xsl:value-of select="'【発明の名称】'" />
                            </xsl:when>
                            <xsl:when test="$kind-of-law = 'utility'">
                                <xsl:value-of select="'【考案の名称】'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'【発明の名称】'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="invention-title">
        <schema:property name="tag" type="string"
                         const="invention-title" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="inline-text" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ======================= End of invention-title ======================== -->
    
    <!-- ====================================================================
         summary-of-invention 発明の概要
         ====================================================================-->
    <xsl:template match="summary-of-invention | disclosure">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:call-template name="summary-of-invention-jpTag">
                    <xsl:with-param name="summary-or-disclosure" select="name()" />
                </xsl:call-template>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates
                    select="tech-problem | tech-solution | advantageous-effects | heading | p" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <xsl:template name="summary-of-invention-jpTag">
        <xsl:param name="summary-or-disclosure" />
        <xsl:variable name="summary-or-disclosure-text">
            <xsl:choose>
                <xsl:when test="$summary-or-disclosure = 'summary-of-invention'">
                    <xsl:value-of select="'概要'" />
                </xsl:when>
                <xsl:when test="$summary-or-disclosure = 'disclosure'">
                    <xsl:value-of select="'開示'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="patent-or-utility">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                            <xsl:value-of select="'発明'" />
                        </xsl:when>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                            <xsl:value-of select="'考案'" />
                        </xsl:when>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                            <xsl:value-of select="'発明'" />
                        </xsl:when>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                            <xsl:value-of select="'考案'" />
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$kind-of-law = 'patent'">
                            <xsl:value-of select="'発明'" />
                        </xsl:when>
                        <xsl:when test="$kind-of-law = 'utility'">
                            <xsl:value-of select="'考案'" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'発明'" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of
            select="'【' || $patent-or-utility || 'の' || $summary-or-disclosure-text || '】'" />
    </xsl:template>
    <schema:object name="summary-of-invention">
        <schema:property name="tag" type="string"
                         enum="summary-of-invention disclosure" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="summary-of-invention-items" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ======================= End of summary-of-invention ======================== -->
    
    <!-- ===================================================================
         description item type contains
         tag, jpTag, indentLevel=0 or 2 depends on amendments, and text="."
         =================================================================== -->
    <xsl:template match="technical-field | background-art | description-of-drawings |
        industrial-applicability | sequence-list-text | reference-signs-list |
        reference-to-deposited-biological-material">
        <xsl:variable name="params"
            select="key('description-items-key', name(), $description-items-parameters)" />
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="$params/@jpTag" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="$params/@indentLevel-amendment" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$params/@indentLevel" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="p" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <xsl:key name="description-items-key" match="parameter" use="@tag" />
    <xsl:variable name="description-items-parameters">
        <parameter tag="technical-field" jpTag="【技術分野】" indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="background-art" jpTag="【背景技術】" indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="description-of-drawings" jpTag="【図面の簡単な説明】" indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="industrial-applicability" jpTag="【産業上の利用可能性】" indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="sequence-list-text" jpTag="【配列リストテキスト】" indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="reference-signs-list" jpTag="【符号の説明】" indentLevel="0"
                   indentLevel-amendment="2" />
        <parameter tag="reference-to-deposited-biological-material" jpTag="【受託番号】" indentLevel="0"
                   indentLevel-amendment="2" />
    </xsl:variable>
    <schema:object name="description-items">
        <schema:property name="tag" type="string"
                         enum="technical-field background-art description-of-drawings industrial-applicability
                               sequence-list-text reference-signs-list reference-to-deposited-biological-material" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="paragraph" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ======================= End of description-items ======================== -->
    
    <!-- ===================================================================
         tech-problem 発明が解決しようとする課題
         tech-solutions 課題を解決するための手段
         advantageous-effects 発明の効果
         =================================================================== -->
    <xsl:template match="tech-problem | tech-solutions | advantageous-effects">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:call-template name="summary-of-invention-items-jpTag">
                    <xsl:with-param name="tag" select="name()" />
                </xsl:call-template>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="p" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <xsl:template name="summary-of-invention-items-jpTag">
        <xsl:param name="tag" />
        <xsl:variable name="law-text">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                            <xsl:value-of select="'発明'" />
                        </xsl:when>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                            <xsl:value-of select="'考案'" />
                        </xsl:when>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                            <xsl:value-of select="'発明'" />
                        </xsl:when>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                            <xsl:value-of select="'考案'" />
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$kind-of-law = 'patent'">
                            <xsl:value-of select="'発明'" />
                        </xsl:when>
                        <xsl:when test="$kind-of-law = 'utility'">
                            <xsl:value-of select="'考案'" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'発明'" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when
                test="$tag = 'tech-problem'">
                <xsl:value-of select="'【' || $law-text || 'が解決しようとする課題】'" />
            </xsl:when>
            <xsl:when
                test="$tag = 'tech-solution'">
                <xsl:value-of select="'【課題を解決するための手段】'" />
            </xsl:when>
            <xsl:when
                test="$tag = 'advantageous-effects'">
                <xsl:value-of select="'【' || $law-text || 'の効果】'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <schema:object name="summary-of-invention-items">
        <schema:property name="tag" type="string"
                         enum="tech-problem tech-solutions advantageous-effects heading paragraph" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="paragraph" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ==== End of tech-problem | tech-solutions | advantageous-effects == -->
    
    <!-- ====================================================================
         citation-list 先行技術文献
         ====================================================================-->
    <xsl:template match="citation-list">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【先行技術文献】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="patent-literature | non-patent-literature | p" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="citation-list">
        <schema:property name="tag" type="string"
                         const="citation-list" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="literature" />
                <schema:ref name="paragraph" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ======================= End of citation-list ======================== -->
    
    <!-- ====================================================================
         patent-literature 特許文献
         non-patent-literature 非特許文献 
         ====================================================================-->
    <xsl:template match="patent-literature | non-patent-literature">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when
                        test="name() = 'patent-literature'">
                        <xsl:value-of select="'【特許文献】'" />
                    </xsl:when>
                    <xsl:when
                        test="name() = 'non-patent-literature'">
                        <xsl:value-of select="'【非特許文献】'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【unknown】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="p" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <schema:object name="literature">
        <schema:property name="tag" type="string"
                         enum="patent-literature non-patent-literature" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="paragraph" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ======================= End of patent-literature ======================== -->
    
    <!-- ====================================================================
         description-of-embodiments 発明を実施するための形態
         best-mode 発明を実施するための最良の形態
         ====================================================================-->
    <xsl:template match="description-of-embodiments | best-mode">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:call-template name="description-of-embodiments-jpTag">
                    <xsl:with-param name="description-of-embodiments-or-best-mode" select="name()" />
                </xsl:call-template>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="embodiments-example | p" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <xsl:template name="description-of-embodiments-jpTag">
        <xsl:param name="description-of-embodiments-or-best-mode" />
        
        <xsl:variable name="second-part">
            <xsl:choose>
                <xsl:when
                    test="$description-of-embodiments-or-best-mode = 'description-of-embodiments'">
                    <xsl:value-of select="'を実施するための形態'" />
                </xsl:when>
                <xsl:when test="$description-of-embodiments-or-best-mode = 'best-mode'">
                    <xsl:value-of select="'を実施するための最良の形態'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="first-part">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                            <xsl:value-of select="'発明'" />
                        </xsl:when>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                            <xsl:value-of select="'考案'" />
                        </xsl:when>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'patent'">
                            <xsl:value-of select="'発明'" />
                        </xsl:when>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment/@jp:kind-of-law = 'utility'">
                            <xsl:value-of select="'考案'" />
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$kind-of-law = 'patent'">
                            <xsl:value-of select="'発明'" />
                        </xsl:when>
                        <xsl:when test="$kind-of-law = 'utility'">
                            <xsl:value-of select="'考案'" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'発明'" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of
            select="'【' || $first-part || $second-part || '】'" />
    </xsl:template>
    <schema:object name="description-of-embodiments">
        <schema:property name="tag" type="string"
                         enum="description-of-embodiments best-mode" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="embodiments-example" />
                <schema:ref name="paragraph" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ======================= End of description-of-embodiments ======================== -->
    
    <!-- ====================================================================
         embodiments-example 実施例 
         mode-for-invention  実施例
         ====================================================================-->
    <xsl:template match="embodiments-example | mode-for-invention">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【実施例'" />
                <xsl:choose>
                    <xsl:when test="./@ex-num">
                        <xsl:apply-templates select="@ex-num" />
                    </xsl:when>
                    <xsl:when test="./@mode-num">
                        <xsl:apply-templates select="@mode-num" />
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of select="'】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="p" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="embodiments-example">
        <schema:property name="tag" type="string"
                         enum="embodiments-example mode-for-invention" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="paragraph" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    <!-- ======================= End of embodiments-example ======================== -->
    
    <!-- ====================================================================
         drawings 図面
         ====================================================================-->
    <xsl:template match="drawings">
        <xf:map>
            <xf:string key="tag">drawings</xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【書類名】図面'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="figure" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="drawings">
        <schema:property name="tag" type="string" const="drawings" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="figure" />
        </schema:property>
    </schema:object>
    <!-- ======================= End of drawings ======================== -->
    
    <!-- ====================================================================
         abstract 要約書
         ====================================================================-->
    <xsl:template match="abstract">
        <xf:map>
            <xf:string key="tag">abstract</xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【書類名】要約書'" />
            </xf:string>
            <xf:string key="text">
                <xsl:call-template name="trim">
                    <xsl:with-param name="text" select="." />
                </xsl:call-template>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <!-- 未サポート -->
                <xsl:if test="doc-page or abst-problem or abst-solution">
                    <xsl:apply-templates select="doc-page | abst-problem | abst-solution" />
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <schema:object
        name="abstract">
        <schema:property name="tag" type="string" const="abstract" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="text" type="string" />
    </schema:object>
    <!-- ======================= End of abstract ======================== -->
    
    
    <!-- ====================================================================
         figure 図
         ====================================================================-->
    <xsl:template match="figure">
        <!-- figref[@num=@num] だと集合値の比較なので失敗する 
             変数にすると単一値の比較になるので意図通りになる
             figref[@num=current()/@num] でも可 -->
        <xsl:variable name="num" select="@num" />
        <xsl:variable name="image-file" select="img/@file" />
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="'figures'" />
            </xf:string>
            <xf:string key="number">
                <xsl:value-of select="@num" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【図'" />
                <xsl:apply-templates select="@num" />
                <xsl:value-of select="'】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="alt">
                <xsl:value-of select="name() || ' No. ' || @num || ' '" />
                <xsl:value-of
                    select="//description-of-drawings//figref[@num=$num]" />
            </xf:string>
            <xf:boolean key="representative">
                <xsl:choose>
                    <xsl:when
                        test="//jp:procedure//jp:representation-image/jp:file-name = $image-file">
                        true</xsl:when>
                    <xsl:otherwise>false</xsl:otherwise>
                </xsl:choose>
            </xf:boolean>
            <xf:array key="blocks">
                <xsl:apply-templates select="img" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="figure">
        <schema:property name="tag" type="string" const="figures" />
        <schema:property name="number" type="string" />
        <schema:property name="jpTag" type="string" optional="true" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="alt" type="string" />
        <schema:property name="representative" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="image" />
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         p 段落 ,段落内テキスト
         ====================================================================-->
    <xsl:template match="p">
        <xf:map>
            <xf:string key="tag">paragraph</xf:string>
            <xf:string key="number">
                <xsl:value-of select="@num" />
            </xf:string>
            <xsl:if test="normalize-space(@num) != ''">
                <xf:string key="jpTag">
                    <xsl:value-of select="'【' || f:to-fullwidth-digit(@num) || '】'" />
                </xf:string>
            </xsl:if>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'1'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates />
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object name="paragraph">
        <schema:property name="tag" type="string" const="paragraph" />
        <schema:property name="number" type="string" />
        <schema:property name="jpTag" type="string" optional="true" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref name="inline-text" />
                <schema:ref name="inline-text-with-header" />
                <schema:ref name="image-container" />
                <schema:ref name="other-images" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!--  inline text under paragraph   -->
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
            <xf:map>
                <xf:string key="tag">
                    <xsl:value-of select="$tag" />
                </xf:string>
                <xf:string key="text">
                    <xsl:call-template name="trim">
                        <xsl:with-param name="text" select="." />
                    </xsl:call-template>
                </xf:string>
                <xf:boolean key="isLastSentence">
                    <xsl:value-of select="$isLastSentence" />
                </xf:boolean>
            </xf:map>
        </xsl:if>
    </xsl:template>
    <schema:object name="inline-text">
        <schema:property name="tag" type="string" enum="text sup sub underline" />
        <schema:property name="text" type="string" />
        <schema:property name="isLastSentence" type="boolean" />
    </schema:object>
    
    <!-- ====================================================================
         figref 図の説明
         patcit 特許文献
         nplcit 非特許文献
         ====================================================================-->
    <xsl:template match="description//figref | jp:contents-of-amendment//figref |
        description//patcit | jp:contents-of-amendment//patcit |
        description//nplcit | jp:contents-of-amendment//nplcit">
        <xsl:variable name="params"
            select="key('inline-text-with-header-key', name(), $inline-text-with-header-parameters)" />
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="number">
                <xsl:value-of select="@num" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="$params/@jpTag" />
                <xsl:apply-templates select="@num" />
                <xsl:value-of select="'】'" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
            <xf:string key="indentLevel">2</xf:string>
        </xf:map>
    </xsl:template>
    
    <xsl:key name="inline-text-with-header-key" match="parameter" use="@tag" />
    <xsl:variable name="inline-text-with-header-parameters">
        <parameter tag="figref" jpTag="【図" />
        <parameter tag="patcit" jpTag="【特許文献" />
        <parameter tag="nplcit" jpTag="【非特許文献" />
    </xsl:variable>
    <schema:object name="inline-text-with-header">
        <schema:property name="tag" type="string"
                         enum="figref patcit nplcit" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="number" type="string" />
        <schema:property name="text" type="string" />
        <schema:property name="indentLevel" type="string" />
    </schema:object>
    <!-- ============= End of inline-text-with-header ============================= -->
    
    
    <!-- ====================================================================
         tables 表
         maths 数式 
         chemistry 化学式
         ====================================================================-->
    <xsl:template match="application-body//tables | jp:contents-of-amendment//tables |
        application-body//maths | jp:contents-of-amendment//maths |
        application-body//chemistry | jp:contents-of-amendment//chemistry">
        <xsl:variable name="params"
            select="key('image-container-key', name(), $image-container-parameters)" />
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="$params/@tag2" />
            </xf:string>
            <xf:string key="number">
                <xsl:value-of select="@num" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="$params/@jpTag" />
                <xsl:apply-templates select="@num" />
                <xsl:value-of select="'】'" />
            </xf:string>
            <xf:string key="indentLevel">2</xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="img" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <xsl:key name="image-container-key" match="parameter" use="@tag" />
    <xsl:variable name="image-container-parameters">
        <parameter tag="tables" tag2="tables" jpTag="【表" />
        <parameter tag="maths" tag2="equations" jpTag="【数" />
        <parameter tag="chemistry" tag2="chemical-formulas" jpTag="【化" />
    </xsl:variable>
    <schema:object name="image-container">
        <schema:property name="tag" type="string"
                         enum="tables equations chemical-formulas" />
        <schema:property name="jpTag" type="string" />
        <schema:property name="number" type="string" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="blocks" type="array">
            <schema:ref name="image" />
        </schema:property>
    </schema:object>
    <!-- ============= End of image-container ============================= -->
    
    
    <!-- 変換元XMLにある images/image のlookup -->
    <xsl:key name="images-table-key" match="/root/images/image" use="@orig-filename" />
    
    <!-- maths, tables, figure, chemistry 下の img -->
    <xsl:template match="maths/img | tables/img | figure/img | chemistry/img">
        <xsl:for-each select="key('images-table-key', @file)">
            <xf:map>
                <xf:string key="src">
                    <xsl:value-of select="@new" />
                </xf:string>
                <xf:number key="width">
                    <xsl:value-of select="@width" />
                </xf:number>
                <xf:number key="height">
                    <xsl:value-of select="@height" />
                </xf:number>
                <xf:string key="kind">
                    <xsl:value-of select="@kind" />
                </xf:string>
                <xf:string key="size-tag">
                    <xsl:value-of select="@sizeTag" />
                </xf:string>
            </xf:map>
        </xsl:for-each>
    </xsl:template>
    <schema:object name="image">
        <schema:property name="tag" type="string"
                         const="image" />
        <schema:property name="src" type="string" />
        <schema:property name="width" type="string" />
        <schema:property name="height" type="string" />
        <schema:property name="kind" type="string" />
        <schema:property name="size-tag" type="string" />
    </schema:object>
    
    <!-- paragraph 下の img -->
    <xsl:template match="p/img">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="'other-images'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:value-of select="'0'" />
            </xf:string>
            
            <xf:array key="images">
                <xsl:for-each select="key('images-table-key', @file)">
                    <xf:map>
                        <xf:string key="src">
                            <xsl:value-of select="@new" />
                        </xf:string>
                        <xf:number key="width">
                            <xsl:value-of select="@width" />
                        </xf:number>
                        <xf:number key="height">
                            <xsl:value-of select="@height" />
                        </xf:number>
                        <xf:string key="kind">
                            <xsl:value-of select="@kind" />
                        </xf:string>
                        <xf:string key="size-tag">
                            <xsl:value-of select="@sizeTag" />
                        </xf:string>
                    </xf:map>
                </xsl:for-each>
            </xf:array>
        </xf:map>
    </xsl:template>
    <schema:object
        name="other-images">
        <schema:property name="tag" type="string"
                         const="other-images" />
        <schema:property name="indentLevel" type="string" />
        <schema:property name="images" type="array">
            <schema:ref name="image" />
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         数字系属性の全角変換
         ====================================================================-->
    <xsl:template match="@num | @mode-num | @ex-num">
        <xsl:value-of select="f:to-fullwidth-alnum(.)" />
    </xsl:template>
    
    <!-- ====================================================================
         heading
         import from <xsl:template name="既定外項目名編集">
         
         xsl, xsd に定義あるけど、実データで確認できていない。
         当面はずす。
         ====================================================================
         <xsl:template
         match="heading">
         <xf:map>
         <xf:string key="tag">
         <xsl:value-of select="name()" />
         </xf:string>
         <xf:string key="jpTag">
         <xsl:value-of select="'【' || . || '】'" />
         </xf:string>
         <xf:string key="indentLevel">
         <xsl:choose>
         <xsl:when
         test="ancestor::jp:contents-of-amendment">
         <xsl:value-of select="'2'" />
         </xsl:when>
         <xsl:otherwise>
         <xsl:value-of select="'0'" />
         </xsl:otherwise>
         </xsl:choose>
         </xf:string>
         </xf:string>
         </xsl:template>
    --> 
    
    <!-- Begin: template-name =============================================-->
    <!-- ====================================================================
         整理番号項目名編集
         ====================================================================-->
    <xsl:template
        name="整理番号項目名編集">
        <xsl:variable name="kinddoc">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:value-of select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="c-payment">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:value-of
                        select="substring(ancestor::jp:contents-of-amendment/@jp:kind-of-document,1,11)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$payment" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when
                test="parent::jp:contents-of-amendment
                    and ancestor::jp:appeal-article">
                <xf:string key="jpTag">
                    <xsl:value-of select="'【整理番号】'" />
                </xf:string>
                <xf:string key="indentLevel">
                    <xsl:value-of select="'2'" />
                </xf:string>
            </xsl:when>
            
            <xsl:when test="ancestor::jp:contents-of-amendment">
                <xf:string key="jpTag">
                    <xsl:choose>
                        <xsl:when test="parent::jp:amendment-group">
                            <xsl:choose>
                                <xsl:when test="$kinddoc = 'jp:amendment-a524'">
                                    <xsl:value-of select="'【訂正対象書類整理番号】'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'【補正対象書類整理番号】'" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'【整理番号】'" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xf:string>
                <xf:string key="indentLevel">
                    <xsl:value-of select="'2'" />
                </xf:string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="ancestor::jp:indication-of-case-article">
                        <xsl:choose>
                            <xsl:when
                                test="$c-payment = 'jp:payment-' or $kinddoc = 'jp:demand-e853'
                                    or $kinddoc = 'jp:demand-e854' or $kinddoc = 'jp:demand-e862' ">
                                <xf:string key="jpTag">
                                    <xsl:value-of select="'【整理番号】'" />
                                </xf:string>
                                <xf:string key="indentLevel">
                                    <xsl:value-of select="'0'" />
                                </xf:string>
                            </xsl:when>
                            <xsl:otherwise>
                                <xf:string key="jpTag">
                                    <xsl:value-of select="'【整理番号】'" />
                                </xf:string>
                                <xf:string key="indentLevel">
                                    <xsl:value-of select="'2'" />
                                </xf:string>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:parent-application-article
                            or ancestor::jp:declaration-priority-ear-app">
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【整理番号】'" />
                        </xf:string>
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'2'" />
                        </xf:string>
                    </xsl:when>
                    <xsl:when test="parent::jp:amendment-group">
                        <xf:string key="jpTag">
                            <xsl:choose>
                                <xsl:when test="$kinddoc = 'jp:amendment-a524'">
                                    <xsl:value-of select="'【訂正対象書類整理番号】'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'【補正対象書類整理番号】'" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xf:string>
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'1'" />
                        </xf:string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【整理番号】'" />
                        </xf:string>
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'0'" />
                        </xf:string>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- ====================================================================
         事件の表示編集
         ====================================================================-->
    <xsl:template
        name="事件の表示編集">
        <xsl:param name="node" />
        
        <xsl:variable name="kindlaw">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment/@jp:kind-of-law" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$kind-of-law" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="paym">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="substring(ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-document,1,11)" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="substring(ancestor::jp:contents-of-amendment/@jp:kind-of-document,1,11)" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$payment" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!--  項目名の編集  -->
        <xf:string key="jpTag">
            <xsl:choose>
                <xsl:when
                    test="$node = 'jp:application-a631' or $node = 'jp:application-a632' or
                        $node = 'jp:application-a633' or $node = 'jp:application-a634' or
                        $node = 'jp:application-a635' or $node = 'jp:etcetera-a621' or
                        $node = 'jp:etcetera-a623' or $node = 'jp:etcetera-a624' or
                        $node = 'jp:etcetera-a625' or $node = 'jp:etcetera-a626' or
                        $node = 'jp:etcetera-a627' or $node = 'jp:etcetera-a914' or
                        $node = 'jp:amendment-a5210' or $node = 'jp:amendment-a5211' or
                        $node = 'jp:amendment-a5212' or $node = 'jp:amendment-a525' or
                        $node = 'jp:amendment-a526' or $node = 'jp:amendment-a527' or
                        $node = 'jp:amendment-a528' or $node = 'jp:amendment-a529' or
                        $node = 'jp:etcetera-a917' or $node = 'jp:etcetera-a918' or
                        $node = 'jp:etcetera-a919'">
                    
                    <xsl:choose>
                        <xsl:when
                            test="($node = 'jp:etcetera-a623' or $node = 'jp:etcetera-a624') and $kindlaw = 'utility'
                                and ./jp:application-reference/@appl-type = 'registration'
                                and string-length(normalize-space(./jp:application-reference/jp:document-id/jp:date)) = 0">
                            <xsl:if test="./jp:application-reference/@appl-type != 'registration'">
                                <xsl:if test="ancestor::jp:contents-of-amendment">
                                    <xsl:value-of select="'　　'" />
                                </xsl:if>
                                <xsl:value-of select="'【出願の表示】'" />
                                <BR />
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="ancestor::jp:contents-of-amendment">
                                <xsl:value-of select="'　　'" />
                            </xsl:if>
                            <xsl:value-of select="'【出願の表示】'" />
                            <BR />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when
                    test="($node = 'jp:demand-e853' or $node = 'jp:demand-e854' or
                            $node = 'jp:demand-e862') or ($paym = 'jp:payment-')">
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when
                            test="($node = 'jp:etcetera-a915') and $kindlaw = 'utility'
                                and ./jp:application-reference/@appl-type = 'registration'
                                and string-length(normalize-space(./jp:application-reference/jp:document-id/jp:date)) = 0">
                            <xsl:if test="./jp:application-reference/@appl-type != 'registration'">
                                <xsl:if test="ancestor::jp:contents-of-amendment">
                                    <xsl:value-of select="'　　'" />
                                </xsl:if>
                                <xsl:value-of select="'【事件の表示】'" />
                                <BR />
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="ancestor::jp:contents-of-amendment">
                                <xsl:value-of select="'　　'" />
                            </xsl:if>
                            <xsl:value-of select="'【事件の表示】'" />
                            <BR />
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:otherwise>
            </xsl:choose>
        </xf:string>
        
        
        <xsl:apply-templates
            select="jp:application-reference[@appl-type = 'international-application']//jp:doc-number" />
        <xsl:apply-templates
            select="jp:application-reference[@appl-type = 'international-application']//jp:date" />
        <xsl:for-each
            select="jp:application-reference[@appl-type = 'international-application']">
            <xsl:call-template name="出願書類参照編集" />
        </xsl:for-each>
        <xsl:apply-templates select="jp:appeal-reference/jp:doc-number" />
        <xsl:apply-templates select="jp:appeal-reference/jp:date" />
        <xsl:apply-templates
            select="jp:application-reference[@appl-type = 'application']//jp:doc-number" />
        <xsl:apply-templates
            select="jp:application-reference[@appl-type = 'registration']//jp:doc-number" />
        <xsl:apply-templates
            select="jp:application-reference[@appl-type = 'examined-pub']//jp:doc-number" />
        <xsl:apply-templates
            select="jp:application-reference[@appl-type = 'un-examined-pub']//jp:doc-number" />
        <xsl:apply-templates
            select="jp:application-reference[@appl-type = 'application']//jp:date" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:receipt-number" />
        
    </xsl:template>
    
    <!-- ====================================================================
         日付タイトル
         ====================================================================-->
    <xsl:template
        name="日付タイトル">
        
        <xsl:variable name="kinddoc">
            <xsl:choose>
                <xsl:when test="parent::jp:submission-date">
                    <xsl:choose>
                        <xsl:when test="ancestor::jp:contents-of-amendment">
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$node" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="ancestor::jp:contents-of-amendment">
                            <xsl:choose>
                                <xsl:when
                                    test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                                    <xsl:value-of
                                        select="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-document" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$node" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="kindlaw">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-law" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment/@jp:kind-of-law" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$kind-of-law" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="paym">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="substring(ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-document,1,11)" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="substring(ancestor::jp:contents-of-amendment/@jp:kind-of-document,1,11)" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$payment" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="parent::jp:submission-date">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:target-document/jp:submission-date">
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【提出日】'" />
                        </xf:string>
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'2'" />
                        </xf:string>
                    </xsl:when>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:choose>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment/jp:submission-date">
                                <xf:string key="jpTag">
                                    <xsl:value-of select="'【提出日】'" />
                                </xf:string>
                                <xf:string key="indentLevel">
                                    <xsl:value-of select="'2'" />
                                </xf:string>
                            </xsl:when>
                            <xsl:when
                                test="ancestor::jp:contents-of-amendment/jp:amendment-group/jp:submission-date">
                                <xsl:choose>
                                    <xsl:when test="$kinddoc = 'jp:amendment-a524'">
                                        <xf:string key="jpTag">
                                            <xsl:value-of select="'【訂正対象書類提出日】'" />
                                        </xf:string>
                                        <xf:string key="indentLevel">
                                            <xsl:value-of select="'2'" />
                                        </xf:string>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xf:string key="jpTag">
                                            <xsl:value-of select="'【補正対象書類提出日】'" />
                                        </xf:string>
                                        <xf:string key="indentLevel">
                                            <xsl:value-of select="'2'" />
                                        </xf:string>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xf:string key="jpTag">
                                    <xsl:value-of select="'【提出日】'" />
                                </xf:string>
                                <xf:string key="indentLevel">
                                    <xsl:value-of select="'2'" />
                                </xf:string>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="ancestor::jp:amendment-group/jp:submission-date">
                                <xsl:choose>
                                    <xsl:when test="$kinddoc = 'jp:amendment-a524'">
                                        <xf:string key="jpTag">
                                            <xsl:value-of select="'【訂正対象書類提出日】'" />
                                        </xf:string>
                                        <xf:string key="indentLevel">
                                            <xsl:value-of select="'1'" />
                                        </xf:string>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xf:string key="jpTag">
                                            <xsl:value-of select="'【補正対象書類提出日】'" />
                                        </xf:string>
                                        <xf:string key="indentLevel">
                                            <xsl:value-of select="'1'" />
                                        </xf:string>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xf:string key="jpTag">
                                    <xsl:value-of select="'【提出日】'" />
                                </xf:string>
                                <xf:string key="indentLevel">
                                    <xsl:value-of select="'0'" />
                                </xf:string>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <xsl:when
                test="ancestor::jp:application-reference
                    and ancestor::jp:application-reference [@appl-type = 'application']">
                <xsl:choose>
                    <xsl:when
                        test="(ancestor::jp:indication-of-case-article)
                            and ($payment = 'jp:payment-' or $node = 'jp:demand-e853'
                                or $node = 'jp:demand-e854' or $node = 'jp:demand-e862')
                            and not(ancestor::jp:contents-of-amendment)">
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【出願日】'" />
                        </xf:string>
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'0'" />
                        </xf:string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【出願日】'" />
                        </xf:string>
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'2'" />
                        </xf:string>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when
                test="ancestor::jp:application-reference
                    and ancestor::jp:application-reference [@appl-type = 'international-application']">
                <xsl:choose>
                    <xsl:when
                        test="(ancestor::jp:indication-of-case-article)
                            and ($payment = 'jp:payment-' or $node = 'jp:demand-e853'
                                or $node = 'jp:demand-e854' or $node = 'jp:demand-e862')
                            and not(ancestor::jp:contents-of-amendment)">
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【国際出願日】'" />
                        </xf:string>
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'0'" />
                        </xf:string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【国際出願日】'" />
                        </xf:string>
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'2'" />
                        </xf:string>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when
                test="ancestor::jp:application-reference
                    and ancestor::jp:application-reference [@appl-type = 'registration']">
                <xf:string key="jpTag">
                    <xsl:value-of select="'【登録日】'" />
                </xf:string>
                <xf:string key="indentLevel">
                    <xsl:value-of select="'2'" />
                </xf:string>
            </xsl:when>
            <xsl:when test="ancestor::jp:priority-claim">
                <xf:string key="jpTag">
                    <xsl:value-of select="'【出願日】'" />
                </xf:string>
                <xf:string key="indentLevel">
                    <xsl:value-of select="'2'" />
                </xf:string>
            </xsl:when>
            
            <xsl:when test="ancestor::jp:appeal-reference">
                <xsl:choose>
                    <xsl:when
                        test="(ancestor::jp:indication-of-case-article)
                            and ($payment = 'jp:payment-' or $node = 'jp:demand-e853'
                                or $node = 'jp:demand-e854' or $node = 'jp:demand-e862')
                            and not(ancestor::jp:contents-of-amendment)">
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【審判請求日】'" />
                        </xf:string>
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'0'" />
                        </xf:string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【審判請求日】'" />
                        </xf:string>
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'2'" />
                        </xf:string>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <xsl:when test="ancestor::jp:dispatch-date">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:choose>
                            <xsl:when test="$paym = 'jp:payment-'">
                                <xsl:choose>
                                    <xsl:when test="$kindlaw = 'patent'">
                                        <xf:string key="jpTag">
                                            <xsl:value-of select="'【特許査定の謄本発送日】'" />
                                        </xf:string>
                                        <xf:string key="indentLevel">
                                            <xsl:value-of select="'2'" />
                                        </xf:string>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xf:string key="jpTag">
                                            <xsl:value-of select="'【登録査定の謄本発送日】'" />
                                        </xf:string>
                                        <xf:string key="indentLevel">
                                            <xsl:value-of select="'2'" />
                                        </xf:string>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xf:string key="jpTag">
                                    <xsl:value-of select="'【発送日】'" />
                                </xf:string>
                                <xf:string key="indentLevel">
                                    <xsl:value-of select="'2'" />
                                </xf:string>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$paym = 'jp:payment-'">
                                <xsl:choose>
                                    <xsl:when test="$kindlaw = 'patent'">
                                        <xf:string key="jpTag">
                                            <xsl:value-of select="'【特許査定の謄本発送日】'" />
                                        </xf:string>
                                        <xf:string key="indentLevel">
                                            <xsl:value-of select="'0'" />
                                        </xf:string>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xf:string key="jpTag">
                                            <xsl:value-of select="'【登録査定の謄本発送日】'" />
                                        </xf:string>
                                        <xf:string key="indentLevel">
                                            <xsl:value-of select="'0'" />
                                        </xf:string>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xf:string key="jpTag">
                                    <xsl:value-of select="'【発送日】'" />
                                </xf:string>
                                <xf:string key="indentLevel">
                                    <xsl:value-of select="'0'" />
                                </xf:string>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="ancestor::jp:submit-date-of-amendment">
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【補正書の提出年月日】'" />
                        </xf:string>
                    </xsl:when>
                    <xsl:when test="ancestor::jp:notice-filing-date">
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【出願番号通知の出願日】'" />
                        </xf:string>
                    </xsl:when>
                    <xsl:when test="ancestor::jp:proof-filing-date">
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【証明しようとする出願日】'" />
                        </xf:string>
                    </xsl:when>
                    <xsl:when test="ancestor::jp:receipt-date">
                        <xf:string key="jpTag">
                            <xsl:value-of select="'【１９条補正のＷＩＰＯ受領日】'" />
                        </xf:string>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'2'" />
                        </xf:string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xf:string key="indentLevel">
                            <xsl:value-of select="'0'" />
                        </xf:string>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ====================================================================
         出願書類参照編集
         ====================================================================-->
    <xsl:template
        name="出願書類参照編集">
        <xsl:if
            test="(ancestor::jp:indication-of-case-article
                    or ancestor::jp:parent-application-article)
                and (./@appl-type = 'international-application')
                and (./@jp:kind-of-law)">
            <xf:map>
                <xf:string key="tag">
                    <xsl:value-of select="'shutugan-kubun'" />
                </xf:string>
                <xf:string key="jpTag">
                    <xsl:value-of select="'【出願の区分】'" />
                </xf:string>
                <xf:string key="text">
                    <xsl:choose>
                        <xsl:when test="./@jp:kind-of-law = 'patent'">
                            <xsl:value-of select="'特許'" />
                        </xsl:when>
                        <xsl:when test="./@jp:kind-of-law = 'utility'">
                            <xsl:value-of select="'実用新案登録'" />
                        </xsl:when>
                        <xsl:when test="./@jp:kind-of-law = ''">
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="書誌編集エラー処理" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xf:string>
                <xf:string key="indentLevel">
                    <xsl:choose>
                        <xsl:when
                            test="(ancestor::jp:indication-of-case-article
                                    or ancestor::jp:parent-application-article)
                                and (./@appl-type = 'international-application')
                                and (./@jp:kind-of-law)">
                            <xsl:choose>
                                <xsl:when
                                    test="$payment = 'jp:payment-' or $node = 'jp:demand-e853'
                                        or $node = 'jp:demand-e854' or $node = 'jp:demand-e862' ">
                                    <xsl:value-of select="'0'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'2'" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'0'" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xf:string>
            </xf:map>
        </xsl:if>
    </xsl:template>
    
    <!-- ====================================================================
         名称編集
         ====================================================================-->
    <xsl:template
        name="名称編集">
        <xsl:param name="type" />
        <!-- type = 1　…　氏名又は名称の編集の場合
             type = 2　…　氏名又は名称言語表記の編集の場合  -->
        <xsl:variable name="meisyo"
            select="normalize-space(preceding-sibling::jp:representative-identification)" />
        <xsl:choose>
            <xsl:when test="$type = '1'">
                <xsl:value-of select="'【' || $meisyo || '】'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'【' || $meisyo || '原語表記】'" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ====================================================================
         先の出願日編集
         YYYYMMDD -> 元号YY年MM月DD日
         this template must be called from a template having jp:date as descendant node.
         ====================================================================-->
    <xsl:template
        name="先の出願日編集">
        <xsl:variable name="date-str" select="normalize-space(.//jp:date)" />
        <xsl:variable name="m" select="substring(normalize-space(.//jp:date),5,2)" />
        <xsl:variable name="d" select="substring(normalize-space(.//jp:date),7,2)" />
        
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="'jp:date'" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【出願日】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="($payment = 'jp:payment-' or $node = 'jp:demand-e853'
                                or $node = 'jp:demand-e854' or $node = 'jp:demand-e862')
                            and not(ancestor::jp:contents-of-amendment)">
                        <xsl:value-of select="'0'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'2'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select=".//jp:date" />
            </xf:string>
            <xf:string key="convertedText">
                <xsl:choose>
                    <xsl:when test=".//jp:date/@jp:error-code">
                        <xsl:value-of select=".//jp:date" />
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space(.//jp:date)) = 0" />
                    <xsl:when
                        test="(number(.//jp:date) != number(normalize-space(.//jp:date))) or (number(.//jp:date) &lt; 19260101)">
                        <xsl:call-template name="書誌編集エラー処理" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="gengo">
                            <xsl:with-param name="date" select="$date-str" />
                        </xsl:call-template>
                        <xsl:call-template name="warekinen">
                            <xsl:with-param name="date" select="$date-str" />
                        </xsl:call-template>
                        <xsl:value-of select="'年'" />
                        <xsl:value-of select="$m || '月'" />
                        <xsl:value-of select="$d || '日'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    <!-- End: template-name  =============================================--> 
    
    <!-- ====================================================================
         ↓ 当面、処理対象にしないテンプレート群
         ====================================================================-->
    
    <!-- ====================================================================
         pat-atny
         a7431 代理人変更届
         a7431 復代理人変更届
         jp:attorney-disappear-article 
         ====================================================================-->
    <!-- 消滅する代理人の記事     -->
    <xsl:template match="jp:attorney-disappear-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:agent" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         pat-atny
         a7422 代理人受任届 
         a7424 代理人辞任届
         a7431 復代理人変更届
         a7432 復代理人受任届 
         a7433 復代理人選任届 
         a7434 復代理人辞任届 
         a7435 復代理人解任届 
         a7436 復代理権変更届
         a7437 復代理権消滅届 
         jp:proceeded-attorney-article 手続した代理人の記事
         ====================================================================-->
    <xsl:template match="jp:proceeded-attorney-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:agent" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         pat-aplc
         a711  出願人名義変更届 
         a712  出願人名義変更届（一般承継）
         pat-atny
         a7432 復代理人受任届 
         a7434 復代理人辞任届 
         jp:attorney-of-case-article 事件の出願人の代理人の記事
         ====================================================================-->
    <xsl:template match="jp:attorney-of-case-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:agent" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         pat-aplc
         a711  出願人名義変更届 
         a712  出願人名義変更届（一般承継）
         pat-atny
         a7422 代理人受任届 
         a7424 代理人辞任届
         a7431 復代理人変更届
         a7432 復代理人受任届 
         a7433 復代理人選任届 
         a7434 復代理人辞任届 
         a7435 復代理人解任届 
         a7436 復代理権変更届
         a7437 復代理権消滅届 
         jp:applicant-of-case-article 事件の出願人の記事
         ====================================================================-->
    <xsl:template match="jp:applicant-of-case-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:applicant" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:req-for-inspct
         e841 優先権証明請求書
         jp:notice-history-list
         jp:notice-status-info
         jp:demand-history-list
         jp:req-for-inspct-history-info 
         
         jp:application-country-article 出願国名
         ====================================================================-->
    <xsl:template
        match="jp:application-country-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xsl:apply-templates select="jp:country" />
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:rgs-doc
         jp:payment-r20 特許料納付書, 実用新案登録料納付書
         jp:annexation-payment-article 併合納付の明細の記事
         ====================================================================-->
    <xsl:template match="jp:annexation-payment-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【併合納付の明細】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:annexation-payment" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:rgs-doc
         jp:payment-r20 特許料納付書, 実用新案登録料納付書
         jp:annexation-payment 併合納付の明細
         import from <xsl:template name="併合納付の明細編集">
         ====================================================================-->
    <xsl:template match="jp:annexation-payment">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:application-reference" />
                <xsl:apply-templates select="jp:number-of-claim" />
                <xsl:apply-templates select="jp:payment-years" />
                <xsl:apply-templates select="jp:fee" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         pat-etc
         jp:etcetera-a914 出願審査請求手数料返還請求書
         jp:target-document-article 返還請求対象書類
         ====================================================================-->
    <xsl:template match="jp:target-document-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:target-document" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         pat-etc
         jp:etcetera-a914 出願審査請求手数料返還請求書
         jp:etcetera-a915 既納手数料返還請求書
         jp:target-document 対象書類
         import from <xsl:template name="対象書類編集">
         ====================================================================-->
    <xsl:template match="jp:target-document">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="parent::jp:target-document-article">
                        <xsl:if test="position() = 1">
                            <xsl:value-of select="'【返還請求対象書類】'" />
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'【返還請求対象書類】'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="parent::jp:target-document-article">
                        <xsl:choose>
                            <xsl:when test="position() = 1">
                                <xsl:choose>
                                    <xsl:when test="ancestor::jp:contents-of-amendment">
                                        <xsl:value-of select="'2'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'0'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'0'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="ancestor::jp:contents-of-amendment">
                                <xsl:value-of select="'2'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'0'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:document-code" />
                <xsl:apply-templates select="jp:submission-date" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         unreferenced?
         jp:sequence-list 配列表
         ====================================================================-->
    <xsl:template match="jp:sequence-list">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【配列表】'" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="p" />
                
                <!-- 未サポート -->
                <xsl:if test="doc-page">
                    <xsl:apply-templates select="doc-page" />
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:class-of-goods-and-service 商品及び役務の区分
         ====================================================================-->
    <xsl:template match="jp:class-of-goods-and-service">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【商品及び役務の区分】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xsl:for-each select="jp:class">
                <xf:map>
                    <xf:string key="tag">
                        <xsl:value-of select="'jp:class'" />
                    </xf:string>
                    <xf:string key="text">
                        <xsl:value-of select="." />
                    </xf:string>
                </xf:map>
            </xsl:for-each>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:rgs-doc
         jp:payment-r20
         jp:payment-r21
         jp:kind-of-annexation 併合識別 
         import from <xsl:template name="併合識別編集">
         ====================================================================-->
    <xsl:template match="jp:kind-of-annexation">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【併合識別】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@jp:error-code">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="normalize-space(.) = '1'">
                            <xsl:value-of select="'併合'" />
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:req-for-inspct
         jp:demand-e842
         jp:proof-matter-article 証明に係る事項
         ====================================================================-->
    <xsl:template match="jp:proof-matter-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【証明に係る事項】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="p" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:req-for-inspct
         jp:demand-e852
         jp:rejection-case-accept-notice-art 拒絶理由通知を受けた事件の表示
         import from <xsl:template name="拒絶理由通知を受けた事件の表示編集">
         ====================================================================-->
    <xsl:template match="jp:rejection-case-accept-notice-art">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【拒絶理由通知を受けた事件の表示】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:for-each select="jp:application-reference">
                    <xsl:apply-templates select=".//jp:doc-number" />
                </xsl:for-each>
                <xsl:apply-templates select="jp:appeal-reference/jp:doc-number" />
                
                <!-- 未サポート -->
                <xsl:if
                    test="jp:appeal-reference/jp:date or .//country
                        or .//kind or .//name or jp:application-reference//jp:date">
                    <xsl:apply-templates
                        select="jp:appeal-reference/jp:date | .//country | .//kind | .//name
                            | jp:application-reference//jp:date" />
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:req-for-inspct
         jp:demand-e841
         jp:demand-e842
         jp:demand-e851
         jp:demand-e852
         jp:demand-e853
         jp:demand-e854
         jp:delivery-way 交付方法 
         import from  <xsl:template name="交付方法編集">
         ====================================================================-->
    <xsl:template match="jp:delivery-way">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【交付方法】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@jp:error-code">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="normalize-space(.) = '1'">
                                <xsl:value-of select="'手交'" />
                            </xsl:when>
                            <xsl:when test="normalize-space(.) = '2'">
                                <xsl:value-of select="'郵送'" />
                            </xsl:when>
                            <xsl:when test="normalize-space(.) = ''">
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="書誌編集エラー処理" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:req-for-inspct
         jp:demand-e842
         jp:demand-e851
         jp:demand-e852
         jp:demand-e853
         jp:demand-e854
         jp:number-of-copy 請求部数
         import from <xsl:template name="請求部数編集">
         ====================================================================-->
    <xsl:template match="jp:number-of-copy">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【請求部数】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:if test="string-length(normalize-space(.)) != 0">
                    <xsl:choose>
                        <xsl:when test="ancestor::jp:contents-of-amendment">
                            <xsl:value-of select="'　　　' || ." />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'　　　　　' || ." />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:rgs-doc
         jp:payment-r100
         jp:payment-r104
         jp:payment-r110
         jp:payment-r114
         jp:payment-r200
         jp:payment-r201
         jp:payment-r210
         jp:payment-r211
         jp:indicate-payment 納付の表示
         import from <xsl:template name="納付の表示編集">
         ====================================================================-->
    <xsl:template match="jp:indicate-payment">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【納付の表示】　　　　'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:choose>
                    <xsl:when test="./@jp:error-code">
                        <xsl:value-of select="." />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when
                                test="($node = 'jp:payment-r200' or $node = 'jp:payment-r210')
                                    and $kind-of-law = 'trademark'">
                                <xsl:choose>
                                    <xsl:when test="normalize-space(.) = ''">
                                    </xsl:when>
                                    <xsl:when test="normalize-space(.) = '1'">
                                        <xsl:value-of select="'分割納付'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="書誌編集エラー処理" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="normalize-space(.) = ''">
                                    </xsl:when>
                                    <xsl:when test="normalize-space(.) = '0'">
                                        <xsl:value-of select="'一括納付'" />
                                    </xsl:when>
                                    <xsl:when test="normalize-space(.) = '1'">
                                        <xsl:value-of select="'分割納付'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="書誌編集エラー処理" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:req-for-inspct
         jp:demand-e841
         jp:demand-e842
         jp:demand-e851
         jp:proof-or-deliverty-document 証明又は交付に係る書類名
         import from <xsl:template name="証明又は交付に係る書類名編集">
         ====================================================================-->
    <xsl:template match="jp:proof-or-deliverty-document">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:variable name="node">
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$node = 'jp:demand-e842'">
                                <xsl:value-of select="'【証明に係る書類名】'" />
                            </xsl:when>
                            <xsl:when test="$node = 'jp:demand-e841'">
                                <xsl:value-of select="'【証明に係る他の書類名】'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'【交付に係る書類名】'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$node = 'jp:demand-e842'">
                                <xsl:value-of select="'【証明に係る書類名】'" />
                            </xsl:when>
                            <xsl:when test="$node = 'jp:demand-e841'">
                                <xsl:value-of select="'【証明に係る他の書類名】'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'【交付に係る書類名】'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:pat-submsn
         jp:presentment-a80
         jp:publications-etc-article 刊行物等の記事
         ====================================================================-->
    <xsl:template match="jp:publications-etc-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【刊行物等】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:publications-etc" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         jp:pat-submsn
         jp:presentment-a80
         jp:publications-etc-article/jp:publications-etc 刊行物等
         ====================================================================-->
    <xsl:template match="jp:publications-etc">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="text">
                <xsl:if test="position() != 1">
                    <xsl:value-of select="'　　　　　　　　　　　'" />
                </xsl:if>
                <xsl:value-of select="." />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         pat-etc
         etcetera-a914 出願審査請求手数料返還請求書
         etcetera-a915 既納手数料返還請求書
         jp:bank-account 返還金振込先
         import from <xsl:template name="振込先編集">
         ====================================================================-->
    <xsl:template match="jp:bank-account">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【返還金振込先】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:financial-institution-name" />
                <xsl:apply-templates select="jp:account-type" />
                <xsl:apply-templates select="jp:account-number" />
                <xsl:apply-templates select="jp:kana" />
                <xsl:apply-templates select="jp:name" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         pat-etc
         jp:etcetera-a918
         jp:invention-contents-article 申出に係る発明の内容
         ====================================================================-->
    <xsl:template match="jp:invention-contents-article">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:string key="jpTag">
                <xsl:value-of select="'【申出に係る発明の内容】'" />
            </xf:string>
            <xf:string key="indentLevel">
                <xsl:choose>
                    <xsl:when
                        test="ancestor::jp:contents-of-amendment">
                        <xsl:value-of select="'2'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="p" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         pat-etc
         jp:etcetera-a914 出願審査請求手数料返還請求書
         jp:amount-paid jp:amount-restoration-claim
         jp:etcetera-a915 既納手数料返還請求書
         jp:amount-paid、jp:amount-proper-payment、jp:amount-restoration-claim
         納付済金額、適正納付金額、返還請求金額
         ====================================================================-->
    <xsl:template match="jp:amount-paid | jp:amount-proper-payment | jp:amount-restoration-claim">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="jp:fee" />
            </xf:array>
        </xf:map>
    </xsl:template>
    <!-- ====================================================================
         End 当面、処理対象にしないテンプレート群
         ====================================================================-->
    
    <!-- ====================================================================
         deceased-inventor
         ====================================================================-->
    <!-- 未サポート -->
    <xsl:template match="deceased-inventor">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                
                <xsl:apply-templates
                    select="name | prefix | last-name | first-name | midle-name | suffix
                        | iid | role | orgname | department | synonym
                        | jp:registered-number" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         designated-states | designated-states-as-inventor
         ====================================================================-->
    <!-- 未サポート -->
    <xsl:template match="designated-states | designated-states-as-inventor">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:if test="./country[1]">
                    <xsl:apply-templates select="country[1]" />
                </xsl:if>
                <xsl:if test="region">
                    <xsl:apply-templates select="region/country" />
                </xsl:if>
                <xsl:if test="./country[2]">
                    <xsl:apply-templates select="country[2]" />
                </xsl:if>
            </xf:array>
        </xf:map>
    </xsl:template>
    
    
    <!-- ====================================================================
         residence
         ====================================================================-->
    <!-- 未サポート -->
    <xsl:template match="residence">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="name()" />
            </xf:string>
            <xf:array key="blocks">
                <xsl:apply-templates select="country" />
            </xf:array>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         未サポートタグ
         ====================================================================-->
    <xsl:template
        match="country | kind | name | prefix | last-name | first-name | midle-name
            | suffix | iid | role | orgname | department | synonym | address-1
            | address-2 | address-3 | mailcode | pobox | room | address-floor
            | building | street | city | county | state | postcode | email | url
            | ead | dtext | text | region | customer-number
            | jp:inventor/jp:addressbook/jp:original-language-of-name
            | jp:inventor/jp:addressbook/jp:address/jp:original-language-of-address
            | jp:inventor/jp:addressbook/jp:phone | jp:inventor/jp:addressbook/jp:fax
            | deceased-inventor/jp:registered-number | other-method
            | jp:agent/jp:representative-group//jp:original-language-of-name
            | jp:applicant-of-case-article//jp:share | jp:applicant-of-case-article//jp:representative-applicant
            | jp:applicant-of-case-article/jp:applicant//jp:original-language-of-address
            | jp:applicant-of-case-article/jp:applicant/jp:addressbook/jp:original-language-of-name
            | jp:applicant-of-case-article/jp:applicant/jp:representative-group//jp:original-language-of-name
            | jp:applicant-of-case-article//jp:office-address | jp:applicant-of-case-article//jp:office
            | jp:applicant-of-case-article//jp:office-in-japan
            | jp:applicant-of-case-article//jp:legal-entity-property
            | jp:attorney-of-case-article//jp:office-address
            | jp:rejection-case-accept-notice-art/jp:appeal-reference/jp:date
            | jp:rejection-case-accept-notice-art//country | jp:rejection-case-accept-notice-art//kind
            | jp:rejection-case-accept-notice-art//name
            | jp:rejection-case-accept-notice-art/jp:application-reference//jp:date
            | jp:withdrawal-kind | jp:withdrawn-date/jp:date | jp:accepted-date/jp:date
            | jp:preliminary-exam-report/jp:date | jp:demand-date/jp:date
            | jp:regional-patent-group/jp:regional-patent | jp:nationality-and-residence
            | doc-page | abst-problem | abst-solution
            | address-4 | address-5">
        <xsl:call-template name="unsupported-tag" />
    </xsl:template>
    
    <!-- ====================================================================
         ｐタグ未サポート
         ====================================================================-->
    <xsl:template
        match="b | i | smallcaps | dl | ul | ol | bio-deposit |
            crossref
            | o | pre | table-external-doc">
        <xsl:call-template name="unsupported-tag" />
    </xsl:template>
    
    <!-- ====================================================================
         未サポートタグ
         ====================================================================-->
    <xsl:template
        match="office-of-filing | priority-doc-requested | priority-doc-attached | fee-total
            | credit-card">
        <xsl:call-template name="unsupported-tag" />
    </xsl:template>
    
    <!-- ====================================================================
         書誌編集エラー処理
         ====================================================================-->
    <xsl:template
        name="書誌編集エラー処理">
        <xsl:value-of select="'＊＊＊　書誌書類　内容エラー　＊＊＊'" />
    </xsl:template>
    
    <!-- ====================================================================
         属性値出力１
         ====================================================================-->
    <xsl:template
        match="@number | @expires | @name | @postal-code | @account-type
            | @jp:error-code | @appl-type | @jp:kind-of-law | @lang | @name-type
            | @sequence | @designation | @app-type | @jp:kind-of-application">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="unsupported-attribute" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="name() || '=&quot;' || . || '&quot;'" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
    <!-- ====================================================================
         属性値出力２
         ====================================================================-->
    <xsl:template
        match="@to-dead-inventor | @kind | @jp:kind-of-agent
            | @legal-representative| @amount | @fee-code | @quantity | @currency">
        <xf:map>
            <xf:string key="tag">
                <xsl:value-of select="unsupported-attribute" />
            </xf:string>
            <xf:string key="text">
                <xsl:value-of select="name() || '=&quot;' || . || '&quot;'" />
            </xf:string>
        </xf:map>
    </xsl:template>
    
</xsl:stylesheet>