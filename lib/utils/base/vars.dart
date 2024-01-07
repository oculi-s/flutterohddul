import 'package:flutter/material.dart';
import 'package:flutterohddul/utils/colors/colors.vars.dart';

const countryName = {
  "KR": "한국",
  "US": "미국",
  "CN": "중국",
  "JP": "일본",
  "GB": "영국",
  "IN": "인도",
  "CA": "캐나다",
  "RU": "러시아",
  "EUR": "유로존",
};

const defaultFavs = [
  '.반도체',
  '005930',
  '000660',
  '.이차전지',
  '373220',
  '051910',
  '006400',
  '247540',
  '003670',
  '.자동차',
  '005380',
  '000270',
  '003620',
  '.철강',
  '005490',
  '.IT',
  '035420',
  '035720'
];

const visibleCountries = [
  "KR",
  "US",
];

const indutyIcons = {
  "전자 부품": Icons.dashboard,
  "전기장비": Icons.electric_bolt,
  "지주사": Icons.attach_money,
  "의약품": Icons.medication,
  "화학물질": Icons.science,
  "자동차": Icons.electric_car,
  "기계장비": Icons.precision_manufacturing,
  "출판": Icons.album,
  "도매업": Icons.store,
  // "금속 생산":Icons.metal
  "정보서비스": Icons.info,
};

var indutyColors = {
  "전자 부품": groupColor['삼성'],
  "전기장비": groupColor['LG'],
  "지주사": groupColor['카카오'],
  "의약품": groupColor['셀트리온'],
  "자동차": groupColor['현대차']
};
