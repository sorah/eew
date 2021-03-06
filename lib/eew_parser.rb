#encoding: utf-8

# 緊急地震速報パーサ
# Author:: Glass_saga
# License:: NYSL Version 0.9982
#
# 高度利用者向け緊急地震速報コード電文フォーマットを扱う為のライブラリです。
# http://eew.mizar.jp/excodeformat を元に作成しました。
#
#   str = <<EOS
#   37 03 00 110415005029 C11
#   110415004944
#   ND20110415005001 NCN001 JD////////////// JN///
#   189 N430 E1466 070 41 02 RK66204 RT10/// RC/////
#   9999=
#   EOS
#
#   eew = EEWParser.new(str)
#   puts "最大予測震度: #{fc.seismic_intensity}"
#
class EEWParser
# 震央地名コードをkey,震央地名称をvalueとするHash
EpicenterCord = {
0 => "不明",
11 => "北海道地方",
12 => "東北地方",
13 => "北陸地方",
14 => "関東甲信地方",
15 => "小笠原地方",
16 => "東海地方",
17 => "近畿地方",
18 => "中国地方",
19 => "四国地方",
20 => "九州地方",
21 => "沖縄地方",
100 => "石狩支庁北部",
101 => "石狩支庁中部",
102 => "石狩支庁南部",
105 => "渡島支庁北部",
106 => "渡島支庁東部",
107 => "渡島支庁西部",
110 => "檜山支庁",
115 => "後志支庁北部",
116 => "後志支庁東部",
117 => "後志支庁西部",
120 => "空知支庁北部",
121 => "空知支庁中部",
122 => "空知支庁南部",
125 => "上川支庁北部",
126 => "上川支庁中部",
127 => "上川支庁南部",
130 => "留萌支庁中北部",
131 => "留萌支庁南部",
135 => "宗谷支庁北部",
136 => "宗谷支庁南部",
140 => "網走支庁網走地方",
141 => "網走支庁北見地方",
142 => "網走支庁紋別地方",
145 => "胆振支庁西部",
146 => "胆振支庁中東部",
150 => "日高支庁西部",
151 => "日高支庁中部",
152 => "日高支庁東部",
155 => "十勝支庁北部",
156 => "十勝支庁中部",
157 => "十勝支庁南部",
160 => "釧路支庁北部",
161 => "釧路支庁中南部",
165 => "根室支庁北部",
166 => "根室支庁中部",
167 => "根室支庁南部",
180 => "北海道南西沖",
181 => "北海道西方沖",
182 => "石狩湾",
183 => "北海道北西沖",
184 => "宗谷海峡",
185 => "北海道北東沖(廃止)",
186 => "国後島付近",
187 => "択捉島付近",
188 => "北海道東方沖",
189 => "根室半島南東沖",
190 => "釧路沖",
191 => "十勝沖",
192 => "浦河沖",
193 => "苫小牧沖",
194 => "内浦湾",
195 => "宗谷東方沖",
196 => "網走沖",
197 => "択捉島南東沖",
200 => "青森県津軽北部",
201 => "青森県津軽南部",
202 => "青森県三八上北地方",
203 => "青森県下北地方",
210 => "岩手県沿岸北部",
211 => "岩手県沿岸南部",
212 => "岩手県内陸北部",
213 => "岩手県内陸南部",
220 => "宮城県北部",
221 => "宮城県南部",
222 => "宮城県中部",
230 => "秋田県沿岸北部",
231 => "秋田県沿岸南部",
232 => "秋田県内陸北部",
233 => "秋田県内陸南部",
240 => "山形県庄内地方",
241 => "山形県最上地方",
242 => "山形県村山地方",
243 => "山形県置賜地方",
250 => "福島県中通り",
251 => "福島県浜通り",
252 => "福島県会津",
280 => "津軽海峡",
281 => "山形県沖",
282 => "秋田県沖",
283 => "青森県西方沖",
284 => "陸奥湾",
285 => "青森県東方沖",
286 => "岩手県沖",
287 => "宮城県沖",
288 => "三陸沖",
289 => "福島県沖",
290 => "仙台湾(廃止)",
300 => "茨城県北部",
301 => "茨城県南部",
309 => "千葉県南東沖",
310 => "栃木県北部",
311 => "栃木県南部",
320 => "群馬県北部",
321 => "群馬県南部",
330 => "埼玉県北部",
331 => "埼玉県南部",
332 => "埼玉県秩父地方",
340 => "千葉県北東部",
341 => "千葉県北西部",
342 => "千葉県南部",
349 => "房総半島南方沖",
350 => "東京都23区",
351 => "東京都多摩東部",
352 => "東京都多摩西部",
360 => "神奈川県東部",
361 => "神奈川県西部",
370 => "新潟県上越地方",
371 => "新潟県中越地方",
372 => "新潟県下越地方",
378 => "新潟県下越沖",
379 => "新潟県上中越沖",
380 => "富山県東部",
381 => "富山県西部",
390 => "石川県能登地方",
391 => "石川県加賀地方",
400 => "福井県嶺北",
401 => "福井県嶺南",
411 => "山梨県中・西部",
412 => "山梨県東部・富士五湖",
420 => "長野県北部",
421 => "長野県中部",
422 => "長野県南部",
430 => "岐阜県飛騨地方",
431 => "岐阜県美濃東部",
432 => "岐阜県美濃中西部",
440 => "静岡県伊豆地方",
441 => "静岡県東部",
442 => "静岡県中部",
443 => "静岡県西部",
450 => "愛知県東部",
451 => "愛知県西部",
460 => "三重県北部",
461 => "三重県中部",
462 => "三重県南部",
469 => "三重県南東沖",
470 => "鹿島灘(廃止)",
471 => "茨城県沖",
472 => "関東東方沖",
473 => "千葉県東方沖",
474 => "房総半島南東沖(廃止)",
475 => "八丈島東方沖",
476 => "八丈島近海",
477 => "東京湾",
478 => "相模湾",
479 => "千葉県南方沖(廃止)",
480 => "伊豆大島近海",
481 => "伊豆半島東方沖",
482 => "三宅島近海",
483 => "新島・神津島近海",
484 => "伊豆半島南方沖(廃止)",
485 => "駿河湾",
486 => "駿河湾南方沖",
487 => "遠州灘",
488 => "東海道沖(廃止)",
489 => "三河湾",
490 => "伊勢湾",
491 => "熊野灘(廃止)",
492 => "若狭湾",
493 => "福井県沖",
494 => "石川県西方沖",
495 => "能登半島沖",
496 => "新潟県沖(廃止)",
497 => "富山湾",
498 => "佐渡付近",
499 => "東海道南方沖",
500 => "滋賀県北部",
501 => "滋賀県南部",
510 => "京都府北部",
511 => "京都府南部",
520 => "大阪府北部",
521 => "大阪府南部",
530 => "兵庫県北部",
531 => "兵庫県南東部",
532 => "兵庫県南西部",
540 => "奈良県",
550 => "和歌山県北部",
551 => "和歌山県南部",
560 => "鳥取県東部",
562 => "鳥取県中部",
563 => "鳥取県西部",
570 => "島根県東部",
571 => "島根県西部",
580 => "岡山県北部",
581 => "岡山県南部",
590 => "広島県北部",
591 => "広島県南東部",
592 => "広島県南西部",
600 => "徳島県北部",
601 => "徳島県南部",
610 => "香川県東部",
611 => "香川県西部",
620 => "愛媛県東予",
621 => "愛媛県中予",
622 => "愛媛県南予",
630 => "高知県東部",
631 => "高知県中部",
632 => "高知県西部",
670 => "紀伊半島沖(廃止)",
671 => "室戸岬沖(廃止)",
672 => "足摺岬沖(廃止)",
673 => "土佐湾",
674 => "紀伊水道",
675 => "大阪湾",
676 => "播磨灘",
677 => "瀬戸内海中部",
678 => "安芸灘",
679 => "周防灘",
680 => "伊予灘",
681 => "豊後水道",
682 => "山口県北西沖",
683 => "島根県沖",
684 => "鳥取県沖",
685 => "隠岐島近海",
686 => "兵庫県北方沖",
687 => "京都府沖",
688 => "淡路島付近",
689 => "和歌山県南方沖",
700 => "山口県北部",
701 => "山口県東部",
702 => "山口県西部",
710 => "福岡県福岡地方",
711 => "福岡県北九州地方",
712 => "福岡県筑豊地方",
713 => "福岡県筑後地方",
720 => "佐賀県北部",
721 => "佐賀県南部",
730 => "長崎県北部",
731 => "長崎県南西部",
732 => "長崎県島原半島",
740 => "熊本県阿蘇地方",
741 => "熊本県熊本地方",
742 => "熊本県球磨地方",
743 => "熊本県天草・芦北地方",
750 => "大分県北部",
751 => "大分県中部",
752 => "大分県南部",
753 => "大分県西部",
760 => "宮崎県北部平野部",
761 => "宮崎県北部山沿い",
762 => "宮崎県南部平野部",
763 => "宮崎県南部山沿い",
770 => "鹿児島県薩摩地方",
771 => "鹿児島県大隅地方",
780 => "対馬近海(廃止)",
781 => "福岡県西方沖(廃止)",
782 => "長崎県沖(廃止)",
783 => "五島列島近海",
784 => "天草灘",
785 => "有明海",
786 => "橘湾",
787 => "鹿児島湾",
788 => "鹿児島県西方沖(廃止)",
789 => "鹿児島県南西沖(廃止)",
790 => "種子島近海",
791 => "日向灘",
792 => "種子島東方沖(廃止)",
793 => "奄美大島近海",
794 => "奄美大島東方沖(廃止)",
795 => "壱岐・対馬近海",
796 => "福岡県北西沖",
797 => "薩摩半島西方沖",
798 => "トカラ列島近海",
799 => "奄美大島北西沖",
820 => "大隅半島東方沖",
821 => "九州地方南東沖",
822 => "種子島南東沖",
823 => "奄美大島北東沖",
850 => "沖縄本島近海",
851 => "南大東島近海",
852 => "沖縄本島南方沖",
853 => "宮古島近海",
854 => "石垣島近海",
855 => "石垣島南方沖",
856 => "西表島付近",
857 => "与那国島近海",
858 => "沖縄本島北西沖",
859 => "宮古島北西沖",
860 => "石垣島北西沖",
900 => "台湾付近",
901 => "東シナ海",
902 => "四国沖",
903 => "鳥島近海",
904 => "鳥島東方沖",
905 => "オホーツク海南部",
906 => "サハリン西方沖",
907 => "日本海北部",
908 => "日本海中部",
909 => "日本海西部",
910 => "日本海南西部(廃止)",
911 => "父島近海",
912 => "千島列島",
913 => "千島列島南東沖",
914 => "北海道南東沖",
915 => "東北地方東方沖",
916 => "小笠原諸島西方沖",
917 => "硫黄島近海",
918 => "小笠原諸島東方沖",
919 => "南海道南方沖",
920 => "薩南諸島東方沖",
921 => "本州南方沖",
922 => "サハリン南部付近",
930 => "北西太平洋",
931 => "フィリピン海北部(廃止)",
932 => "マリアナ諸島",
933 => "黄海",
934 => "朝鮮半島南部",
935 => "朝鮮半島北部",
936 => "中国東北部",
937 => "ウラジオストク付近",
938 => "シベリア南部",
939 => "サハリン近海",
940 => "アリューシャン列島",
941 => "カムチャツカ半島付近",
942 => "北米西部",
943 => "北米中部",
944 => "北米東部",
945 => "中米",
946 => "南米西部",
947 => "南米中部",
948 => "南米東部",
949 => "北東太平洋",
950 => "南太平洋",
951 => "インドシナ半島付近",
952 => "フィリピン付近",
953 => "インドネシア付近",
954 => "グアム付近",
955 => "ニューギニア付近",
956 => "ニュージーランド付近",
957 => "オーストラリア付近",
958 => "シベリア付近",
959 => "ロシア西部",
960 => "ロシア中部",
961 => "ロシア東部",
962 => "中央アジア",
963 => "中国西部",
964 => "中国中部",
965 => "中国東部",
966 => "インド付近",
967 => "インド洋",
968 => "中東",
969 => "ヨーロッパ西部",
970 => "ヨーロッパ中部",
971 => "ヨーロッパ東部",
972 => "地中海",
973 => "アフリカ西部",
974 => "アフリカ中部",
975 => "アフリカ東部",
976 => "北大西洋",
977 => "南大西洋",
978 => "北極付近",
979 => "南極付近"}

# 地域コードをkey,地域名称をvalueとするHash
AreaCord = {
0 => "不明",
135 => "宗谷支庁北部",
136 => "宗谷支庁南部",
125 => "上川支庁北部",
126 => "上川支庁中部",
127 => "上川支庁南部",
130 => "留萌支庁中北部",
131 => "留萌支庁南部",
139 => "北海道利尻礼文",
150 => "日高支庁西部",
151 => "日高支庁中部",
152 => "日高支庁東部",
145 => "胆振支庁西部",
146 => "胆振支庁中東部",
110 => "檜山支庁",
105 => "渡島支庁北部",
106 => "渡島支庁東部",
107 => "渡島支庁西部",
140 => "網走支庁網走",
141 => "網走支庁北見",
142 => "網走支庁紋別",
165 => "根室支庁北部",
166 => "根室支庁中部",
167 => "根室支庁南部",
160 => "釧路支庁北部",
161 => "釧路支庁中南部",
155 => "十勝支庁北部",
156 => "十勝支庁中部",
157 => "十勝支庁南部",
119 => "北海道奥尻島",
120 => "空知支庁北部",
121 => "空知支庁中部",
122 => "空知支庁南部",
100 => "石狩支庁北部",
101 => "石狩支庁中部",
102 => "石狩支庁南部",
115 => "後志支庁北部",
116 => "後志支庁東部",
117 => "後志支庁西部",
200 => "青森県津軽北部",
201 => "青森県津軽南部",
202 => "青森県三八上北",
203 => "青森県下北",
230 => "秋田県沿岸北部",
231 => "秋田県沿岸南部",
232 => "秋田県内陸北部",
233 => "秋田県内陸南部",
210 => "岩手県沿岸北部",
211 => "岩手県沿岸南部",
212 => "岩手県内陸北部",
213 => "岩手県内陸南部",
220 => "宮城県北部",
221 => "宮城県南部",
222 => "宮城県中部",
240 => "山形県庄内",
241 => "山形県最上",
242 => "山形県村山",
243 => "山形県置賜",
250 => "福島県中通り",
251 => "福島県浜通り",
252 => "福島県会津",
300 => "茨城県北部",
301 => "茨城県南部",
310 => "栃木県北部",
311 => "栃木県南部",
320 => "群馬県北部",
321 => "群馬県南部",
330 => "埼玉県北部",
331 => "埼玉県南部",
332 => "埼玉県秩父",
350 => "東京都23区",
351 => "東京都多摩東部",
352 => "東京都多摩西部",
354 => "神津島",
355 => "伊豆大島",
356 => "新島",
357 => "三宅島",
358 => "八丈島",
359 => "小笠原",
340 => "千葉県北東部",
341 => "千葉県北西部",
342 => "千葉県南部",
360 => "神奈川県東部",
361 => "神奈川県西部",
420 => "長野県北部",
421 => "長野県中部",
422 => "長野県南部",
410 => "山梨県東部",
411 => "山梨県中・西部",
412 => "山梨県東部・富士五湖",
440 => "静岡県伊豆",
441 => "静岡県東部",
442 => "静岡県中部",
443 => "静岡県西部",
450 => "愛知県東部",
451 => "愛知県西部",
430 => "岐阜県飛騨",
431 => "岐阜県美濃東部",
432 => "岐阜県美濃中西部",
460 => "三重県北部",
461 => "三重県中部",
462 => "三重県南部",
370 => "新潟県上越",
371 => "新潟県中越",
372 => "新潟県下越",
375 => "新潟県佐渡",
380 => "富山県東部",
381 => "富山県西部",
390 => "石川県能登",
391 => "石川県加賀",
400 => "福井県嶺北",
401 => "福井県嶺南",
500 => "滋賀県北部",
501 => "滋賀県南部",
510 => "京都府北部",
511 => "京都府南部",
520 => "大阪府北部",
521 => "大阪府南部",
530 => "兵庫県北部",
531 => "兵庫県南東部",
532 => "兵庫県南西部",
535 => "兵庫県淡路島",
540 => "奈良県",
550 => "和歌山県北部",
551 => "和歌山県南部",
580 => "岡山県北部",
581 => "岡山県南部",
590 => "広島県北部",
591 => "広島県南東部",
592 => "広島県南西部",
570 => "島根県東部",
571 => "島根県西部",
575 => "島根県隠岐",
560 => "鳥取県東部",
562 => "鳥取県中部",
563 => "鳥取県西部",
600 => "徳島県北部",
601 => "徳島県南部",
610 => "香川県東部",
611 => "香川県西部",
620 => "愛媛県東予",
621 => "愛媛県中予",
622 => "愛媛県南予",
630 => "高知県東部",
631 => "高知県中部",
632 => "高知県西部",
700 => "山口県北部",
701 => "山口県東部",
702 => "山口県西部",
710 => "福岡県福岡",
711 => "福岡県北九州",
712 => "福岡県筑豊",
713 => "福岡県筑後",
750 => "大分県北部",
751 => "大分県中部",
752 => "大分県南部",
753 => "大分県西部",
730 => "長崎県北部",
731 => "長崎県南西部",
732 => "長崎県島原半島",
735 => "長崎県対馬",
736 => "長崎県壱岐",
737 => "長崎県五島",
720 => "佐賀県北部",
721 => "佐賀県南部",
740 => "熊本県阿蘇",
741 => "熊本県熊本",
742 => "熊本県球磨",
743 => "熊本県天草・芦北",
760 => "宮崎県北部平野部",
761 => "宮崎県北部山沿い",
762 => "宮崎県南部平野部",
763 => "宮崎県南部山沿い",
770 => "鹿児島県薩摩",
771 => "鹿児島県大隅",
774 => "鹿児島県十島村",
775 => "鹿児島県甑島",
776 => "鹿児島県種子島",
777 => "鹿児島県屋久島",
778 => "鹿児島県奄美北部",
779 => "鹿児島県奄美南部",
800 => "沖縄県本島北部",
801 => "沖縄県本島中南部",
802 => "沖縄県久米島",
803 => "沖縄県大東島",
804 => "沖縄県宮古島",
805 => "沖縄県石垣島",
806 => "沖縄県与那国島",
807 => "沖縄県西表島"}

  class Error < StandardError; end
 
  # 引数には緊急地震速報の電文を与えます。
  def initialize(str)
    @fastcast = str
    @fastcast.freeze
    raise Error, "電文の形式が不正です" if @fastcast.size < 134
  end

  attr_reader :fastcast

  # initializeに与えられた電文を返します。
  def to_s
    @fastcast
  end

  # 電文を解析した結果をHashで返します。
  def to_hash
    hash = {}
    hash[:type] = self.type
    hash[:from] = self.from
    hash[:drill_type] = self.drill_type
    hash[:report_time] = self.report_time
    hash[:number_of_telegram] = self.number_of_telegram
    hash[:continue?] = self.continue?
    hash[:earthquake_time] = self.earthquake_time
    hash[:id] = self.id
    hash[:status] = self.status
    hash[:final?] = self.final?
    hash[:number] = self.number
    hash[:epicenter] = self.epicenter
    hash[:position] = self.position
    hash[:depth] = self.depth
    hash[:magnitude] = self.magnitude
    hash[:seismic_intensity] = self.seismic_intensity
    hash[:probability_of_position] = self.probability_of_position
    hash[:probability_of_depth] = self.probability_of_depth
    hash[:probability_of_magnitude] = self.probability_of_magnitude
    hash[:probability_of_position_jma] = self.probability_of_position_jma
    hash[:probability_of_depth_jma] = self.probability_of_depth_jma
    hash[:land_or_sea] = self.land_or_sea
    hash[:warning?] = self.warning?
    hash[:change] = self.change
    hash[:reason_of_change] = self.reason_of_change
    hash[:ebi] = self.ebi
    hash
  end

  def inspect
    "#<EEWParser:#{self.id}>"
  end

  def ==(other)
    self.fastcast == other.fastcast  
  end

  def <=>(other)
    self.id.to_i <=> other.id.to_i
  end

  # 電文種別コード
  def type
    case @fastcast[0, 2]
    when "35"
      "最大予測震度のみの高度利用者向け緊急地震速報"
    when "36"
      "マグニチュード、最大予測震度及び主要動到達予測時刻の高度利用者向け緊急地震速報(B-Δ法、テリトリ法)"
    when "37"
      "マグニチュード、最大予測震度及び主要動到達予測時刻の高度利用者向け緊急地震速報(グリッドサーチ法、EPOS自動処理手法)"
    when "39"
      "キャンセル報"
    else
      raise Error, "電文の形式が不正です(電文種別コード)"
    end
  end

  # 発信官署
  def from
    case @fastcast[3, 2]
    when "01"
      "札幌"
    when "02"
      "仙台"
    when "03"
      "東京"
    when "04"
      "大阪"
    when "05"
      "福岡"
    when "06"
      "沖縄"
    else
      raise Error, "電文の形式が不正です(発信官署)"
    end
  end

  # 訓練等の識別符
  def drill_type
    case @fastcast[6, 2]
    when "00"
      "通常"
    when "01"
      "訓練"
    when "10"
      "取り消し"
    when "11"
      "訓練取り消し"
    when "20"
      "参考情報またはテキスト"
    when "30"
      "コード部のみの配信試験"
    else
      raise Error, "電文の形式が不正です(識別符)"
    end
  end

  # 電文の発表時刻のTimeオブジェクトを返します。
  def report_time
    Time.local("20" + @fastcast[9, 2], @fastcast[11, 2], @fastcast[13, 2], @fastcast[15, 2], @fastcast[17, 2], @fastcast[19, 2])
  end

  # 電文がこの電文を含め何通あるか(Integer)
  def number_of_telegram
    number_of_telegram = @fastcast[23]
    raise Error, "電文の形式が不正です" if number_of_telegram =~ /[^\d]/
    number_of_telegram.to_i
  end

  # コードが続くかどうか
  def continue?
    case @fastcast[24]
    when "1"
      true
    when "0"
      false
    else
      raise Error, "電文の形式が不正です"
    end
  end

  # 地震発生時刻もしくは地震検知時刻のTimeオブジェクトを返します。
  def earthquake_time
    Time.local("20" + @fastcast[26, 2], @fastcast[28, 2], @fastcast[30, 2], @fastcast[32, 2], @fastcast[34, 2], @fastcast[36, 2])
  end
  
  # 地震識別番号(String)
  def id
    id = @fastcast[41, 14]
    raise Error, "電文の形式が不正です(地震識別番号)" if id =~ /[^\d]/
    id
  end

  # 発表状況(訂正等)の指示
  def status
    case @fastcast[59]
    when "0"
      "通常発表"
    when "6"
      "情報内容の訂正"
    when "7"
      "キャンセルを誤って発表した場合の訂正"
    when "8"
      "訂正事項を盛り込んだ最終の高度利用者向け緊急地震速報"
    when "9"
      "最終の高度利用者向け緊急地震速報"
    when "/"
      "未設定"
    else
      raise Error, "電文の形式が不正です"     
    end
  end

  # 最終報であればtrueを、そうでなければfalseを返します。
  def final?
    case @fastcast[59]
    when "9"
      true
    when "0", "6", "7", "8", "/"
      false
    else
      raise Error, "電文の形式が不正です"
    end
  end

  # 発表する高度利用者向け緊急地震速報の番号(地震単位での通番)(Integer)
  def number
    number = @fastcast[60, 2]
    raise Error, "電文の形式が不正です(高度利用者向け緊急地震速報の番号)" if number =~ /[^\d]/
    number.to_i
  end

  alias :revision :number

  # 震央の名称
  def epicenter
    key = @fastcast[86, 3]
    raise Error, "電文の形式が不正です(震央の名称)" if key =~ /[^\d]/
    EpicenterCord[key.to_i]
  end

  # 震央の位置
  def position
    position = @fastcast[90, 10]
    if position == "//// /////"
      "不明又は未設定"
    else
      raise Error, "電文の形式が不正です(震央の位置)" if position =~ /[^\d|\s|N|E]/
      position.insert(3, ".").insert(10, ".")
    end
  end

  # 震源の深さ(単位 km)
  def depth
    depth = @fastcast[101, 3]
    if depth == "///"
      "不明又は未設定"
    else
      raise Error, "電文の形式が不正です(震源の深さ)" if depth =~ /[^\d]/
      depth.to_i
    end
  end

  # マグニチュード
  #   マグニチュードが不明又は未設定である場合は"不明又は未設定"を返します。
  #   そうでなければ、マグニチュードをFloatで返します。
  def magnitude
    magnitude = @fastcast[105, 2]
    if magnitude == "//"
      "不明又は未設定"
    else
      raise Error, "電文の形式が不正です(マグニチュード)" if magnitude =~ /[^\d]/
      (magnitude[0] + "." + magnitude[1]).to_f
    end
  end

  # 電文フォーマットの震度を文字列に変換
  def to_seismic_intensity(str)
    case str
    when "//"
      "不明又は未設定"
    when "01"
      "1"
    when "02"
      "2"
    when "03"
      "3"
    when "04"
      "4"
    when "5-"
      "5弱"
    when "5+"
      "5強"
    when "6-"
      "6弱"
    when "6+"
      "6強"
    when "07"
      "7"
    else
      raise Error, "電文の形式が不正です(震度)"
    end
  end

  # 最大予測震度
  def seismic_intensity
    to_seismic_intensity(@fastcast[108, 2]) 
  rescue Error
    raise Error, "電文の形式が不正です(最大予測震度)" 
  end

  # 震央の確からしさ
  def probability_of_position
    case @fastcast[113]
    when "1"
      "P波/S波レベル越え、またはテリトリー法(1点)[気象庁データ]"
    when "2"
      "テリトリー法(2点)[気象庁データ]"
    when "3"
      "グリッドサーチ法(3点/4点)[気象庁データ]"
    when "4"
      "グリッドサーチ法(5点)[気象庁データ]"
    when "5"
      "防災科研システム(4点以下、または精度情報なし)[防災科学技術研究所データ]"
    when "6"
      "防災科研システム(5点以上)[防災科学技術研究所データ]"
    when "7"
      "EPOS(海域[観測網外])[気象庁データ]"
    when "8"
      "EPOS(内陸[観測網内])[気象庁データ]"
    when "9"
      "予備"
    when "/"
      "不明又は未設定"
    else
      raise Error, "電文の形式が不正です(震央の確からしさ)"
    end    
  end

  # 震源の深さの確からしさ
  def probability_of_depth
    case @fastcast[114]
    when "1"
      "P波/S波レベル越え、またはテリトリー法(1点)[気象庁データ]"
    when "2"
      "テリトリー法(2点)[気象庁データ]"
    when "3"
      "グリッドサーチ法(3点/4点)[気象庁データ]"
    when "4"
      "グリッドサーチ法(5点)[気象庁データ]"
    when "5"
      "防災科研システム(4点以下、または精度情報なし)[防災科学技術研究所データ]"
    when "6"
      "防災科研システム(5点以上)[防災科学技術研究所データ]"
    when "7"
      "EPOS(海域[観測網外])[気象庁データ]"
    when "8"
      "EPOS(内陸[観測網内])[気象庁データ]"
    when "9"
      "予備"
    when "/"
      "不明又は未設定"
    else
      raise Error, "電文の形式が不正です(震源の深さの確からしさ)"
    end 
  end

  # マグニチュードの確からしさ
  def probability_of_magnitude
    case @fastcast[115]
    when "1"
      "未定義"
    when "2"
      "防災科研システム[防災科学技術研究所データ]"
    when "3"
      "全点P相(最大5点)[気象庁データ]"
    when "4"
      "P相/全相混在[気象庁データ]"
    when "5"
      "全点全相(最大5点)[気象庁データ]"
    when "6"
      "EPOS[気象庁データ]"
    when "7"
      "未定義"
    when "8"
      "P波/S波レベル越え[気象庁データ]"
    when "9"
      "予備"
    when "/"
      "不明又は未設定"
    else
      raise Error, "電文の形式が不正です(マグニチュードの確からしさ)"
    end
  end

  # 震央の確からしさ（※気象庁の部内システムでの利用）
  def probability_of_position_jma
    case @fastcast[116]
    when "1"
      "P波/S波レベル越え又はテリトリー法(1点)[気象庁データ]"
    when "2"
      "テリトリー法(2点)[気象庁データ]"
    when "3"
      "グリッドサーチ法(3点/4点)[気象庁データ]"
    when "4"
      "グリッドサーチ法(5点)[気象庁データ]"
    when "/"
      "不明又は未設定"
    when "5".."9"
      "未定義"
    else
      raise Error, "電文の形式が不正です(震央の確からしさ[気象庁の部内システムでの利用])"
    end
  end

  # 震源の深さの確からしさ（※気象庁の部内システムでの利用）
  def probability_of_depth_jma
    case @fastcast[117]
    when "1"
      "P波/S波レベル越え又はテリトリー法(1点)[気象庁データ]"
    when "2"
      "テリトリー法(2点)[気象庁データ]"
    when "3"
      "グリッドサーチ法(3点/4点)[気象庁データ]"
    when "4"
      "グリッドサーチ法(5点)[気象庁データ]"
    when "/"
      "不明又は未設定"
    when "5".."9"
      "未定義"
    else
      raise Error, "電文の形式が不正です(震源の深さの確からしさ[気象庁の部内システムでの利用])"
    end
  end

  # 震央位置の海陸判定
  def land_or_sea
    case @fastcast[121]
    when "0"
      "陸域"
    when "1"
      "海域"
    when "/"
      "不明又は未設定"
    when "2".."9"
      "未定義"
    else
      raise Error, "電文の形式が不正です(震央位置の海陸判定)"
    end
  end

  # 警報を含む内容であればtrue、そうでなければfalse
  def warning?
    case @fastcast[122]
    when "0", "/", "2".."9"
      false
    when "1"
      true
    else
      raise Error, "電文の形式が不正です(警報の判別)"
    end
  end

  # 最大予測震度の変化
  def change
    case @fastcast[129]
    when "0"
      "ほとんど変化無し"
    when "1"
      "最大予測震度が1.0以上大きくなった"
    when "2"
      "最大予測震度が1.0以上小さくなった"
    when "3".."9"
      "未定義"
    when "/"
      "不明又は未設定"  
    else
      raise Error, "電文の形式が不正です(最大予測震度の変化)"
    end
  end

  # 最大予測震度の変化の理由
  def reason_of_change
    case @fastcast[130]
    when "0"
      "変化無し"
    when "1"
      "主としてMが変化したため(1.0以上)"
    when "2"
      "主として震源位置が変化したため(10.0km以上)"
    when "3"
      "M及び震源位置が変化したため"
    when "4"
      "震源の深さが変化したため"
    when "/"
      "不明又は未設定"
    when "5".."9"
      "未定義"
    else
      raise Error, "電文の形式が不正です(最大予測震度の変化の理由)"
    end
  end

  # 地域毎の警報の判別、最大予測震度及び主要動到達予測時刻
  #   EBIがあればHashを格納したArrayを、なければ空のArrayを返します。Hashに格納されるkeyとvalueはそれぞれ次のようになっています。
  #   :area_name 地域名称
  #   :intensity 最大予測震度
  #   :arrival_time 予想到達時刻のTimeオブジェクト。既に到達している場合はnil
  #   :warning 警報を含んでいればtrue、含んでいなければfalse、電文にこの項目が設定されていなければnil
  #   :arrival 既に到達していればtrue、そうでなければfalse、電文にこの項目が設定されていなければnil
  def ebi
    data = []
    return data unless @fastcast[135, 3] == "EBI"
    i = 139
    while i + 20 < @fastcast.size
      local = {}
      local[:area_cord] = @fastcast[i, 3].to_i
      local[:area_name] = AreaCord[local[:area_cord]] # 地域名称
      raise Error, "電文の形式が不正でです(地域名称[EBI])" unless local[:area_name]
      if @fastcast[i+7, 2] == "//"
        local[:intensity] = "#{to_seismic_intensity(@fastcast[i+5, 2])}以上" # 最大予測震度
      elsif @fastcast[i+5, 2] == @fastcast[i+7, 2]
        local[:intensity] = "#{to_seismic_intensity(@fastcast[i+5, 2])}"
      else
        local[:intensity] = "#{to_seismic_intensity(@fastcast[i+7, 2])}から#{to_seismic_intensity(@fastcast[i+5, 2])}"
      end
      if @fastcast[i+10, 6] == "//////"
        local[:arrival_time] = nil # 予想到達時刻
      else
        local[:arrival_time] = Time.local("20" + @fastcast[26, 2], @fastcast[28, 2], @fastcast[30, 2], @fastcast[i+10, 2], @fastcast[i+12, 2], @fastcast[i+14, 2])
      end
      case @fastcast[i+17]
      when "0"
        local[:warning] = false # 警報を含むかどうか
      when "1"
        local[:warning] = true
      when "/", "2".."9"
        local[:warning] = nil
      else
        raise Error, "電文の形式が不正でです(警報の判別[EBI])"
      end
      case @fastcast[i+18]
      when "0"
        local[:arrival] = false # 既に到達しているかどうか
      when "1"
        local[:arrival] = true
      when "/", "2".."9"
        local[:arrival] = nil
      else
        raise Error, "電文の形式が不正でです(主要動の到達予測状況[EBI])"
      end
      data << local
      i += 20
    end
    data
  end
end

if __FILE__ == $PROGRAM_NAME # テスト
  str = <<EOS #テスト用の電文
37 03 00 110415233453 C11
110415233416
ND20110415233435 NCN005 JD////////////// JN///
251 N370 E1408 010 66 6+ RK66324 RT01/// RC13///
EBI 251 S6+6- ////// 11 300 S5+5- ////// 11 250 S5+5- ////// 11
310 S0404 ////// 11 311 S0404 ////// 11 252 S0404 ////// 11
301 S0404 ////// 11 221 S0404 ////// 01 340 S0404 ////// 01
341 S0404 ////// 01 321 S0404 233455 00 331 S0404 233457 10
350 S0404 233501 00 360 S0404 233508 00 243 S0403 ////// 01
330 S0403 233454 00 222 S0403 233455 00
9999=
EOS
  
  fc = EEWParser.new(str)
  p fc
  p fc.fastcast
  p fc.to_hash
  
  puts <<FC
電文種別コード: #{fc.type}
発信官署: #{fc.from}
訓練等の識別符: #{fc.drill_type}
電文の発表時刻: #{fc.report_time}
電文がこの電文を含め何通あるか: #{fc.number_of_telegram}
コードが続くかどうか: #{fc.continue?}
地震発生時刻もしくは地震検知時刻: #{fc.earthquake_time}
地震識別番号: #{fc.id}
発表状況(訂正等)の指示: #{fc.status}
発表する高度利用者向け緊急地震速報の番号(地震単位での通番): #{fc.number}
震央地名コード: #{fc.epicenter}
震央の位置: #{fc.position}
震源の深さ(単位 km)(不明・未設定時,キャンセル時:///): #{fc.depth}
マグニチュード(不明・未設定時、キャンセル時:///): #{fc.magnitude}
最大予測震度(不明・未設定時、キャンセル時://): #{fc.seismic_intensity}
震央の確からしさ: #{fc.probability_of_position}
震源の深さの確からしさ: #{fc.probability_of_depth}
マグニチュードの確からしさ: #{fc.probability_of_magnitude}
震央の確からしさ(気象庁の部内システムでの利用): #{fc.probability_of_position_jma}
震源の深さの確からしさ(気象庁の部内システムでの利用): #{fc.probability_of_depth_jma}
震央位置の海陸判定: #{fc.land_or_sea}
警報を含む内容かどうか: #{fc.warning?}
最大予測震度の変化: #{fc.change}
最大予測震度の変化の理由: #{fc.reason_of_change}
FC
  fc.ebi.each do |local|
    puts "地域コード: #{local[:area_cord]} 地域名: #{local[:area_name]} 最大予測震度: #{local[:intensity]} 予想到達時刻: #{local[:arrival_time]}"
    puts "警報を含むかどうか: #{local[:warning]} 既に到達しているかどうか: #{local[:arrival]}"
  end
end
