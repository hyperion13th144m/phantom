<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp">
    <xsl:output method="html" encoding="UTF-16" />

    <xsl:variable name="sp" select="'&#160;'" /> <!--　半角空白の代わり　-->
    <xsl:variable name="zero" select="'0'" />
    <xsl:variable name="kuhaku" select="'　'" />
    <!-- 2003/04/03 delete
<xsl:variable name="hankaku" select="'1234567890-ABCDEFGHIJKLMNOPQRSTUVWXYZ,:/'" />
<xsl:variable name="zenkaku" select="'１２３４５６７８９０－ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ，：／'" />
     2003/04/03 delete -->
    <!--Y09M01
    V2PC-ST 'の全角対応 2008/07/03 Start-->
    <!-- Y06M04 start -->
    <!--
<xsl:variable name="hankaku"
    select="'1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ().,-/!#$%*+:;=?@[\]^_`{|}~&amp;&quot;&lt;&gt;'"
    />
<xsl:variable name="zenkaku"
    select="'１２３４５６７８９０ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ（）．，－／！＃＄％＊＋：；＝？＠［￥］＾＿‘｛｜｝～＆”＜＞'"
    />
-->
    <!-- Y06M04 end -->
    <xsl:variable name="hankaku"
        select="'1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ().,-/!#$%*+:;=?@[\]^_`{|}~&amp;&quot;&lt;&gt;&#160;'" />
    <xsl:variable name="zenkaku"
        select="'１２３４５６７８９０ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ（）．，－／！＃＄％＊＋：；＝？＠［￥］＾＿‘｛｜｝～＆”＜＞　'" />
    <xsl:variable name="hankaku-apos" select='"&apos;"' />
    <xsl:variable name="zenkaku-apos" select="'’'" />
    <!--Y09M01
    V2PC-ST 'の全角対応 2008/07/03 Start-->
    <xsl:variable name="hankaku2" select="'1234567890-ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
    <xsl:variable name="zenkaku2" select="'１２３４５６７８９　－ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ'" />
    <!-- 2006/10/19 庁内印刷対応追加 「substring(name(*),1,6) = 'jp:prt'」 start -->
    <!-- 2003/02/27 同じ書類でも発送と閲覧で仕様するＤＴＤが違うことを考慮していなかった start -->

    <!-- ====================================================================
     jp:certification-column-article
     ====================================================================-->
    <!-- 認証欄  -->
    <xsl:template match="jp:certification-column-article">


        <!--  2005-2007年度マルチ対応 【IT-Y08M01M-H0042】 
          <u>タグをV4_INDENTで囲む Start-->
        <xsl:element name="V4_INDENT">
            <xsl:attribute name="COL">1</xsl:attribute>
            <xsl:attribute name="COE">36</xsl:attribute>
            <U>
                <xsl:value-of select="'　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　'" />
            </U>
            <BR />
        </xsl:element>
        <!--  2005-2007年度マルチ対応 【IT-Y08M01M-H0042】 End-->

        <!--2007/05/01
        庁内印刷対応　イメージと認証欄の出力順を逆にする(仕様通り) Start-->
        <!--<xsl:apply-templates
        select="img" />
  <xsl:apply-templates select="jp:certification-column-group" />-->
        <!--2007/06/13
        修正
  <xsl:choose>
    <xsl:when test="($multi = 'yes') or ($chonai = 'yes')">
      <xsl:apply-templates select="jp:certification-column-group" />
      <xsl:apply-templates select="img" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="img" />
      <xsl:apply-templates select="jp:certification-column-group" />
    </xsl:otherwise>
  </xsl:choose>-->
        <xsl:apply-templates select="jp:certification-column-group" />
        <xsl:apply-templates select="img" />
        <!--2007/05/01
        庁内印刷対応　イメージと認証欄の出力順を逆にする(仕様通り) End-->


        <!--  2005-2007年度マルチ対応 End-->
    </xsl:template>

    <!-- ====================================================================
     jp:inquiry-article
     ====================================================================-->
    <!-- 問い合わせ文  -->
    <xsl:template match="jp:inquiry-article">

        <!--  2005-2007年度マルチ対応 【IT-Y08M01M-H0042】 
          <u>タグをV4_INDENTで囲む Start-->
        <xsl:element name="V4_INDENT">
            <xsl:attribute name="COL">1</xsl:attribute>
            <xsl:attribute name="COE">36</xsl:attribute>
            <U>
                <xsl:value-of select="'　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　'" />
            </U>
            <BR />
        </xsl:element>
        <!--  2005-2007年度マルチ対応 【IT-Y08M01M-H0042】 End-->

        <xsl:apply-templates select="p" />
        <xsl:apply-templates select="jp:inquiry-staff-group" />
        <xsl:apply-templates select="jp:phone" />
        <xsl:apply-templates select="jp:fax" />

        <!--2007/05/01
        無駄な<BR>タグの削除(仕様通り)  Start-->
        <!--<xsl:if
        test="not(jp:inquiry-staff-group)" >
    <BR/>
  </xsl:if>
  <BR/>-->
        <!--2007/05/01
        無駄な<BR>タグの削除(仕様通り)  End-->

    </xsl:template>

    <!-- ====================================================================
     img
     ====================================================================-->
    <!-- イメージ  -->
    <xsl:template match="img">

        <xsl:element name="IMG">
            <xsl:attribute name="SRC">
                <xsl:value-of select="./@file" />
            </xsl:attribute>
            <xsl:attribute name="WIDTH">
                <xsl:value-of select="./@wi" />
            </xsl:attribute>
            <xsl:attribute name="HEIGHT">
                <xsl:value-of select="./@he" />
            </xsl:attribute>
            <!-- 2005-2007年度マルチ対応/庁内共通化 Xalan差異修正 Start-->

            <!-- 2005-2007年度マルチ対応/庁内共通化 Xalan差異修正 End-->
        </xsl:element>
        <!--BR/-->

    </xsl:template>

    <!-- ====================================================================
     jp:certification-column-article/img
     ====================================================================-->
    <!-- 認証イメージ  -->
    <xsl:template match="jp:certification-column-article/img">

        <xsl:element name="IMG">
            <xsl:attribute name="SRC">
                <xsl:value-of select="./@file" />
            </xsl:attribute>
            <xsl:attribute name="WIDTH">
                <xsl:value-of select="./@wi" />
            </xsl:attribute>
            <xsl:attribute name="HEIGHT">
                <xsl:value-of select="./@he" />
            </xsl:attribute>
            <!-- 2005-2007年度マルチ対応/庁内共通化 Xalan差異修正 Start-->

            <!-- 2005-2007年度マルチ対応/庁内共通化 Xalan差異修正 End-->
            <xsl:attribute name="ALIGN">
                <xsl:value-of select="'right'" />
            </xsl:attribute>
        </xsl:element>

    </xsl:template>

    <!-- ====================================================================
     jp:certification-column-group
     ====================================================================-->
    <!-- 認証文 -->
    <xsl:template match="jp:certification-column-group">

        <xsl:apply-templates select="p[1]" />
        <xsl:apply-templates select="jp:certification-group" />

        <xsl:choose>
            <xsl:when test="p[2]">
                <xsl:apply-templates select="p[2]" />
                <xsl:if test="jp:phone">
                    <xsl:apply-templates select="jp:phone" />
                    <xsl:apply-templates select="jp:fax" />
                    <!--2007/05/01
                    無駄な<BR>タグの削除(仕様通り) Start-->
                    <!--<BR/>-->
                    <!--2007/05/01
                    無駄な<BR>タグの削除(仕様通り) End-->
                </xsl:if>
            </xsl:when>

            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="jp:inclusion-payment-group">
                        <xsl:apply-templates select="jp:inclusion-payment-group" />
                        <!--2007/05/01
                        無駄な<BR>タグの削除(仕様通り) Start-->
                        <!--<BR/>-->
                        <!--2007/05/01
                        無駄な<BR>タグの削除(仕様通り) End-->
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- delete 2003/02/06
           <xsl:if test="string-length(p[1]) &lt; 31" >
           <BR/>        
          </xsl:if>
        -->
                        <!--2007/05/01
                        無駄な<BR>タグの削除(仕様通り) Start-->
                        <!--<BR/>-->
                        <!-- 庁内印刷対応 2007/03/15 BRタグの出力 Start-->
                        <!--<xsl:choose>
            <xsl:when test="$chonai='yes'">
              <xsl:if test="not(following-sibling::img)">
                <BR/>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="not(following::img)">
                <BR/>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>-->
                        <!-- 庁内印刷対応 2007/03/15 BRタグの出力 End-->
                        <!--2007/05/01
                        無駄な<BR>タグの削除(仕様通り) End-->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- ====================================================================
     jp:certification-column-group/p | jp:inquiry-article/p
     ====================================================================-->
    <!-- 段落 -->
    <xsl:template match="jp:certification-column-group/p | jp:inquiry-article/p">

        <xsl:choose>
            <xsl:when test="ancestor::jp:certification-column-group">
                <xsl:choose>
                    <!--Y08M01J
                    ST-Y08M01J-H038 2007/11/02-->
                    <!--<xsl:when
                    test="string-length(.) &gt; 30" >-->
                    <xsl:when test="string-length(normalize-space(.)) &gt; 30"> <!--
                        ３１桁以上の場合、V4_INDENT　を使用 -->
                        <xsl:element name="V4_INDENT">
                            <xsl:attribute name="COL">1</xsl:attribute>
                            <xsl:attribute name="COE">30</xsl:attribute>
                            <xsl:apply-templates />
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates />
            </xsl:otherwise>
        </xsl:choose>

        <!--2007/05/01
        無駄な<BR>タグの削除(仕様通り) Start-->
        <!--<xsl:variable
        name="kakunin1">
    <xsl:apply-templates select="." mode="kakunin" />
  </xsl:variable>
  <xsl:variable name="kakunin2" select="string-length(normalize-space($kakunin1))" />

  <xsl:if test="substring(normalize-space($kakunin1),$kakunin2 - 7,8) != '**exit**'" >--><!--
        2005-2007年度マルチ対応 Xalan差異修正 -->
        <!-- <BR/>
  </xsl:if>-->
        <BR />
        <!--2007/05/01
        無駄な<BR>タグの削除(仕様通り) End-->

    </xsl:template>

    <!-- ====================================================================
     jp:inquiry-staff-group
     ====================================================================-->
    <!-- 担当者情報 -->
    <xsl:template match="jp:inquiry-staff-group">

        <xsl:apply-templates select="jp:division" />
        <xsl:apply-templates select="jp:name" />
        <BR />

        <!-- 未サポート -->
        <xsl:if test="jp:guidance">
            <xsl:element name="SAMP">
                <BR />
                <xsl:apply-templates select="jp:guidance" />
            </xsl:element>
        </xsl:if>

    </xsl:template>

    <!-- ====================================================================
     jp:certification-group
     ====================================================================-->
    <!--  認証情報 -->
    <xsl:template match="jp:certification-group">
        <!-- 2003/03/04 start -->
        <!--Y08M01J
        ST-Y08M01J-H038 2007/11/02-->
        <!--<xsl:variable
        name="length_of_cg" select="20 + string-length(child::jp:name)"/>-->
        <xsl:variable name="length_of_cg"
            select="20 + string-length(normalize-space(child::jp:name))" />
        <xsl:choose>
            <xsl:when test="$length_of_cg &gt; 30">
                <xsl:element name="V4_INDENT">
                    <xsl:attribute name="COL">1</xsl:attribute>
                    <xsl:attribute name="COE">30</xsl:attribute>
                    <xsl:apply-templates select="jp:date" />
                    <xsl:apply-templates select="jp:official-title" />
                    <xsl:apply-templates select="jp:name" />
                </xsl:element>
                <BR />
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="jp:date" />
                <xsl:apply-templates select="jp:official-title" />
                <xsl:apply-templates select="jp:name" />
                <BR />
            </xsl:otherwise>
        </xsl:choose>
        <!-- 2003/03/04 end -->
    </xsl:template>

    <!-- ====================================================================
     jp:inclusion-payment-group
     ====================================================================-->
    <!--  包括納付情報 -->
    <xsl:template match="jp:inclusion-payment-group">

        <xsl:value-of select="'包括納付対象案件　'" />
        <xsl:apply-templates select="jp:account" />
        <xsl:apply-templates select="jp:payment-years" />
        <!--2007/05/01
        無駄な<BR>タグの削除(仕様通り) Start-->
        <!--<BR/>-->
        <!--2007/05/01
        無駄な<BR>タグの削除(仕様通り) End-->

    </xsl:template>

    <!-- ====================================================================
     jp:certification-column-group/jp:phone |
     jp:inquiry-article//jp:phone
     ====================================================================-->
    <!--  電話番号 -->
    <xsl:template
        match="jp:certification-column-group/jp:phone
                   | jp:inquiry-article//jp:phone">
        <!--Y08M01J
        ST-Y08M01J-H038 2007/11/02 Start-->
        <!--<xsl:variable
        name="tel1" select="string-length(substring-before(.,'-'))" />-->
        <xsl:variable name="tel1" select="string-length(substring-before(normalize-space(.),'-'))" />
        <xsl:variable name="tel2"
            select="string-length(substring-before(substring(normalize-space(.),$tel1 + 2),'-'))" />
        <xsl:variable name="tel3"
            select="string-length(substring-before(substring(normalize-space(.),$tel1 + $tel2 + 3),'('))" />
        <xsl:variable name="tel4"
            select="string-length(substring-before(substring(normalize-space(.),$tel1 + $tel2 + $tel3 + 4),')'))" />

        <!--  項目名の編集  -->
        <xsl:choose>
            <xsl:when test="ancestor::jp:inquiry-article">
                <xsl:value-of select="'　電話　'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'電話'" />
            </xsl:otherwise>
        </xsl:choose>

        <!--  項目内容の編集  -->
        <xsl:choose>
            <xsl:when test="./@jp:error-code">
                <xsl:value-of select="." />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="concat(substring(normalize-space(.),1,$tel1),'(',
                                  substring(normalize-space(.),($tel1 + 2),$tel2),')',
                                  substring(normalize-space(.),($tel1 + $tel2 + 3),$tel3),'　内線',
                                  substring(normalize-space(.),($tel1 + $tel2 + $tel3 + 4),$tel4))" />
            </xsl:otherwise>
        </xsl:choose>
        <!--Y08M01J
        ST-Y08M01J-H038 2007/11/02 End-->
        <!--Y24M04
        発送手続のデジタル化対応 2023/08/01 Start-->
        <xsl:if test="ancestor::jp:notice-transmit">
            <BR />
        </xsl:if>
        <!--Y24M04
        発送手続のデジタル化対応 2023/08/01 End-->
    </xsl:template>

    <!-- ====================================================================
     jp:certification-column-group/jp:fax |
     jp:inquiry-article//jp:fax
     ====================================================================-->
    <!--  ファクシミリ番号 -->
    <xsl:template
        match="jp:certification-column-group/jp:fax
                   | jp:inquiry-article//jp:fax">
        <!--Y24M04
        発送手続のデジタル化対応 2023/08/01 Start-->
        <xsl:if test="not(ancestor::jp:notice-transmit)">
            <!--Y24M04
            発送手続のデジタル化対応 2023/08/01 End-->
            <!--Y08M01J
            ST-Y08M01J-H038 2007/11/02 Start-->
            <!--<xsl:variable
            name="fax1" select="string-length(substring-before(.,'-'))" />-->
            <xsl:variable name="fax1"
                select="string-length(substring-before(normalize-space(.),'-'))" />
            <xsl:variable name="fax2"
                select="string-length(substring-before(substring(normalize-space(.),$fax1 + 2),'-'))" />
            <xsl:variable name="fax3"
                select="string-length(substring(normalize-space(.),$fax1 + $fax2 + 3))" />

            <!--  項目名の編集  -->
            <xsl:choose>
                <xsl:when test="ancestor::jp:inquiry-article">
                    <xsl:value-of select="'　　　ファクシミリ　'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'　　　ファクシミリ'" />
                </xsl:otherwise>
            </xsl:choose>

            <!--  項目内容の編集  -->
            <xsl:choose>
                <xsl:when test="./@jp:error-code">
                    <xsl:value-of select="." />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat(substring(normalize-space(.),1,$fax1),'(',
                              substring(normalize-space(.),($fax1 + 2),$fax2),')',
                              substring(normalize-space(.),($fax1 + $fax2 + 3),$fax3))" />
                </xsl:otherwise>
            </xsl:choose>
            <!--Y08M01J
            ST-Y08M01J-H038 2007/11/02 End-->
            <!--2007/05/01
            項目内容編集後の改行を追加(仕様通り)  Start-->
            <BR />
            <!--2007/05/01
            項目内容編集後の改行を追加(仕様通り)  End-->
            <!--Y24M04
            発送手続のデジタル化対応 2023/08/01 Start-->
        </xsl:if>
        <!--Y24M04
        発送手続のデジタル化対応 2023/08/01 End-->

    </xsl:template>

    <!-- ====================================================================
     jp:division
     ====================================================================-->
    <!-- 所属  -->
    <xsl:template match="jp:division">
        <xsl:variable name="division" select="translate(.,' ','')" />

        <!--  項目内容の編集  -->
        <xsl:value-of select="concat('　',substring($division,1,15))" />

        <xsl:if test="string-length($division) &lt; 15">
            <xsl:call-template name="空白">
                <xsl:with-param name="i" select="16 - string-length($division)" />
                <xsl:with-param name="count" select="1" />
            </xsl:call-template>
        </xsl:if>

    </xsl:template>

    <!-- ====================================================================
     jp:account
     ====================================================================-->
    <!-- 予納台帳番号・納付書番号  -->
    <xsl:template match="jp:account">

        <!--  項目名の編集  -->
        <xsl:choose>
            <xsl:when test="./@account-type = 'deposit'">
                <xsl:value-of select="'予納台帳番号　'" />
            </xsl:when>
            <!--Y09M01
            2007/10/01 Start-->
            <xsl:when test="./@account-type = 'transfer'">
                <xsl:value-of select="'振替番号　　　'" />
            </xsl:when>
            <!--Y09M01
            2007/10/01 End-->
            <xsl:otherwise>
                <xsl:value-of select="'納付書番号　　'" />
            </xsl:otherwise>
        </xsl:choose>

        <!--  項目内容の編集  -->
        <xsl:choose>
            <xsl:when test="./@jp:error-code">
                <xsl:value-of select="./@number" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="translate(./@number,$hankaku,$zenkaku)" />
            </xsl:otherwise>
        </xsl:choose>
        <BR />

    </xsl:template>

    <!-- ====================================================================
     jp:certification-group/jp:date
     ====================================================================-->
    <!-- 認証・日付  -->
    <xsl:template match="jp:certification-group/jp:date">

        <!--  項目名の編集  -->
        <xsl:value-of select="'認証日　'" />

        <!--  項目内容の編集  -->
        <xsl:choose>
            <xsl:when test="./@jp:error-code">
                <xsl:value-of select="." />
            </xsl:when>
            <!--Y08M01J
            ST-Y08M01J-H038 2007/11/02 Start-->
            <!--<xsl:when
            test=". = 0 or string-length(.) = 0">-->
            <xsl:when test="number(.) = 0 or string-length(normalize-space(.)) = 0">
                <xsl:value-of select="'　　　　　　　　'" /> <!-- 2004/08/05 一部修正 -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="日付変換半角" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- ====================================================================
     jp:certification-group/jp:name
     ====================================================================-->
    <!-- 認証・名前  -->
    <xsl:template match="jp:certification-group/jp:name">

        <!--  項目内容の編集  -->
        <xsl:value-of select="'　'" />
        <!--Y08M01J
        ST-Y08M01J-H038 2007/11/02-->
        <!--<xsl:value-of
        select="." />-->
        <xsl:value-of select="normalize-space(.)" />
        <!--  2003/03/04 delete 
  <xsl:if test="string-length(.) &lt; 9" >
    <xsl:call-template name="空白">
      <xsl:with-param name="i" select="10 - string-length(.)" />
      <xsl:with-param name="count" select="1" />
    </xsl:call-template>
  </xsl:if>  -->
    </xsl:template>

    <!-- ====================================================================
     jp:inquiry-article/jp:name
     ====================================================================-->
    <!-- 2004/08/05 start -->
    <!-- 担当者・名前  -->
    <xsl:template match="jp:inquiry-staff-group/jp:name">
        <!--Y08M01J
        ST-Y08M01J-H038 2007/11/02-->
        <!--<xsl:value-of
        select="." />-->
        <xsl:value-of select="normalize-space(.)" />
    </xsl:template>
    <!-- 2004/08/05 end -->

    <!-- ====================================================================
     jp:certification-group/jp:official-title
     ====================================================================-->
    <!-- 認証・役職名  -->
    <xsl:template match="jp:certification-group/jp:official-title">

        <!--  項目内容の編集  -->
        <xsl:value-of select="'　'" />
        <!--Y08M01J
        ST-Y08M01J-H038 2007/11/02 Start-->
        <!--<xsl:value-of
        select="." />-->
        <xsl:value-of select="normalize-space(.)" />
        <xsl:if test="string-length(normalize-space(.)) &lt; 7">
            <xsl:call-template name="空白">
                <xsl:with-param name="i" select="8 - string-length(normalize-space(.))" />
                <xsl:with-param name="count" select="1" />
            </xsl:call-template>
        </xsl:if>
        <!--Y08M01J
        ST-Y08M01J-H038 2007/11/02 End-->
    </xsl:template>

    <!-- ====================================================================
     jp:payment-years
     ====================================================================-->
    <!-- 納付年分     -->
    <xsl:template match="jp:payment-years">

        <!--  項目名の編集  -->
        <xsl:value-of select="'　　　　　　　　　納付年分　　　'" />

        <!--  項目内容の編集  -->
        <xsl:apply-templates select="jp:year-from" />
        <xsl:apply-templates select="jp:year-to" />
        <BR />

    </xsl:template>

    <!-- ====================================================================
     jp:year-from
     ====================================================================-->
    <!-- 納付年分（自） -->
    <xsl:template match="jp:year-from">

        <xsl:choose>
            <!--Y08M01J
            ST-Y08M01J-H038 2007/11/02 Start-->
            <xsl:when test="./@jp:error-code">
                <xsl:value-of select="." />
                <xsl:value-of select="'年～'" />
            </xsl:when>
            <xsl:when test="string-length(normalize-space(.)) = 0" />
            <xsl:otherwise>
                <xsl:choose>
                    <!--<xsl:when
                    test="string-length(.) = 0" >
          <xsl:value-of select="'　０'" />
        </xsl:when>-->
                    <xsl:when test="string-length(normalize-space(.)) = 1">
                        <xsl:value-of select="'　'" />
                        <xsl:value-of select="translate(normalize-space(.),$hankaku,$zenkaku)" />
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space(.)) = 2">
                        <xsl:value-of
                            select="translate(substring(normalize-space(.),1,1),$hankaku2,$zenkaku2)" />
                        <xsl:value-of
                            select="translate(substring(normalize-space(.),2,1),$hankaku,$zenkaku)" />
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of select="'年～'" />
            </xsl:otherwise>
        </xsl:choose>
        <!--Y08M01J
        ST-Y08M01J-H038 2007/11/02 End-->

    </xsl:template>

    <!-- ====================================================================
     jp:year-to
     ====================================================================-->
    <!-- 納付年分（至） -->
    <xsl:template match="jp:year-to">

        <xsl:choose>
            <!--Y08M01J
            ST-Y08M01J-H038 2007/11/02 Start-->
            <xsl:when test="./@jp:error-code">
                <xsl:value-of select="." />
                <xsl:value-of select="'年分'" />
            </xsl:when>
            <xsl:when test="string-length(normalize-space(.)) = 0" />
            <xsl:otherwise>
                <xsl:choose>
                    <!--<xsl:when
                    test="string-length(.) = 0" >
          <xsl:value-of select="'　０'" />
        </xsl:when>-->
                    <xsl:when test="string-length(normalize-space(.)) = 1">
                        <xsl:value-of select="'　'" />
                        <xsl:value-of select="translate(normalize-space(.),$hankaku,$zenkaku)" />
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space(.)) = 2">
                        <xsl:value-of
                            select="translate(substring(normalize-space(.),1,1),$hankaku2,$zenkaku2)" />
                        <xsl:value-of
                            select="translate(substring(normalize-space(.),2,1),$hankaku,$zenkaku)" />
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of select="'年分'" />
            </xsl:otherwise>
        </xsl:choose>
        <!--Y08M01J
        ST-Y08M01J-H038 2007/11/02 End-->

    </xsl:template>

    <!-- ====================================================================
     日付変換半角
     ====================================================================-->
    <xsl:template name="日付変換半角">
        <!--Y08M01J
        ST-Y08M01J-H038 2007/11/02 Start-->
        <!--<xsl:variable
        name="hyy" select="substring(.,1,4) - 1988" />--> <!--平成の年-->
        <xsl:variable name="hyy" select="substring(normalize-space(.),1,4) - 1988" /> <!--平成の年-->
        <xsl:variable name="syy" select="63 - (1988 - substring(normalize-space(.),1,4))" /> <!--昭和の年-->
        <xsl:variable name="seireki" select="substring(normalize-space(.),1,4)" />   <!--西暦年-->
        <xsl:variable name="gappi" select="substring(normalize-space(.),5,4)" />     <!--月日-->
        <xsl:variable name="m1" select="substring(normalize-space(.),5,1)" />        <!--月の十の位-->
        <xsl:variable name="m2" select="substring(normalize-space(.),6,1)" />        <!--月の一の位-->
        <xsl:variable name="d1" select="substring(normalize-space(.),7,1)" />        <!--日の十の位-->
        <xsl:variable name="d2" select="substring(normalize-space(.),8,1)" />        <!--日の一の位-->
        <!--Y08M01J
        ST-Y08M01J-H038 2007/11/02 End-->
        <xsl:choose>
            <!--Y19M04
            2018/05/08 元号変更対応 Start-->
            <xsl:when test="normalize-space(.) &gt;= 20190501">
                <xsl:call-template name="gengo">
                    <xsl:with-param name="date" select="normalize-space(.)" />
                </xsl:call-template>
                <xsl:variable name="wareki">
                    <xsl:call-template name="warekinen">
                        <xsl:with-param name="date" select="normalize-space(.)" />
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="$wareki &lt; 10">
                    <xsl:value-of select="$sp" />
                </xsl:if>
                <xsl:value-of select="concat($wareki,'年')" />
            </xsl:when>
            <!--Y19M04
            2018/05/08 元号変更対応 End-->
            <xsl:when test="$seireki = 1989">
                <xsl:choose>
                    <xsl:when test="$gappi &gt;= 108">
                        <xsl:value-of select="concat('平成',$sp,$hyy,'年')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('昭和',$syy,'年')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$seireki &gt; 1989">
                <xsl:value-of select="'平成'" />
                <xsl:if test="$hyy &lt; 10">
                    <xsl:value-of select="$sp" />
                </xsl:if>
                <xsl:value-of select="concat($hyy,'年')" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('昭和',$syy,'年')" />
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="$m1 = 0">
                <xsl:value-of select="concat($sp,$m2,'月')" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($m1,$m2,'月')" />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$d1 = 0">
                <!-- スペースとる様に変更　2002.12.18
      <xsl:value-of select="concat($sp,$d2,'日　')" />
-->
                <xsl:value-of select="concat($sp,$d2,'日')" />
            </xsl:when>
            <xsl:otherwise>
                <!-- スペースとる様に変更　2002.12.18
      <xsl:value-of select="concat($d1,$d2,'日　')" />
-->
                <xsl:value-of select="concat($d1,$d2,'日')" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- ====================================================================
     平成編集
    <xsl:template name="平成編集">
        <xsl:variable name="hyy" select="substring(normalize-space(.),1,4) - 1988" />
        <xsl:if test="string-length($hyy) = 1">
            <xsl:value-of select="'　'" />
        </xsl:if>

        <xsl:value-of select="concat(translate($hyy,$hankaku,$zenkaku),'年')" />

    </xsl:template>
     ====================================================================-->

    <!-- ====================================================================
     昭和編集
    <xsl:template name="昭和編集">
        <xsl:variable name="syy" select="63 - (1988 - substring(normalize-space(.),1,4))" />
        <xsl:if test="string-length($syy) = 1">
            <xsl:value-of select="'　'" />
        </xsl:if>

        <xsl:value-of select="concat(translate($syy,$hankaku,$zenkaku),'年')" />

    </xsl:template>
     ====================================================================-->

    <!-- 2003/02/23 大正・明治・不明の対応 start -->
    <!-- ====================================================================
     大正編集
     ====================================================================-->
    <xsl:template name="大正編集">
        <!--Y08M01J
        ST-Y08M01J-H038 2007/11/02-->
        <!--<xsl:variable
        name="tyy" select="15 - (1926 - substring(.,1,4))" />-->
        <xsl:variable name="tyy" select="15 - (1926 - substring(normalize-space(.),1,4))" />
        <xsl:if test="string-length($tyy) = 1">
            <xsl:value-of select="'　'" />
        </xsl:if>

        <xsl:value-of select="concat(translate($tyy,$hankaku,$zenkaku),'年')" />

    </xsl:template>

    <!-- ====================================================================
     明治編集
     ====================================================================-->
    <xsl:template name="明治編集">
        <!--Y08M01J
        ST-Y08M01J-H038 2007/11/02-->
        <!--<xsl:variable
        name="myy" select="45 - (1912 - substring(.,1,4))" />-->
        <xsl:variable name="myy" select="45 - (1912 - substring(normalize-space(.),1,4))" />
        <xsl:if test="string-length($myy) = 1">
            <xsl:value-of select="'　'" />
        </xsl:if>

        <xsl:value-of select="concat(translate($myy,$hankaku,$zenkaku),'年')" />

    </xsl:template>
    <!-- 2003/02/23 end -->

    <!-- ====================================================================
     未サポートタグ（jp:guidance）
     ====================================================================-->
    <xsl:template match="jp:guidance">

        <xsl:call-template name="タグ編集">
            <xsl:with-param name="i" select="2" />
        </xsl:call-template>
        <BR />

    </xsl:template>

    <!-- ====================================================================
     タグ編集
     ====================================================================-->
    <xsl:template name="タグ編集">

        <xsl:param name="i" />
        <xsl:call-template name="空白">
            <xsl:with-param name="i" select="$i" />
            <xsl:with-param name="count" select="1" />
        </xsl:call-template>
        <xsl:value-of select="concat('&lt;',name())" />
        <xsl:apply-templates select="./@*" />
        <xsl:value-of select="concat('&gt;',.,'&lt;/',name(),'&gt;')" />

    </xsl:template>

    <!-- ====================================================================
     空白
     ====================================================================-->
    <xsl:template name="空白">
        <xsl:param name="i" />
        <!-- 何カラム目直前まで全角空白を入れる -->
        <xsl:param name="count" />
        <!-- 行カウント（初期値は'1'） -->

        <xsl:if test="$count &lt; $i">
            <xsl:value-of select="'　'" />
            <xsl:call-template name="空白">
                <xsl:with-param name="i" select="$i" />
                <xsl:with-param name="count" select="$count + 1" />
            </xsl:call-template>
        </xsl:if>

    </xsl:template>

    <!-- ====================================================================
     属性値出力
     ====================================================================-->
    <xsl:template match="@file | @he | @wi | @img-format |@img-content">

        <xsl:value-of select="concat($sp,name(),'=&quot;',.,'&quot;')" />

    </xsl:template>

</xsl:stylesheet>