<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp">

    <!-- this xslt was created with reference to pat_common.xsl
         of Internet Application Software-->

    <!-- ====================================================================
         original: 国名県名変換
         長いのでこっちに移した
            INPUT: country-code (value-of jp:country) e.g. "01", "JP", "US"
            OUTPUT: e.g. "北海道", "日本", "アメリカ合衆国"
         ====================================================================-->
    <xsl:template
        name="国名県名変換">
        <xsl:variable name="kuni" select="normalize-space(.)" />
        <xsl:choose>
            <xsl:when test="$kuni = ''" />
            <xsl:when test="$kuni = '00'">
                <xsl:value-of select="'住所無し'" />
            </xsl:when>
            <xsl:when test="$kuni = '01'">
                <xsl:value-of select="'北海道'" />
            </xsl:when>
            <xsl:when test="$kuni = '02'">
                <xsl:value-of select="'青森県'" />
            </xsl:when>
            <xsl:when test="$kuni = '03'">
                <xsl:value-of select="'岩手県'" />
            </xsl:when>
            <xsl:when test="$kuni = '04'">
                <xsl:value-of select="'宮城県'" />
            </xsl:when>
            <xsl:when test="$kuni = '05'">
                <xsl:value-of select="'秋田県'" />
            </xsl:when>
            <xsl:when test="$kuni = '06'">
                <xsl:value-of select="'山形県'" />
            </xsl:when>
            <xsl:when test="$kuni = '07'">
                <xsl:value-of select="'福島県'" />
            </xsl:when>
            <xsl:when test="$kuni = '08'">
                <xsl:value-of select="'茨城県'" />
            </xsl:when>
            <xsl:when test="$kuni = '09'">
                <xsl:value-of select="'栃木県'" />
            </xsl:when>
            <xsl:when test="$kuni = '10'">
                <xsl:value-of select="'群馬県'" />
            </xsl:when>
            <xsl:when test="$kuni = '11'">
                <xsl:value-of select="'埼玉県'" />
            </xsl:when>
            <xsl:when test="$kuni = '12'">
                <xsl:value-of select="'千葉県'" />
            </xsl:when>
            <xsl:when test="$kuni = '13'">
                <xsl:value-of select="'東京都'" />
            </xsl:when>
            <xsl:when test="$kuni = '14'">
                <xsl:value-of select="'神奈川県'" />
            </xsl:when>
            <xsl:when test="$kuni = '15'">
                <xsl:value-of select="'新潟県'" />
            </xsl:when>
            <xsl:when test="$kuni = '16'">
                <xsl:value-of select="'富山県'" />
            </xsl:when>
            <xsl:when test="$kuni = '17'">
                <xsl:value-of select="'石川県'" />
            </xsl:when>
            <xsl:when test="$kuni = '18'">
                <xsl:value-of select="'福井県'" />
            </xsl:when>
            <xsl:when test="$kuni = '19'">
                <xsl:value-of select="'山梨県'" />
            </xsl:when>
            <xsl:when test="$kuni = '20'">
                <xsl:value-of select="'長野県'" />
            </xsl:when>
            <xsl:when test="$kuni = '21'">
                <xsl:value-of select="'岐阜県'" />
            </xsl:when>
            <xsl:when test="$kuni = '22'">
                <xsl:value-of select="'静岡県'" />
            </xsl:when>
            <xsl:when test="$kuni = '23'">
                <xsl:value-of select="'愛知県'" />
            </xsl:when>
            <xsl:when test="$kuni = '24'">
                <xsl:value-of select="'三重県'" />
            </xsl:when>
            <xsl:when test="$kuni = '25'">
                <xsl:value-of select="'滋賀県'" />
            </xsl:when>
            <xsl:when test="$kuni = '26'">
                <xsl:value-of select="'京都府'" />
            </xsl:when>
            <xsl:when test="$kuni = '27'">
                <xsl:value-of select="'大阪府'" />
            </xsl:when>
            <xsl:when test="$kuni = '28'">
                <xsl:value-of select="'兵庫県'" />
            </xsl:when>
            <xsl:when test="$kuni = '29'">
                <xsl:value-of select="'奈良県'" />
            </xsl:when>
            <xsl:when test="$kuni = '30'">
                <xsl:value-of select="'和歌山県'" />
            </xsl:when>
            <xsl:when test="$kuni = '31'">
                <xsl:value-of select="'鳥取県'" />
            </xsl:when>
            <xsl:when test="$kuni = '32'">
                <xsl:value-of select="'島根県'" />
            </xsl:when>
            <xsl:when test="$kuni = '33'">
                <xsl:value-of select="'岡山県'" />
            </xsl:when>
            <xsl:when test="$kuni = '34'">
                <xsl:value-of select="'広島県'" />
            </xsl:when>
            <xsl:when test="$kuni = '35'">
                <xsl:value-of select="'山口県'" />
            </xsl:when>
            <xsl:when test="$kuni = '36'">
                <xsl:value-of select="'徳島県'" />
            </xsl:when>
            <xsl:when test="$kuni = '37'">
                <xsl:value-of select="'香川県'" />
            </xsl:when>
            <xsl:when test="$kuni = '38'">
                <xsl:value-of select="'愛媛県'" />
            </xsl:when>
            <xsl:when test="$kuni = '39'">
                <xsl:value-of select="'高知県'" />
            </xsl:when>
            <xsl:when test="$kuni = '40'">
                <xsl:value-of select="'福岡県'" />
            </xsl:when>
            <xsl:when test="$kuni = '41'">
                <xsl:value-of select="'佐賀県'" />
            </xsl:when>
            <xsl:when test="$kuni = '42'">
                <xsl:value-of select="'長崎県'" />
            </xsl:when>
            <xsl:when test="$kuni = '43'">
                <xsl:value-of select="'熊本県'" />
            </xsl:when>
            <xsl:when test="$kuni = '44'">
                <xsl:value-of select="'大分県'" />
            </xsl:when>
            <xsl:when test="$kuni = '45'">
                <xsl:value-of select="'宮崎県'" />
            </xsl:when>
            <xsl:when test="$kuni = '46'">
                <xsl:value-of select="'鹿児島県'" />
            </xsl:when>
            <xsl:when test="$kuni = '47'">
                <xsl:value-of select="'沖縄県'" />
            </xsl:when>
            <xsl:when test="$kuni = 'JP'">
                <xsl:value-of select="'日本'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AD'">
                <xsl:value-of select="'アンドラ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AE'">
                <xsl:value-of select="'アラブ首長国連邦'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AF'">
                <xsl:value-of select="'アフガニスタン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AG'">
                <xsl:value-of select="'アンティグア・バーブーダ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AI'">
                <xsl:value-of select="'アンギラ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AL'">
                <xsl:value-of select="'アルバニア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AM'">
                <xsl:value-of select="'アルメニア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AO'">
                <xsl:value-of select="'アンゴラ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AP'">
                <xsl:value-of select="'アフリカ地域工業所有権機関'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AR'">
                <xsl:value-of select="'アルゼンチン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AT'">
                <xsl:value-of select="'オーストリア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AU'">
                <xsl:value-of select="'オーストラリア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AW'">
                <xsl:value-of select="'アルバ島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'AZ'">
                <xsl:value-of select="'アゼルバイジャン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BA'">
                <xsl:value-of select="'ボスニア・ヘルツェゴビナ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BB'">
                <xsl:value-of select="'バルバドス'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BD'">
                <xsl:value-of select="'バングラデシュ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BE'">
                <xsl:value-of select="'ベルギー'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BF'">
                <xsl:value-of select="'ブルキナファソ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BG'">
                <xsl:value-of select="'ブルガリア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BH'">
                <xsl:value-of select="'バーレーン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BI'">
                <xsl:value-of select="'ブルンジ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BJ'">
                <xsl:value-of select="'ベナン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BM'">
                <xsl:value-of select="'バーミューダ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BN'">
                <xsl:value-of select="'ブルネイ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BO'">
                <xsl:value-of select="'ボリビア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BQ'">
                <xsl:value-of select="'ボネール島、シント・ユースタティウス島、サバ島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BR'">
                <xsl:value-of select="'ブラジル'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BS'">
                <xsl:value-of select="'バハマ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BT'">
                <xsl:value-of select="'ブータン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BU'">
                <xsl:value-of select="'ビルマ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BW'">
                <xsl:value-of select="'ボツワナ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BX'">
                <xsl:value-of select="'ベネルクス商標庁及びベネルクス意匠庁'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BY'">
                <xsl:value-of select="'ベラルーシ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'BZ'">
                <xsl:value-of select="'ベリーズ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CA'">
                <xsl:value-of select="'カナダ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CD'">
                <xsl:value-of select="'コンゴ民主共和国'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CF'">
                <xsl:value-of select="'中央アフリカ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CG'">
                <xsl:value-of select="'コンゴ共和国'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CH'">
                <xsl:value-of select="'スイス'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CI'">
                <xsl:value-of select="'コートジボワール'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CK'">
                <xsl:value-of select="'クック諸島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CL'">
                <xsl:value-of select="'チリ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CM'">
                <xsl:value-of select="'カメルーン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CN'">
                <xsl:value-of select="'中華人民共和国'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CO'">
                <xsl:value-of select="'コロンビア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CR'">
                <xsl:value-of select="'コスタリカ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CS'">
                <xsl:value-of select="'チェッコ・スロヴァキア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CU'">
                <xsl:value-of select="'キューバ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CV'">
                <xsl:value-of select="'カーボヴェルデ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CW'">
                <xsl:value-of select="'キュラソー島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CY'">
                <xsl:value-of select="'キプロス'" />
            </xsl:when>
            <xsl:when test="$kuni = 'CZ'">
                <xsl:value-of select="'チェコ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'DD'">
                <xsl:value-of select="'ドイツ民主共和国'" />
            </xsl:when>
            <xsl:when test="$kuni = 'DE'">
                <xsl:value-of select="'ドイツ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'DJ'">
                <xsl:value-of select="'ジブチ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'DK'">
                <xsl:value-of select="'デンマーク'" />
            </xsl:when>
            <xsl:when test="$kuni = 'DM'">
                <xsl:value-of select="'ドミニカ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'DO'">
                <xsl:value-of select="'ドミニカ共和国'" />
            </xsl:when>
            <xsl:when test="$kuni = 'DZ'">
                <xsl:value-of select="'アルジェリア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'EA'">
                <xsl:value-of select="'ユーラシア特許庁'" />
            </xsl:when>
            <xsl:when test="$kuni = 'EC'">
                <xsl:value-of select="'エクアドル'" />
            </xsl:when>
            <xsl:when test="$kuni = 'EE'">
                <xsl:value-of select="'エストニア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'EG'">
                <xsl:value-of select="'エジプト'" />
            </xsl:when>
            <xsl:when test="$kuni = 'EM'">
                <xsl:value-of select="'欧州連合知的財産庁'" />
            </xsl:when>
            <xsl:when test="$kuni = 'EP'">
                <xsl:value-of select="'欧州特許庁'" />
            </xsl:when>
            <xsl:when test="$kuni = 'ER'">
                <xsl:value-of select="'エリトリア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'ES'">
                <xsl:value-of select="'スペイン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'ET'">
                <xsl:value-of select="'エチオピア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'FI'">
                <xsl:value-of select="'フィンランド'" />
            </xsl:when>
            <xsl:when test="$kuni = 'FJ'">
                <xsl:value-of select="'フィジー'" />
            </xsl:when>
            <xsl:when test="$kuni = 'FK'">
                <xsl:value-of select="'フォークランド諸島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'FO'">
                <xsl:value-of select="'フェロー諸島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'FR'">
                <xsl:value-of select="'フランス'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GA'">
                <xsl:value-of select="'ガボン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GB'">
                <xsl:value-of select="'英国'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GC'">
                <xsl:value-of select="'湾岸協力理事会特許庁'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GD'">
                <xsl:value-of select="'グレナダ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GE'">
                <xsl:value-of select="'ジョージア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GG'">
                <xsl:value-of select="'ガーンジー島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GH'">
                <xsl:value-of select="'ガーナ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GI'">
                <xsl:value-of select="'ジブラルタル'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GM'">
                <xsl:value-of select="'ガンビア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GN'">
                <xsl:value-of select="'ギニア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GQ'">
                <xsl:value-of select="'赤道ギニア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GR'">
                <xsl:value-of select="'ギリシャ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GT'">
                <xsl:value-of select="'グアテマラ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GW'">
                <xsl:value-of select="'ギニアビサウ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'GY'">
                <xsl:value-of select="'ガイアナ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'HK'">
                <xsl:value-of select="'香港'" />
            </xsl:when>
            <xsl:when test="$kuni = 'HN'">
                <xsl:value-of select="'ホンジュラス'" />
            </xsl:when>
            <xsl:when test="$kuni = 'HR'">
                <xsl:value-of select="'クロアチア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'HT'">
                <xsl:value-of select="'ハイチ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'HU'">
                <xsl:value-of select="'ハンガリー'" />
            </xsl:when>
            <xsl:when test="$kuni = 'HV'">
                <xsl:value-of select="'上ヴォルタ共和国'" />
            </xsl:when>
            <xsl:when test="$kuni = 'IB'">
                <xsl:value-of select="'国際事務局'" />
            </xsl:when>
            <xsl:when test="$kuni = 'ID'">
                <xsl:value-of select="'インドネシア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'IE'">
                <xsl:value-of select="'アイルランド'" />
            </xsl:when>
            <xsl:when test="$kuni = 'IL'">
                <xsl:value-of select="'イスラエル'" />
            </xsl:when>
            <xsl:when test="$kuni = 'IM'">
                <xsl:value-of select="'マン島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'IN'">
                <xsl:value-of select="'インド'" />
            </xsl:when>
            <xsl:when test="$kuni = 'IQ'">
                <xsl:value-of select="'イラク'" />
            </xsl:when>
            <xsl:when test="$kuni = 'IR'">
                <xsl:value-of select="'イラン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'IS'">
                <xsl:value-of select="'アイスランド'" />
            </xsl:when>
            <xsl:when test="$kuni = 'IT'">
                <xsl:value-of select="'イタリア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'JE'">
                <xsl:value-of select="'ジャージー島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'JM'">
                <xsl:value-of select="'ジャマイカ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'JO'">
                <xsl:value-of select="'ヨルダン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'KE'">
                <xsl:value-of select="'ケニア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'KG'">
                <xsl:value-of select="'キルギス'" />
            </xsl:when>
            <xsl:when test="$kuni = 'KH'">
                <xsl:value-of select="'カンボジア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'KI'">
                <xsl:value-of select="'キリバス'" />
            </xsl:when>
            <xsl:when test="$kuni = 'KM'">
                <xsl:value-of select="'コモロ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'KN'">
                <xsl:value-of select="'セントクリストファー・ネーヴィス'" />
            </xsl:when>
            <xsl:when test="$kuni = 'KP'">
                <xsl:value-of select="'北朝鮮'" />
            </xsl:when>
            <xsl:when test="$kuni = 'KR'">
                <xsl:value-of select="'大韓民国'" />
            </xsl:when>
            <xsl:when test="$kuni = 'KW'">
                <xsl:value-of select="'クウェート'" />
            </xsl:when>
            <xsl:when test="$kuni = 'KY'">
                <xsl:value-of select="'ケイマン諸島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'KZ'">
                <xsl:value-of select="'カザフスタン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'LA'">
                <xsl:value-of select="'ラオス'" />
            </xsl:when>
            <xsl:when test="$kuni = 'LB'">
                <xsl:value-of select="'レバノン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'LC'">
                <xsl:value-of select="'セントルシア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'LI'">
                <xsl:value-of select="'リヒテンシュタイン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'LK'">
                <xsl:value-of select="'スリランカ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'LR'">
                <xsl:value-of select="'リベリア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'LS'">
                <xsl:value-of select="'レソト'" />
            </xsl:when>
            <xsl:when test="$kuni = 'LT'">
                <xsl:value-of select="'リトアニア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'LU'">
                <xsl:value-of select="'ルクセンブルク'" />
            </xsl:when>
            <xsl:when test="$kuni = 'LV'">
                <xsl:value-of select="'ラトビア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'LY'">
                <xsl:value-of select="'リビア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MA'">
                <xsl:value-of select="'モロッコ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MC'">
                <xsl:value-of select="'モナコ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MD'">
                <xsl:value-of select="'モルドバ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MG'">
                <xsl:value-of select="'マダガスカル'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MK'">
                <xsl:value-of select="'北マケドニア共和国'" />
            </xsl:when>
            <xsl:when test="$kuni = 'ML'">
                <xsl:value-of select="'マリ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MM'">
                <xsl:value-of select="'ミャンマー'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MN'">
                <xsl:value-of select="'モンゴル'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MO'">
                <xsl:value-of select="'マカオ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MR'">
                <xsl:value-of select="'モーリタニア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MS'">
                <xsl:value-of select="'モンセラット'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MT'">
                <xsl:value-of select="'マルタ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MU'">
                <xsl:value-of select="'モーリシャス'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MV'">
                <xsl:value-of select="'モルディブ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MW'">
                <xsl:value-of select="'マラウイ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MX'">
                <xsl:value-of select="'メキシコ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MY'">
                <xsl:value-of select="'マレーシア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'MZ'">
                <xsl:value-of select="'モザンビーク'" />
            </xsl:when>
            <xsl:when test="$kuni = 'ME'">
                <xsl:value-of select="'モンテネグロ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'NA'">
                <xsl:value-of select="'ナミビア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'NE'">
                <xsl:value-of select="'ニジェール'" />
            </xsl:when>
            <xsl:when test="$kuni = 'NG'">
                <xsl:value-of select="'ナイジェリア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'NI'">
                <xsl:value-of select="'ニカラグア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'NL'">
                <xsl:value-of select="'オランダ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'NO'">
                <xsl:value-of select="'ノルウェー'" />
            </xsl:when>
            <xsl:when test="$kuni = 'NP'">
                <xsl:value-of select="'ネパール'" />
            </xsl:when>
            <xsl:when test="$kuni = 'NR'">
                <xsl:value-of select="'ナウル'" />
            </xsl:when>
            <xsl:when test="$kuni = 'NU'">
                <xsl:value-of select="'ニウエ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'NZ'">
                <xsl:value-of select="'ニュージーランド'" />
            </xsl:when>
            <xsl:when test="$kuni = 'OA'">
                <xsl:value-of select="'アフリカ知的所有権機関'" />
            </xsl:when>
            <xsl:when test="$kuni = 'OM'">
                <xsl:value-of select="'オマーン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'PA'">
                <xsl:value-of select="'パナマ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'PE'">
                <xsl:value-of select="'ペルー'" />
            </xsl:when>
            <xsl:when test="$kuni = 'PG'">
                <xsl:value-of select="'パプアニューギニア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'PH'">
                <xsl:value-of select="'フィリピン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'PK'">
                <xsl:value-of select="'パキスタン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'PL'">
                <xsl:value-of select="'ポーランド'" />
            </xsl:when>
            <xsl:when test="$kuni = 'PR'">
                <xsl:value-of select="'プエルトリコ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'PT'">
                <xsl:value-of select="'ポルトガル'" />
            </xsl:when>
            <xsl:when test="$kuni = 'PW'">
                <xsl:value-of select="'パラオ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'PY'">
                <xsl:value-of select="'パラグアイ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'QA'">
                <xsl:value-of select="'カタール'" />
            </xsl:when>
            <xsl:when test="$kuni = 'RH'">
                <xsl:value-of select="'南ローデシア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'RO'">
                <xsl:value-of select="'ルーマニア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'RU'">
                <xsl:value-of select="'ロシア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'RW'">
                <xsl:value-of select="'ルワンダ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'RS'">
                <xsl:value-of select="'セルビア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SA'">
                <xsl:value-of select="'サウジアラビア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SB'">
                <xsl:value-of select="'ソロモン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SC'">
                <xsl:value-of select="'セーシェル'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SD'">
                <xsl:value-of select="'スーダン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SE'">
                <xsl:value-of select="'スウェーデン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SG'">
                <xsl:value-of select="'シンガポール'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SH'">
                <xsl:value-of select="'セントヘレナ島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SI'">
                <xsl:value-of select="'スロベニア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SK'">
                <xsl:value-of select="'スロバキア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SL'">
                <xsl:value-of select="'シエラレオネ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SM'">
                <xsl:value-of select="'サンマリノ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SN'">
                <xsl:value-of select="'セネガル'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SO'">
                <xsl:value-of select="'ソマリア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SR'">
                <xsl:value-of select="'スリナム'" />
            </xsl:when>
            <xsl:when test="$kuni = 'ST'">
                <xsl:value-of select="'サントメ・プリンシペ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SU'">
                <xsl:value-of select="'ソヴィエト連邦'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SV'">
                <xsl:value-of select="'エルサルバドル'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SX'">
                <xsl:value-of select="'シント・マールテン島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SY'">
                <xsl:value-of select="'シリア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'SZ'">
                <xsl:value-of select="'エスワティニ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TD'">
                <xsl:value-of select="'チャド'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TG'">
                <xsl:value-of select="'トーゴ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TH'">
                <xsl:value-of select="'タイ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TJ'">
                <xsl:value-of select="'タジキスタン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TK'">
                <xsl:value-of select="'トケラウ諸島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TL'">
                <xsl:value-of select="'東ティモール'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TM'">
                <xsl:value-of select="'トルクメニスタン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TN'">
                <xsl:value-of select="'チュニジア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TO'">
                <xsl:value-of select="'トンガ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TR'">
                <xsl:value-of select="'トルコ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TT'">
                <xsl:value-of select="'トリニダード・トバゴ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TV'">
                <xsl:value-of select="'ツバル'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TW'">
                <xsl:value-of select="'台湾'" />
            </xsl:when>
            <xsl:when test="$kuni = 'TZ'">
                <xsl:value-of select="'タンザニア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'UA'">
                <xsl:value-of select="'ウクライナ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'UG'">
                <xsl:value-of select="'ウガンダ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'US'">
                <xsl:value-of select="'アメリカ合衆国'" />
            </xsl:when>
            <xsl:when test="$kuni = 'UY'">
                <xsl:value-of select="'ウルグアイ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'UZ'">
                <xsl:value-of select="'ウズベキスタン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'VA'">
                <xsl:value-of select="'バチカン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'VC'">
                <xsl:value-of select="'セントビンセント'" />
            </xsl:when>
            <xsl:when test="$kuni = 'VE'">
                <xsl:value-of select="'ベネズエラ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'VG'">
                <xsl:value-of select="'ヴァージン諸島'" />
            </xsl:when>
            <xsl:when test="$kuni = 'VN'">
                <xsl:value-of select="'ベトナム'" />
            </xsl:when>
            <xsl:when test="$kuni = 'VU'">
                <xsl:value-of select="'バヌアツ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'WO'">
                <xsl:value-of select="'世界知的所有権機関'" />
            </xsl:when>
            <xsl:when test="$kuni = 'WS'">
                <xsl:value-of select="'サモア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'XX'">
                <xsl:value-of select="'無国籍、その他の国名及び地域名'" />
            </xsl:when>
            <xsl:when test="$kuni = 'YD'">
                <xsl:value-of select="'南イエメン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'YE'">
                <xsl:value-of select="'イエメン'" />
            </xsl:when>
            <xsl:when test="$kuni = 'YU'">
                <xsl:value-of select="'セルビア・モンテネグロ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'ZA'">
                <xsl:value-of select="'南アフリカ'" />
            </xsl:when>
            <xsl:when test="$kuni = 'ZM'">
                <xsl:value-of select="'ザンビア'" />
            </xsl:when>
            <xsl:when test="$kuni = 'ZR'">
                <xsl:value-of select="'ザイール'" />
            </xsl:when>
            <xsl:when test="$kuni = 'ZW'">
                <xsl:value-of select="'ジンバブエ'" />
            </xsl:when>
            <xsl:when test="$kuni = '99'">
                <xsl:value-of select="'９９'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="書誌編集エラー処理" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>