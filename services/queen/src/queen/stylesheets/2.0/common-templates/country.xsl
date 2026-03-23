<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:jp="http://www.jpo.go.jp"
                xmlns:xf="http://www.w3.org/2005/xpath-functions"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map">
    
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
        <xsl:variable name="country-name" select="map:get($country-map, $kuni)" />
        <xsl:choose>
            <xsl:when test="$country-name">
                <xsl:value-of select="$country-name" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'Unknown country code: ' || $kuni" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:variable name="country-map" as="map(xs:string, xs:string)">
        <xsl:map>
            <xsl:map-entry key="'00'" select="'住所無し'" />
            <xsl:map-entry key="'01'" select="'北海道'" />
            <xsl:map-entry key="'02'" select="'青森県'" />
            <xsl:map-entry key="'03'" select="'岩手県'" />
            <xsl:map-entry key="'04'" select="'宮城県'" />
            <xsl:map-entry key="'05'" select="'秋田県'" />
            <xsl:map-entry key="'06'" select="'山形県'" />
            <xsl:map-entry key="'07'" select="'福島県'" />
            <xsl:map-entry key="'08'" select="'茨城県'" />
            <xsl:map-entry key="'09'" select="'栃木県'" />
            <xsl:map-entry key="'10'" select="'群馬県'" />
            <xsl:map-entry key="'11'" select="'埼玉県'" />
            <xsl:map-entry key="'12'" select="'千葉県'" />
            <xsl:map-entry key="'13'" select="'東京都'" />
            <xsl:map-entry key="'14'" select="'神奈川県'" />
            <xsl:map-entry key="'15'" select="'新潟県'" />
            <xsl:map-entry key="'16'" select="'富山県'" />
            <xsl:map-entry key="'17'" select="'石川県'" />
            <xsl:map-entry key="'18'" select="'福井県'" /> 
            <xsl:map-entry key="'19'" select="'山梨県'" /> 
            <xsl:map-entry key="'20'" select="'長野県'" /> 
            <xsl:map-entry key="'21'" select="'岐阜県'" /> 
            <xsl:map-entry key="'22'" select="'静岡県'" /> 
            <xsl:map-entry key="'23'" select="'愛知県'" /> 
            <xsl:map-entry key="'24'" select="'三重県'" /> 
            <xsl:map-entry key="'25'" select="'滋賀県'" /> 
            <xsl:map-entry key="'26'" select="'京都府'" /> 
            <xsl:map-entry key="'27'" select="'大阪府'" /> 
            <xsl:map-entry key="'28'" select="'兵庫県'" /> 
            <xsl:map-entry key="'29'" select="'奈良県'" /> 
            <xsl:map-entry key="'30'" select="'和歌山県'" /> 
            <xsl:map-entry key="'31'" select="'鳥取県'" /> 
            <xsl:map-entry key="'32'" select="'島根県'" /> 
            <xsl:map-entry key="'33'" select="'岡山県'" /> 
            <xsl:map-entry key="'34'" select="'広島県'" /> 
            <xsl:map-entry key="'35'" select="'山口県'" /> 
            <xsl:map-entry key="'36'" select="'徳島県'" /> 
            <xsl:map-entry key="'37'" select="'香川県'" /> 
            <xsl:map-entry key="'38'" select="'愛媛県'" /> 
            <xsl:map-entry key="'39'" select="'高知県'" /> 
            <xsl:map-entry key="'40'" select="'福岡県'" /> 
            <xsl:map-entry key="'41'" select="'佐賀県'" /> 
            <xsl:map-entry key="'42'" select="'長崎県'" /> 
            <xsl:map-entry key="'43'" select="'熊本県'" /> 
            <xsl:map-entry key="'44'" select="'大分県'" /> 
            <xsl:map-entry key="'45'" select="'宮崎県'" /> 
            <xsl:map-entry key="'46'" select="'鹿児島県'" /> 
            <xsl:map-entry key="'47'" select="'沖縄県'" /> 
            <xsl:map-entry key="'JP'" select="'日本'" /> 
            <xsl:map-entry key="'AD'" select="'アンドラ'" /> 
            <xsl:map-entry key="'AE'" select="'アラブ首長国連邦'" /> 
            <xsl:map-entry key="'AF'" select="'アフガニスタン'" /> 
            <xsl:map-entry key="'AG'" select="'アンティグア・バーブーダ'" /> 
            <xsl:map-entry key="'AI'" select="'アンギラ'" /> 
            <xsl:map-entry key="'AL'" select="'アルバニア'" /> 
            <xsl:map-entry key="'AM'" select="'アルメニア'" /> 
            <xsl:map-entry key="'AO'" select="'アンゴラ'" /> 
            <xsl:map-entry key="'AP'" select="'アフリカ地域工業所有権機関'" /> 
            <xsl:map-entry key="'AR'" select="'アルゼンチン'" /> 
            <xsl:map-entry key="'AT'" select="'オーストリア'" /> 
            <xsl:map-entry key="'AU'" select="'オーストラリア'" /> 
            <xsl:map-entry key="'AW'" select="'アルバ島'" /> 
            <xsl:map-entry key="'AZ'" select="'アゼルバイジャン'" /> 
            <xsl:map-entry key="'BA'" select="'ボスニア・ヘルツェゴビナ'" /> 
            <xsl:map-entry key="'BB'" select="'バルバドス'" /> 
            <xsl:map-entry key="'BD'" select="'バングラデシュ'" /> 
            <xsl:map-entry key="'BE'" select="'ベルギー'" /> 
            <xsl:map-entry key="'BF'" select="'ブルキナファソ'" /> 
            <xsl:map-entry key="'BG'" select="'ブルガリア'" /> 
            <xsl:map-entry key="'BH'" select="'バーレーン'" /> 
            <xsl:map-entry key="'BI'" select="'ブルンジ'" /> 
            <xsl:map-entry key="'BJ'" select="'ベナン'" /> 
            <xsl:map-entry key="'BM'" select="'バーミューダ'" /> 
            <xsl:map-entry key="'BN'" select="'ブルネイ'" /> 
            <xsl:map-entry key="'BO'" select="'ボリビア'" /> 
            <xsl:map-entry key="'BQ'" select="'ボネール島、シント・ユースタティウス島、サバ島'" /> 
            <xsl:map-entry key="'BR'" select="'ブラジル'" /> 
            <xsl:map-entry key="'BS'" select="'バハマ'" /> 
            <xsl:map-entry key="'BT'" select="'ブータン'" /> 
            <xsl:map-entry key="'BU'" select="'ビルマ'" /> 
            <xsl:map-entry key="'BW'" select="'ボツワナ'" /> 
            <xsl:map-entry key="'BX'" select="'ベネルクス商標庁及びベネルクス意匠庁'" /> 
            <xsl:map-entry key="'BY'" select="'ベラルーシ'" /> 
            <xsl:map-entry key="'BZ'" select="'ベリーズ'" /> 
            <xsl:map-entry key="'CA'" select="'カナダ'" /> 
            <xsl:map-entry key="'CD'" select="'コンゴ民主共和国'" /> 
            <xsl:map-entry key="'CF'" select="'中央アフリカ'" /> 
            <xsl:map-entry key="'CG'" select="'コンゴ共和国'" /> 
            <xsl:map-entry key="'CH'" select="'スイス'" /> 
            <xsl:map-entry key="'CI'" select="'コートジボワール'" /> 
            <xsl:map-entry key="'CK'" select="'クック諸島'" /> 
            <xsl:map-entry key="'CL'" select="'チリ'" /> 
            <xsl:map-entry key="'CM'" select="'カメルーン'" /> 
            <xsl:map-entry key="'CN'" select="'中華人民共和国'" /> 
            <xsl:map-entry key="'CO'" select="'コロンビア'" /> 
            <xsl:map-entry key="'CR'" select="'コスタリカ'" /> 
            <xsl:map-entry key="'CS'" select="'チェッコ・スロヴァキア'" /> 
            <xsl:map-entry key="'CU'" select="'キューバ'" /> 
            <xsl:map-entry key="'CV'" select="'カーボヴェルデ'" /> 
            <xsl:map-entry key="'CW'" select="'キュラソー島'" /> 
            <xsl:map-entry key="'CY'" select="'キプロス'" /> 
            <xsl:map-entry key="'CZ'" select="'チェコ'" /> 
            <xsl:map-entry key="'DD'" select="'ドイツ民主共和国'" /> 
            <xsl:map-entry key="'DE'" select="'ドイツ'" /> 
            <xsl:map-entry key="'DJ'" select="'ジブチ'" /> 
            <xsl:map-entry key="'DK'" select="'デンマーク'" /> 
            <xsl:map-entry key="'DM'" select="'ドミニカ'" /> 
            <xsl:map-entry key="'DO'" select="'ドミニカ共和国'" /> 
            <xsl:map-entry key="'DZ'" select="'アルジェリア'" /> 
            <xsl:map-entry key="'EA'" select="'ユーラシア特許庁'" /> 
            <xsl:map-entry key="'EC'" select="'エクアドル'" /> 
            <xsl:map-entry key="'EE'" select="'エストニア'" /> 
            <xsl:map-entry key="'EG'" select="'エジプト'" /> 
            <xsl:map-entry key="'EM'" select="'欧州連合知的財産庁'" /> 
            <xsl:map-entry key="'EP'" select="'欧州特許庁'" /> 
            <xsl:map-entry key="'ER'" select="'エリトリア'" /> 
            <xsl:map-entry key="'ES'" select="'スペイン'" /> 
            <xsl:map-entry key="'ET'" select="'エチオピア'" /> 
            <xsl:map-entry key="'FI'" select="'フィンランド'" /> 
            <xsl:map-entry key="'FJ'" select="'フィジー'" /> 
            <xsl:map-entry key="'FK'" select="'フォークランド諸島'" /> 
            <xsl:map-entry key="'FO'" select="'フェロー諸島'" /> 
            <xsl:map-entry key="'FR'" select="'フランス'" /> 
            <xsl:map-entry key="'GA'" select="'ガボン'" /> 
            <xsl:map-entry key="'GB'" select="'英国'" /> 
            <xsl:map-entry key="'GC'" select="'湾岸協力理事会特許庁'" /> 
            <xsl:map-entry key="'GD'" select="'グレナダ'" /> 
            <xsl:map-entry key="'GE'" select="'ジョージア'" /> 
            <xsl:map-entry key="'GG'" select="'ガーンジー島'" /> 
            <xsl:map-entry key="'GH'" select="'ガーナ'" /> 
            <xsl:map-entry key="'GI'" select="'ジブラルタル'" /> 
            <xsl:map-entry key="'GM'" select="'ガンビア'" /> 
            <xsl:map-entry key="'GN'" select="'ギニア'" /> 
            <xsl:map-entry key="'GQ'" select="'赤道ギニア'" /> 
            <xsl:map-entry key="'GR'" select="'ギリシャ'" /> 
            <xsl:map-entry key="'GT'" select="'グアテマラ'" /> 
            <xsl:map-entry key="'GW'" select="'ギニアビサウ'" /> 
            <xsl:map-entry key="'GY'" select="'ガイアナ'" /> 
            <xsl:map-entry key="'HK'" select="'香港'" /> 
            <xsl:map-entry key="'HN'" select="'ホンジュラス'" /> 
            <xsl:map-entry key="'HR'" select="'クロアチア'" /> 
            <xsl:map-entry key="'HT'" select="'ハイチ'" /> 
            <xsl:map-entry key="'HU'" select="'ハンガリー'" /> 
            <xsl:map-entry key="'HV'" select="'上ヴォルタ共和国'" /> 
            <xsl:map-entry key="'IB'" select="'国際事務局'" /> 
            <xsl:map-entry key="'ID'" select="'インドネシア'" /> 
            <xsl:map-entry key="'IE'" select="'アイルランド'" /> 
            <xsl:map-entry key="'IL'" select="'イスラエル'" /> 
            <xsl:map-entry key="'IM'" select="'マン島'" /> 
            <xsl:map-entry key="'IN'" select="'インド'" /> 
            <xsl:map-entry key="'IQ'" select="'イラク'" /> 
            <xsl:map-entry key="'IR'" select="'イラン'" /> 
            <xsl:map-entry key="'IS'" select="'アイスランド'" /> 
            <xsl:map-entry key="'IT'" select="'イタリア'" /> 
            <xsl:map-entry key="'JE'" select="'ジャージー島'" /> 
            <xsl:map-entry key="'JM'" select="'ジャマイカ'" /> 
            <xsl:map-entry key="'JO'" select="'ヨルダン'" /> 
            <xsl:map-entry key="'KE'" select="'ケニア'" /> 
            <xsl:map-entry key="'KG'" select="'キルギス'" /> 
            <xsl:map-entry key="'KH'" select="'カンボジア'" /> 
            <xsl:map-entry key="'KI'" select="'キリバス'" /> 
            <xsl:map-entry key="'KM'" select="'コモロ'" /> 
            <xsl:map-entry key="'KN'" select="'セントクリストファー・ネーヴィス'" /> 
            <xsl:map-entry key="'KP'" select="'北朝鮮'" /> 
            <xsl:map-entry key="'KR'" select="'大韓民国'" /> 
            <xsl:map-entry key="'KW'" select="'クウェート'" /> 
            <xsl:map-entry key="'KY'" select="'ケイマン諸島'" /> 
            <xsl:map-entry key="'KZ'" select="'カザフスタン'" /> 
            <xsl:map-entry key="'LA'" select="'ラオス'" /> 
            <xsl:map-entry key="'LB'" select="'レバノン'" /> 
            <xsl:map-entry key="'LC'" select="'セントルシア'" /> 
            <xsl:map-entry key="'LI'" select="'リヒテンシュタイン'" /> 
            <xsl:map-entry key="'LK'" select="'スリランカ'" /> 
            <xsl:map-entry key="'LR'" select="'リベリア'" /> 
            <xsl:map-entry key="'LS'" select="'レソト'" /> 
            <xsl:map-entry key="'LT'" select="'リトアニア'" /> 
            <xsl:map-entry key="'LU'" select="'ルクセンブルク'" /> 
            <xsl:map-entry key="'LV'" select="'ラトビア'" /> 
            <xsl:map-entry key="'LY'" select="'リビア'" /> 
            <xsl:map-entry key="'MA'" select="'モロッコ'" /> 
            <xsl:map-entry key="'MC'" select="'モナコ'" /> 
            <xsl:map-entry key="'MD'" select="'モルドバ'" /> 
            <xsl:map-entry key="'MG'" select="'マダガスカル'" /> 
            <xsl:map-entry key="'MK'" select="'北マケドニア共和国'" /> 
            <xsl:map-entry key="'ML'" select="'マリ'" /> 
            <xsl:map-entry key="'MM'" select="'ミャンマー'" /> 
            <xsl:map-entry key="'MN'" select="'モンゴル'" /> 
            <xsl:map-entry key="'MO'" select="'マカオ'" /> 
            <xsl:map-entry key="'MR'" select="'モーリタニア'" /> 
            <xsl:map-entry key="'MS'" select="'モンセラット'" /> 
            <xsl:map-entry key="'MT'" select="'マルタ'" /> 
            <xsl:map-entry key="'MU'" select="'モーリシャス'" /> 
            <xsl:map-entry key="'MV'" select="'モルディブ'" /> 
            <xsl:map-entry key="'MW'" select="'マラウイ'" /> 
            <xsl:map-entry key="'MX'" select="'メキシコ'" /> 
            <xsl:map-entry key="'MY'" select="'マレーシア'" /> 
            <xsl:map-entry key="'MZ'" select="'モザンビーク'" /> 
            <xsl:map-entry key="'ME'" select="'モンテネグロ'" /> 
            <xsl:map-entry key="'NA'" select="'ナミビア'" /> 
            <xsl:map-entry key="'NE'" select="'ニジェール'" /> 
            <xsl:map-entry key="'NG'" select="'ナイジェリア'" /> 
            <xsl:map-entry key="'NI'" select="'ニカラグア'" /> 
            <xsl:map-entry key="'NL'" select="'オランダ'" /> 
            <xsl:map-entry key="'NO'" select="'ノルウェー'" /> 
            <xsl:map-entry key="'NP'" select="'ネパール'" /> 
            <xsl:map-entry key="'NR'" select="'ナウル'" /> 
            <xsl:map-entry key="'NU'" select="'ニウエ'" /> 
            <xsl:map-entry key="'NZ'" select="'ニュージーランド'" /> 
            <xsl:map-entry key="'OA'" select="'アフリカ知的所有権機関'" /> 
            <xsl:map-entry key="'OM'" select="'オマーン'" /> 
            <xsl:map-entry key="'PA'" select="'パナマ'" /> 
            <xsl:map-entry key="'PE'" select="'ペルー'" /> 
            <xsl:map-entry key="'PG'" select="'パプアニューギニア'" /> 
            <xsl:map-entry key="'PH'" select="'フィリピン'" /> 
            <xsl:map-entry key="'PK'" select="'パキスタン'" /> 
            <xsl:map-entry key="'PL'" select="'ポーランド'" /> 
            <xsl:map-entry key="'PR'" select="'プエルトリコ'" /> 
            <xsl:map-entry key="'PT'" select="'ポルトガル'" /> 
            <xsl:map-entry key="'PW'" select="'パラオ'" /> 
            <xsl:map-entry key="'PY'" select="'パラグアイ'" /> 
            <xsl:map-entry key="'QA'" select="'カタール'" /> 
            <xsl:map-entry key="'RH'" select="'南ローデシア'" /> 
            <xsl:map-entry key="'RO'" select="'ルーマニア'" /> 
            <xsl:map-entry key="'RU'" select="'ロシア'" /> 
            <xsl:map-entry key="'RW'" select="'ルワンダ'" /> 
            <xsl:map-entry key="'RS'" select="'セルビア'" /> 
            <xsl:map-entry key="'SA'" select="'サウジアラビア'" /> 
            <xsl:map-entry key="'SB'" select="'ソロモン'" /> 
            <xsl:map-entry key="'SC'" select="'セーシェル'" /> 
            <xsl:map-entry key="'SD'" select="'スーダン'" /> 
            <xsl:map-entry key="'SE'" select="'スウェーデン'" /> 
            <xsl:map-entry key="'SG'" select="'シンガポール'" /> 
            <xsl:map-entry key="'SH'" select="'セントヘレナ島'" /> 
            <xsl:map-entry key="'SI'" select="'スロベニア'" /> 
            <xsl:map-entry key="'SK'" select="'スロバキア'" /> 
            <xsl:map-entry key="'SL'" select="'シエラレオネ'" /> 
            <xsl:map-entry key="'SM'" select="'サンマリノ'" /> 
            <xsl:map-entry key="'SN'" select="'セネガル'" /> 
            <xsl:map-entry key="'SO'" select="'ソマリア'" /> 
            <xsl:map-entry key="'SR'" select="'スリナム'" /> 
            <xsl:map-entry key="'ST'" select="'サントメ・プリンシペ'" /> 
            <xsl:map-entry key="'SU'" select="'ソヴィエト連邦'" /> 
            <xsl:map-entry key="'SV'" select="'エルサルバドル'" /> 
            <xsl:map-entry key="'SX'" select="'シント・マールテン島'" /> 
            <xsl:map-entry key="'SY'" select="'シリア'" /> 
            <xsl:map-entry key="'SZ'" select="'エスワティニ'" /> 
            <xsl:map-entry key="'TD'" select="'チャド'" /> 
            <xsl:map-entry key="'TG'" select="'トーゴ'" /> 
            <xsl:map-entry key="'TH'" select="'タイ'" /> 
            <xsl:map-entry key="'TJ'" select="'タジキスタン'" /> 
            <xsl:map-entry key="'TK'" select="'トケラウ諸島'" /> 
            <xsl:map-entry key="'TL'" select="'東ティモール'" /> 
            <xsl:map-entry key="'TM'" select="'トルクメニスタン'" /> 
            <xsl:map-entry key="'TN'" select="'チュニジア'" /> 
            <xsl:map-entry key="'TO'" select="'トンガ'" /> 
            <xsl:map-entry key="'TR'" select="'トルコ'" /> 
            <xsl:map-entry key="'TT'" select="'トリニダード・トバゴ'" /> 
            <xsl:map-entry key="'TV'" select="'ツバル'" /> 
            <xsl:map-entry key="'TW'" select="'台湾'" /> 
            <xsl:map-entry key="'TZ'" select="'タンザニア'" /> 
            <xsl:map-entry key="'UA'" select="'ウクライナ'" /> 
            <xsl:map-entry key="'UG'" select="'ウガンダ'" /> 
            <xsl:map-entry key="'US'" select="'アメリカ合衆国'" /> 
            <xsl:map-entry key="'UY'" select="'ウルグアイ'" /> 
            <xsl:map-entry key="'UZ'" select="'ウズベキスタン'" /> 
            <xsl:map-entry key="'VA'" select="'バチカン'" /> 
            <xsl:map-entry key="'VC'" select="'セントビンセント'" /> 
            <xsl:map-entry key="'VE'" select="'ベネズエラ'" /> 
            <xsl:map-entry key="'VG'" select="'ヴァージン諸島'" /> 
            <xsl:map-entry key="'VN'" select="'ベトナム'" /> 
            <xsl:map-entry key="'VU'" select="'バヌアツ'" /> 
            <xsl:map-entry key="'WO'" select="'世界知的所有権機関'" /> 
            <xsl:map-entry key="'WS'" select="'サモア'" /> 
            <xsl:map-entry key="'XX'" select="'無国籍、その他の国名及び地域名'" /> 
            <xsl:map-entry key="'YD'" select="'南イエメン'" /> 
            <xsl:map-entry key="'YE'" select="'イエメン'" /> 
            <xsl:map-entry key="'YU'" select="'セルビア・モンテネグロ'" /> 
            <xsl:map-entry key="'ZA'" select="'南アフリカ'" /> 
            <xsl:map-entry key="'ZM'" select="'ザンビア'" /> 
            <xsl:map-entry key="'ZR'" select="'ザイール'" /> 
            <xsl:map-entry key="'ZW'" select="'ジンバブエ'" /> 
            <xsl:map-entry key="'99'" select="'９９'" /> 
        </xsl:map>
    </xsl:variable>
</xsl:stylesheet>