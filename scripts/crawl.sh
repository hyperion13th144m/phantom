#!/bin/sh

SCRIPT_DIR=$(dirname $0)
PROJECT_DIR="$SCRIPT_DIR/.."
CMD="docker compose -f $PROJECT_DIR/docker-compose.yml run --rm -i mona"

while getopts "om:t:" opt; do
  case $opt in
    m)
      NUM_MULTI_PROCESSORS="-m $OPTARG"
      ;;
    o)
      OVERWRITE="-o"
      ;;
    t)
      TARGET="$OPTARG"
      ;;
    *)
      echo "Usage: $0 [-m {num_multi_processors}] [-o] [-t {target}]"
      echo "  -m: Number of multi-processors to use for crawling. Default is 1. max is 4"
      echo "  -o: Overwrite existing data in the data_dir. WARNING: This will delete all existing data in the data_dir."
      echo "  -t: Specify the target for crawling."
      exit 1
      ;;
  esac
done

PAT_APP_DOC_CODES="A163 A263 A1631 A1632 A1634"
PAT_AMND="A151 A1523 A1524 A1525 A1529 A1526 A15210 A1527 A15211 A1528 A15212 A2523"
PAT_RSPN="A153 A159"
PAT_ETC="A1781 A1871 A1872"
NOTICE="A101 A102 A1131 A1191 A1192 A130"
ALL="$PAT_APP_DOC_CODES $PAT_AMND $PAT_RSPN $PAT_ETC $NOTICE"
#    "A101",  特許査定
#    "A102",  拒絶査定
#    "A1131", 拒絶理由通知書
#    "A1191", 補正却下の決定
#    "A1192", 補正却下の決定
#    "A130",  引用非特許文献
#    "A163",  特許願
#    "A263",  実用新案登録願
#    "A1631", 翻訳文提出書
#    "A1632", 国内書面
#    # "A2633", 図面の提出書（実案）は対象外(データないので確認できない)
#    "A1634",   国際出願翻訳文提出書
#    # "A1635", 国際出願翻訳文提出書（職権）は対象外(データないので確認できない)
#    "A151",  手続補正書（方式）| 手続補正書
#    "A1523",  手続補正書 特許
#    "A2523",  手続補正書 実案
#    "A1524",  誤訳訂正書
#    "A1525",  特許協力条約第１９条補正の翻訳文提出書
#    "A1529",  特許協力条約第３４条補正の翻訳文提出書
#    "A1526",  特許協力条約第１９条補正の翻訳文提出書（職権）
#    "A15210", 特許協力条約第３４条補正の翻訳文提出書（職権）
#    "A1527",  特許協力条約第１９条補正の写し提出書
#    "A15211", 特許協力条約第３４条補正の写し提出書
#    "A1528",  特許協力条約第１９条補正の写し提出書（職権）
#    "A15212", 特許協力条約第３４条補正の写し提出書（職権）
#    "A153",   意見書
#    "A159",   弁明書
#    "A1781",  上申書
#    "A1871",  早期審査に関する事情説明書
#    "A1872",  早期審査に関する事情説明補充書
#    # 実用新案
#    "A2242623",  # 実用新案技術評価の通知
case $TARGET in
  "ALL")
    TARGET_CODES="$ALL"
    ;;
  "APP_DOC")
    TARGET_CODES="$PAT_APP_DOC_CODES"
    ;;
  "AMND")
    TARGET_CODES="$PAT_AMND"
    ;;
  "RSPN")
    TARGET_CODES="$PAT_RSPN"
    ;;
  "ETC")
    TARGET_CODES="$PAT_ETC"
    ;;
  "NOTICE")
    TARGET_CODES="$NOTICE"
    ;;
  *)
    echo "Invalid target specified. Supported targets are: ALL, APP_DOC, AMND, RSPN, ETC, NOTICE"
    exit 1
    ;;
esac
$CMD $OVERWRITE $NUM_MULTI_PROCESSORS /src_dir /data_dir $TARGET_CODES
