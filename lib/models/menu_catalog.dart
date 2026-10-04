import 'dart:math';

import 'package:flutter/material.dart';

/// A searchable dish and the cuisine used to make its search more specific.
class MenuDish {
  final String name;
  final String koreanName;

  const MenuDish(this.name, this.koreanName);

  String label(bool isKorean) => isKorean ? koreanName : name;
}

class MenuCuisine {
  final String name;
  final String koreanName;
  final IconData icon;
  final List<MenuDish> dishes;

  const MenuCuisine(this.name, this.koreanName, this.icon, this.dishes);

  String label(bool isKorean) => isKorean ? koreanName : name;
}

class MenuPick {
  final MenuCuisine cuisine;
  final MenuDish dish;

  const MenuPick(this.cuisine, this.dish);

  String label(bool isKorean) =>
      '${dish.label(isKorean)} · ${cuisine.label(isKorean)}';

  String get searchQuery => '${dish.name} ${cuisine.name}';
}

/// Curated food choices for local restaurant searches.
///
/// Each category has the same number of real, named dishes. A random cuisine
/// followed by a random dish therefore gives every catalog entry equal odds.
class MenuCatalog {
  static const int dishesPerCuisine = 15;

  static const cuisines = <MenuCuisine>[
    MenuCuisine('Korean', '한식', Icons.rice_bowl, [
      MenuDish('Bibimbap', '비빔밥'),
      MenuDish('Bulgogi', '불고기'),
      MenuDish('Kimchi Jjigae', '김치찌개'),
      MenuDish('Tteokbokki', '떡볶이'),
      MenuDish('Samgyeopsal', '삼겹살'),
      MenuDish('Japchae', '잡채'),
      MenuDish('Sundubu Jjigae', '순두부찌개'),
      MenuDish('Korean Fried Chicken', '한국식 치킨'),
      MenuDish('Naengmyeon', '냉면'),
      MenuDish('Kimbap', '김밥'),
      MenuDish('Galbi', '갈비'),
      MenuDish('Jajangmyeon', '짜장면'),
      MenuDish('Dakgalbi', '닭갈비'),
      MenuDish('Samgyetang', '삼계탕'),
      MenuDish('Yukgaejang', '육개장'),
    ]),
    MenuCuisine('Japanese', '일식', Icons.set_meal, [
      MenuDish('Sushi', '초밥'),
      MenuDish('Ramen', '라멘'),
      MenuDish('Udon', '우동'),
      MenuDish('Soba', '소바'),
      MenuDish('Katsu Curry', '카츠 카레'),
      MenuDish('Tonkatsu', '돈카츠'),
      MenuDish('Tempura', '덴푸라'),
      MenuDish('Okonomiyaki', '오코노미야키'),
      MenuDish('Yakitori', '야키토리'),
      MenuDish('Donburi', '덮밥'),
      MenuDish('Takoyaki', '타코야키'),
      MenuDish('Shabu Shabu', '샤부샤부'),
      MenuDish('Gyoza', '교자'),
      MenuDish('Karaage', '가라아게'),
      MenuDish('Yakisoba', '야키소바'),
    ]),
    MenuCuisine('Chinese', '중식', Icons.ramen_dining, [
      MenuDish('Dim Sum', '딤섬'),
      MenuDish('Hot Pot', '훠궈'),
      MenuDish('Mapo Tofu', '마파두부'),
      MenuDish('Kung Pao Chicken', '궁바오지딩'),
      MenuDish('Peking Duck', '베이징덕'),
      MenuDish('Xiao Long Bao', '샤오롱바오'),
      MenuDish('Dan Dan Noodles', '탄탄면'),
      MenuDish('Chow Mein', '차오미엔'),
      MenuDish('Wonton Soup', '완탕면'),
      MenuDish('Char Siu', '차슈'),
      MenuDish('Salt and Pepper Squid', '소금 후추 오징어'),
      MenuDish('Scallion Pancakes', '총유빙'),
      MenuDish('Sweet and Sour Pork', '탕수육'),
      MenuDish('Twice-Cooked Pork', '후이궈러우'),
      MenuDish('Dongpo Pork', '동파육'),
    ]),
    MenuCuisine('Vietnamese', '베트남', Icons.soup_kitchen, [
      MenuDish('Pho', '쌀국수'),
      MenuDish('Banh Mi', '반미'),
      MenuDish('Bun Bo Hue', '분보후에'),
      MenuDish('Bun Cha', '분짜'),
      MenuDish('Com Tam', '껌땀'),
      MenuDish('Goi Cuon', '월남쌈'),
      MenuDish('Banh Xeo', '반쎄오'),
      MenuDish('Bo Luc Lac', '보룩락'),
      MenuDish('Bun Thit Nuong', '분팃느엉'),
      MenuDish('Cha Ca', '짜까'),
      MenuDish('Hu Tieu', '후띠우'),
      MenuDish('Banh Cuon', '반꾸온'),
      MenuDish('Mi Quang', '미꽝'),
      MenuDish('Cao Lau', '까오러우'),
      MenuDish('Banh Khot', '반콧'),
    ]),
    MenuCuisine('Thai', '태국', Icons.local_dining, [
      MenuDish('Pad Thai', '팟타이'),
      MenuDish('Pad See Ew', '팟씨유'),
      MenuDish('Tom Yum', '똠얌'),
      MenuDish('Green Curry', '그린 커리'),
      MenuDish('Massaman Curry', '마사만 커리'),
      MenuDish('Panang Curry', '파냉 커리'),
      MenuDish('Pad Kra Pao', '팟카파오'),
      MenuDish('Khao Soi', '카오소이'),
      MenuDish('Som Tam', '쏨땀'),
      MenuDish('Thai Boat Noodles', '태국 보트 누들'),
      MenuDish('Moo Ping', '무핑'),
      MenuDish('Mango Sticky Rice', '망고 찹쌀밥'),
      MenuDish('Khao Man Gai', '카오만가이'),
      MenuDish('Larb', '랍'),
      MenuDish('Tom Kha Gai', '똠카가이'),
    ]),
    MenuCuisine('Indian', '인도', Icons.restaurant, [
      MenuDish('Butter Chicken', '버터 치킨'),
      MenuDish('Chicken Tikka Masala', '치킨 티카 마살라'),
      MenuDish('Biryani', '비리야니'),
      MenuDish('Palak Paneer', '팔락 파니르'),
      MenuDish('Chana Masala', '차나 마살라'),
      MenuDish('Dosa', '도사'),
      MenuDish('Samosa', '사모사'),
      MenuDish('Tandoori Chicken', '탄두리 치킨'),
      MenuDish('Dal Makhani', '달 마카니'),
      MenuDish('Rogan Josh', '로건 조시'),
      MenuDish('Pav Bhaji', '파브 바지'),
      MenuDish('Vada Pav', '바다 파브'),
      MenuDish('Aloo Gobi', '알루 고비'),
      MenuDish('Idli', '이들리'),
      MenuDish('Pani Puri', '파니 푸리'),
    ]),
    MenuCuisine('Italian', '이탈리아', Icons.local_pizza, [
      MenuDish('Margherita Pizza', '마르게리타 피자'),
      MenuDish('Carbonara', '카르보나라'),
      MenuDish('Lasagna', '라자냐'),
      MenuDish('Risotto', '리소토'),
      MenuDish('Gnocchi', '뇨키'),
      MenuDish('Ravioli', '라비올리'),
      MenuDish('Pesto Pasta', '페스토 파스타'),
      MenuDish('Focaccia', '포카치아'),
      MenuDish('Arancini', '아란치니'),
      MenuDish('Osso Buco', '오소부코'),
      MenuDish('Pasta alla Norma', '파스타 알라 노르마'),
      MenuDish('Tiramisu', '티라미수'),
      MenuDish('Cacio e Pepe', '카초 에 페페'),
      MenuDish('Bucatini all Amatriciana', '부카티니 아마트리치아나'),
      MenuDish('Gnocchi alla Sorrentina', '뇨키 알라 소렌티나'),
    ]),
    MenuCuisine('Mexican', '멕시코', Icons.lunch_dining, [
      MenuDish('Tacos al Pastor', '타코 알 파스토르'),
      MenuDish('Carnitas Tacos', '카르니타스 타코'),
      MenuDish('Birria Tacos', '비리아 타코'),
      MenuDish('Burrito', '부리토'),
      MenuDish('Quesadilla', '케사디야'),
      MenuDish('Enchiladas', '엔칠라다'),
      MenuDish('Chilaquiles', '칠라킬레스'),
      MenuDish('Pozole', '포솔레'),
      MenuDish('Tamales', '타말레스'),
      MenuDish('Tostadas', '토스타다'),
      MenuDish('Mole Poblano', '몰레 포블라노'),
      MenuDish('Elote', '엘로테'),
      MenuDish('Sopes', '소페스'),
      MenuDish('Tlacoyos', '틀라코요스'),
      MenuDish('Torta Ahogada', '토르타 아오가다'),
    ]),
    MenuCuisine('Greek', '그리스', Icons.kebab_dining, [
      MenuDish('Gyros', '기로스'),
      MenuDish('Souvlaki', '수블라키'),
      MenuDish('Moussaka', '무사카'),
      MenuDish('Spanakopita', '스파나코피타'),
      MenuDish('Pastitsio', '파스티치오'),
      MenuDish('Greek Salad', '그리스 샐러드'),
      MenuDish('Dolmades', '돌마데스'),
      MenuDish('Gemista', '게미스타'),
      MenuDish('Keftedes', '케프테데스'),
      MenuDish('Grilled Octopus', '문어구이'),
      MenuDish('Loukoumades', '루쿠마데스'),
      MenuDish('Baklava', '바클라바'),
      MenuDish('Saganaki', '사가나키'),
      MenuDish('Fasolada', '파솔라다'),
      MenuDish('Avgolemono', '아브골레모노'),
    ]),
    MenuCuisine('Middle Eastern', '중동', Icons.kebab_dining, [
      MenuDish('Shawarma', '샤와르마'),
      MenuDish('Falafel', '팔라펠'),
      MenuDish('Hummus', '후무스'),
      MenuDish('Kofta Kebab', '코프타 케밥'),
      MenuDish('Shish Kebab', '시시 케밥'),
      MenuDish('Fattoush', '파투시'),
      MenuDish('Tabbouleh', '타불레'),
      MenuDish('Manakish', '마나키시'),
      MenuDish('Mansaf', '만사프'),
      MenuDish('Maqluba', '마클루바'),
      MenuDish('Kibbeh', '키베'),
      MenuDish('Kunafa', '쿠나파'),
      MenuDish('Baba Ghanoush', '바바 가누쉬'),
      MenuDish('Mujadara', '무자다라'),
      MenuDish('Musakhan', '무사칸'),
    ]),
    MenuCuisine('American', '미국', Icons.lunch_dining, [
      MenuDish('Cheeseburger', '치즈버거'),
      MenuDish('BBQ Brisket', '바비큐 브리스킷'),
      MenuDish('Buffalo Wings', '버팔로 윙'),
      MenuDish('Mac and Cheese', '맥앤치즈'),
      MenuDish('Pulled Pork', '풀드 포크'),
      MenuDish('Fried Chicken', '프라이드 치킨'),
      MenuDish('Philly Cheesesteak', '필리 치즈스테이크'),
      MenuDish('Clam Chowder', '클램 차우더'),
      MenuDish('Chicken and Waffles', '치킨 앤 와플'),
      MenuDish('Lobster Roll', '랍스터 롤'),
      MenuDish('Cajun Gumbo', '케이준 검보'),
      MenuDish('Reuben Sandwich', '루벤 샌드위치'),
      MenuDish('Jambalaya', '잠발라야'),
      MenuDish('Shrimp and Grits', '새우 앤 그리츠'),
      MenuDish('Meatloaf', '미트로프'),
    ]),
    MenuCuisine('French', '프랑스', Icons.bakery_dining, [
      MenuDish('Croque Monsieur', '크로크 무슈'),
      MenuDish('Quiche Lorraine', '키슈 로렌'),
      MenuDish('French Onion Soup', '프렌치 어니언 수프'),
      MenuDish('Beef Bourguignon', '뵈프 부르기뇽'),
      MenuDish('Ratatouille', '라따뚜이'),
      MenuDish('Coq au Vin', '코코뱅'),
      MenuDish('Steak Frites', '스테이크 프리트'),
      MenuDish('Duck Confit', '오리 콩피'),
      MenuDish('Nicoise Salad', '니수아즈 샐러드'),
      MenuDish('Crepes', '크레프'),
      MenuDish('Croissant', '크루아상'),
      MenuDish('Creme Brulee', '크렘 브륄레'),
      MenuDish('Cassoulet', '카술레'),
      MenuDish('Bouillabaisse', '부야베스'),
      MenuDish('Blanquette de Veau', '블랑케트 드 보'),
    ]),
    MenuCuisine('Spanish', '스페인', Icons.tapas, [
      MenuDish('Paella', '파에야'),
      MenuDish('Patatas Bravas', '파타타스 브라바스'),
      MenuDish('Tortilla Espanola', '스페인식 오믈렛'),
      MenuDish('Gambas al Ajillo', '감바스 알 아히요'),
      MenuDish('Croquetas', '크로케타스'),
      MenuDish('Pulpo a la Gallega', '문어 갈리시아식'),
      MenuDish('Gazpacho', '가스파초'),
      MenuDish('Pisto Manchego', '피스토 만체고'),
      MenuDish('Bocadillo', '보카디요'),
      MenuDish('Pimientos de Padron', '피미엔토스 데 파드론'),
      MenuDish('Fabada Asturiana', '파바다 아스투리아나'),
      MenuDish('Churros', '추로스'),
      MenuDish('Cocido Madrileno', '코시도 마드릴레뇨'),
      MenuDish('Bacalao al Pil Pil', '바칼라오 알 필필'),
      MenuDish('Salmorejo', '살모레호'),
    ]),
    MenuCuisine('Canadian', '캐나다', Icons.local_dining, [
      MenuDish('Poutine', '푸틴'),
      MenuDish('Montreal Smoked Meat', '몬트리올 스모크드 미트'),
      MenuDish('Peameal Bacon Sandwich', '피밀 베이컨 샌드위치'),
      MenuDish('Butter Tarts', '버터 타르트'),
      MenuDish('Nanaimo Bars', '나나이모 바'),
      MenuDish('Tourtiere', '투르티에르'),
      MenuDish('Halifax Donair', '핼리팩스 도네어'),
      MenuDish('Montreal Bagel', '몬트리올 베이글'),
      MenuDish('Jiggs Dinner', '지그스 디너'),
      MenuDish('Lobster Roll', '랍스터 롤'),
      MenuDish('Bannock', '배넉'),
      MenuDish('BeaverTails', '비버테일즈'),
      MenuDish('Split Pea Soup', '완두콩 수프'),
      MenuDish('Pouding Chomeur', '푸딩 쇼뫼르'),
      MenuDish('Sugar Pie', '슈거 파이'),
    ]),
    MenuCuisine('Caribbean', '카리브해', Icons.restaurant, [
      MenuDish('Jerk Chicken', '저크 치킨'),
      MenuDish('Curry Goat', '염소 커리'),
      MenuDish('Oxtail Stew', '소꼬리 스튜'),
      MenuDish('Roti', '로티'),
      MenuDish('Doubles', '더블스'),
      MenuDish('Rice and Peas', '라이스 앤 피스'),
      MenuDish('Ackee and Saltfish', '아키와 소금대구'),
      MenuDish('Cuban Sandwich', '쿠바 샌드위치'),
      MenuDish('Mofongo', '모퐁고'),
      MenuDish('Empanadas', '엠파나다'),
      MenuDish('Tostones', '토스토네스'),
      MenuDish('Jamaican Patties', '자메이카 패티'),
      MenuDish('Cou Cou and Flying Fish', '쿠쿠와 날치'),
      MenuDish('Pudding and Souse', '푸딩 앤 사우스'),
      MenuDish('Escovitch Fish', '에스코비치 생선'),
    ]),
    MenuCuisine('Ethiopian', '에티오피아', Icons.restaurant, [
      MenuDish('Doro Wat', '도로 왓'),
      MenuDish('Timatim Fitfit', '티마팀 피트피트'),
      MenuDish('Tibs', '팁스'),
      MenuDish('Shiro Wat', '시로 왓'),
      MenuDish('Misir Wat', '미시르 왓'),
      MenuDish('Kitfo', '키트포'),
      MenuDish('Beyaynetu', '베야이네투'),
      MenuDish('Gomen', '고멘'),
      MenuDish('Firfir', '피르피르'),
      MenuDish('Azifa', '아지파'),
      MenuDish('Chechebsa', '체체브사'),
      MenuDish('Sambusa', '삼부사'),
      MenuDish('Kik Alicha', '키크 알리차'),
      MenuDish('Key Wat', '케이 왓'),
      MenuDish('Fasolia', '파솔리아'),
    ]),
    MenuCuisine('Fast Food', '패스트푸드', Icons.fastfood, [
      MenuDish('Cheeseburger', '치즈버거'),
      MenuDish('Chicken Burger', '치킨 버거'),
      MenuDish('Fried Chicken', '프라이드 치킨'),
      MenuDish('Chicken Nuggets', '치킨 너겟'),
      MenuDish('Hot Dog', '핫도그'),
      MenuDish('Pizza Slice', '피자 조각'),
      MenuDish('Fish and Chips', '피시 앤 칩스'),
      MenuDish('Loaded Fries', '토핑 감자튀김'),
      MenuDish('Chicken Wrap', '치킨 랩'),
      MenuDish('Grilled Cheese', '그릴드 치즈'),
      MenuDish('Sub Sandwich', '서브 샌드위치'),
      MenuDish('Breakfast Sandwich', '아침 샌드위치'),
      MenuDish('Chicken Tenders', '치킨 텐더'),
      MenuDish('Mozzarella Sticks', '모차렐라 스틱'),
      MenuDish('Onion Rings', '어니언 링'),
    ]),
    MenuCuisine('Desserts', '디저트', Icons.icecream, [
      MenuDish('Gelato', '젤라토'),
      MenuDish('Cheesecake', '치즈케이크'),
      MenuDish('Tiramisu', '티라미수'),
      MenuDish('Macarons', '마카롱'),
      MenuDish('Bingsu', '빙수'),
      MenuDish('Mochi', '모치'),
      MenuDish('Crepes', '크레프'),
      MenuDish('Churros', '추로스'),
      MenuDish('Baklava', '바클라바'),
      MenuDish('Panna Cotta', '판나 코타'),
      MenuDish('Waffles', '와플'),
      MenuDish('Doughnuts', '도넛'),
      MenuDish('Tres Leches Cake', '트레스 레체스 케이크'),
      MenuDish('Cannoli', '카놀리'),
      MenuDish('Flan', '플란'),
    ]),
  ];

  static final List<MenuPick> allDishes = List.unmodifiable([
    for (final cuisine in cuisines)
      for (final dish in cuisine.dishes) MenuPick(cuisine, dish),
  ]);

  static List<MenuCuisine> sampleCuisines(Random random, {int count = 8}) {
    final choices = [...cuisines]..shuffle(random);
    return choices.take(count).toList();
  }
}
