<?xml version="1.0" encoding="UTF-8"?>

<!-- ====================================================================
     変換対象書類名：申請書類（補正書）
     original: pat-amnd.xsl at Jan 22  2007 
     sha256sum: 07526880fdb7472ad99e02fc63356fc9f0f122846d24b52678691f1730d3d037
     ====================================================================-->
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:jp="http://www.jpo.go.jp"
                xmlns:schema="urn:schema-dsl">
    
    <xsl:variable name="node" select="name(//jp:pat-amnd/*)" />
    <xsl:variable name="kind-of-law" select="//jp:pat-amnd/*/@jp:kind-of-law" />
    <xsl:variable name="payment" select="substring($node,1,11)" />
    
    <xsl:include href="common-templates/pat_common.xsl" />
    
    <!-- ====================================================================
         root
         ====================================================================-->
    <xsl:template match="/">
        <xsl:element name="root">
            <xsl:element name="blocks">
                <xsl:element name="tag">pat-amnd</xsl:element>
                <xsl:apply-templates select="root/jp:pat-amnd" />
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- schema:title is set to the name of this stylesheet -->
    <schema:title>pat-amnd</schema:title>
    
    <!-- ====================================================================
         jp:amendment-a51 | jp:amendment-a523 手続補正書（方式）| 手続補正書
         ====================================================================-->
    <xsl:template match="jp:amendment-a51 | jp:amendment-a523">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
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
        </xsl:element>
    </xsl:template>
    <schema:object
        name="amendment-a51-a523">
        <schema:property name="tag" type="string"
                         enum="jp:amendment-a51,jp:amendment-a523" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.xsl" name="document-code" />
                <schema:ref file="pat_common.xsl" name="file-reference-id" />
                <schema:ref file="pat_common.xsl" name="submission-date" />
                <schema:ref file="pat_common.xsl" name="addressed-to-person" />
                <schema:ref file="pat_common.xsl" name="indication-of-case-article" />
                <schema:ref file="pat_common.xsl" name="proof-necessity" />
                <schema:ref file="pat_common.xsl" name="applicants" />
                <schema:ref file="pat_common.xsl" name="agents" />
                <schema:ref file="pat_common.xsl" name="dispatch-number" />
                <schema:ref file="pat_common.xsl" name="dispatch-date" />
                <schema:ref file="pat_common.xsl" name="num-claim-decrease-amendment" />
                <schema:ref file="pat_common.xsl" name="num-claim-increase-amendment" />
                <schema:ref file="pat_common.xsl" name="amendment-article" />
                <schema:ref file="pat_common.xsl" name="amendment-charge-article" />
                <schema:ref file="pat_common.xsl" name="proof-means" />
                <schema:ref file="pat_common.xsl" name="share-rate" />
                <schema:ref file="pat_common.xsl" name="charge-article" />
                <schema:ref file="pat_common.xsl" name="dtext" />
                <schema:ref file="pat_common.xsl" name="submission-object-list-article" />
                <schema:ref file="pat_common.xsl" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:amendment-a524 誤訳訂正書
         ====================================================================-->
    <xsl:template match="jp:amendment-a524">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
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
        </xsl:element>
    </xsl:template>
    <schema:object
        name="amendment-a524">
        <schema:property name="tag" type="string"
                         const="jp:amendment-a524" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="document-code" />
                <schema:ref file="pat_common.json" name="file-reference-id" />
                <schema:ref file="pat_common.json" name="submission-date" />
                <schema:ref file="pat_common.json" name="addressed-to-person" />
                <schema:ref file="pat_common.json" name="indication-of-case-article" />
                <schema:ref file="pat_common.json" name="proof-necessity" />
                <schema:ref file="pat_common.json" name="applicants" />
                <schema:ref file="pat_common.json" name="agents" />
                <schema:ref file="pat_common.json" name="dispatch-number" />
                <schema:ref file="pat_common.json" name="dispatch-date" />
                <schema:ref file="pat_common.json" name="num-claim-decrease-amendment"/>
                <schema:ref file="pat_common.json" name="num-claim-increase-amendment"/>
                <schema:ref file="pat_common.json" name="amendment-article" />
                <schema:ref file="pat_common.json" name="opinion-contents-article"/>
                <schema:ref file="pat_common.json" name="share-rate" />
                <schema:ref file="pat_common.json" name="charge-article" />
                <schema:ref file="pat_common.json" name="dtext" />
                <schema:ref file="pat_common.json" name="submission-object-list-article" />
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    
    <!-- ====================================================================
         jp:amendment-a525 | jp:amendment-a529
         特許協力条約第１９条補正の翻訳文提出書 | 特許協力条約第３４条補正の翻訳文提出書
         ====================================================================-->
    <xsl:template match="jp:amendment-a525 | jp:amendment-a529">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
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
        </xsl:element>
    </xsl:template>
    <schema:object
        name="amendment-a525-a529">
        <schema:property name="tag" type="string"
                         enum="jp:amendment-a525,jp:amendment-a529" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="document-code" />
                <schema:ref file="pat_common.json" name="file-reference-id" />
                <schema:ref file="pat_common.json" name="submission-date" />
                <schema:ref file="pat_common.json" name="addressed-to-person" />
                <schema:ref file="pat_common.json" name="indication-of-case-article" />
                <schema:ref file="pat_common.json" name="proof-necessity" />
                <schema:ref file="pat_common.json" name="applicants" />
                <schema:ref file="pat_common.json" name="agents" />
                <schema:ref file="pat_common.json" name="submit-date-of-amendment" />
                <schema:ref file="pat_common.json" name="num-claim-decrease-amendment"/>
                <schema:ref file="pat_common.json" name="num-claim-increase-amendment"/>
                <schema:ref file="pat_common.json" name="amendment-article" />
                <schema:ref file="pat_common.json" name="dtext" />
                <schema:ref file="pat_common.json" name="submission-object-list-article" />
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:amendment-a526 | jp:amendment-a5210
         特許協力条約第１９条補正の翻訳文提出書（職権） |
         特許協力条約第３４条補正の翻訳文提出書（職権）
         ====================================================================-->
    <xsl:template match="jp:amendment-a526 | jp:amendment-a5210">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
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
        </xsl:element>
    </xsl:template>
    <schema:object
        name="amendment-a526-a5210">
        <schema:property name="tag" type="string"
                         enum="jp:amendment-a526,jp:amendment-a5210" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="document-code" />
                <schema:ref file="pat_common.json" name="file-reference-id" />
                <schema:ref file="pat_common.json" name="submission-date" />
                <schema:ref file="pat_common.json" name="addressed-to-person" />
                <schema:ref file="pat_common.json" name="indication-of-case-article" />
                <schema:ref file="pat_common.json" name="proof-necessity" />
                <schema:ref file="pat_common.json" name="applicants" />
                <schema:ref file="pat_common.json" name="agents" />
                <schema:ref file="pat_common.json" name="submit-date-of-amendment" />
                <schema:ref file="pat_common.json" name="num-claim-decrease-amendment"/>
                <schema:ref file="pat_common.json" name="num-claim-increase-amendment"/>
                <schema:ref file="pat_common.json" name="notice-contents-group" />
                <schema:ref file="pat_common.json" name="amendment-article" />
                <schema:ref file="pat_common.json" name="dtext" />
                <schema:ref file="pat_common.json" name="submission-object-list-article" />
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:amendment-a527 | jp:amendment-a5211
         特許協力条約第１９条補正の写し提出書 |
         特許協力条約第３４条補正の写し提出書
         ====================================================================-->
    <xsl:template match="jp:amendment-a527 | jp:amendment-a5211">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
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
        </xsl:element>
    </xsl:template>
    <schema:object
        name="amendment-a527-a5211">
        <schema:property name="tag" type="string"
                         enum="jp:amendment-a527,jp:amendment-a5211" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="document-code" />
                <schema:ref file="pat_common.json" name="file-reference-id" />
                <schema:ref file="pat_common.json" name="submission-date" />
                <schema:ref file="pat_common.json" name="addressed-to-person" />
                <schema:ref file="pat_common.json" name="indication-of-case-article" />
                <schema:ref file="pat_common.json" name="proof-necessity" />
                <schema:ref file="pat_common.json" name="applicants" />
                <schema:ref file="pat_common.json" name="agents" />
                <schema:ref file="pat_common.json" name="submit-date-of-amendment" />
                <schema:ref file="pat_common.json" name="num-claim-decrease-amendment"/>
                <schema:ref file="pat_common.json" name="num-claim-increase-amendment"/>
                <schema:ref file="pat_common.json" name="dtext" />
                <schema:ref file="pat_common.json" name="submission-object-list-article" />
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
    
    <!-- ====================================================================
         jp:amendment-a528 | jp:amendment-a5212
         特許協力条約第１９条補正の写し提出書（職権） |
         特許協力条約第３４条補正の写し提出書（職権）
         ====================================================================-->
    <xsl:template match="jp:amendment-a528 | jp:amendment-a5212">
        <xsl:element name="blocks">
            <xsl:element name="tag">
                <xsl:value-of select="name()" />
            </xsl:element>
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
        </xsl:element>
    </xsl:template>
    <schema:object name="amendment-a528-a5212">
        <schema:property name="tag" type="string"
                         enum="jp:amendment-a528,jp:amendment-a5212" />
        <schema:property name="blocks" type="array">
            <schema:anyOf>
                <schema:ref file="pat_common.json" name="document-code" />
                <schema:ref file="pat_common.json" name="file-reference-id" />
                <schema:ref file="pat_common.json" name="submission-date" />
                <schema:ref file="pat_common.json" name="addressed-to-person" />
                <schema:ref file="pat_common.json" name="indication-of-case-article" />
                <schema:ref file="pat_common.json" name="proof-necessity" />
                <schema:ref file="pat_common.json" name="applicants" />
                <schema:ref file="pat_common.json" name="agents" />
                <schema:ref file="pat_common.json" name="submit-date-of-amendment" />
                <schema:ref file="pat_common.json" name="num-claim-decrease-amendment"/>
                <schema:ref file="pat_common.json" name="num-claim-increase-amendment"/>
                <schema:ref file="pat_common.json" name="notice-contents-group" />
                <schema:ref file="pat_common.json" name="dtext" />
                <schema:ref file="pat_common.json" name="submission-object-list-article" />
                <schema:ref file="pat_common.json" name="rule-outside-item-article" />
            </schema:anyOf>
        </schema:property>
    </schema:object>
</xsl:stylesheet>