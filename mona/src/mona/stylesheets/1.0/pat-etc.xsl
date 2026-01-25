<?xml version="1.0" encoding="UTF-8"?>

<!-- ====================================================================
　　　変換対象書類名：申請書類（その他）
    original: pat-etc.xsl at Apr  4  2023
    sha256sum: e92b7b0cf3dc490ebe277718403b962639716522066812695e6854d963233adf
     ====================================================================-->
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp">

    <xsl:variable name="node" select="name(//jp:pat-etc/*)" />
    <xsl:variable name="kind-of-law" select="//jp:pat-etc/*/@jp:kind-of-law" />
    <xsl:variable name="payment" select="substring($node,1,11)" />

    <xsl:include href="common-templates/pat_common.xsl" />

    <!-- ====================================================================
     root
     ====================================================================-->
    <xsl:template match="/">
        <xsl:element name="root">
            <xsl:element name="textBlocksRoot">
                <xsl:element name="tag">pat-etc</xsl:element>
                <!-- 上申書 -->
                <xsl:apply-templates select="root/jp:pat-etc/jp:etcetera-a781" />
                <!-- 早期審査に関する事情説明書 -->
                <xsl:apply-templates select="root/jp:pat-etc/jp:etcetera-a871" />
                <!-- 早期審査に関する事情説明補充書 -->
                <xsl:apply-templates select="root/jp:pat-etc/jp:etcetera-a872" />

                <!-- その他の書類は必要になったら取り込む -->
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a601 期間延長請求書
     ====================================================================-->
    <xsl:template match="jp:etcetera-a601">
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
        <xsl:apply-templates select="jp:charge-article" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a621 審査請求書
     ====================================================================-->
    <xsl:template match="jp:etcetera-a621">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:number-of-claim" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <!-- Y05M04　ＳＲ添付による審査請求料の減額対応　追加　Start-->
        <xsl:apply-templates select="jp:srep-request-no" />
        <!-- Y05M04　ＳＲ添付による審査請求料の減額対応　追加　End-->
        <xsl:apply-templates select="jp:share-rate" />
        <xsl:apply-templates select="jp:charge-article" />
        <xsl:apply-templates select="jp:opinion-contents-article">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a623 | jp:etcetera-a624 実用新案技術評価請求書
     ====================================================================-->
    <!-- Y05M04　実用新案法改正　追加　Start-->
    <xsl:template match="jp:etcetera-a623 | jp:etcetera-a624">
        <!-- Y05M04　実用新案法改正　追加　End-->
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:number-of-claim" />
        <xsl:apply-templates select="jp:notice-contents-group" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:charge-article" />
        <xsl:apply-templates select="jp:dtext" />
        <!-- Y05M04　実用新案法改正　追加　Start-->
        <xsl:apply-templates select="jp:opinion-contents-article">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <!-- Y05M04　実用新案法改正　追加　End-->
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a625 審査請求書(by他人)
     ====================================================================-->
    <xsl:template match="jp:etcetera-a625">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:number-of-claim" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <!-- Y05M04　ＳＲ添付による審査請求料の減額対応　追加　Start-->
        <xsl:apply-templates select="jp:srep-request-no" />
        <!-- Y05M04　ＳＲ添付による審査請求料の減額対応　追加　End-->
        <xsl:apply-templates select="jp:charge-article" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a626 | jp:etcetera-a627 国内処理請求書、出願公開請求書
     ====================================================================-->
    <xsl:template match="jp:etcetera-a626 | jp:etcetera-a627">
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
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a67 受託番号変更届
     ====================================================================-->
    <xsl:template match="jp:etcetera-a67">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:proof-necessity" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:name-of-old-depository" />
        <xsl:apply-templates select="jp:old-depository-number" />
        <xsl:apply-templates select="jp:name-of-new-depository" />
        <xsl:apply-templates select="jp:new-depository-number" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a691 雑書類
     ====================================================================-->
    <xsl:template match="jp:etcetera-a691">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:proof-necessity" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a781 上申書
     ====================================================================-->
    <xsl:template match="jp:etcetera-a781">
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
        <xsl:apply-templates select="jp:opinion-contents-article">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:proof-means" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a821 手続補足書
     ====================================================================-->
    <xsl:template match="jp:etcetera-a821">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:proof-necessity" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:proof-means" />
        <xsl:apply-templates select="jp:notice-contents-group" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a831 刊行物提出書
     ====================================================================-->
    <xsl:template match="jp:etcetera-a831">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:proof-necessity" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:document-name" />
        <xsl:apply-templates select="jp:notice-contents-group" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a87 優先審査に関する事情説明書
     ====================================================================-->
    <xsl:template match="jp:etcetera-a87">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:opinion-contents-article">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- Y21M04 特実審査業務システム刷新に伴う既存システムの対応 2019/07/05 Start-->
    <!-- ====================================================================
     jp:etcetera-a871 早期審査に関する事情説明書
     ====================================================================-->
    <xsl:template match="jp:etcetera-a871">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:proof-necessity" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:kind-of-accelerated-examination" /><!--ADD-->
        <xsl:apply-templates select="jp:opinion-contents-article">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>
    <!-- Y21M04 特実審査業務システム刷新に伴う既存システムの対応 2019/07/05 End-->

    <!-- ====================================================================
     jp:etcetera-a872 早期審査に関する事情説明補充書
     ====================================================================-->
    <xsl:template match="jp:etcetera-a872">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:proof-necessity" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:opinion-contents-article">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- Y05M04　料金法改正対応　追加　Start-->
    <!-- ====================================================================
     jp:etcetera-a914
     ====================================================================-->
    <xsl:template match="jp:etcetera-a914">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:target-document-article" />
        <xsl:apply-templates select="jp:amount-paid" />
        <xsl:apply-templates select="jp:amount-restoration-claim" />
        <xsl:apply-templates select="jp:bank-account" />
        <xsl:apply-templates select="jp:charge-article" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a915
     ====================================================================-->
    <xsl:template match="jp:etcetera-a915">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:target-document" />
        <xsl:apply-templates select="jp:amount-paid" />
        <xsl:apply-templates select="jp:amount-proper-payment" />
        <xsl:apply-templates select="jp:amount-restoration-claim" />
        <xsl:apply-templates select="jp:bank-account" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>
    <!-- Y05M04　料金法改正対応　追加　End-->

    <!--Y09M04
    優先権DAS対応 2008/09/03 Start-->
    <!-- ====================================================================
     jp:etcetera-a916 世界知的所有権機関へのアクセスコード付与請求書 
     ====================================================================-->
    <xsl:template match="jp:etcetera-a916">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:proof-necessity" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:use-of-das" />
        <xsl:apply-templates select="jp:priority-claims" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>
    <!--Y09M04
    優先権DAS対応 2008/09/03 End-->

    <!--Y16M04
    PLT対応 2015/06/15 Start-->
    <!-- ====================================================================
     jp:etcetera-a603 期間延長請求書（期間徒過）
     ====================================================================-->
    <xsl:template match="jp:etcetera-a603">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:dispatch-number" />
        <xsl:apply-templates select="jp:dispatch-date" />
        <xsl:apply-templates select="jp:notice-contents-group" />
        <!--Y20M04
        期間延長請求書（期間徒過）の様式変更対応 2019/06/21 Start-->
        <xsl:apply-templates select="jp:share-rate" />
        <!--Y20M04
        期間延長請求書（期間徒過）の様式変更対応 2019/06/21 End-->
        <xsl:apply-templates select="jp:charge-article" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a917 回復理由書
     ====================================================================-->
    <xsl:template match="jp:etcetera-a917">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:dispatch-number" />
        <xsl:apply-templates select="jp:dispatch-date" />
        <xsl:apply-templates select="jp:opinion-contents-article">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <!--Y23M04
        権利の回復の要件緩和 2022/06/29 Start-->
        <xsl:apply-templates select="jp:charge-article" />
        <!--Y23M04
        権利の回復の要件緩和 2022/06/29 End-->
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>
    <!--Y16M04
    PLT対応 2015/06/15 End-->

    <!--Y24M04
    特許出願の非公開化対応 2023/04/03 Start-->
    <!-- ====================================================================
     jp:etcetera-a918
     ====================================================================-->
    <xsl:template match="jp:etcetera-a918">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:invention-contents-article" />
        <xsl:apply-templates select="jp:opinion-contents-article">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:etcetera-a919
     ====================================================================-->
    <xsl:template match="jp:etcetera-a919">
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
    </xsl:template>
    <!--Y24M04
    特許出願の非公開化対応 2023/04/03 End-->

</xsl:stylesheet>