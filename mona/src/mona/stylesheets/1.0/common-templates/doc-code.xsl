<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp">

    <!-- this xslt was created with reference to pat_common.xsl
         of Internet Application Software -->


    <!-- ====================================================================
            書類名変換
            長いのでこっちに移した
            INPUT: code e.g. A151
            OUTPUT: 書類名 e.g. 手続補正書（方式）
         ====================================================================-->
    <xsl:template
        name="書類名変換">

        <xsl:choose>
            <xsl:when test="parent::jp:amendment-group">
                <xsl:call-template name="書類名振り分け">
                    <xsl:with-param name="code"
                        select="normalize-space(parent::jp:amendment-group/jp:document-code)" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="parent::jp:contents-of-amendment">
                <xsl:call-template name="書類名振り分け">
                    <xsl:with-param name="code"
                        select="normalize-space(parent::jp:contents-of-amendment/jp:document-code)" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="parent::jp:amendment-charge-article">
                <xsl:call-template name="書類名振り分け">
                    <xsl:with-param name="code"
                        select="normalize-space(parent::jp:amendment-charge-article/jp:document-code)" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="parent::jp:target-document">
                <xsl:call-template name="書類名振り分け">
                    <xsl:with-param name="code"
                        select="normalize-space(parent:: jp:target-document/jp:document-code)" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="書類名振り分け">
                    <xsl:with-param name="code" select="normalize-space($doc-code)" />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- ====================================================================
     書類名振り分け
     ====================================================================-->
    <xsl:template
        name="書類名振り分け">
        <xsl:param name="code" />
        <xsl:variable name="firstChar" select="substring($code,1,1)" />
        <xsl:choose>
            <xsl:when test="$firstChar = 'A' ">
                <xsl:call-template name="書類名出願">
                    <xsl:with-param name="code" select="$code" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$firstChar = 'R' ">
                <xsl:call-template name="書類名登録">
                    <xsl:with-param name="code" select="$code" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$firstChar = 'E' ">
                <xsl:call-template name="書類名請求">
                    <xsl:with-param name="code" select="$code" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$firstChar = 'C' ">
                <xsl:call-template name="書類名審判">
                    <xsl:with-param name="code" select="$code" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="書誌編集エラー処理" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     書類名出願（Ａで始まる書類識別コード）
     ====================================================================-->
    <xsl:template
        name="書類名出願">
        <xsl:param name="code" />
        <xsl:choose>
            <xsl:when
                test="$code = 'A151' or $code = 'A251'
                 or $code = 'A351' or $code = 'A451'">
                <xsl:value-of select="'手続補正書（方式）'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1521' or $code = 'A2521'
                 or $code = 'A1522' or $code = 'A2522'
                 or $code = 'A1523' or $code = 'A2523'
                 or $code = 'A3523' or $code = 'A4523'">
                <xsl:value-of select="'手続補正書'" />
            </xsl:when>
            <xsl:when test="$code = 'A35231'">
                <xsl:value-of select="'手続補正書（複数）'" />
            </xsl:when>
            <xsl:when test="$code = 'A15210' or $code = 'A25210'">
                <xsl:value-of select="'特許協力条約第３４条補正の翻訳文提出書（職権）'" />
            </xsl:when>
            <xsl:when test="$code = 'A15211' or $code = 'A25211'">
                <xsl:value-of select="'特許協力条約第３４条補正の写し提出書'" />
            </xsl:when>
            <xsl:when test="$code = 'A15212' or $code = 'A25212'">
                <xsl:value-of select="'特許協力条約第３４条補正の写し提出書（職権）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1524' or $code = 'A2524'">
                <xsl:value-of select="'誤訳訂正書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1525' or $code = 'A2525'">
                <xsl:value-of select="'特許協力条約第１９条補正の翻訳文提出書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1526' or $code = 'A2526'">
                <xsl:value-of select="'特許協力条約第１９条補正の翻訳文提出書（職権）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1527' or $code = 'A2527'">
                <xsl:value-of select="'特許協力条約第１９条補正の写し提出書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1528' or $code = 'A2528'">
                <xsl:value-of select="'特許協力条約第１９条補正の写し提出書（職権）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1529' or $code = 'A2529'">
                <xsl:value-of select="'特許協力条約第３４条補正の翻訳文提出書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A153' or $code = 'A253'
                 or $code = 'A353' or $code = 'A453'">
                <xsl:value-of select="'意見書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A155' or $code = 'A255'
                 or $code = 'A355' or $code = 'A455'">
                <xsl:value-of select="'受継申立書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A159' or $code = 'A259'
                 or $code = 'A359' or $code = 'A459'">
                <xsl:value-of select="'弁明書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1601' or $code = 'A2601'
                 or $code = 'A3601' or $code = 'A4601'">
                <xsl:value-of select="'期間延長請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1621' or $code = 'A2621'">
                <xsl:value-of select="'出願審査請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'A2623'">
                <xsl:value-of select="'実用新案技術評価請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1625' or $code = 'A2625'">
                <xsl:value-of select="'出願審査請求書（他人）'" />
            </xsl:when>
            <xsl:when test="$code = 'A2626'">
                <xsl:value-of select="'国内処理請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1627'">
                <xsl:value-of select="'出願公開請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'A163'">
                <xsl:value-of select="'特許願'" />
            </xsl:when>
            <xsl:when test="$code = 'A263'">
                <xsl:value-of select="'実用新案登録願'" />
            </xsl:when>
            <xsl:when test="$code = 'A363'">
                <xsl:value-of select="'意匠登録願'" />
            </xsl:when>
            <xsl:when test="$code = 'A463'">
                <xsl:value-of select="'商標登録願'" />
            </xsl:when>
            <xsl:when test="$code = 'A3630'">
                <xsl:value-of select="'意匠登録願（複数）'" />
            </xsl:when>
            <xsl:when test="$code = 'A3636'">
                <xsl:value-of select="'類似意匠登録願'" />
            </xsl:when>
            <xsl:when test="$code = 'A4639'">
                <xsl:value-of select="'団体商標登録願'" />
            </xsl:when>
            <xsl:when test="$code = 'A1631'">
                <xsl:value-of select="'翻訳文提出書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1632' or $code = 'A2632'">
                <xsl:value-of select="'国内書面'" />
            </xsl:when>
            <xsl:when test="$code = 'A4632'">
                <xsl:value-of select="'防護標章登録願'" />
            </xsl:when>
            <xsl:when test="$code = 'A2633'">
                <xsl:value-of select="'図面の提出書'" />
            </xsl:when>
            <xsl:when test="$code = 'A4633'">
                <xsl:value-of select="'防護標章登録に基づく権利存続期間更新登録願'" />
            </xsl:when>
            <xsl:when test="$code = 'A1634' or $code = 'A2634'">
                <xsl:value-of select="'国際出願翻訳文提出書'" />
            </xsl:when>
            <xsl:when test="$code = 'A4634'">
                <xsl:value-of select="'書換登録申請書'" />
            </xsl:when>
            <xsl:when test="$code = 'A46341'">
                <xsl:value-of select="'外国語図面'" />
            </xsl:when>
            <xsl:when test="$code = 'A46342'">
                <xsl:value-of select="'外国語要約書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1635' or $code = 'A2635'">
                <xsl:value-of select="'国際出願翻訳文提出書（職権）'" />
            </xsl:when>
            <xsl:when test="$code = 'A4635'">
                <xsl:value-of select="'防護標章登録に基づく権利書換登録申請書'" />
            </xsl:when>
            <xsl:when test="$code = 'A4637'">
                <xsl:value-of select="'重複登録商標に係る商標権存続期間更新登録願'" />
            </xsl:when>
            <xsl:when test="$code = 'A4638'">
                <xsl:value-of select="'地域団体商標登録願'" />
            </xsl:when>
            <xsl:when test="$code = 'A167'">
                <xsl:value-of select="'受託番号変更届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1681' or $code = 'A2681'
                 or $code = 'A3681' or $code = 'A4681'">
                <xsl:value-of select="'代表者選定届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1691' or $code = 'A2691'
                 or $code = 'A3691' or $code = 'A4691'">
                <xsl:value-of select="'雑書類'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1711' or $code = 'A2711'
                 or $code = 'A3711' or $code = 'A4711'">
                <xsl:value-of select="'出願人名義変更届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1712' or $code = 'A2712'
                 or $code = 'A3712' or $code = 'A4712'">
                <xsl:value-of select="'出願人名義変更届（一般承継）'" />
            </xsl:when>
            <xsl:when test="$code = 'A4713'">
                <xsl:value-of select="'出願人名義変更届（特例商標登録出願）'" />
            </xsl:when>
            <xsl:when test="$code = 'A4714'">
                <xsl:value-of select="'出願人名義変更届（特例商標登録出願）（一般承継）'" />
            </xsl:when>
            <xsl:when test="$code = 'A4715'">
                <xsl:value-of select="'書換登録申請者名義変更届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17421' or $code = 'A27421'
                 or $code = 'A37421' or $code = 'A47421'">
                <xsl:value-of select="'代理人変更届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17422' or $code = 'A27422'
                 or $code = 'A37422' or $code = 'A47422'">
                <xsl:value-of select="'代理人受任届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17423' or $code = 'A27423'
                 or $code = 'A37423' or $code = 'A47423'">
                <xsl:value-of select="'代理人選任届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17424' or $code = 'A27424'
                 or $code = 'A37424' or $code = 'A47424'">
                <xsl:value-of select="'代理人辞任届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17425' or $code = 'A27425'
                 or $code = 'A37425' or $code = 'A47425'">
                <xsl:value-of select="'代理人解任届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17426' or $code = 'A27426'
                 or $code = 'A37426' or $code = 'A47426'">
                <xsl:value-of select="'代理権変更届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17427' or $code = 'A27427'
                 or $code = 'A37427' or $code = 'A47427'">
                <xsl:value-of select="'代理権消滅届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17428' or $code = 'A27428'
                 or $code = 'A37428' or $code = 'A47428'">
                <xsl:value-of select="'包括委任状援用制限届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17431' or $code = 'A27431'
                 or $code = 'A37431' or $code = 'A47431'">
                <xsl:value-of select="'復代理人変更届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17432' or $code = 'A27432'
                 or $code = 'A37432' or $code = 'A47432'">
                <xsl:value-of select="'復代理人受任届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17433' or $code = 'A27433'
                 or $code = 'A37433' or $code = 'A47433'">
                <xsl:value-of select="'復代理人選任届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17434' or $code = 'A27434'
                 or $code = 'A37434' or $code = 'A47434'">
                <xsl:value-of select="'復代理人辞任届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17435' or $code = 'A27435'
                 or $code = 'A37435' or $code = 'A47435'">
                <xsl:value-of select="'復代理人解任届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17436' or $code = 'A27436'
                 or $code = 'A37436' or $code = 'A47436'">
                <xsl:value-of select="'復代理権変更届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A17437' or $code = 'A27437'
                 or $code = 'A37437' or $code = 'A47437'">
                <xsl:value-of select="'復代理権消滅届'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1761' or $code = 'A2761'
                 or $code = 'A3761' or $code = 'A4761'">
                <xsl:value-of select="'出願取下書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1762' or $code = 'A2762'
                 or $code = 'A3762' or $code = 'A4762'">
                <xsl:value-of select="'出願放棄書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1764' or $code = 'A2764'">
                <xsl:value-of select="'先の出願に基づく優先権主張取下書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1765' or $code = 'A2765'
                 or $code = 'A3765' or $code = 'A4765'">
                <xsl:value-of select="'パリ条約による優先権主張放棄書'" />
            </xsl:when>
            <xsl:when test="$code = 'A4766'">
                <xsl:value-of select="'書換登録申請取下書'" />
            </xsl:when>
            <xsl:when test="$code = 'A4768'">
                <xsl:value-of select="'使用に基づく特例の適用の主張取下書'" />
            </xsl:when>
            <xsl:when test="$code = 'A37731'">
                <xsl:value-of select="'出願変更届（独立→類似）'" />
            </xsl:when>
            <xsl:when test="$code = 'A37732'">
                <xsl:value-of select="'出願変更届（類似→独立）'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1781' or $code = 'A2781'
                 or $code = 'A3781' or $code = 'A4781'">
                <xsl:value-of select="'上申書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A179' or $code = 'A279'
                 or $code = 'A379' or $code = 'A479'">
                <xsl:value-of select="'優先権証明書提出書'" />
            </xsl:when>
            <xsl:when test="$code = 'A180' or $code = 'A280'
                 or $code = 'A380'">
                <xsl:value-of select="'新規性の喪失の例外証明書提出書'" />
            </xsl:when>
            <xsl:when test="$code = 'A480'">
                <xsl:value-of select="'出願時の特例証明書提出書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1801' or $code = 'A2801'">
                <xsl:value-of select="'新規性喪失の例外適用申請書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A181' or $code = 'A281'
                 or $code = 'A381' or $code = 'A481'">
                <xsl:value-of select="'出願日証明書提出書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A182' or $code = 'A282'
                 or $code = 'A382' or $code = 'A482'">
                <xsl:value-of select="'物件提出書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1821' or $code = 'A2821'
                 or $code = 'A3821' or $code = 'A4821'">
                <xsl:value-of select="'手続補足書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1822' or $code = 'A2822'
                 or $code = 'A3822' or $code = 'A4822'">
                <xsl:value-of select="'証明書類提出書'" />
            </xsl:when>
            <xsl:when test="$code = 'A3824'">
                <xsl:value-of select="'ひな形又は見本補足書'" />
            </xsl:when>
            <xsl:when test="$code = 'A3833'">
                <xsl:value-of select="'特徴記載書'" />
            </xsl:when>
            <xsl:when test="$code = 'A3826'">
                <xsl:value-of select="'意匠法第９条第５項に基づく協議の結果届'" />
            </xsl:when>
            <xsl:when test="$code = 'A1831' or $code = 'A2831'
                 or $code = 'A4831'">
                <xsl:value-of select="'刊行物等提出書'" />
            </xsl:when>
            <xsl:when test="$code = 'A187' or $code = 'A287'">
                <xsl:value-of select="'優先審査に関する事情説明書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1871' or $code = 'A2871'
                 or $code = 'A3871' or $code = 'A4871'">
                <xsl:value-of select="'早期審査に関する事情説明書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1872' or $code = 'A2872'
                 or $code = 'A3872' or $code = 'A4872'">
                <xsl:value-of select="'早期審査に関する事情説明補充書'" />
            </xsl:when>
            <xsl:when test="$code = 'A3907'">
                <xsl:value-of select="'秘密意匠期間変更請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'A4908'">
                <xsl:value-of select="'協議の結果届'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB101' or $code = 'A2IB101'">
                <xsl:value-of select="'国際出願の写し'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB101J' or $code = 'A2IB101J'">
                <xsl:value-of select="'国際出願の願書の写し'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB210' or $code = 'A2IB210'">
                <xsl:value-of select="'国際調査報告'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB21J' or $code = 'A2IB21J'">
                <xsl:value-of select="'国際調査報告（日本語）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB304' or $code = 'A2IB304'">
                <xsl:value-of select="'優先権主張の書類提出に関する通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB305' or $code = 'A2IB305'">
                <xsl:value-of select="'先の出願番号の遅れた提出の通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB306' or $code = 'A2IB306'">
                <xsl:value-of select="'記録の変更通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB307' or $code = 'A2IB307'">
                <xsl:value-of select="'国際出願又は指定の取り下げの通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB310' or $code = 'A2IB310'">
                <xsl:value-of select="'送達書類に関する通知（その他雑通知等）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB317' or $code = 'A2IB317'">
                <xsl:value-of select="'優先権に関する取下の通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB31A' or $code = 'A2IB31A'">
                <xsl:value-of select="'優先権書類'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB31B' or $code = 'A2IB31B'">
                <xsl:value-of select="'条約１９条補正'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB31B1' or $code = 'A2IB31B1'">
                <xsl:value-of select="'条約１９条補正（職権）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB31C' or $code = 'A2IB31C'">
                <xsl:value-of select="'条約３４条補正'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB31C1' or $code = 'A2IB31C1'">
                <xsl:value-of select="'条約３４条補正（職権）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB31E' or $code = 'A2IB31E'">
                <xsl:value-of select="'国際予備審査報告（日本語／英語以外の言語）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB31J' or $code = 'A2IB31J'">
                <xsl:value-of select="'国際予備審査報告（日本語）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB324' or $code = 'A2IB324'">
                <xsl:value-of select="'指定が取り下げられたものとみなす旨の通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB325' or $code = 'A2IB325'">
                <xsl:value-of select="'国際出願が取り下げられたものとみなす通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB331' or $code = 'A2IB331'">
                <xsl:value-of select="'選択の通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB334' or $code = 'A2IB334'">
                <xsl:value-of select="'後にする選択の届出が提出・選択無とみなす通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB338' or $code = 'A2IB338'">
                <xsl:value-of select="'国際予備審査報告（英語）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB339' or $code = 'A2IB339'">
                <xsl:value-of select="'予備審査請求又は選択の取り下げの通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB345' or $code = 'A2IB345'">
                <xsl:value-of select="'他に使用すべき様式がない場合の通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB349' or $code = 'A2IB349'">
                <xsl:value-of select="'国際公開'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB3491' or $code = 'A2IB3491'">
                <xsl:value-of select="'日本語国際公開（職権）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB3492' or $code = 'A2IB3492'">
                <xsl:value-of select="'外国語国際公開図面（職権）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB3493' or $code = 'A2IB3493'">
                <xsl:value-of select="'外国語国際公開配列表（職権）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB350' or $code = 'A2IB350'">
                <xsl:value-of select="'予備審査請求書の提出又は選択無とみなす通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB500' or $code = 'A2IB500'">
                <xsl:value-of select="'ＩＢ回答書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC101' or $code = 'A2IBC101'">
                <xsl:value-of select="'訂正／国際出願の写し'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC210' or $code = 'A2IBC210'">
                <xsl:value-of select="'訂正／国際調査報告'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC21J' or $code = 'A2IBC21J'">
                <xsl:value-of select="'訂正／国際調査報告（日本語）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC304' or $code = 'A2IBC304'">
                <xsl:value-of select="'訂正／優先権主張の書類提出に関する通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC305' or $code = 'A2IBC305'">
                <xsl:value-of select="'訂正／先の出願番号の遅れた提出の通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC306' or $code = 'A2IBC306'">
                <xsl:value-of select="'訂正／記録の変更通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC307' or $code = 'A2IBC307'">
                <xsl:value-of select="'訂正／国際出願又は指定の取り下げの通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC310' or $code = 'A2IBC310'">
                <xsl:value-of select="'訂正／送達書類に関する通知（その他雑通知等）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC317' or $code = 'A2IBC317'">
                <xsl:value-of select="'訂正／優先権に関する取下の通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC31A' or $code = 'A2IBC31A'">
                <xsl:value-of select="'訂正／優先権書類'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC31B' or $code = 'A2IBC31B'">
                <xsl:value-of select="'訂正／条約１９条補正'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC31C' or $code = 'A2IBC31C'">
                <xsl:value-of select="'訂正／条約３４条補正'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC31E' or $code = 'A2IBC31E'">
                <xsl:value-of select="'訂正／国際予備審査報告（日本語／英語以外の言語）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC31J' or $code = 'A2IBC31J'">
                <xsl:value-of select="'訂正／国際予備審査報告（日本語）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC324' or $code = 'A2IBC324'">
                <xsl:value-of select="'訂正／指定が取り下げられたものとみなす旨の通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC325' or $code = 'A2IBC325'">
                <xsl:value-of select="'訂正／国際出願が取り下げられたものとみなす通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC331' or $code = 'A2IBC331'">
                <xsl:value-of select="'訂正／選択の通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC334' or $code = 'A2IBC334'">
                <xsl:value-of select="'訂正／後にする選択の届出が提出・選択無とみなす通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC338' or $code = 'A2IBC338'">
                <xsl:value-of select="'訂正／国際予備審査報告（英語）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC339' or $code = 'A2IBC339'">
                <xsl:value-of select="'訂正／予備審査請求又は選択の取り下げの通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC345' or $code = 'A2IBC345'">
                <xsl:value-of select="'訂正／他に使用すべき様式がない場合の通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC349' or $code = 'A2IBC349'">
                <xsl:value-of select="'訂正／国際公開'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IBC350' or $code = 'A2IBC350'">
                <xsl:value-of select="'訂正／予備審査請求書の提出又は選択無とみなす通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB318' or $code = 'A2IB318'">
                <xsl:value-of select="'優先権主張に関する通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB335' or $code = 'A2IB335'">
                <xsl:value-of select="'指定または選択の取り消しの通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB346' or $code = 'A2IB346'">
                <xsl:value-of select="'請求の範囲の補正書の提出に関する通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB369' or $code = 'A2IB369'">
                <xsl:value-of select="'予備審査請求がされなかった旨の通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB373' or $code = 'A2IB373'">
                <xsl:value-of select="'特許性に関する国際予備報告（第Ｉ章）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB374' or $code = 'A2IB374'">
                <xsl:value-of select="'国際調査機関の見解の翻訳の写しの送付通知'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB399' or $code = 'A2IB399'">
                <xsl:value-of select="'国際出願経過情報様式'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB3494' or $code = 'A2IB3494'">
                <xsl:value-of select="'日本語国際公開要約図（職権）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB3495' or $code = 'A2IB3495'">
                <xsl:value-of select="'外国語国際公開要約図（職権）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB3731' or $code = 'A2IB3731'">
                <xsl:value-of select="'非公式コメント'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB501' or $code = 'A2IB501'">
                <xsl:value-of select="'補充国際調査報告'" />
            </xsl:when>
            <xsl:when test="$code = 'A1IB502' or $code = 'A2IB502'">
                <xsl:value-of select="'補充国際調査報告を作成しない旨の決定'" />
            </xsl:when>
            <xsl:when test="$code = 'A16330' or $code = 'A26330'">
                <xsl:value-of select="'明細書'" />
            </xsl:when>
            <xsl:when test="$code = 'A16331' or $code = 'A26331'">
                <xsl:value-of select="'図面'" />
            </xsl:when>
            <xsl:when test="$code = 'A16332' or $code = 'A26332'">
                <xsl:value-of select="'要約書'" />
            </xsl:when>
            <xsl:when test="$code = 'A16333'">
                <xsl:value-of select="'特許請求の範囲'" />
            </xsl:when>
            <xsl:when test="$code = 'A26333'">
                <xsl:value-of select="'実用新案登録請求の範囲'" />
            </xsl:when>
            <xsl:when test="$code = 'A1914'">
                <xsl:value-of select="'出願審査請求手数料返還請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1915' or $code = 'A3915' or $code = 'A4915'">
                <xsl:value-of select="'既納手数料返還請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'A2915'">
                <xsl:value-of select="'既納手数料（登録料）返還請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'A2624'">
                <xsl:value-of select="'実用新案技術評価請求書（他人）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1916' or $code = 'A2916'">
                <xsl:value-of select="'世界知的所有権機関へのアクセスコード付与請求書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'A1603' or $code = 'A2603'
                 or $code = 'A3603' or $code = 'A4603'">
                <xsl:value-of select="'期間延長請求書（期間徒過）'" />
            </xsl:when>
            <xsl:when test="$code = 'A1917' or $code = 'A2917' or $code = 'A3917'">
                <xsl:value-of select="'回復理由書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1918'">
                <xsl:value-of select="'保全審査に付することを求める申出書'" />
            </xsl:when>
            <xsl:when test="$code = 'A1919'">
                <xsl:value-of select="'不送付通知申出書'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="書誌編集エラー処理" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     書類名登録（Ｒで始まる書類識別コード）
     ====================================================================-->
    <xsl:template
        name="書類名登録">
        <xsl:param name="code" />
        <xsl:choose>
            <xsl:when test="$code = 'R1100' or $code = 'R120'">
                <xsl:value-of select="'特許料納付書'" />
            </xsl:when>
            <xsl:when test="$code = 'R2100' or $code = 'R220'">
                <xsl:value-of select="'実用新案登録料納付書'" />
            </xsl:when>
            <xsl:when test="$code = 'R3100' or $code = 'R320'">
                <xsl:value-of select="'意匠登録料納付書'" />
            </xsl:when>
            <xsl:when test="$code = 'R4100' or $code = 'R4200'">
                <xsl:value-of select="'商標登録料納付書'" />
            </xsl:when>
            <xsl:when test="$code = 'R1101'">
                <xsl:value-of select="'追加の特許の特許料納付書'" />
            </xsl:when>
            <xsl:when test="$code = 'R3102'">
                <xsl:value-of select="'類似意匠登録料納付書'" />
            </xsl:when>
            <xsl:when test="$code = 'R4103'">
                <xsl:value-of select="'防護標章登録料納付書'" />
            </xsl:when>
            <xsl:when test="$code = 'R4104'">
                <xsl:value-of select="'商標更新登録料納付書'" />
            </xsl:when>
            <xsl:when test="$code = 'R4105'">
                <xsl:value-of select="'防護標章更新登録料納付書'" />
            </xsl:when>
            <xsl:when test="$code = 'R1110'">
                <xsl:value-of select="'特許料納付書（設定補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R2110'">
                <xsl:value-of select="'実用新案登録料納付書（設定補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R3110'">
                <xsl:value-of select="'意匠登録料納付書（設定補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R4110'">
                <xsl:value-of select="'商標登録料納付書（設定補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R1111'">
                <xsl:value-of select="'追加の特許の特許料納付書（設定補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R3112'">
                <xsl:value-of select="'類似意匠登録料納付書（設定補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R4113'">
                <xsl:value-of select="'防護標章登録料納付書（設定補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R4114'">
                <xsl:value-of select="'商標更新登録料納付書（設定補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R4115'">
                <xsl:value-of select="'防護標章更新登録料納付書（設定補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R121'">
                <xsl:value-of select="'特許料納付書（補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R221'">
                <xsl:value-of select="'実用新案登録料納付書（補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R321'">
                <xsl:value-of select="'意匠登録料納付書（補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R4210'">
                <xsl:value-of select="'商標登録料納付書（分納補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R4201'">
                <xsl:value-of select="'商標権存続期間更新登録申請書'" />
            </xsl:when>
            <xsl:when test="$code = 'R4211'">
                <xsl:value-of select="'商標権存続期間更新登録申請書（補充）'" />
            </xsl:when>
            <xsl:when test="$code = 'R4220'">
                <xsl:value-of select="'手続補足書'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="書誌編集エラー処理" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     書類名請求（Ｅで始まる書類識別コード）
     ====================================================================-->
    <xsl:template
        name="書類名請求">
        <xsl:param name="code" />
        <xsl:choose>
            <xsl:when test="$code = 'E1841' or $code = 'E2841'">
                <xsl:value-of select="'優先権証明請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'E1842' or $code = 'E2842'">
                <xsl:value-of select="'証明請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'E1851' or $code = 'E2851'">
                <xsl:value-of select="'ファイル記録事項記載書類の交付請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'E1852' or $code = 'E2852'">
                <xsl:value-of select="'認証付ファイル記録事項記載書類の交付請求書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'E1853' or $code = 'E2853'
                 or $code = 'E3853' or $code = 'E4853'">
                <xsl:value-of select="'登録事項記載書類の交付請求書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'E1854' or $code = 'E2854'
                 or $code = 'E3854' or $code = 'E4854'">
                <xsl:value-of select="'認証付登録事項記載書類の交付請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'E1861' or $code = 'E2861'">
                <xsl:value-of select="'ファイル記録事項の閲覧（縦覧）請求書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'E1862' or $code = 'E2862'
                 or $code = 'E3862' or $code = 'E4862'">
                <xsl:value-of select="'登録事項の閲覧請求書'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="書誌編集エラー処理" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     書類名審判（Ｃで始まる書類識別コード）
     ====================================================================-->
    <xsl:template
        name="書類名審判">
        <xsl:param name="code" />
        <xsl:choose>
            <xsl:when
                test="$code = 'C154' or $code = 'C254'
                 or $code = 'C354' or $code = 'C454'">
                <xsl:value-of select="'回答書'" />
            </xsl:when>
            <xsl:when test="$code = 'C1561' or $code = 'C2561'
                 or $code = 'C4561'">
                <xsl:value-of select="'異議申立書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C157' or $code = 'C257'
                 or $code = 'C357' or $code = 'C457'">
                <xsl:value-of select="'答弁書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C158' or $code = 'C258'
                 or $code = 'C358' or $code = 'C458'">
                <xsl:value-of select="'弁駁書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C160' or $code = 'C260'
                 or $code = 'C360' or $code = 'C460'">
                <xsl:value-of select="'審判請求書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C1601' or $code = 'C2601'
                 or $code = 'C3601' or $code = 'C4601'">
                <xsl:value-of select="'判定請求書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C1609' or $code = 'C2609'
                 or $code = 'C3609' or $code = 'C4609'">
                <xsl:value-of select="'請求取下書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16091' or $code = 'C26091'
                 or $code = 'C36091' or $code = 'C46091'">
                <xsl:value-of select="'一部請求取下書'" />
            </xsl:when>
            <xsl:when test="$code = 'C1611' or $code = 'C2611'">
                <xsl:value-of select="'訂正請求書'" />
            </xsl:when>
            <xsl:when test="$code = 'C1619' or $code = 'C2619'">
                <xsl:value-of select="'訂正請求取下書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C164' or $code = 'C264'
                 or $code = 'C364' or $code = 'C464'">
                <xsl:value-of select="'審理再開申立書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16511' or $code = 'C26511'
                 or $code = 'C36511' or $code = 'C46511'">
                <xsl:value-of select="'書面審理申立書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16512' or $code = 'C26512'
                 or $code = 'C36512' or $code = 'C46512'">
                <xsl:value-of select="'口頭審理申立書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16513' or $code = 'C26513'
                 or $code = 'C36513' or $code = 'C46513'">
                <xsl:value-of select="'口頭審理陳述要領書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16514' or $code = 'C26514'
                 or $code = 'C36514' or $code = 'C46514'">
                <xsl:value-of select="'証拠申出書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16515' or $code = 'C26515'
                 or $code = 'C36515' or $code = 'C46515'">
                <xsl:value-of select="'証拠説明書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16517' or $code = 'C26517'
                 or $code = 'C36517' or $code = 'C46517'">
                <xsl:value-of select="'録音テープ等の内容説明書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C1652' or $code = 'C2652'
                 or $code = 'C3652' or $code = 'C4652'">
                <xsl:value-of select="'証拠調申立書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16541' or $code = 'C26541'
                 or $code = 'C36541' or $code = 'C46541'">
                <xsl:value-of select="'尋問事項書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C1654' or $code = 'C2654'
                 or $code = 'C3654' or $code = 'C4654'">
                <xsl:value-of select="'証人尋問申出書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16542' or $code = 'C26542'
                 or $code = 'C36542' or $code = 'C46542'">
                <xsl:value-of select="'回答希望事項記載書面'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16543' or $code = 'C26543'
                 or $code = 'C36543' or $code = 'C46543'">
                <xsl:value-of select="'尋問に代わる書面の提出書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16544' or $code = 'C26544'
                 or $code = 'C36544' or $code = 'C46544'">
                <xsl:value-of select="'書証の申出書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16546' or $code = 'C26546'
                 or $code = 'C36546' or $code = 'C46546'">
                <xsl:value-of select="'文書特定の申出書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C1655' or $code = 'C2655'
                 or $code = 'C3655' or $code = 'C4655'">
                <xsl:value-of select="'検証申出書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C1657' or $code = 'C2657'
                 or $code = 'C3657' or $code = 'C4657'">
                <xsl:value-of select="'鑑定の申出書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16572' or $code = 'C26572'
                 or $code = 'C36572' or $code = 'C46572'">
                <xsl:value-of select="'鑑定事項書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16573' or $code = 'C26573'
                 or $code = 'C36573' or $code = 'C46573'">
                <xsl:value-of select="'鑑定書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C1659' or $code = 'C2659'
                 or $code = 'C3659' or $code = 'C4659'">
                <xsl:value-of select="'期日変更請求書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16591' or $code = 'C26591'
                 or $code = 'C36591' or $code = 'C46591'">
                <xsl:value-of select="'証拠調申請取下書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C16592' or $code = 'C26592'
                 or $code = 'C36592' or $code = 'C46592'">
                <xsl:value-of select="'不出頭の届出書'" />
            </xsl:when>
            <xsl:when test="$code = 'C1661' or $code = 'C2661'
                 or $code = 'C4661'">
                <xsl:value-of select="'異議取下書'" />
            </xsl:when>
            <xsl:when test="$code = 'C1662' or $code = 'C2662'
                 or $code = 'C4662'">
                <xsl:value-of select="'一部異議取下書'" />
            </xsl:when>
            <xsl:when test="$code = 'C1875' or $code = 'C2875'">
                <xsl:value-of select="'優先審理に関する事情説明書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C1876' or $code = 'C2876'
                 or $code = 'C3876' or $code = 'C4876'">
                <xsl:value-of select="'早期審理に関する事情説明書'" />
            </xsl:when>
            <xsl:when
                test="$code = 'C1877' or $code = 'C2877'
                 or $code = 'C3877' or $code = 'C4877'">
                <xsl:value-of select="'早期審理に関する事情説明補充書'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="書誌編集エラー処理" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>