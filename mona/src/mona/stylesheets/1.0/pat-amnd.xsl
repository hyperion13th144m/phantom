<?xml version="1.0" encoding="UTF-8"?>

<!-- ====================================================================
　　　変換対象書類名：申請書類（補正書）
    original: pat-amnd.xsl at Jan 22  2007 
    sha256sum: 07526880fdb7472ad99e02fc63356fc9f0f122846d24b52678691f1730d3d037
     ====================================================================-->
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp">

    <xsl:variable name="node" select="name(//jp:pat-amnd/*)" />
    <xsl:variable name="kind-of-law" select="//jp:pat-amnd/*/@jp:kind-of-law" />
    <xsl:variable name="payment" select="substring($node,1,11)" />

    <xsl:include href="common-templates/pat_common.xsl" />

    <!-- ====================================================================
     root
     ====================================================================-->
    <xsl:template match="/">
        <xsl:element name="root">
            <xsl:element name="textBlocksRoot">
                <xsl:element name="tag">patAmnd</xsl:element>
                <xsl:apply-templates select="root/jp:pat-amnd" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <!-- ====================================================================
     jp:amendment-a51 | jp:amendment-a523 手続補正書（方式）| 手続補正書
     ====================================================================-->
    <xsl:template match="jp:amendment-a51 | jp:amendment-a523">
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
        <xsl:apply-templates select="jp:num-claim-decrease-amendment">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:num-claim-increase-amendment">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:amendment-article" />
        <xsl:apply-templates select="jp:amendment-charge-article" />
        <xsl:apply-templates select="jp:proof-means" />
        <xsl:apply-templates select="jp:share-rate" />
        <xsl:apply-templates select="jp:charge-article" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:amendment-a524 誤訳訂正書
     ====================================================================-->
    <xsl:template match="jp:amendment-a524">
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
        <xsl:apply-templates select="jp:num-claim-decrease-amendment">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:num-claim-increase-amendment">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:amendment-article" />
        <xsl:apply-templates select="jp:opinion-contents-article">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:share-rate" />
        <xsl:apply-templates select="jp:charge-article" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:amendment-a525 | jp:amendment-a529
     特許協力条約第１９条補正の翻訳文提出書 | 特許協力条約第３４条補正の翻訳文提出書
     ====================================================================-->
    <xsl:template match="jp:amendment-a525 | jp:amendment-a529">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:proof-necessity" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:submit-date-of-amendment" />
        <xsl:apply-templates select="jp:num-claim-decrease-amendment">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:num-claim-increase-amendment">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:amendment-article" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:amendment-a526 | jp:amendment-a5210
     特許協力条約第１９条補正の翻訳文提出書（職権） |
     特許協力条約第３４条補正の翻訳文提出書（職権）
     ====================================================================-->
    <xsl:template match="jp:amendment-a526 | jp:amendment-a5210">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:proof-necessity" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:submit-date-of-amendment" />
        <xsl:apply-templates select="jp:num-claim-decrease-amendment">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:num-claim-increase-amendment">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:notice-contents-group" />
        <xsl:apply-templates select="jp:amendment-article" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:amendment-a527 | jp:amendment-a5211
     特許協力条約第１９条補正の写し提出書 |
     特許協力条約第３４条補正の写し提出書
     ====================================================================-->
    <xsl:template match="jp:amendment-a527 | jp:amendment-a5211">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:proof-necessity" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:submit-date-of-amendment" />
        <xsl:apply-templates select="jp:num-claim-decrease-amendment">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:num-claim-increase-amendment">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

    <!-- ====================================================================
     jp:amendment-a528 | jp:amendment-a5212
     特許協力条約第１９条補正の写し提出書（職権） |
     特許協力条約第３４条補正の写し提出書（職権）
     ====================================================================-->
    <xsl:template match="jp:amendment-a528 | jp:amendment-a5212">
        <xsl:apply-templates select="jp:document-code" />
        <xsl:apply-templates select="jp:file-reference-id" />
        <xsl:apply-templates select="jp:submission-date" />
        <xsl:apply-templates select="jp:addressed-to-person" />
        <xsl:apply-templates select="jp:indication-of-case-article" />
        <xsl:apply-templates select="jp:proof-necessity" />
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
        <xsl:apply-templates select="jp:submit-date-of-amendment" />
        <xsl:apply-templates select="jp:num-claim-decrease-amendment">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:num-claim-increase-amendment">
            <xsl:with-param name="document" select="$node" />
        </xsl:apply-templates>
        <xsl:apply-templates select="jp:notice-contents-group" />
        <xsl:apply-templates select="jp:dtext" />
        <xsl:apply-templates select="jp:submission-object-list-article" />
        <xsl:apply-templates select="jp:rule-outside-item-article" />
    </xsl:template>

</xsl:stylesheet>