<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map">
    
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
        
        <xsl:variable name="doc-code">
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
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$doc-code = ''">
                <xsl:value-of select="'unknown'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$doc-code" />
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
                <xsl:value-of select="map:get($a-code-table, $code)" />
            </xsl:when>
            <xsl:when test="$firstChar = 'R' ">
                <xsl:value-of select="map:get($r-code-table, $code)" />
            </xsl:when>
            <xsl:when test="$firstChar = 'E' ">
                <xsl:value-of select="map:get($e-code-table, $code)" />
            </xsl:when>
            <xsl:when test="$firstChar = 'C' ">
                <xsl:value-of select="map:get($c-code-table, $code)" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:variable name="a-config" select="(
            map{ 'code': ('A151', 'A251', 'A351', 'A451'), 'value':'手続補正書（方式）'},
            map{ 'code': ('A1521', 'A2521', 'A1522', 'A2522', 'A1523', 'A2523', 'A3523', 'A4523'), 'value':'手続補正書'},
            map{ 'code': ('A35231'), 'value':'手続補正書（複数）'},
            map{ 'code': ('A15210', 'A25210'), 'value':'特許協力条約第３４条補正の翻訳文提出書（職権）'},
            map{ 'code': ('A15211', 'A25211'), 'value':'特許協力条約第３４条補正の写し提出書'},
            map{ 'code': ('A15212', 'A25212'), 'value':'特許協力条約第３４条補正の写し提出書（職権）'},
            map{ 'code': ('A1524', 'A2524'), 'value':'誤訳訂正書'},
            map{ 'code': ('A1525', 'A2525'), 'value':'特許協力条約第１９条補正の翻訳文提出書'},
            map{ 'code': ('A1526', 'A2526'), 'value':'特許協力条約第１９条補正の翻訳文提出書（職権）'},
            map{ 'code': ('A1527', 'A2527'), 'value':'特許協力条約第１９条補正の写し提出書'},
            map{ 'code': ('A1528', 'A2528'), 'value':'特許協力条約第１９条補正の写し提出書（職権）'},
            map{ 'code': ('A1529', 'A2529'), 'value':'特許協力条約第３４条補正の翻訳文提出書'},
            map{ 'code': ('A153', 'A253', 'A353', 'A453'), 'value':'意見書'},
            map{ 'code': ('A155', 'A255', 'A355', 'A455'), 'value':'受継申立書'},
            map{ 'code': ('A159', 'A259', 'A359', 'A459'), 'value':'弁明書'},
            map{ 'code': ('A1601', 'A2601', 'A3601', 'A4601'), 'value':'期間延長請求書'},
            map{ 'code': ('A1621', 'A2621'), 'value':'出願審査請求書'},
            map{ 'code': ('A2623'), 'value':'実用新案技術評価請求書'},
            map{ 'code': ('A1625', 'A2625'), 'value':'出願審査請求書（他人）'},
            map{ 'code': ('A2626'), 'value':'国内処理請求書'},
            map{ 'code': ('A1627'), 'value':'出願公開請求書'},
            map{ 'code': ('A163'), 'value':'特許願'},
            map{ 'code': ('A263'), 'value':'実用新案登録願'},
            map{ 'code': ('A363'), 'value':'意匠登録願'},
            map{ 'code': ('A463'), 'value':'商標登録願'},
            map{ 'code': ('A3630'), 'value':'意匠登録願（複数）'},
            map{ 'code': ('A3636'), 'value':'類似意匠登録願'},
            map{ 'code': ('A4639'), 'value':'団体商標登録願'},
            map{ 'code': ('A1631'), 'value':'翻訳文提出書'},
            map{ 'code': ('A1632', 'A2632'), 'value':'国内書面'},
            map{ 'code': ('A4632'), 'value':'防護標章登録願'},
            map{ 'code': ('A2633'), 'value':'図面の提出書'},
            map{ 'code': ('A4633'), 'value':'防護標章登録に基づく権利存続期間更新登録願'},
            map{ 'code': ('A1634', 'A2634'), 'value':'国際出願翻訳文提出書'},
            map{ 'code': ('A4634'), 'value':'書換登録申請書'},
            map{ 'code': ('A46341'), 'value':'外国語図面'},
            map{ 'code': ('A46342'), 'value':'外国語要約書'},
            map{ 'code': ('A1635', 'A2635'), 'value':'国際出願翻訳文提出書（職権）'},
            map{ 'code': ('A4635'), 'value':'防護標章登録に基づく権利書換登録申請書'},
            map{ 'code': ('A4637'), 'value':'重複登録商標に係る商標権存続期間更新登録願'},
            map{ 'code': ('A4638'), 'value':'地域団体商標登録願'},
            map{ 'code': ('A167'), 'value':'受託番号変更届'},
            map{ 'code': ('A1681', 'A2681', 'A3681', 'A4681'), 'value':'代表者選定届'},
            map{ 'code': ('A1691', 'A2691', 'A3691', 'A4691'), 'value':'雑書類'},
            map{ 'code': ('A1711', 'A2711', 'A3711', 'A4711'), 'value':'出願人名義変更届'},
            map{ 'code': ('A1712', 'A2712', 'A3712', 'A4712'), 'value':'出願人名義変更届（一般承継）'},
            map{ 'code': ('A4713'), 'value':'出願人名義変更届（特例商標登録出願）'},
            map{ 'code': ('A4714'), 'value':'出願人名義変更届（特例商標登録出願）（一般承継）'},
            map{ 'code': ('A4715'), 'value':'書換登録申請者名義変更届'},
            map{ 'code': ('A17421', 'A27421', 'A37421', 'A47421'), 'value':'代理人変更届'},
            map{ 'code': ('A17422', 'A27422', 'A37422', 'A47422'), 'value':'代理人受任届'},
            map{ 'code': ('A17423', 'A27423', 'A37423', 'A47423'), 'value':'代理人選任届'},
            map{ 'code': ('A17424', 'A27424', 'A37424', 'A47424'), 'value':'代理人辞任届'},
            map{ 'code': ('A17425', 'A27425', 'A37425', 'A47425'), 'value':'代理人解任届'},
            map{ 'code': ('A17426', 'A27426', 'A37426', 'A47426'), 'value':'代理権変更届'},
            map{ 'code': ('A17427', 'A27427', 'A37427', 'A47427'), 'value':'代理権消滅届'},
            map{ 'code': ('A17428', 'A27428', 'A37428', 'A47428'), 'value':'包括委任状援用制限届'},
            map{ 'code': ('A17431', 'A27431', 'A37431', 'A47431'), 'value':'復代理人変更届'},
            map{ 'code': ('A17432', 'A27432', 'A37432', 'A47432'), 'value':'復代理人受任届'},
            map{ 'code': ('A17433', 'A27433', 'A37433', 'A47433'), 'value':'復代理人選任届'},
            map{ 'code': ('A17434', 'A27434', 'A37434', 'A47434'), 'value':'復代理人辞任届'},
            map{ 'code': ('A17435', 'A27435', 'A37435', 'A47435'), 'value':'復代理人解任届'},
            map{ 'code': ('A17436', 'A27436', 'A37436', 'A47436'), 'value':'復代理権変更届'},
            map{ 'code': ('A17437', 'A27437', 'A37437', 'A47437'), 'value':'復代理権消滅届'},
            map{ 'code': ('A1761', 'A2761', 'A3761', 'A4761'), 'value':'出願取下書'},
            map{ 'code': ('A1762', 'A2762', 'A3762', 'A4762'), 'value':'出願放棄書'},
            map{ 'code': ('A1764', 'A2764'), 'value':'先の出願に基づく優先権主張取下書'},
            map{ 'code': ('A1765', 'A2765', 'A3765', 'A4765'), 'value':'パリ条約による優先権主張放棄書'},
            map{ 'code': ('A4766'), 'value':'書換登録申請取下書'},
            map{ 'code': ('A4768'), 'value':'使用に基づく特例の適用の主張取下書'},
            map{ 'code': ('A37731'), 'value':'出願変更届（独立→類似）'},
            map{ 'code': ('A37732'), 'value':'出願変更届（類似→独立）'},
            map{ 'code': ('A1781', 'A2781', 'A3781', 'A4781'), 'value':'上申書'},
            map{ 'code': ('A179', 'A279', 'A379', 'A479'), 'value':'優先権証明書提出書'},
            map{ 'code': ('A180', 'A280', 'A380'), 'value':'新規性の喪失の例外証明書提出書'},
            map{ 'code': ('A480'), 'value':'出願時の特例証明書提出書'},
            map{ 'code': ('A1801', 'A2801'), 'value':'新規性喪失の例外適用申請書'},
            map{ 'code': ('A181', 'A281', 'A381', 'A481'), 'value':'出願日証明書提出書'},
            map{ 'code': ('A182', 'A282', 'A382', 'A482'), 'value':'物件提出書'},
            map{ 'code': ('A1821', 'A2821', 'A3821', 'A4821'), 'value':'手続補足書'},
            map{ 'code': ('A1822', 'A2822', 'A3822', 'A4822'), 'value':'証明書類提出書'},
            map{ 'code': ('A3824'), 'value':'ひな形又は見本補足書'},
            map{ 'code': ('A3833'), 'value':'特徴記載書'},
            map{ 'code': ('A3826'), 'value':'意匠法第９条第５項に基づく協議の結果届'},
            map{ 'code': ('A1831', 'A2831', 'A4831'), 'value':'刊行物等提出書'},
            map{ 'code': ('A187', 'A287'), 'value':'優先審査に関する事情説明書'},
            map{ 'code': ('A1871', 'A2871', 'A3871', 'A4871'), 'value':'早期審査に関する事情説明書'},
            map{ 'code': ('A1872', 'A2872', 'A3872', 'A4872'), 'value':'早期審査に関する事情説明補充書'},
            map{ 'code': ('A3907'), 'value':'秘密意匠期間変更請求書'},
            map{ 'code': ('A4908'), 'value':'協議の結果届'},
            map{ 'code': ('A1IB101', 'A2IB101'), 'value':'国際出願の写し'},
            map{ 'code': ('A1IB101J', 'A2IB101J'), 'value':'国際出願の願書の写し'},
            map{ 'code': ('A1IB210', 'A2IB210'), 'value':'国際調査報告'},
            map{ 'code': ('A1IB21J', 'A2IB21J'), 'value':'国際調査報告（日本語）'},
            map{ 'code': ('A1IB304', 'A2IB304'), 'value':'優先権主張の書類提出に関する通知'},
            map{ 'code': ('A1IB305', 'A2IB305'), 'value':'先の出願番号の遅れた提出の通知'},
            map{ 'code': ('A1IB306', 'A2IB306'), 'value':'記録の変更通知'},
            map{ 'code': ('A1IB307', 'A2IB307'), 'value':'国際出願又は指定の取り下げの通知'},
            map{ 'code': ('A1IB310', 'A2IB310'), 'value':'送達書類に関する通知（その他雑通知等）'},
            map{ 'code': ('A1IB317', 'A2IB317'), 'value':'優先権に関する取下の通知'},
            map{ 'code': ('A1IB31A', 'A2IB31A'), 'value':'優先権書類'},
            map{ 'code': ('A1IB31B', 'A2IB31B'), 'value':'条約１９条補正'},
            map{ 'code': ('A1IB31B1', 'A2IB31B1'), 'value':'条約１９条補正（職権）'},
            map{ 'code': ('A1IB31C', 'A2IB31C'), 'value':'条約３４条補正'},
            map{ 'code': ('A1IB31C1', 'A2IB31C1'), 'value':'条約３４条補正（職権）'},
            map{ 'code': ('A1IB31E', 'A2IB31E'), 'value':'国際予備審査報告（日本語／英語以外の言語）'},
            map{ 'code': ('A1IB31J', 'A2IB31J'), 'value':'国際予備審査報告（日本語）'},
            map{ 'code': ('A1IB324', 'A2IB324'), 'value':'指定が取り下げられたものとみなす旨の通知'},
            map{ 'code': ('A1IB325', 'A2IB325'), 'value':'国際出願が取り下げられたものとみなす通知'},
            map{ 'code': ('A1IB331', 'A2IB331'), 'value':'選択の通知'},
            map{ 'code': ('A1IB334', 'A2IB334'), 'value':'後にする選択の届出が提出・選択無とみなす通知'},
            map{ 'code': ('A1IB338', 'A2IB338'), 'value':'国際予備審査報告（英語）'},
            map{ 'code': ('A1IB339', 'A2IB339'), 'value':'予備審査請求又は選択の取り下げの通知'},
            map{ 'code': ('A1IB345', 'A2IB345'), 'value':'他に使用すべき様式がない場合の通知'},
            map{ 'code': ('A1IB349', 'A2IB349'), 'value':'国際公開'},
            map{ 'code': ('A1IB3491', 'A2IB3491'), 'value':'日本語国際公開（職権）'},
            map{ 'code': ('A1IB3492', 'A2IB3492'), 'value':'外国語国際公開図面（職権）'},
            map{ 'code': ('A1IB3493', 'A2IB3493'), 'value':'外国語国際公開配列表（職権）'},
            map{ 'code': ('A1IB350', 'A2IB350'), 'value':'予備審査請求書の提出又は選択無とみなす通知'},
            map{ 'code': ('A1IB500', 'A2IB500'), 'value':'ＩＢ回答書'},
            map{ 'code': ('A1IBC101', 'A2IBC101'), 'value':'訂正／国際出願の写し'},
            map{ 'code': ('A1IBC210', 'A2IBC210'), 'value':'訂正／国際調査報告'},
            map{ 'code': ('A1IBC21J', 'A2IBC21J'), 'value':'訂正／国際調査報告（日本語）'},
            map{ 'code': ('A1IBC304', 'A2IBC304'), 'value':'訂正／優先権主張の書類提出に関する通知'},
            map{ 'code': ('A1IBC305', 'A2IBC305'), 'value':'訂正／先の出願番号の遅れた提出の通知'},
            map{ 'code': ('A1IBC306', 'A2IBC306'), 'value':'訂正／記録の変更通知'},
            map{ 'code': ('A1IBC307', 'A2IBC307'), 'value':'訂正／国際出願又は指定の取り下げの通知'},
            map{ 'code': ('A1IBC310', 'A2IBC310'), 'value':'訂正／送達書類に関する通知（その他雑通知等）'},
            map{ 'code': ('A1IBC317', 'A2IBC317'), 'value':'訂正／優先権に関する取下の通知'},
            map{ 'code': ('A1IBC31A', 'A2IBC31A'), 'value':'訂正／優先権書類'},
            map{ 'code': ('A1IBC31B', 'A2IBC31B'), 'value':'訂正／条約１９条補正'},
            map{ 'code': ('A1IBC31C', 'A2IBC31C'), 'value':'訂正／条約３４条補正'},
            map{ 'code': ('A1IBC31E', 'A2IBC31E'), 'value':'訂正／国際予備審査報告（日本語／英語以外の言語）'},
            map{ 'code': ('A1IBC31J', 'A2IBC31J'), 'value':'訂正／国際予備審査報告（日本語）'},
            map{ 'code': ('A1IBC324', 'A2IBC324'), 'value':'訂正／指定が取り下げられたものとみなす旨の通知'},
            map{ 'code': ('A1IBC325', 'A2IBC325'), 'value':'訂正／国際出願が取り下げられたものとみなす通知'},
            map{ 'code': ('A1IBC331', 'A2IBC331'), 'value':'訂正／選択の通知'},
            map{ 'code': ('A1IBC334', 'A2IBC334'), 'value':'訂正／後にする選択の届出が提出・選択無とみなす通知'},
            map{ 'code': ('A1IBC338', 'A2IBC338'), 'value':'訂正／国際予備審査報告（英語）'},
            map{ 'code': ('A1IBC339', 'A2IBC339'), 'value':'訂正／予備審査請求又は選択の取り下げの通知'},
            map{ 'code': ('A1IBC345', 'A2IBC345'), 'value':'訂正／他に使用すべき様式がない場合の通知'},
            map{ 'code': ('A1IBC349', 'A2IBC349'), 'value':'訂正／国際公開'},
            map{ 'code': ('A1IBC350', 'A2IBC350'), 'value':'訂正／予備審査請求書の提出又は選択無とみなす通知'},
            map{ 'code': ('A1IB318', 'A2IB318'), 'value':'優先権主張に関する通知'},
            map{ 'code': ('A1IB335', 'A2IB335'), 'value':'指定または選択の取り消しの通知'},
            map{ 'code': ('A1IB346', 'A2IB346'), 'value':'請求の範囲の補正書の提出に関する通知'},
            map{ 'code': ('A1IB369', 'A2IB369'), 'value':'予備審査請求がされなかった旨の通知'},
            map{ 'code': ('A1IB373', 'A2IB373'), 'value':'特許性に関する国際予備報告（第Ｉ章）'},
            map{ 'code': ('A1IB374', 'A2IB374'), 'value':'国際調査機関の見解の翻訳の写しの送付通知'},
            map{ 'code': ('A1IB399', 'A2IB399'), 'value':'国際出願経過情報様式'},
            map{ 'code': ('A1IB3494', 'A2IB3494'), 'value':'日本語国際公開要約図（職権）'},
            map{ 'code': ('A1IB3495', 'A2IB3495'), 'value':'外国語国際公開要約図（職権）'},
            map{ 'code': ('A1IB3731', 'A2IB3731'), 'value':'非公式コメント'},
            map{ 'code': ('A1IB501', 'A2IB501'), 'value':'補充国際調査報告'},
            map{ 'code': ('A1IB502', 'A2IB502'), 'value':'補充国際調査報告を作成しない旨の決定'},
            map{ 'code': ('A16330', 'A26330'), 'value':'明細書'},
            map{ 'code': ('A16331', 'A26331'), 'value':'図面'},
            map{ 'code': ('A16332', 'A26332'), 'value':'要約書'},
            map{ 'code': ('A16333'), 'value':'特許請求の範囲'},
            map{ 'code': ('A26333'), 'value':'実用新案登録請求の範囲'},
            map{ 'code': ('A1914'), 'value':'出願審査請求手数料返還請求書'},
            map{ 'code': ('A1915', 'A3915', 'A4915'), 'value':'既納手数料返還請求書'},
            map{ 'code': ('A2915'), 'value':'既納手数料（登録料）返還請求書'},
            map{ 'code': ('A2624'), 'value':'実用新案技術評価請求書（他人）'},
            map{ 'code': ('A1916', 'A2916'), 'value':'世界知的所有権機関へのアクセスコード付与請求書'},
            map{ 'code': ('A1603', 'A2603', 'A3603', 'A4603'), 'value':'期間延長請求書（期間徒過）'},
            map{ 'code': ('A1917', 'A2917', 'A3917'), 'value':'回復理由書'},
            map{ 'code': ('A1918'), 'value':'保全審査に付することを求める申出書'},
            map{ 'code': ('A1919'), 'value':'不送付通知申出書'}
        )"/> 
    <xsl:variable name="a-code-table" as="map(xs:string, xs:string)">  
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$a-config" />
        </xsl:call-template>
    </xsl:variable>    
    
    <xsl:variable name="r-config" select="(
            map{ 'code': ('R1100', 'R120'), 'value':'特許料納付書'},
            map{ 'code': ('R2100', 'R220'), 'value':'実用新案登録料納付書'},
            map{ 'code': ('R3100', 'R320'), 'value':'意匠登録料納付書'},
            map{ 'code': ('R4100', 'R4200'), 'value':'商標登録料納付書'},
            map{ 'code': ('R1101'), 'value':'追加の特許の特許料納付書'},
            map{ 'code': ('R3102'), 'value':'類似意匠登録料納付書'},
            map{ 'code': ('R4103'), 'value':'防護標章登録料納付書'},
            map{ 'code': ('R4104'), 'value':'商標更新登録料納付書'},
            map{ 'code': ('R4105'), 'value':'防護標章更新登録料納付書'},
            map{ 'code': ('R1110'), 'value':'特許料納付書（設定補充）'},
            map{ 'code': ('R2110'), 'value':'実用新案登録料納付書（設定補充）'},
            map{ 'code': ('R3110'), 'value':'意匠登録料納付書（設定補充）'},
            map{ 'code': ('R4110'), 'value':'商標登録料納付書（設定補充）'},
            map{ 'code': ('R1111'), 'value':'追加の特許の特許料納付書（設定補充）'},
            map{ 'code': ('R3112'), 'value':'類似意匠登録料納付書（設定補充）'},
            map{ 'code': ('R4113'), 'value':'防護標章登録料納付書（設定補充）'},
            map{ 'code': ('R4114'), 'value':'商標更新登録料納付書（設定補充）'},
            map{ 'code': ('R4115'), 'value':'防護標章更新登録料納付書（設定補充）'},
            map{ 'code': ('R121'), 'value':'特許料納付書（補充）'},
            map{ 'code': ('R221'), 'value':'実用新案登録料納付書（補充）'},
            map{ 'code': ('R321'), 'value':'意匠登録料納付書（補充）'},
            map{ 'code': ('R4210'), 'value':'商標登録料納付書（分納補充）'},
            map{ 'code': ('R4201'), 'value':'商標権存続期間更新登録申請書'},
            map{ 'code': ('R4211'), 'value':'商標権存続期間更新登録申請書（補充）'},
            map{ 'code': ('R4220'), 'value':'手続補足書'}
        )"/>
    <xsl:variable name="r-code-table" as="map(xs:string, xs:string)">  
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$r-config" />
        </xsl:call-template>
    </xsl:variable>    
    
    <xsl:variable name="e-config" select="(
            map{ 'code': ('E1841', 'E2841'), 'value':'優先権証明請求書'},
            map{ 'code': ('E1842', 'E2842'), 'value':'証明請求書'},
            map{ 'code': ('E1851', 'E2851'), 'value':'ファイル記録事項記載書類の交付請求書'},
            map{ 'code': ('E1852', 'E2852'), 'value':'認証付ファイル記録事項記載書類の交付請求書'},
            map{ 'code': ('E1853', 'E2853', 'E3853', 'E4853'), 'value':'登録事項記載書類の交付請求書'},
            map{ 'code': ('E1854', 'E2854', 'E3854', 'E4854'), 'value':'認証付登録事項記載書類の交付請求書'},
            map{ 'code': ('E1861', 'E2861'), 'value':'ファイル記録事項の閲覧（縦覧）請求書'},
            map{ 'code': ('E1862', 'E2862', 'E3862', 'E4862'), 'value':'登録事項の閲覧請求書'}
        )"/>
    <xsl:variable name="e-code-table" as="map(xs:string, xs:string)">  
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$e-config" />
        </xsl:call-template>
    </xsl:variable>    
    
    <xsl:variable name="c-config" select="(
            map{ 'code': ('C154', 'C254', 'C354', 'C454'), 'value':'回答書'},
            map{ 'code': ('C1561', 'C2561', 'C4561'), 'value':'異議申立書'},
            map{ 'code': ('C157', 'C257', 'C357', 'C457'), 'value':'答弁書'},
            map{ 'code': ('C158', 'C258', 'C358', 'C458'), 'value':'弁駁書'},
            map{ 'code': ('C160', 'C260', 'C360', 'C460'), 'value':'審判請求書'},
            map{ 'code': ('C1601', 'C2601', 'C3601', 'C4601'), 'value':'判定請求書'},
            map{ 'code': ('C1609', 'C2609', 'C3609', 'C4609'), 'value':'請求取下書'},
            map{ 'code': ('C16091', 'C26091', 'C36091', 'C46091'), 'value':'一部請求取下書'},
            map{ 'code': ('C1611', 'C2611'), 'value':'訂正請求書'},
            map{ 'code': ('C1619', 'C2619'), 'value':'訂正請求取下書'},
            map{ 'code': ('C164', 'C264', 'C364', 'C464'), 'value':'審理再開申立書'},
            map{ 'code': ('C16511', 'C26511', 'C36511', 'C46511'), 'value':'書面審理申立書'},
            map{ 'code': ('C16512', 'C26512', 'C36512', 'C46512'), 'value':'口頭審理申立書'},
            map{ 'code': ('C16513', 'C26513', 'C36513', 'C46513'), 'value':'口頭審理陳述要領書'},
            map{ 'code': ('C16514', 'C26514', 'C36514', 'C46514'), 'value':'証拠申出書'},
            map{ 'code': ('C16515', 'C26515', 'C36515', 'C46515'), 'value':'証拠説明書'},
            map{ 'code': ('C16517', 'C26517', 'C36517', 'C46517'), 'value':'録音テープ等の内容説明書'},
            map{ 'code': ('C1652', 'C2652', 'C3652', 'C4652'), 'value':'証拠調申立書'},
            map{ 'code': ('C16541', 'C26541', 'C36541', 'C46541'), 'value':'尋問事項書'},
            map{ 'code': ('C1654', 'C2654', 'C3654', 'C4654'), 'value':'証人尋問申出書'},
            map{ 'code': ('C16542', 'C26542', 'C36542', 'C46542'), 'value':'回答希望事項記載書面'},
            map{ 'code': ('C16543', 'C26543', 'C36543', 'C46543'), 'value':'尋問に代わる書面の提出書'},
            map{ 'code': ('C16544', 'C26544', 'C36544', 'C46544'), 'value':'書証の申出書'},
            map{ 'code': ('C16546', 'C26546', 'C36546', 'C46546'), 'value':'文書特定の申出書'},
            map{ 'code': ('C1655', 'C2655', 'C3655', 'C4655'), 'value':'検証申出書'},
            map{ 'code': ('C1657', 'C2657', 'C3657', 'C4657'), 'value':'鑑定の申出書'},
            map{ 'code': ('C16572', 'C26572', 'C36572', 'C46572'), 'value':'鑑定事項書'},
            map{ 'code': ('C16573', 'C26573', 'C36573', 'C46573'), 'value':'鑑定書'},
            map{ 'code': ('C1659', 'C2659', 'C3659', 'C4659'), 'value':'期日変更請求書'},
            map{ 'code': ('C16591', 'C26591', 'C36591', 'C46591'), 'value':'証拠調申請取下書'},
            map{ 'code': ('C16592', 'C26592', 'C36592', 'C46592'), 'value':'不出頭の届出書'},
            map{ 'code': ('C1661', 'C2661', 'C4661'), 'value':'異議取下書'},
            map{ 'code': ('C1662', 'C2662', 'C4662'), 'value':'一部異議取下書'},
            map{ 'code': ('C1875', 'C2875'), 'value':'優先審理に関する事情説明書'},
            map{ 'code': ('C1876', 'C2876', 'C3876', 'C4876'), 'value':'早期審理に関する事情説明書'},
            map{ 'code': ('C1877', 'C2877', 'C3877', 'C4877'), 'value':'早期審理に関する事情説明補充書'}
        )"/>
    <xsl:variable name="c-code-table" as="map(xs:string, xs:string)">  
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$c-config" />
        </xsl:call-template>
    </xsl:variable>    
</xsl:stylesheet>